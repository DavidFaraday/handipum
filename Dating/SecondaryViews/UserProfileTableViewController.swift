//
//  UserProfileTableViewController.swift
//  Dating
//
//  Created by David Kababyan on 06/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - Vars
    var delegate: UserProfileTableViewControllerDelegate?
    var userObject: FUser?
    var notificationController: NotificationController!
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 5)

    var allImages: [UIImage] = []
    
    var currentWidth: CGFloat = 0

    //MARK: - View LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationController = NotificationController(_view: self.view)

        if userObject != nil {
            showUserDetails()
            loadImages()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgrounds()
    }

    //MARK: - IBActions
    @IBAction func likeButtonPressed(_ sender: Any) {
        self.delegate?.didLikeUser()
        checkForLikesWith(userId: userObject!.objectId)

    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        self.delegate?.didDislikeUser()
        self.dismissView()

    }
    
    //MARK: - Helpers

    private func checkForLikesWith(userId: String) {
        
        if !didLikeUserWith(userId: userId) {
            saveLikeToUser(userId: userId)

            let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId)
            like.saveToFirestore()
        }
        
        //fetch likes
        checkIfUserLikedUs(userId: userId) { (didLikeUs) in

            if didLikeUs {
                self.notificationController.showNotification(text: "It's a Match!!!", isError: false)
                saveMatchWith(userId: userId)
            }
            
            self.dismissView()
        }
    }

    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
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

    //MARK: - LoadImages
    private func loadImages() {
        
        allImages = [userObject!.avatar!]
        self.setPageControlPages()

        collectionView.reloadData()

        if userObject!.imageLinks != nil && userObject!.imageLinks!.count > 0 {
            FileStorage.downloadImages(imageUrls: userObject!.imageLinks!) { (returnedImages) in
                
                self.allImages += returnedImages as! [UIImage]
                self.setPageControlPages()
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

    //MARK: - PageControl
    
    private func setPageControlPages() {
        self.pageControl.numberOfPages = self.allImages.count
    }

    private func setSelectedPageTo(page: Int) {
        self.pageControl.currentPage = page
    }
}

extension UserProfileTableViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        let countryCity = userObject!.country + ", " + userObject!.city
        let nameAge = userObject!.username + ", \(userObject!.dateOfBirth.interval(ofComponent: .year, fromDate: Date()))"


        cell.setupCell(image: allImages[indexPath.row], countryCity: countryCity, nameAge: nameAge, indexPath: indexPath)
        
        return cell
    }
    
    
}


extension UserProfileTableViewController : UICollectionViewDelegate {
    




    
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
