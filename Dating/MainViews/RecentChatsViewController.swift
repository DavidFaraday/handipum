//
//  RecentChatsViewController.swift
//  Dating
//
//  Created by David Kababyan on 09/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class RecentChatsViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Vars
    var recentMatches: [FUser] = []
    var recentChats: [RecentChat] = []
    
    let activityIndicator = UIActivityIndicatorView()

    //MARK: - ViewLifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        showActivityIndicator()

        downloadRecentChats()
        downloadRecentMatches()

        overrideUserInterfaceStyle = .light
        tableView.tableFooterView = UIView()
    }
    

    //MARK: - Download
    private func downloadRecentMatches() {
        
        FirebaseListener.shared.downloadUserMatches { (matchedUserIds) in

            if matchedUserIds.count > 0 {
                
                FirebaseListener.shared.downloadUserFromFirebase(withIds: matchedUserIds) { (allUsers) in
                    
                    self.recentMatches = allUsers
                    
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        self.collectionView.reloadData()
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    private func downloadRecentChats() {
        FirebaseListener.shared.downloadRecentChatsFromFireStore { (allChats) in

            self.recentChats = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    //MARK: - Navigation
    
    private func showUserProfileFor(user: FUser) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableView") as! UserProfileTableViewController

        profileView.userObject = user
        profileView.isMatchedUser = true
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
    private func goToChat(recent: RecentChat) {
        
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
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

}


//MARK: - TableViewDataSource
extension RecentChatsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        cell.generateCell(recentChat: recentChats[indexPath.row])
        
        return cell
    }
}

//MARK: - TableView Delegate
extension RecentChatsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        FirebaseListener.shared.clearUnreadCounter(recent: recentChats[indexPath.row])
        goToChat(recent: recentChats[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = self.recentChats[indexPath.row]
            recent.deleteRecent()
            
            self.recentChats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
}

//MARK: - CollectionViewDataSource
extension RecentChatsViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return recentMatches.count > 0 ? recentMatches.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewMatchCollectionViewCell
        
        if recentMatches.count > 0 {
            cell.setupCell(avatarLink: recentMatches[indexPath.row].avatarLink)
        }
        
        
        return cell
    }
    
}

//MARK: - CollectionViewDelegate
extension RecentChatsViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if recentMatches.count > 0 {
            showUserProfileFor(user: recentMatches[indexPath.row])
        }
    }
}



