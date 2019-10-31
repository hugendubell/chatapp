//
//  ChatLogController.swift
//  chatapp
//
//  Created by Joey Kraus on 27/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase
import  MobileCoreServices
import AVFoundation

class ChatLogController : UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    //messages array
    var messages = [Message]()
    //this function will fetch the info from the firebase that the user has sent
    func  observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else{
            return
        }
        //a ref from firebase to all what is in the user-messages.uid ->which is the current user
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded) { (DataSnapshot) in
            
            let messageId = DataSnapshot.key
            
                
            
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                //print(DataSnapshot)
                
                guard let dictionary = DataSnapshot.value as? [String:AnyObject] else{
                    return
                }
                let message = Message(dictionary: dictionary)
                /*message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String*/
                //by printing the message it wil prisent in the console the intire messages sent by the user
                print("we fetched a message from firebase and we need to decide wither to",message.text)
                
                //this will check if the user is in fact the chat partner we are chating with .if so it will add the messges to the array
                if message.chatPartnerId() == self.user?.id{
                     self.messages.append(message)
                    
                    //
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        //scroll to the last index. WHN A MESSAGE IS SENT IT WILL SCROLL TO THE LAST INDEXPATH
                        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        
                        
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                }
               
                
              
                
            }, withCancel: nil)
        }
    }
    
    lazy var inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter message..."
    textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this sets the entire page constriants of the collectionsView. in this case only the top has a constraint of 8
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        //this will allow to drag the page down        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
         collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "eve")!)
        
        collectionView?.register(chatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
       navigationController?.navigationBar.tintColor = .black
        
        
       // setupInputComponets()
        //this function will open the keyboared and close it
       // setUpKeyboardObservers()
        setUpKeyboardObservers()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let upLoadImageView = UIImageView()
        //in order for it to be clicked we must use this
        upLoadImageView.isUserInteractionEnabled = true
        upLoadImageView.image = UIImage(named: "sendPicture")
        upLoadImageView.translatesAutoresizingMaskIntoConstraints = false
        //adding tha tap gesture will send it tot the function
        upLoadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(upLoadImageView)
        
        //constarints for the image
        upLoadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant: 20).isActive = true
        upLoadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        upLoadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        upLoadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        /*let inputTextField = UITextField()
         inputTextField.placeholder = "Enter message..."
         inputTextField.translatesAutoresizingMaskIntoConstraints = false*/
        containerView.addSubview(inputTextField)
        //x,y,w,h
        
        inputTextField.leftAnchor.constraint(equalTo: upLoadImageView.rightAnchor,constant: 15).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        //inputTextField.widthAnchor.constraint(equalToConstant: 100)
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor ).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
        
    }()
    
    @objc func handleUploadTap(){
        //will open the image picker
       let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        
        imagePickerController.delegate = self
        //allow us to addd videos to the picker
        imagePickerController.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        
        present(imagePickerController, animated: true,completion: nil)
        
        
            
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //this function will select thw picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        //this will fetch the url string of the file
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
            //will send us to the dunction that sends the video
            handleVideoSelectedForUrl(url: videoUrl)
            }else{
            //will send us to the function that sends us to the picture
            handleImageSelectedForInfo(info: info)
            }
            dismiss(animated: true, completion: nil)
            
        }
    
    
    private func handleVideoSelectedForUrl(url:NSURL){
        let fileName = NSUUID().uuidString + ".mov"
        let uploadVidTask = Storage.storage().reference().child("sent_videos").child(fileName)
        
        //once we have the ref to the storage firebase we wil place the video url in a file
        uploadVidTask.putFile(from: url as URL, metadata: nil) { (metadata, error) in
            if error != nil{
                print("Failed to upload the video:" ,error)
                return
            }
            
            
            uploadVidTask.downloadURL(completion: { (url, error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                let movUrl = url?.absoluteString
                print(movUrl)
                
                //thumbnailImage = image that will return from thumbnailImageUrl
                if let thumbNailImage = self.thumbNailImageForFileUrl(fileUrl: url as! NSURL){
                    self.uploadToFirebaseStorageUsingImage(image: thumbNailImage, completion: { (imageUrl) in
                        let properties = ["imageUrl": imageUrl, "imageWidth":thumbNailImage.size.width,"imageHeight":thumbNailImage.size.height,"videoUrl": movUrl] as [String : AnyObject]
                        
                        self.sendMessagesWithProperties(properties: properties)
                        
                    })
                    //all we are missing is imageUrl
                   
                    
                }
                
                
                
                
                
            })
           
            }
    }
    //this function will receive a url and return a UIImage
    private func thumbNailImageForFileUrl(fileUrl: NSURL) -> UIImage?{
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
             let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        }catch let err{
            print(err)
        }
        
       
        return nil
        
    }
    
    private func handleImageSelectedForInfo(info:[UIImagePickerController.InfoKey : Any]){
            //we selected an image
            var selectedImageFromPicker :UIImage?
            
            if let editedImage = info[.editedImage] as? UIImage{
                
                selectedImageFromPicker = editedImage
                
                //trhis weill cast the originalImage from the info original Image
            }else if let originalImage = info[.originalImage] as? UIImage{
                selectedImageFromPicker = originalImage
            }
            if let selectedImage = selectedImageFromPicker{
                
                uploadToFirebaseStorageUsingImage(image: selectedImage) { (imageUrl) in
                    self.sendMessageWithImageUrl(imageUrl: imageUrl,image: selectedImage)
                }
                /*uploadToFirebaseStorageUsingImage(image: selectedImage) { (imageUrl) in
                 
                }*/
                
                
            }
       
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        //casting the ref as the storage restore
       let ref = Storage.storage().reference().child("sent_images").child("\(imageName).jpg")
        
        //converting the image to jpeg with the quality of 0.2
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData, metadata: nil, completion: {(metadata,error) in
                
                if error != nil{
                    print("Failed to upload image:", error)
                }
               
               
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil{
                        print(error)
                        return
                    }
                    
                     let ImageURL = url?.absoluteString
                    completion(ImageURL!)
                    
                    
                    
                })
            })
            
        }
        
        
    }
    
    
    

    override var inputAccessoryView: UIView?{
        get{
          
            return inputContainerView
                
            }
        }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setUpKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        /*NotificationCenter.default.addObserver(self, selector: #selector(handelSelectorWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handelSelectorWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)*/
        
        
        
    }
    @objc func handleKeyBoardDidShow(){
        //this function will show the collctionview at the very last message that was sent
        let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
    }
    //thiis will save in memory w
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        
    }
    
    @objc func handelSelectorWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
       
        //this here will take the ref of the bottom constraint of the input and place it ontop of the keyboreds height frame
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        //
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
            
            
        }
        
    }
    //THIS FUNCTION WILL HIDE THE KEYBORED AND
    @objc func handelSelectorWillHide(notification: NSNotification){
       
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        //this here will take the ref of the bottom constraint of the input and place it ontop of the keyboreds height frame
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
    }    //the number of cells
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! chatMessageCell
        
        cell.chatLogController = self
        
        //this will fetch the mwsswge from the array of messges at the indexpart and cast it to message
        let message = messages[indexPath.item]
        
        cell.message = message
        
        //by doing this the text that was sent will be placed in the textview of the cell
        cell.textView.text = message.text
        
        
            
        setUpCell(cell: cell, message: message)
        
        //lets modify the bubble view with somehow??
        
        if let text = message.text{
        cell.bubbleWidthAnchor?.constant = estimatedFrameText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil{
            //fall in here if it is an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            
        }
        //this will hide the play button if it is nil
       
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    
    private func setUpCell(cell:chatMessageCell,message:Message){
        if let profileImageUrl = self.user?.profileImageUrl{
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        //this
        
        //changging the background color to each user sender and reciever and the textview color
        if message.fromId == Auth.auth().currentUser?.uid{
            //outgoing blue
            cell.bubbleView.backgroundColor = chatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        }else{
            //incoming green
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
        }
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
            
        }
        
    }
    //this function while rotation will adapt
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    //size for the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        let message = messages[indexPath.item]
        //get estimated height somehow??
        if let text = message.text{
            height = estimatedFrameText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            
            //h1 / w1 = h2 / w2
            //solve each
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimatedFrameText(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil )
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    
    
    @objc func handleSend(){
        let properties = ["text":inputTextField.text!] as [String : AnyObject]
        sendMessagesWithProperties(properties: properties)
        
        }
    
    
    private func sendMessageWithImageUrl(imageUrl: String,image: UIImage){
        let properties = ["imageUrl": imageUrl,"imageWidth": image.size.width,"imageHeight": image.size.height] as [String : AnyObject]
        
        sendMessagesWithProperties(properties: properties)
        
    }
    

    private func sendMessagesWithProperties(properties: [String:AnyObject]){
        
        //connecting the messages to firebase
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        //the id of the receiver of the message
        let toId = user!.id!
        //the id from the sender
        let fromId = Auth.auth().currentUser!.uid
        //this will give the time it was sent
        let timestamp = NSNumber(value:Int(NSDate().timeIntervalSince1970))
        var values = ["toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : AnyObject]
        //childRef.updateChildValues(values)
        
        //append properties somehow?
        properties.forEach({values[$0] = $1})
        

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            
            //this will clear the text once sent
            self.inputTextField.text = nil
            
            let messageId = childRef.key
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            //let userMessagesDictionary = ["/\(fromId)/\(messageId)":1, /*"/\(toId)/\(messageId)":1*/]
            let userMessagesDic = [messageId: 1]
            userMessageRef.updateChildValues(userMessagesDic)
            
            let recipientMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientMessageRef.updateChildValues(userMessagesDic)
            
           
        }
    }
    //by hitting the enter button it will send the message to firebase
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //my custom zooming logic
    func performZoomInForstartingImageView(startingImageView: UIImageView){
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
                self.inputContainerView.alpha = 0
                
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
                self.inputContainerView.alpha = 1
            }) { (completed) in
                 zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
                          }
            
           
        }
        
    }
}

