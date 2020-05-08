//
//  FUser.swift
//  Dating
//
//  Created by David Kababyan on 17/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class FUser {

    let objectId: String
    var email: String
    var username: String
    var dateOfBirth: Date
    var isMale: Bool
    var avatar: UIImage?
    var profession: String
    var jobTitle: String
    var about: String
    var city: String
    var country: String
    var height: Double
    var lookingFor: String
    var avatarLink: String

    var likedIdArray: [String]?
    var imageLinks: [String]?

    //MARK: - Helper funcs
    var userDictionary: NSDictionary {
        
        return NSDictionary(objects: [self.objectId,
                                      self.email,
                                      self.username,
                                      self.dateOfBirth,
                                      self.isMale,
                                      self.profession,
                                      self.jobTitle,
                                      self.about,
                                      self.city,
                                      self.country,
                                      self.height,
                                      self.lookingFor,
                                      self.avatarLink,
                                      self.likedIdArray ?? [],
                                      self.imageLinks ?? []
            ],
                            forKeys: [kOBJECTID as NSCopying,
                                      kEMAIL as NSCopying,
                                      kUSERNAME as NSCopying,
                                      kDATEOFBIRTH as NSCopying,
                                      kISMALE as NSCopying,
                                      kPROFESSION as NSCopying,
                                      kJOBTITLE as NSCopying,
                                      kABOUT as NSCopying,
                                      kCITY as NSCopying,
                                      kCOUNTRY as NSCopying,
                                      kHEIGHT as NSCopying,
                                      kLOOKINGFOR as NSCopying,
                                      kAVATARLINK as NSCopying,
                                      kLIKEDIDARRAY as NSCopying,
                                      kIMAGELINKS as NSCopying
            ]
        )
    }
    
    var returnLocalAvatar: UIImage? {
        return UIImage(contentsOfFile: fileInDocumentsDirectory(filename: self.objectId))
    }
    
    //MARK: - Initializers
    
    init(_objectId: String, _email: String, _username: String, _city: String, _dateOfBirth: Date, _isMale: Bool, _avatarLink: String = "") {
        
        objectId = _objectId
        email = _email
        username = _username
        dateOfBirth = _dateOfBirth
        isMale = _isMale
        profession = ""
        jobTitle = ""
        about = ""
        city = _city
        country = "My Country"
        height = 0.0
        lookingFor = ""
        avatarLink = _avatarLink
        likedIdArray = []
        imageLinks = []
    }
    
    init(_dictionary: NSDictionary, _avatar: UIImage? = nil) {
        
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        username = _dictionary[kUSERNAME] as? String ?? ""
        dateOfBirth = (_dictionary[kDATEOFBIRTH] as? Timestamp)?.dateValue() ?? Date()
        isMale = _dictionary[kISMALE] as? Bool ?? true
        profession = _dictionary[kPROFESSION] as? String ?? ""
        jobTitle = _dictionary[kJOBTITLE] as? String ?? ""
        about = _dictionary[kABOUT] as? String ?? ""
        city = _dictionary[kCITY] as? String ?? ""
        country = _dictionary[kCOUNTRY] as? String ?? ""
        height = _dictionary[kHEIGHT] as? Double ?? 0.0
        lookingFor = _dictionary[kLOOKINGFOR] as? String ?? ""
        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
        likedIdArray = _dictionary[kLIKEDIDARRAY] as? [String]
        avatar = _avatar
    }
    

    
    //MARK: - Returning current user funcs
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser () -> FUser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }

    func getUserAvatarFromFirestore(completion: @escaping (_ didSet: Bool) -> Void) {
        
        
        FileStorage.downloadImage(imageUrl: self.avatarLink) { (avatarImage) in

            self.avatar = avatarImage
            completion(true)
        }
    }
    
    //MARK: - Login function
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            

            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    
                    downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                } else {
                    print("Email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }
    
    //MARK: - RegisterUser
    class func registerUserWith(email: String, password: String, userName: String, city: String, isMale: Bool, dateOfBirth: Date, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult, error) in
            
            completion(error)

            if error == nil {
                
                //send verification email
                authDataResult!.user.sendEmailVerification(completion: { (error) in
                    print("auth email sent error is :", error?.localizedDescription)
                })
                
                //create user and save it
                if authDataResult?.user != nil {
                    let user = FUser(_objectId: authDataResult!.user.uid, _email: email, _username: userName, _city: city, _dateOfBirth: dateOfBirth, _isMale: isMale)
                    
                    user.saveUserLocally()
                }

            }
        })
    }
    
    //MARK: - Edit User profile
    func updateUserEmail(newEmail: String, completion: @escaping (_ error: Error?) -> Void) {

        Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
            if error == nil {

                FUser.resendVerificationEmail(email: newEmail, completion: { (error) in
                    
                })
                completion(error)
            } else {
                print("error updating email\(error!.localizedDescription)")
                completion(error)
            }
        }
    }
    
    //MARK: - Resend link methods
    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in

            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in

                completion(error)
            })
        })
    }

    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    
    //MARK: - LogOut func
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Save user funcs
    func saveUserToFirestore() {
        FirebaseReference(.User).document(self.objectId).setData(self.userDictionary as! [String : Any]) { (error) in
            if error != nil {
                print("error saving user \(error!.localizedDescription)")
            }
        }
    }


    func saveUserLocally() {

        userDefaults.set(self.userDictionary as! [String : Any], forKey: kCURRENTUSER)
        userDefaults.synchronize()
    }


} // end of class


//MARK: - DownloadUser
func downloadUserFromFirebase(userId: String, email: String) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {

            FUser(_dictionary: snapshot.data()! as NSDictionary).saveUserLocally()

            //update email in case there was a change?
            updateCurrentUserInFirestore(withValues: [kEMAIL : email]) { (error) in
                
            }
        } else {
            //first login save to firebase
            if let user = userDefaults.object(forKey: kCURRENTUSER) {
                
                FUser(_dictionary: user as! NSDictionary).saveUserToFirestore()
            }
        }
    }
}

func downloadUsersFromFirebase(isInitialLoad: Bool, limit: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping (_ users: [FUser], _ snapshot: DocumentSnapshot?) -> Void ) {
    
    
    var query: Query!

    if isInitialLoad {
        query = FirebaseReference(.User).limit(to: limit)
        print("First \(limit) users loaded")
    } else {
        if lastDocumentSnapshot != nil {
            query = FirebaseReference(.User).limit(to: limit).start(afterDocument: lastDocumentSnapshot!).limit(to: limit)
            print("Next \(limit) users loaded")
        } else {
            print("last snap is nil")
        }
    }
    
    query.getDocuments { (snapshot, error) in
        
        
        guard let snapshot = snapshot else {  return }
        
        var users:[FUser] = []

        if !snapshot.isEmpty {

            for userData in snapshot.documents {
                
                let userObject = userData.data() as NSDictionary
                
                //removed liked users
                if !(FUser.currentUser()?.likedIdArray?.contains(userData[kOBJECTID] as! String) ?? false) && FUser.currentId() != userData[kOBJECTID] as! String {
                    users.append(FUser(_dictionary: userObject))//image placeholder here
                }
            }

            completion(users, snapshot.documents.last!)

        } else {
            print("no more users to fetch!")
            completion(users, nil)
        }
    }
}






//MARK: - Update user func
func updateCurrentUserInFirestore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
        //get user object from userDefaults and update its values
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) { (error) in
            
            completion(error)
            if error == nil {
                FUser(_dictionary: userObject).saveUserLocally()
            }
        }
    }
}




//needed only to populate with dummy
func createUsers() {
    
    let names = ["Alison Stamp", "Inayah Duggan", "Alfie-Lee Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
    var ImageIndex = 1
    var isMale = true
    var UserIndex = 1

    for _ in 0..<20 {

        let id = UUID().uuidString
        let randomNumber = Int.random(in: 0 ... 5)
        
        let fileDirectory = "Avatar/" + "\(FUser.currentId())" + ".jpg"

        FileStorage.uploadImage(UIImage(named: "user\(ImageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = FUser(_objectId: id, _email: "user\(UserIndex)@mail.com", _username:  names[randomNumber], _city: "New York", _dateOfBirth: Date(), _isMale: isMale, _avatarLink: avatarLink ?? "")

            isMale = !isMale
            UserIndex += 1
            user.saveUserToFirestore()

        }

        ImageIndex += 1
        if ImageIndex == 16 {
            ImageIndex = 1
        }
    }
}
