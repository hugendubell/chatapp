//
//  NewMessageControllerTableViewController.swift
//  chatapp
//
//  Created by Joey Kraus on 05/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase

class NewMessageControllerTableViewController: UITableViewController,UISearchResultsUpdating {
    
    
   
    
    
    
    let cellId = "cellId"
    
  
    var userArray = [User]()
    var filteredUsers = [User]()
    var chatLogController: ChatLogController?
    
    let searchBar = UISearchController(searchResultsController: nil)
    
    var dataBase = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        searchBar.searchResultsUpdater = self
        searchBar.dimsBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Search users..."
         searchBar.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchBar.searchBar
        
        
        //this will set a cancel buttom on the left top of the
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem!.customView?.layer.cornerRadius = 30
        navigationItem.leftBarButtonItem!.customView?.layer.masksToBounds = true
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
        titleLabel.text = "User list"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 8.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        self.navigationController!.navigationBar.topItem!.titleView = titleLabel
        
        
        navigationItem.leftBarButtonItem?.tintColor = .black
         navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        
       
        
        
        
        navigationController?.navigationBar.tintColor = .black
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        //calling the function
        //showSearchBarButton(shouldShow: true)
        
        
        fetchUser()
       
       
    }
   
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.id = snapshot.key
               // user.setValuesForKeys(dictionary)
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                
                
                
                self.userArray.append(user)
                self.filteredUsers.append(user)
                //this will crash because
               
            }
          //  print("User found")
           // print(snapshot)
           
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    //hitting the cancel button will send it back
    @objc func handleCancel(){
        dismiss(animated: true,completion:nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.isActive && searchBar.searchBar.text != "" {
            
        
        return filteredUsers.count
            
        }
        return self.userArray.count
        
    }
    
    //the height of the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messageController: ViewController?
    var user = User()
    //this function will send us to the peoper user id chat box
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        
      
        
        if searchBar.isActive && searchBar.searchBar.text != ""  {
            //searchBar.dismiss(animated: true, completion: nil)
            
              user = filteredUsers[indexPath.row]
            
            
            self.messageController?.showChatControllerForUser(user: user)
            
        }else{
            //this will find the user indexpath while tapping and send the index to the
              user = self.userArray[indexPath.row]
        
            self.messageController?.showChatControllerForUser(user: user)
        }
        
        
    
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let use a hack for now,we actually needd to deque our cells for memory efficiancy
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        //var user = User()
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId,for: indexPath) as! UserCell
          if searchBar.isActive && searchBar.searchBar.text != "" {
            
            //this will fetch the user's name
       
        
            user = filteredUsers[indexPath.row]
        }
          else{
            
            user = userArray[indexPath.row]
        }
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        //cell.imageView?.image = UIImage(named: "nedStark")
        //cell.imageView?.contentMode = .scaleToFill
        
        //this will call the images url from the storage and upload it in the cells
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
            /*let url = NSURL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url! as URL,completionHandler:{(data,response,error) in
                if error != nil{
                print(error)
                return
            }
                DispatchQueue.main.async {
                    //cell.imageView?.image = UIImage(data: data!)
                    cell.profileImageView.image = UIImage(data: data!)
                }
            }).resume()*/
                
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContent(seaerchText: self.searchBar.searchBar.text! ?? "" )
        
    }
    
    func filteredContent(seaerchText: String){
        dataBase.child("users").queryOrdered(byChild: "name").observe(.childAdded, with: { (DataSnapshot) in
           
                
                self.filteredUsers = self.userArray.filter({ (user) -> Bool in
                    //let userName = user.name as? String
                    
                 
                    return(((user.name?.lowercased().contains(seaerchText.lowercased()))!))
                })
               
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
              
          
       
            
        }) { (Error) in
            print(Error)
        }
       
    }
    
  
    
}
/*extension NewMessageControllerTableViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
      search(shouldShow: false)
        
    }
}*/
//customizing our cells image and name

    



