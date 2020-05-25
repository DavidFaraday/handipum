//
//  CardViewController.swift
//  Dating
//
//  Created by David Kababyan on 02/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import Shuffle_iOS
import Firebase

class CardViewController: UIViewController {
    
    
    //MARK: - Vars
    private let cardStack = SwipeCardStack()
    private var cardModels: [UserCardModel] = []
    private var secondCardModels: [UserCardModel] = []
    private var userObjects: [FUser] = []
    
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    
    var numberOfCardsAdded = 0
    var initialLoadNumber = 20
    
    let activityIndicator = UIActivityIndicatorView()

    var notificationController: NotificationController!

    //MARK: - ViewLife Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        setupActivityIndicator()
        showActivityIndicator()

//        let user = FUser.currentUser()!
//        user.likedIdArray = []
//
//        user.saveUserToFirestore()
//        user.saveUserLocally()
//        createUsers()
//        
        downloadInitialUsers()
        notificationController = NotificationController(_view: self.view)
    }
    
    
    //MARK: - Layout cards
    private func layoutCardStackView() {

        hideActivityIndicator()
        
        cardStack.delegate = self
        cardStack.dataSource = self

        view.addSubview(cardStack)

        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
        
    }
    
    
    //MARK: - DownloadUsers
    private func downloadInitialUsers() {

        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: initialLoadNumber, lastDocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in
            
            if allUsers.count == 0 {
                self.hideActivityIndicator()
            }

            self.lastDocumentSnapshot = snapshot
            self.isInitialLoad = false
            self.cardModels = []

            
            self.userObjects = allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in

                    let placeholder = user.isMale ? "mPlaceholder" : "fPlaceholder"
                    
                    let cardModel = UserCardModel(id: user.objectId,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                                  image: user.avatar ?? UIImage(named: placeholder))
                    
                    self.cardModels.append(cardModel)
                    self.numberOfCardsAdded += 1
                    
                    if self.numberOfCardsAdded == allUsers.count {
                        self.layoutCardStackView()
                    }
                }
            }
            
            print("initial \(allUsers.count)")
            self.downloadMoreUsersInBackground()
        }
    }
    
    private func downloadMoreUsersInBackground() {

        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: 1000, lastDocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in
            
            self.lastDocumentSnapshot = snapshot
            self.secondCardModels = []

            
            self.userObjects += allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                  image: user.avatar)
                    
                    self.secondCardModels.append(cardModel)
                }
            }
        }
    }

    //MARK: - User Actions
    private func checkForLikesWith(userId: String) {
        
        if !didLikeUserWith(userId: userId) {
            saveLikeToUser(userId: userId)

            let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId, date: Date())
            like.saveToFirestore()
        }
        
        //fetch likes
        FirebaseListener.shared.checkIfUserLikedUs(userId: userId) { (didLikeUs) in

            if didLikeUs {
                FirebaseListener.shared.saveMatchWith(userId: userId)
                self.showMatchView(userId: userId)
            }
        }
    }
    
    //MARK: - Helpers
    
    private func getUserWithId(userId: String) -> FUser? {
       
        for user in userObjects {
            if user.objectId == userId {
                return user
            }
        }
        
        return nil
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
    private func showUserProfileFor(userId: String) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableView") as! UserProfileTableViewController

        profileView.delegate = self
        profileView.userObject = getUserWithId(userId: userId)
        self.present(profileView, animated: true, completion: nil)
    }

    private func showMatchView(userId: String) {
        
        let matchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "matchView") as! MatchViewController

        matchView.delegate = self
        matchView.user = getUserWithId(userId: userId)
        self.present(matchView, animated: true, completion: nil)
    }

    
    //MARK: - Navigation
    private func goToChat(user: FUser) {
        
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: user)

        let privateChatView = ChatViewController(chatId: chatRoomId, recipientId: user.objectId, recipientName: user.username)
        
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }


}

//MARK: Data Source + Delegates

extension CardViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {

        let card = UserCard()
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]
        
        for direction in card.swipeDirections {
          card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }

        card.configure(withModel: showReserve ? secondCardModels[index] : cardModels[index])

        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {

        return showReserve ? secondCardModels.count : cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
        cardModels = [] //empty initial stack
        if showReserve { secondCardModels = [] } // if reserve has swiped all cards, empty the stack
        
        showReserve = true
        layoutCardStackView()
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {

    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        if direction == .right {
            let user = getUserWithId(userId: showReserve ? secondCardModels[index].id : cardModels[index].id)
            
            checkForLikesWith(userId: showReserve ? secondCardModels[index].id : cardModels[index].id)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {

        showUserProfileFor(userId: showReserve ? secondCardModels[index].id : cardModels[index].id )
    }
}



extension CardViewController: UserProfileTableViewControllerDelegate {
    
    func didLikeUser() {
        cardStack.swipe(.right, animated: true)
    }
    
    func didDislikeUser() {
        cardStack.swipe(.left, animated: true)
    }
}

extension CardViewController: MatchViewControllerDelegate {
    
    func didClickSendMessage(to user: FUser) {
        
    }
    
        
    func didClickKeepSwiping() {
        
    }
}


