//
//  extensions.swift
//  chatapp
//
//  Created by Joey Kraus on 22/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

//this helper cache will help the memory load the images faster
extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString:String){
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL,completionHandler:{(data,response,error) in
            if error != nil{
                print(error)
                return
            }
            DispatchQueue.main.async {
                //cell.imageView?.image = UIImage(data: data!)
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                    
                }
                
                
            }
        }).resume()
        
        
    }
    
    
    
}
    

