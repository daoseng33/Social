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
import FirebaseAuth

class SignInVC: UIViewController {
    @IBOutlet weak var emailTextField: FancyField!
    @IBOutlet weak var passwordTextField: FancyField!
    @IBOutlet weak var signInButton: FancyButton!
    
    // MARK: - IBAction
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        if let email = emailTextField.text, let pwd = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("User authenticated by email with Firebase")
                }
                else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using email")
                        }
                        else {
                            print("Successfully authenticated with Firebase")
                        }
                    })
                }
            })
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
    
    // MARK: - fetch data
    
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
    
    // MARK: - text field
    
    func textDidChange(textField: UITextField) {
        
        let isEnable = (self.emailTextField.text?.characters.count)! > 0 && (self.passwordTextField.text?.characters.count)! > 0
        
        self.signInButton.isEnabled = isEnable
        self.signInButton.backgroundColor = isEnable ? UIColor.init(red: 255.0 / 255.0, green: 88.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0) : UIColor.init(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.y = keyboardFrame.minY - self.view.frame.height
                self.view.frame = frame
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        switch textField {
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
            break
            
        case self.passwordTextField:
            
            break
            
        default:
            break
        }
        
        return true
    }
    
    // MARK: - init values
    
    func setupSignInButton() {
        self.signInButton.backgroundColor = UIColor.init(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    }
    
    func setupTextField() {
        self.emailTextField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        
        addToolBar(textField: self.emailTextField)
        addToolBar(textField: self.passwordTextField)
        
//        self.emailTextField.inputAccessoryView =
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let accessToken = AccessToken.current {
            fetchProfile()
        }
        
        setupTextField()
        setupSignInButton()
        setupNotificationCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIViewController: UITextFieldDelegate {
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func donePressed() {
        view.endEditing(true)
    }
}

