//
//  UserCell.swift
//  chatapp
//
//  Created by Joey Kraus on 31/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase
//the class shows the cell in the list of users
class UserCell: UITableViewCell{
    var chatLogController: ChatLogController?
    
    var message: Message?{
        didSet{
            setupNameAndProfileImage()
          
          
            detailTextLabel?.text = message?.text
            
            
            if let seconds = message?.timestamp?.doubleValue{
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
            
            
        }
    }
    
    private func setupNameAndProfileImage(){
        
        //this here will check the sender and the reciever and set the profile image in order
       
        
        if let id = message?.chatPartnerId(){
            let ref = Database.database().reference().child("users").child(id)
            //this will look for the ref in the firebase database for the key id
            ref.observeSingleEvent(of: .value) { (Datasnapshot) in
                if let dictionary = Datasnapshot.value as? [String:AnyObject]
                {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"]
                    {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                    }
                }
                
            }
            
        }
        
    }
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //the name and email
        textLabel?.frame = CGRect(x: 60, y: textLabel!.frame.origin.y - 2 , width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 60, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapPick)))
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
       let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        //constriants for time Label
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 18).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
    }
   var viewcontroller: ViewController?
    
    @objc func handleTapPick(tapGesture:UITapGestureRecognizer){
      animateProfileImageView(profileImageView: profileImageView)
        
    }
    
   
     var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    let zoomProfileIn = UIImageView()
    var profileImage: UIImageView?
    
    func animateProfileImageView(profileImageView: UIImageView){
        self.profileImage = profileImageView
       
        
        if let startingFrame = profileImageView.superview?.convert(profileImageView.frame, to: nil){
            let zoomProfileIn = UIImageView()
            zoomProfileIn.backgroundColor = UIColor.red
            
            zoomProfileIn.frame = profileImageView.frame
            
            zoomProfileIn.isUserInteractionEnabled = true
            
            zoomProfileIn.image = profileImageView.image
            
            zoomProfileIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapImageOut)))
            
            addSubview(zoomProfileIn)
            
             if let keyWindow = UIApplication.shared.keyWindow{
                
                //setting background to be black
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                blackBackgroundView?.alpha = 1
                //wiil add the blackbaground view to the window
                keyWindow.addSubview(blackBackgroundView!)
                //will add the picture in its size
                keyWindow.addSubview(zoomProfileIn)

                UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                
                    let  height = startingFrame.height / startingFrame.width * keyWindow.frame.width
                
                  zoomProfileIn.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width/1.5, height: height/1.5)
                    
                      zoomProfileIn.center = keyWindow.center
                    
                    zoomProfileIn.layer.cornerRadius = 16
                    zoomProfileIn.clipsToBounds = true
                    
                    
            }) { (completed) in
                //zoomOutImageView.removeFromSuperview()
            }
            }
            
            
        }
       
        
        
    }
    
    @objc func tapImageOut(tapGesture: UITapGestureRecognizer){
         if let startingFrame = profileImageView.superview?.convert(profileImageView.frame, to: nil){        if let zoomOutImageView = tapGesture.view{
            //need to animate back out to controller
            
            blackBackgroundView?.alpha = 0
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.layer.cornerRadius = 24
                zoomOutImageView.clipsToBounds = true
                
                zoomOutImageView.frame = startingFrame
            }){ (completed) in
                
                zoomOutImageView.removeFromSuperview()
                
                
            }
            
            }
    }
    }
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}
}
