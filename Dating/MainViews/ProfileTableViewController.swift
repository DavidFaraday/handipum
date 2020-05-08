//
//  ProfileTableViewController.swift
//  Dating
//
//  Created by David Kababyan on 26/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import Gallery

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var profileCellBackgroundView: UIView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var cityCountryLabel: UILabel!
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var profession: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var lookingForTextField: UITextField!
    
    
    //MARK: - Vars
    var editingMode = false
    var uploadingAvatar = true
    
    var gallery: GalleryController!
    var notificationController: NotificationController!
    
    var avatarImage: UIImage?
    let activityIndicator = UIActivityIndicatorView()
    var alertTextField: UITextField!

    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        notificationController = NotificationController(_view: self.view)

        setupBackgrounds()
        setupPlaceholders()
        
        if FUser.currentUser() != nil {
            loadUserData()
            updateEditingMode()
        }
    }
    
    

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - IBActions
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        showEditOptions()
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        showPictureOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editingMode.toggle()
        updateEditingMode()
        
        editingMode ? showKeyboard() : hideKeyboard()
        showSaveButton()
    }
    

    //MARK: - Setup
    
    private func showSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editUserData))
        
        navigationItem.rightBarButtonItem = editingMode ? saveButton : nil
    }

    private func setupBackgrounds() {
        profileCellBackgroundView.clipsToBounds = true
        profileCellBackgroundView.layer.cornerRadius = 100
        profileCellBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        aboutMeView.layer.cornerRadius = 10

    }
    
    private func setupPlaceholders() {

        jobTextField.attributedPlaceholder = NSAttributedString(string: "Add job", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        profession.attributedPlaceholder = NSAttributedString(string: "Add education", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        genderTextField.attributedPlaceholder = NSAttributedString(string: "Gender", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        cityTextField.attributedPlaceholder = NSAttributedString(string: "My City", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        countryTextField.attributedPlaceholder = NSAttributedString(string: "My Country", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        heightTextField.attributedPlaceholder = NSAttributedString(string: "Height", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        lookingForTextField.attributedPlaceholder = NSAttributedString(string: "Looking for", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])

    }
    
    
    //MARK: - Load User Data
    
    private func loadUserData() {
        let currentUser = FUser.currentUser()!
        
        avatarImageView.image = currentUser.avatar != nil ? currentUser.avatar?.circleMasked : UIImage(named: "avatar")
        nameAgeLabel.text = currentUser.username + ",  \(currentUser.dateOfBirth.interval(ofComponent: .year, fromDate: Date()))"
        cityCountryLabel.text = currentUser.country + ", " + currentUser.city
        aboutMeTextView.text = currentUser.about != "" ? currentUser.about : "A little bit about you..."
        jobTextField.text = currentUser.jobTitle
        profession.text = currentUser.profession
        genderTextField.text = currentUser.isMale ? "Male" : "Female"
        cityTextField.text = currentUser.city
        countryTextField.text = currentUser.country
        heightTextField.text = "\(currentUser.height)"
        lookingForTextField.text = currentUser.lookingFor
        avatarImageView.image = currentUser.returnLocalAvatar?.circleMasked
    }
    
    //MARK: - Editing Mode
    private func updateEditingMode() {
        
        aboutMeTextView.isUserInteractionEnabled = editingMode
        jobTextField.isUserInteractionEnabled = editingMode
        profession.isUserInteractionEnabled = editingMode
        genderTextField.isUserInteractionEnabled = editingMode
        cityTextField.isUserInteractionEnabled = editingMode
        countryTextField.isUserInteractionEnabled = editingMode
        heightTextField.isUserInteractionEnabled = editingMode
        lookingForTextField.isUserInteractionEnabled = editingMode
    }
    


    //MARK: - Helpers
    private func hideKeyboard() {
        self.view.endEditing(false)
    }
    
    private func showKeyboard() {
        self.aboutMeTextView.becomeFirstResponder()
    }
    
    //MARK: - Activity Indicator
    private func initActivityIndicator() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }

    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }



    //MARK: - Update User
    @objc func editUserData() {
        
        let user = FUser.currentUser()!
        
        user.about = aboutMeTextView.text
        user.jobTitle = jobTextField.text ?? ""
        user.profession = profession.text ?? ""
        user.isMale = genderTextField.text == "Male"
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.lookingFor = lookingForTextField.text ?? ""
        user.height = Double(heightTextField.text ?? "0") ?? 0.0
        
        if avatarImage != nil {
            
            uploadAvatarImage(avatarImage!) { (avatarLink) in
                user.avatar = self.avatarImage
                user.avatarLink = avatarLink ?? ""
                self.hideActivityIndicator()

                self.saveUserData(user: user)
            }
            
        } else {
            saveUserData(user: user)
        }
        
        
        editingMode = false
        updateEditingMode()
        showSaveButton()
    }
    
    private func saveUserData(user: FUser) {
        user.saveUserLocally()
        user.saveUserToFirestore()
    }
    

    //MARK: - Gallery
    private func showImageGallery(forAvatar: Bool) {
        uploadingAvatar = forAvatar
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = forAvatar ? 1 : 10
        Config.initialTab = .imageTab
        
        self.present(self.gallery, animated: true, completion: nil)
    }

    //MARK: - AlertController
    private func showPictureOptions() {
        
        let alertController = UIAlertController(title: "Upload Pictures", message: "You can change your Avatar or upload more pictures.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Change Avatar", style: .default) { (alert) in
            
            self.showImageGallery(forAvatar: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Upload Pictures", style: .default) { (alert) in
            
            self.showImageGallery(forAvatar: false)
        })

        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func showEditOptions() {
        
        let alertController = UIAlertController(title: "Edit Account", message: "You are about to edit sensitive information about your account.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Change Email", style: .default) { (alert) in
            
            self.showChangeField(value: "Email")
        })
        
        alertController.addAction(UIAlertAction(title: "Change Name", style: .default) { (alert) in
            
            self.showChangeField(value: "Name")
        })
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
            
            self.logOutUser()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func showChangeField(value: String) {
        
        let alertView = UIAlertController(title: "Updating \(value)", message: "Please write your new \(value).", preferredStyle: .alert)
        
        alertView.addTextField { (textField) in
            
            self.alertTextField = textField
            self.alertTextField.placeholder = "New \(value)"
        }
        
        alertView.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { (action) in
                
            self.updateUserWith(value: value)
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    //MARK: - Change User info

    private func updateUserWith(value: String) {
        
        if alertTextField.text != "" {
            
            if value == "Email" {
                changeEmail()
            } else {
                changeUserName()
            }
            
        } else {
            self.notificationController.showNotification(text: "\(value) is empty!", isError: true)
        }
    }

    private func changeEmail() {
        FUser.currentUser()?.updateUserEmail(newEmail: alertTextField.text!, completion: { (error) in
            
            if error == nil {
                self.notificationController.showNotification(text: "Success!", isError: false)
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        })
    }
    
    private func changeUserName() {
        
        if let currentUser = FUser.currentUser() {
            currentUser.username = alertTextField.text!
            
            saveUserData(user: currentUser)
            loadUserData()
        }
    }
    
    private func logOutUser() {
        
        FUser.logOutCurrentUser { (success) in

            let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")

            DispatchQueue.main.async {
                loginView.modalPresentationStyle = .fullScreen
                self.present(loginView, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - FileStorage
    
    private func uploadAvatarImage(_ image: UIImage, completion: @escaping (_ avatarLink: String?) -> Void) {
        
        self.initActivityIndicator()
        self.showActivityIndicator()
        
        let fileDirectory = "Avatars/" + "\(FUser.currentId())" + ".jpg"

        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            completion(avatarLink)
            
            FileStorage.saveImageLocally(imageData: image.jpegData(compressionQuality: 0.8)!, fileName:  FUser.currentId())
        }
    }

    
    private func uploadImages(images: [UIImage?]) {
        initActivityIndicator()
        showActivityIndicator()
        
        FileStorage.uploadImages(images: images) { (imageLinks) in
            
            let currentUser = FUser.currentUser()!
            currentUser.imageLinks = imageLinks
            
            self.saveUserData(user: currentUser)
            self.hideActivityIndicator()
        }
    }

}

extension ProfileTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            if uploadingAvatar {
                images.first!.resolve(completion: { (icon) in
                    
                    if icon != nil {
                        
                        self.editingMode = true
                        self.showSaveButton()
                        
                        self.avatarImageView.image = icon?.circleMasked
                        self.avatarImage = icon
                    } else {
                        self.notificationController.showNotification(text: "Couldn't select Image!", isError: true)
                    }
                })
                
            } else {
                //upload images
                Image.resolve(images: images) { (resolvedImages) in
                    
                    self.uploadImages(images: resolvedImages)
                }
            }
            
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
