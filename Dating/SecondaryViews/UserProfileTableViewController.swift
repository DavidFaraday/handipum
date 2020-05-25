//
//  UserProfileTableViewController.swift
//  Dating
//
//  Created by David Kababyan on 06/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import SKPhotoBrowser

protocol UserProfileTableViewControllerDelegate {
    func didLikeUser()
    func didDislikeUser()
}


class UserProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var sectionOneView: UIView!
    @IBOutlet weak var sectionTwoView: UIView!
    @IBOutlet weak var sectionThreeView: UIView!
    @IBOutlet weak var sectionFourView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    
    @IBOutlet weak var dislikeButtonOutlet: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    //MARK: - Vars
    var delegate: UserProfileTableViewControllerDelegate?
    var userObject: FUser?
    var notificationController: NotificationController!
    
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 5)

    var allImages: [UIImage] = []
    
    var currentWidth: CGFloat = 0

    var isMatchedUser = false

    
    //MARK: - View LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationController = NotificationController(_view: self.view)
        pageControl.hidesForSinglePage = true

        if userObject != nil {
            updateLikeButtonStatus()
            showUserDetails()
            loadImages()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgrounds()
        hideActivityIndicator()

        
        if isMatchedUser {
            updateUIForMatchedUser()
        }
    }

    //MARK: - IBActions
    @IBAction func likeButtonPressed(_ sender: Any) {
        
        self.delegate?.didLikeUser()
        
        if self.navigationController != nil {
            saveLikeToUser(userId: userObject!.objectId)
            FirebaseListener.shared.saveMatchWith(userId: userObject!.objectId)
            showMatchView()
            
//            navigationController?.popViewController(animated: true)
        } else {
            self.dismissView()
        }
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        self.delegate?.didDislikeUser()
        
        if self.navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismissView()
        }
    }
    
    @objc func startChatButtonClicked() {
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: userObject!)

        let privateChatView = ChatViewController(chatId: chatRoomId, recipientId: userObject!.objectId, recipientName: userObject!.username)

        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    
    //MARK: - Helpers
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Update UI
    private func updateLikeButtonStatus() {
        likeButtonOutlet.isEnabled = !FUser.currentUser()!.likedIdArray!.contains(userObject!.objectId)
    }

    
    //MARK: - Show user profile
    private func showUserDetails() {
        
        aboutTextView.text = userObject!.about
        professionLabel.text = userObject!.profession
        jobLabel.text = userObject!.jobTitle
        genderLabel.text = userObject!.isMale ? "Male" : "Female"
        heightLabel.text = String(format: "%.2f m", userObject!.height)
        lookingForLabel.text = userObject!.lookingFor
    }

    //MARK: - Navigation
    private func showMatchView() {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "matchView") as! MatchViewController

        profileView.user = userObject!
        profileView.delegate = self
        self.present(profileView, animated: true, completion: nil)
    }


    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    //MARK: - Setup UI
    private func setupBackgrounds() {
        sectionOneView.clipsToBounds = true
        sectionOneView.layer.cornerRadius = 30
        sectionOneView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        sectionTwoView.layer.cornerRadius = 10
        sectionThreeView.layer.cornerRadius = 10
        sectionFourView.layer.cornerRadius = 10
    }
    
    private func updateUIForMatchedUser() {
        self.likeButtonOutlet.isHidden = isMatchedUser
        self.dislikeButtonOutlet.isHidden = isMatchedUser
        
        showStartChatButton()
    }
    
    private func showStartChatButton() {
        let messageButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(startChatButtonClicked))
        
        self.navigationItem.rightBarButtonItem = isMatchedUser ? messageButton : nil
    }
    
    
    //MARK: - Activity Indicator
    
    private func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }

    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

    }

    //MARK: - LoadImages
    private func loadImages() {
        
        let placeholder = userObject!.isMale ? "mPlaceholder" : "fPlaceholder"
        let avatar = userObject!.avatar ?? UIImage(named: placeholder)
        
        allImages = [avatar!]
        self.setPageControlPages()

        collectionView.reloadData()

        if userObject!.imageLinks != nil && userObject!.imageLinks!.count > 0 {
            showActivityIndicator()

            FileStorage.downloadImages(imageUrls: userObject!.imageLinks!) { (returnedImages) in
                
                self.allImages += returnedImages as! [UIImage]
                self.setPageControlPages()
                
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.collectionView.reloadData()
                }
            }
        } else {
            hideActivityIndicator()
        }
    }

    //MARK: - PageControl
    
    private func setPageControlPages() {
        self.pageControl.numberOfPages = self.allImages.count
    }

    private func setSelectedPageTo(page: Int) {
        self.pageControl.currentPage = page
    }
    
    //MARK: - SKPhotoBrowser

    private func showImages(_ images: [UIImage], startingIndex: Int) {
        
        var SKImages = [SKPhoto]()
        
        for image in images {
            let photo = SKPhoto.photoWithImage(image)
            SKImages.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(startingIndex)
        self.present(browser, animated: true, completion: nil)
    }
    
    //MARK: - Save Like
    private func saveLikeToUser(userId: String) {
        
        let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId, date: Date())
        like.saveToFirestore()
        
        
        if let currentUser = FUser.currentUser() {
            
            if !currentUser.likedIdArray!.contains(userId) {
                currentUser.likedIdArray!.append(userId)
                
                currentUser.updateCurrentUserInFirestore(withValues: [kLIKEDIDARRAY: currentUser.likedIdArray!]) { (error) in
                    print("updated likes with error ", error)
                }
            }
        }
    }
    
    private func createMatch(userId: String) {
        FirebaseListener.shared.saveMatchWith(userId: userId)
        self.showMatchView()
    }

    //MARK: - Navigation
    private func goToChat() {
        
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: userObject!)
        
        let privateChatView = ChatViewController(chatId: chatRoomId, recipientId: userObject!.objectId, recipientName: userObject!.username)
        
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }

}


//MARK: - CollectionViewDataSource
extension UserProfileTableViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        let countryCity = userObject!.country + ", " + userObject!.city
        let nameAge = userObject!.username + ", \(abs(userObject!.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"


        cell.setupCell(image: allImages[indexPath.row], countryCity: countryCity, nameAge: nameAge, indexPath: indexPath)
        
        return cell
    }
    
    
}

//MARK: - CollectionViewDelegate
extension UserProfileTableViewController : UICollectionViewDelegate {
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showImages(allImages, startingIndex: indexPath.row)
    }
}

extension UserProfileTableViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        currentWidth = CGFloat(self.collectionView.frame.width)

        return CGSize(width: collectionView.frame.width, height: 454.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setSelectedPageTo(page: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return sectionInsets.left
    }
}

extension UserProfileTableViewController: MatchViewControllerDelegate {
    
    func didClickSendMessage(to user: FUser) {
        goToChat()
        updateLikeButtonStatus()

    }
    
    func didClickKeepSwiping() {
        updateLikeButtonStatus()
    }
    
    
    
}
