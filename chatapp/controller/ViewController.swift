//
//  ViewController.swift
//  chatapp
//
//  Created by Joey Kraus on 02/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        //navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
            navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        //setting up a button to the top left of the screen
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLoGOut))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
       
        //user is not logged in
        
       //this will add a button on the right side of the navigationbar
        let image = UIImage(named: "newmessage")
        //setting to button to be on the right side of the navigationItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barStyle = .black
        
        checkIfUserIsLoggedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //observeMessages()
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //will give the current id
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
         let message = self.messages[indexPath.row]
            
        if let chatPartnerId = message.chatPartnerId(){
            Database.database().reference().child("user-messages").child(chatPartnerId).removeValue { (error, DatabaseReference) in
                if error != nil{
                    print("Failed to delete message",error)
                    return
                }
                
                 self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                //one way of updating the table
                /*self.messages.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)*/
                
            }
            
        }
        
    }
    
    //[message]() an array
    var messages = [Message]()
    var messageDictionary = [String:Message]()
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (DataSnapshot) in
            
           let userId = DataSnapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (DataSnapshot) in
                
                
                let messageId = DataSnapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
                
                
               
                
            })
            ref.observe(.childRemoved, with: { (DataSnapshot) in
                print(DataSnapshot.key)
                print(self.messageDictionary)
                
                self.messageDictionary.removeValue(forKey: DataSnapshot.key)
                self.attemptReloadOfTable()
            }, withCancel: nil)
           
            
        }
    }
    private func fetchMessageWithMessageId(messageId: String){
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String:AnyObject]{
                let message = Message(dictionary: dictionary)
                /*message.fromId = dictionary["fromId"] as? String
                message.toId = dictionary["toId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber*/
                //self.messages.append(message)
                
                if let chatPartnerId = message.chatPartnerId(){
                    self.messageDictionary[chatPartnerId] = message
                    
                    
                    
                    
                }
                self.attemptReloadOfTable()
                
                
                
                
            }
        })
        
    }
    
    private func  attemptReloadOfTable(){
        self.timer?.invalidate()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable(){
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            // this will sort the list in an desending manner comparing the time
            return message1.timestamp?.compare(message2.timestamp!) == ComparisonResult.orderedDescending
            
        })
        DispatchQueue.main.async {
            print("we reloaded the table")
            self.tableView.reloadData()
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
    
        let message = messages[indexPath.row]
        
        cell.message = message
     
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        
        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            print(DataSnapshot)
            //this will collect all the data from firebase "Datasnapshot" values and cast it as string anyObject
            guard let dictionary = DataSnapshot.value as? [String:AnyObject]
                else{
                    return
            }
            let user = User()
            user.id = chatPartnerId
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            user.password = dictionary["password"] as? String
            
            
            
            //sending the user to the function
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
        
        
    
        //showChatControllerForUser(user: <#T##User#>)
    }
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageControllerTableViewController()
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
        
        }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            performSelector(onMainThread: #selector(handleLoGOut), with: nil, waitUntilDone: true)
            
        }else{
            fetchUserAndSetupNavBarTitle()
        }
    }
    func fetchUserAndSetupNavBarTitle(){
        
            
       //fetching data from firebase
        guard let uid = Auth.auth().currentUser?.uid else{
            //foe some reason uid is nill
            return
        }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                //THIS CODE WILL SET THE TITLE AS THE NAME OF THE USER FROM THE DATABASE
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                   // self.navigationItem.title = dictionary["profileImageUrl"] as? String
                    
                    
                    let user = User()
                    user.name = dictionary["name"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String                    //user.setValuesForKeys(dictionary)
                    self.setupNavWithUser(user: user)
                }
                
            }
            
        }
    func setupNavWithUser(user:User){
        //this will remove all previous messages from other users
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.red
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        var profileImageView: UIImageView = {
            let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleToFill
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
            
            return profileImage
        }()
        
      
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
       
        
        
        
        //profileImageView.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.tintColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        nameLabel.tintColor = .white
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView

        
 
        profileImageView.isUserInteractionEnabled = true
        /*profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))*/
    }
    var chatLogController: ChatLogController?
    
   
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInProfile(startingImageView: UIImageView){
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        //once tapped it will show the size of the frame picture
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingImageView)
        //color
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        //this will place the image in the zoomingImageView
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        //the entire page window
        if let keyWindow = UIApplication.shared.keyWindow{
            //setting background to be black
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            //wiil add the blackbaground view to the window
            keyWindow.addSubview(blackBackgroundView!)
            //will add the picture in its size
            keyWindow.addSubview(zoomingImageView)
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                //math?
                //h2/w1 = h1/w1
                //h2 = h1 / w1* w1
                //this will set the height
                self.blackBackgroundView!.alpha = 1
                //will make hte lower container fade away
               
                
                let  height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                //this will the zoomingimage in the middle of the window
                zoomingImageView.center = keyWindow.center
                
            }) { (completed) in
                //zoomOutImageView.removeFromSuperview()
            }
            //this animation will zoom the window from the current state to the top of the window with the max width
            
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //bringing back th input to visible
                
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            }
            
            
        }
        
    }
    
    @objc func showChatControllerForUser(user: User){
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        //this will change the page to chatLogController
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //when button tapped it will redirect to logincontroller page with a blue screen
    @objc func handleLoGOut(){
        
        do{
        try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.viewMessageController = self
        
        present(loginController, animated: true, completion: nil)
        
    }
    
    
}



