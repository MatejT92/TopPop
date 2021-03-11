//
//  UIImageViewExtension.swift
//  Top Pop
//
//  Created by Matej Terek on 11/03/2021.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()
typealias CompletionHandler = (_ success:Bool) -> Void

extension UIImageView {
    //Image Handling And Caching
    func loadImageUsingCache(imagePath urlString : String, completionHandler: @escaping CompletionHandler) {
        let url = URL(string: urlString)
        if url == nil  {
            return
        }
        self.image = nil
        // check if is image in cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            // load image from cahce
            self.image = cachedImage
            return
        }
        else{
            self.image = UIImage()
        }
        //download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            //load downloaded image
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    //save image to cache
                    imageCache.setObject(image, forKey: urlString as NSString)
                    // return downloaded image
                    self.image = image
                    let flag = true // true if download succeed
                    completionHandler(flag)
                }
            }
        })
        .resume()
    }

}

