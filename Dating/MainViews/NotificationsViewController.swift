//
//  NotificationsViewController.swift
//  Dating
//
//  Created by David Kababyan on 09/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Vars
    var allLiks: [LikeObject] = []
    var allUsers: [FUser] = []

    let activityIndicator = UIActivityIndicatorView()

    
    //MARK: - View lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActivityIndicator()
        showActivityIndicator()
        
        downloadLikes()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        tableView.tableFooterView = UIView()
    }
    

    //MARK: - Download likes
    private func downloadLikes() {
        
        FirebaseListener.shared.downloadUserLikes { (allUserIds) in

            if allUserIds.count > 0 {

                FirebaseListener.shared.downloadUserFromFirebase(withIds: allUserIds) { (allUsers) in

                    self.allUsers = allUsers
                    
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        self.tableView.reloadData()
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    //MARK: - Activity Indicator
    
    private func setupActivityIndicator() {
                
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
    
    //MARK: - Navigation
    private func showUserProfileFor(user: FUser) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableView") as! UserProfileTableViewController

        profileView.userObject = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }

}

//MARK: - TableVieDataSource
extension NotificationsViewController : UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeTableViewCell
        
        cell.setupCell(user: allUsers[indexPath.row])
        
        return cell
    }
    
}


//MARK: - TableVieDelegate
extension NotificationsViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showUserProfileFor(user: allUsers[indexPath.row])
    }
}



