//
//  LoginController+handlers.swift
//  chatapp
//
//  Created by Joey Kraus on 09/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase

extension LoginController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @objc func handleRegister(){
        
      
        
        guard let email = emailTextField.text,  let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { ( user, error) in
            
            
            if error != nil{
                print(error)
                return
            }
            
            guard let uid = user?.user.uid else{
                return
            }
            let imageName = NSUUID().uuidString
            //succesfully authenticated user
            let storageRef = Storage.storage().reference().child("\(imageName).jpg")
            
            //compressquality will load the pic faster
            if let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1){
            
            //if let uploadData = self.profileImageView.image!.pngData(){
            
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil{
                        print(error)
                        return
                    }
                        
                    
                                
                        storageRef.downloadURL(completion: { (url, error) in
                        
                        if error != nil{
                            print(error)
                            return
                        }
                            
                    if url != nil {
                        //let profileImageUrl = UIImage(contentsOfFile: url!.absoluteString)
                let profileImageUrl:String = (url?.absoluteString) ?? ""
                        
                        let values = ["name": name,"email":email,"password":password,"profileImageUrl": profileImageUrl as Any] as [String : Any]
                            
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                   
                    
                   
                                }
                    })
                
                   
                })
            
                }
            
            })
           
    }
                    
                    
                    
                    
   
            
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
          
        let ref = Database.database().reference()
 
        //this is the key users
        let usersReference = ref.child("users").child(uid)
           
        //under the key users we update the children
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil{
                print(error)
                return
            }
            
            //self.viewMessageController?.fetchUserAndSetupNavBarTitle()
            //upon registration the view page will dismiss once successful
            //self.viewMessageController?.navigationItem.title = values["name"] as? String
           
            let user = User()
            user.name = values["name"] as? String
            self.viewMessageController?.setupNavWithUser(user: user)
            
            self.dismiss(animated: true,completion: nil)
            
        })
        
      
    }
    
        
    
    
    @objc func handleSelectProgileImageView(){
       let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
       present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker :UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
        
    
    
    }
}
