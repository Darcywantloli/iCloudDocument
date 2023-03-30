//
//  Alert.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/28.
//

import UIKit

class Alert {
    
    // 推播
    static func showAlertWith(title: String,
                              message: String,
                              vc: UIViewController,
                              confirmTitle: String,
                              confirm: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            let alertAction = UIAlertAction(title: confirmTitle,
                                            style: .default) { action in confirm?() }
            
            alertController.addAction(alertAction)
            vc.present(alertController, animated: true)
        }
    }
}
