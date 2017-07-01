//
//  ViewController.swift
//  Social
//
//  Created by Ray on 2017/5/3.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let accessToken = AccessToken.current {
            fetchProfile()
        }
    }
    
    // Facebook login button action
    @IBAction func fbLoginAction(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile,.email ], viewController: self) { loginResult in
            print(loginResult)
            
            self.fetchProfile()
        }
    }
    
    func fetchProfile(){
        let parameters = ["fields": "email,name,gender,picture.type(large)"]
        
        //use picture.type(large) for large size profile picture
        let request = GraphRequest(graphPath: "me", parameters: parameters, accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue!)
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
                self.firebaseAuth(credential)
            case .failed(let error):
                print(error)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(String(describing: error))")
            }
            else {
                print("Successfully authenticated with Firebase")
            }
        })
    }
    
}

