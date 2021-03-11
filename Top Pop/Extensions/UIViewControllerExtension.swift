//
//  Extensions.swift
//  Top Pop
//
//  Created by Matej Terek on 11/03/2021.
//

import UIKit

extension UIViewController{
    //show alert with custom title and messgae for specific view controller
    func showAlertFailed(title: String, message: String, controller: UIViewController?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let controller = controller {
                controller.present(alertVC, animated: true)
            }
        }
    }
}

