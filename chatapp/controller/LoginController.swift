//
//  LoginController.swift
//  chatapp
//
//  Created by Joey Kraus on 02/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//


import UIKit
import Firebase

class LoginController: UIViewController {
    
    var viewMessageController: ViewController?
    
    let inputContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        //goes together with coenerRadious
        view.layer.masksToBounds = true
        return view
        
    }()
    
    lazy var loginRegisterButton : UIButton = {
        let button = UIButton(type:.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    @objc func handleLoginRegister(){
        if loginRegisterSegmentControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
        
    }
    func handleLogin(){
        guard let email = emailTextField.text,  let password = passwordTextField.text else{
            print("Form is not valid")
            
            return
            
        }
        Auth.auth().signIn(withEmail: email, password: password,completion:  { (user, error) in
       
        
            if error != nil{
                print(error)
                self.showToast(message:"Incorrect password or Email")
                return
            }
            
            self.viewMessageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
       
    }
    
    func showToast(message:String){
        
       
        toast.text = message
        toast.textColor = .white
        self.toast.isHidden = false
        UIView.animate(withDuration: 3.0, delay: 2.0, options: .curveEaseOut, animations: {
            self.toast.alpha = 0.0
            
        }) { (iscompleted) in
            self.toast.removeFromSuperview()
            
            
        }
    }
   
        

    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        //secure text like a password ...dots
        tf.isSecureTextEntry = true
        //donts inside the text for password
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    
    lazy var profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "butterfly")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        //upon tapping on the image it will send us to the function
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProgileImageView)))
        
        imageView.isUserInteractionEnabled = true
        
        return imageView
        
    }()
    
    let toast: UILabel = {
    let label = UILabel()
    //label.frame = CGRect(x: view.frame.width/2-75, y: view.frame.height - 100, width: self.view.frame.width - 150, height: 40)
    
    label.textAlignment = .center
    label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    label.numberOfLines = 0
    label.alpha = 1.0
    label.layer.cornerRadius = 5
    label.clipsToBounds = true
    label.translatesAutoresizingMaskIntoConstraints = false
   
   
        return label
    }()
    
    //this button will set the button login and register
    lazy var loginRegisterSegmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        return sc
        
    }()
    
    let text: UILabel = {
        let tx = UILabel()
        tx.textAlignment = .center
        tx.text = "Please tap on the Image to set your profile Image :)"
        tx.textColor = .white
         tx.numberOfLines = 2
        tx.font = UIFont.boldSystemFont(ofSize:20)
        
        
        
        tx.translatesAutoresizingMaskIntoConstraints = false
        return tx
    }()
    
    @objc func handleLoginRegisterChange(){
        //everytime we hit one of the buttons of register and login ...the buttom button will change with the index name
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
       loginRegisterButton.setTitle(title, for: .normal)
        
        //change height od input container view
        //everey time we hit the buttom of register or login it will change the height from 100 pixel to 150
        inputsConstrainerViewHeightAnchor?.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 100 : 150
        //change height of name text field
        nameTextFieldHeightAnchor?.isActive = false
        //if the button that was selected wa with index 0 (login) then the input view will small down to 100 heifht constraint
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 : 1/3 )
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordFieldHeightAnchor?.isActive = false
        passwordFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 1/2 :1/3 )
        passwordFieldHeightAnchor?.isActive = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background1")!)
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentControl)
        view.addSubview(text)
        view.addSubview(toast)
       
       
       
        
        
        setUpInputsContainerView()
        setUpLoginRegisterButton()
        setUpProfileImageView()
        setupLoginRegisterSegmentControl()
        setUpTextForImage()
        setUpToast()
        
    }
    
    func setUpToast(){
        toast.isHidden = true
        toast.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toast.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        toast.topAnchor.constraint(equalTo: text.bottomAnchor,constant: 40).isActive = true
        toast.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    func setupLoginRegisterSegmentControl(){
        //constrtians for the segment controller
        loginRegisterSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //this constriant will set the button to the top of the inputview with a gap of -12 between
        loginRegisterSegmentControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    func  setUpProfileImageView() {
        //will constarian it to the center of the view
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //will constarain it to the top of the loginRegisterSegment
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentControl.topAnchor, constant: -25).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }   //button constraints
    func setUpLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor,constant:15 ).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
   
    //TYPE REFERENCES
    var inputsConstrainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordFieldHeightAnchor: NSLayoutConstraint?
    
    func setUpInputsContainerView(){
        //will center the white view directly in the middle of the page
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        //width 12 pixels from each side
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        //the height
inputsConstrainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsConstrainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        
        //constraints for the text field
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true;
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //constraints for the text field
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true;
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //constraints for the text field
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordFieldHeightAnchor?.isActive = true
    }
    func  setUpTextForImage(){
        
        text.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        text.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        text.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor,constant: 40).isActive = true
        text.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    
    
}

//extension for colorUi
extension UIColor{
    
    convenience init (r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255,green: g/255,blue: b/255, alpha : 1)
    }
}
