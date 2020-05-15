//
//  LoginViewController.swift
//  chinwagg
//
//  Created by Jakub Minkiewicz on 01/05/2020.
//  Copyright © 2020 Jakub Minkiewicz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LoginBtn(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            //logs the error and dat whatever
            return
        }
        
        authUI?.delegate = self
        
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
    }

}


extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            //log the error again whatever
            return
        }
        
//        authDataResult?.user.uid
        
        performSegue(withIdentifier: "gotoMenu", sender: self)
        
    }
}
