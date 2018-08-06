//
//  SignInVC.swift
//  HCFA
//
//  Created by Collin Price on 12/30/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import UIKit
import Eureka

class SignInVC: UIViewController {
    
    let navigationAccessory = NavigationAccessoryView()
    let scrollView = UIScrollView()
    let login = UIButton()
    let register = UIButton()
    let email = UITextField()
    let password = UITextField()
    let confirm = UITextField()
    let firstName = UITextField()
    let lastName = UITextField()
    let submit = UIButton()
    let forgot = UIButton()
    let spinner = UIActivityIndicatorView()
    
    var banner: UIImageView!
    var currentTextField: UITextField?
    var loginActive = true
    var switchingMenu = false
    var animationComplete = false
    var atLaunch = true
    var presentingPassword = false
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        spinner.color = redColor
        
        navigationAccessory.barTintColor = redColor
        navigationAccessory.previousButton.target = self
        navigationAccessory.previousButton.action = #selector(self.previousPressed)
        navigationAccessory.nextButton.target = self
        navigationAccessory.nextButton.action = #selector(self.nextPressed)
        navigationAccessory.doneButton.target = self
        navigationAccessory.doneButton.action = #selector(self.donePressed)
    }
    
    func prepareDisplay() {
        let BANNER_HEIGHT = view.frame.width*(54/233)
        banner = UIImageView(image: UIImage(named: "banner"))
        banner.frame = CGRect(x: 0.0, y: view.frame.midY - BANNER_HEIGHT/2,
                              width: view.frame.width, height: BANNER_HEIGHT)
        banner.contentMode = .scaleAspectFit
        
        loginActive = true
        switchingMenu = false
        
        let BUTTON_WIDTH = self.view.frame.width/4
        let BUTTON_HEIGHT = self.view.frame.height*0.05625
        let TEXT_SIZE = view.frame.width*0.05
        
        let TOGGLE_Y = view.frame.height*0.225
        
        login.frame = CGRect(x: view.frame.midX - BUTTON_WIDTH - 2, y: TOGGLE_Y,
                             width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        login.layer.cornerRadius = BUTTON_HEIGHT/5
        login.setBackgroundImage(roundedImage(color: redColor, width: BUTTON_WIDTH, height: BUTTON_HEIGHT,
                                              cornerRadius: login.layer.cornerRadius),
                                 for: .highlighted)
        login.alpha = 0
        login.setTitle("Log In", for: .normal)
        login.titleLabel?.font =  UIFont(name: "Baskerville", size: BUTTON_WIDTH/5)
        login.backgroundColor = redColor
        login.layer.borderWidth = BUTTON_HEIGHT/20
        login.layer.borderColor = redColor.cgColor
        login.addTarget(self, action: #selector(self.loginPressed), for: .touchUpInside)
        
        register.frame = CGRect(x: view.frame.midX + 2, y: TOGGLE_Y,
                                width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        register.layer.cornerRadius = BUTTON_HEIGHT/5
        register.setBackgroundImage(roundedImage(color: redColor, width: BUTTON_WIDTH, height: BUTTON_HEIGHT,
                                                 cornerRadius: register.layer.cornerRadius),
                                    for: .highlighted)
        register.alpha = 0
        register.setTitle("Register", for: .normal)
        register.titleLabel?.font =  UIFont(name: "Baskerville", size: BUTTON_WIDTH/5)
        register.backgroundColor = highlightColor
        register.layer.borderWidth = BUTTON_HEIGHT/20
        register.layer.borderColor = redColor.cgColor
        register.addTarget(self, action: #selector(self.registerPressed), for: .touchUpInside)
        
        firstName.font = UIFont(name: "Baskerville", size: TEXT_SIZE)
        firstName.alpha = 0.0
        firstName.placeholder = "First"
        firstName.borderStyle = .roundedRect
        firstName.delegate = self
        firstName.inputAccessoryView = navigationAccessory
        firstName.autocorrectionType = .no
        firstName.tag = 1
        
        lastName.font = UIFont(name: "Baskerville", size: TEXT_SIZE)
        lastName.alpha = 0.0
        lastName.placeholder = "Last"
        lastName.borderStyle = .roundedRect
        lastName.delegate = self
        lastName.inputAccessoryView = navigationAccessory
        lastName.autocorrectionType = .no
        lastName.tag = 2
        
        email.font = UIFont(name: "Baskerville", size: TEXT_SIZE)
        email.alpha = 0.0
        email.placeholder = "Email"
        email.borderStyle = .roundedRect
        email.autocapitalizationType = UITextAutocapitalizationType.none
        email.delegate = self
        email.inputAccessoryView = navigationAccessory
        email.autocorrectionType = .no
        email.tag = 3
        
        password.font = UIFont(name: "Baskerville", size: TEXT_SIZE)
        password.alpha = 0.0
        password.placeholder = "Password"
        password.borderStyle = .roundedRect
        password.isSecureTextEntry = true
        password.delegate = self
        password.inputAccessoryView = navigationAccessory
        password.autocorrectionType = .no
        password.tag = 4
        
        confirm.font = UIFont(name: "Baskerville", size: TEXT_SIZE)
        confirm.alpha = 0.0
        confirm.placeholder = "Confirm Password"
        confirm.borderStyle = .roundedRect
        confirm.isSecureTextEntry = true
        confirm.delegate = self
        confirm.inputAccessoryView = navigationAccessory
        confirm.autocorrectionType = .no
        confirm.tag = 5
        
        if #available(iOS 11, *) {
            // Disables the password autoFill accessory view.
            let empty = UITextContentType("")
            firstName.textContentType = empty
            lastName.textContentType = empty
            email.textContentType = empty
            password.textContentType = empty
            confirm.textContentType = empty
        }
        
        submit.alpha = 0.0
        submit.layer.cornerRadius = BUTTON_HEIGHT/10
        submit.backgroundColor = redColor
        submit.setTitle("Submit", for: .normal)
        submit.titleLabel?.font = UIFont(name: "Baskerville", size: BUTTON_WIDTH/5)
        submit.setBackgroundImage(roundedImage(color: highlightColor, width: BUTTON_WIDTH, height: BUTTON_HEIGHT,
                                               cornerRadius: submit.layer.cornerRadius), for: .highlighted)
        submit.addTarget(self, action: #selector(self.submitPressed), for: .touchUpInside)
        
        forgot.alpha = 0.0
        forgot.setTitle("Forgot Password?", for: .normal)
        forgot.setTitleColor(redColor, for: .normal)
        forgot.setTitleColor(highlightColor, for: .highlighted)
        forgot.titleLabel?.textAlignment = .center
        forgot.titleLabel?.baselineAdjustment = .alignCenters
        forgot.titleLabel?.adjustsFontSizeToFitWidth = true
        forgot.titleLabel?.font = UIFont(name: "Baskerville", size: BUTTON_WIDTH*0.175)
        forgot.addTarget(self, action: #selector(self.forgotTapped), for: .touchUpInside)
        
        scrollView.frame = CGRect(x: 0, y: view.frame.height*0.31,
                                  width: view.frame.width, height: view.frame.height*0.665)
        scrollView.backgroundColor = .clear
        
        view.addSubview(banner)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(confirm)
        view.addSubview(email)
        view.addSubview(password)
        view.addSubview(submit)
        view.addSubview(forgot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if presentingPassword {
            presentingPassword = false
            return
        }
        if defaults.integer(forKey: "uid") == 0 {
            handleLogin()
            
        } else {
            API.validate(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                         completionHandler: { response, _ in
                
                switch response {
                case.Success:
                    self.atLaunch = false
                    let nav = UINavigationController(rootViewController: HostVC())
                    self.present(nav, animated: true, completion: nil)
                default:
                    resetDefaults()
                    self.handleLogin()
                }
            })
        }
    }
    
    func handleLogin() {
        if !animationComplete {
            prepareDisplay()
            
            if atLaunch {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.moveImage(self.banner, duration: 1, curve: .linear, x: 0, y: -self.view.frame.height * 0.35)
                })
                animationComplete = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    self.displayToggles(duration: 0.5)
                    self.displayLoginForm(duration: 0.5, completion: nil)
                })
                
            } else {
                banner.alpha = 0.0
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                    self.banner.alpha = 1.0
                }, completion: { _ in
                    self.moveImage(self.banner, duration: 1, curve: .linear, x: 0, y: -self.view.frame.height * 0.35)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self.displayToggles(duration: 0.5)
                        self.displayLoginForm(duration: 0.5, completion: nil)
                    })
                    self.animationComplete = true
                })
            }
            
        } else {
            firstName.text = ""
            lastName.text = ""
            email.text = ""
            password.text = ""
            confirm.text = ""
            register.backgroundColor = highlightColor
            login.backgroundColor = redColor
            loginActive = true
            
            view.addSubview(banner)
            scrollView.addSubview(firstName)
            scrollView.addSubview(lastName)
            scrollView.addSubview(confirm)
            scrollView.removeFromSuperview()
            view.addSubview(email)
            view.addSubview(password)
            view.addSubview(submit)
            view.addSubview(forgot)
            
            banner.alpha = 0.0
            banner.frame = CGRect(x: 0, y: view.frame.midY - view.frame.height*0.35 - banner.frame.height/2,
                                  width: banner.frame.width, height: banner.frame.height)
            displayToggles(duration: 0.5)
            displayLoginForm(duration: 0.5, completion: nil)
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                self.banner.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func moveImage(_ image: UIImageView, duration: TimeInterval, curve: UIViewAnimationCurve,
                   x: CGFloat, y: CGFloat) {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        let transform = CGAffineTransform(translationX: x, y: y)
        image.transform = transform
        
        UIView.commitAnimations()
    }
    
    func displayToggles(duration: Double) {
        view.addSubview(login)
        view.addSubview(register)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.login.alpha = 1.0
            self.register.alpha = 1.0
        }, completion: nil)
    }
    
    func displayLoginForm(duration: Double, completion: ((Bool) -> Void)?) {
        
        let FIELD_WIDTH = self.view.frame.width*0.55
        let FIELD_HEIGHT = self.view.frame.height*0.075
        let BUTTON_WIDTH = FIELD_WIDTH/2
        let BUTTON_HEIGHT = FIELD_HEIGHT*0.75
        
        email.frame = CGRect(x: view.frame.midX - FIELD_WIDTH/2, y: view.frame.height*0.32,
                             width: FIELD_WIDTH, height: FIELD_HEIGHT)
        
        password.frame = CGRect(x: view.frame.midX - FIELD_WIDTH/2, y: view.frame.height*0.42,
                                width: FIELD_WIDTH, height: FIELD_HEIGHT)
        
        forgot.frame = CGRect(x: view.frame.midX - BUTTON_WIDTH*0.625,
                              y: password.frame.height + password.frame.origin.y + BUTTON_HEIGHT/8,
                              width: BUTTON_WIDTH*1.25, height: BUTTON_HEIGHT*0.75)
        
        submit.frame = CGRect(x: view.frame.midX - BUTTON_WIDTH/2, y: BUTTON_HEIGHT*0.875 + view.frame.height*0.52,
                              width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.email.alpha = 1.0
            self.password.alpha = 1.0
            self.submit.alpha = 1.0
            self.forgot.alpha = 1.0
        }, completion: completion)
    }
    
    func displayRegisterForm(duration: Double, completion: ((Bool) -> Void)?) {
        
        let FIELD_WIDTH = view.frame.width*0.55
        let FIELD_HEIGHT = view.frame.height*0.075
        let BUTTON_WIDTH = view.frame.width/4
        let BUTTON_HEIGHT = FIELD_HEIGHT*0.75
        
        view.addSubview(scrollView)
        let startingX = scrollView.frame.width*0.49-FIELD_WIDTH/2
        
        firstName.frame = CGRect(x: startingX, y: view.frame.height*0.01,
                                 width: FIELD_WIDTH*0.49, height: FIELD_HEIGHT)
        
        lastName.frame = CGRect(x: scrollView.frame.width*0.51, y: view.frame.height*0.01,
                                width: FIELD_WIDTH*0.49, height: FIELD_HEIGHT)
        
        email.frame = CGRect(x: startingX, y: view.frame.height*0.11, width: FIELD_WIDTH, height: FIELD_HEIGHT)
        
        password.frame = CGRect(x: startingX, y: view.frame.height*0.21, width: FIELD_WIDTH, height: FIELD_HEIGHT)
        
        confirm.frame = CGRect(x: startingX, y: view.frame.height*0.31, width: FIELD_WIDTH, height: FIELD_HEIGHT)
        
        submit.frame = CGRect(x: (scrollView.frame.width - BUTTON_WIDTH)/2, y: view.frame.height*0.41,
                              width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.firstName.alpha = 1.0
            self.lastName.alpha = 1.0
            self.email.alpha = 1.0
            self.password.alpha = 1.0
            self.confirm.alpha = 1.0
            self.submit.alpha = 1.0
        }, completion: completion)
    }
    
    func loadHomePage(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.banner.alpha = 0.0
            self.login.alpha = 0.0
            self.register.alpha = 0.0
            self.firstName.alpha = 0.0
            self.lastName.alpha = 0.0
            self.email.alpha = 0.0
            self.password.alpha = 0.0
            self.confirm.alpha = 0.0
            self.submit.alpha = 0.0
            self.forgot.alpha = 0.0
        }, completion: {_ in
            let nav = UINavigationController(rootViewController: HostVC())
            self.present(nav, animated: true, completion: nil)
        })
    }
    
    func downloadProfile(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                defaults.set(data, forKey: "profile")
            }
        }
    }
    
    func startSpinner() {
        if loginActive {
            spinner.center = CGPoint(x: view.frame.width/2, y: view.frame.height*0.625)
        } else {
            spinner.center = CGPoint(x: view.frame.width/2, y: view.frame.height*0.825)
        }
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
    
    @objc func forgotTapped(sender: UIButton) {
        presentingPassword = true
        let nav = UINavigationController(rootViewController: ForgotPasswordVC())
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func submitPressed(sender: UIButton) {
        
        currentTextField?.resignFirstResponder()
        
        let userEmail = email.text!
        let userPassword = password.text!
        
        if loginActive {
            
            if userEmail.isEmpty {
                createAlert(title: "Email Empty", message: "Enter your email", view: self)
            } else if userPassword.isEmpty {
                createAlert(title: "Password Empty", message: "Enter your password", view: self)
            } else {
                startSpinner()

                API.login(email: userEmail, password: userPassword, completionHandler: {response, data in
                    self.stopSpinner()

                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                    view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InternalError:
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        let data = data as! [String:Any]

                        defaults.set(data["uid"] as! Int, forKey: "uid")
                        defaults.set(data["first_name"] as! String, forKey: "first")
                        defaults.set(data["last_name"] as! String, forKey: "last")
                        defaults.set(data["email"] as! String, forKey: "email")
                        defaults.set(data["admin"] as! Bool, forKey: "admin")
                        defaults.set(data["leader"] as! Bool, forKey: "leader")
                        defaults.set(data["token"] as! String, forKey: "token")
                        
                        if let imageURL = data["image"] as? String {
                            if let url = URL(string: imageURL) {
                                defaults.set(imageURL, forKey: "image")
                                self.downloadProfile(url: url)
                            }
                        } else {
                            defaults.set(nil, forKey: "image")
                            defaults.set(nil, forKey: "profile")
                        }
                        self.loadHomePage(duration: 0.5)
                    }
                })
            }
            
        } else {
            
            let userFirstName = firstName.text!
            let userLastName = lastName.text!
            let confirmedPass = confirm.text!
            
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            
            if userFirstName.isEmpty {
                createAlert(title: "First Name Empty", message: "Enter your first name", view: self)
            } else if userLastName.isEmpty {
                createAlert(title: "Last Name Empty", message: "Enter your last name", view: self)
            } else if userEmail.isEmpty {
                createAlert(title: "Email Empty", message: "Enter your email", view: self)
            } else if userPassword.isEmpty {
                createAlert(title: "Password Empty", message: "Enter a password", view: self)
            } else if !isValidEmail(testStr: userEmail) {
                createAlert(title: "Invalid Email", message: "Enter a valid email address", view: self)
            } else if !isSecure(text: userPassword) {
                createAlert(title: "Insecure Password",
                            message: "Password must be at least 8 characters, with a capital letter and a number",
                            view: self)
            } else if confirmedPass.isEmpty {
                createAlert(title: "Confirmation Empty", message: "Confirm your password", view: self)
            } else if userPassword != confirmedPass {
                createAlert(title: "Passwords Don't Match", message: "Your passwords do not match", view: self)
            } else {
                startSpinner()
                API.register(first: userFirstName, last: userLastName, email: userEmail, password: userPassword,
                             completionHandler: { response, data in
                    self.stopSpinner()
                    
                    switch response {
                    case .NotConnected:
                        createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                    view: self)
                    case .Error:
                        createAlert(title: "Error", message: data as! String, view: self)
                    case .InternalError:
                        createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                    default:
                        let data = data as! [String:Any]
                        
                        defaults.set(data["uid"] as! Int, forKey: "uid")
                        defaults.set(data["first_name"] as! String, forKey: "first")
                        defaults.set(data["last_name"] as! String, forKey: "last")
                        defaults.set(data["email"] as! String, forKey: "email")
                        defaults.set(data["admin"] as! Bool, forKey: "admin")
                        defaults.set(data["leader"] as! Bool, forKey: "leader")
                        defaults.set(data["token"] as! String, forKey: "token")
                        defaults.set("", forKey: "image")
                        defaults.set(nil, forKey: "profile")
                        
                        self.loadHomePage(duration: 0.5)
                    }
                })
            }
        }
    }
    
    @objc func loginPressed(sender: UIButton) {
        if loginActive || switchingMenu { return } else {
            loginActive = true
            switchingMenu = true
            currentTextField?.resignFirstResponder()
            login.backgroundColor = redColor
            register.backgroundColor = highlightColor
            
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                self.firstName.alpha = 0.0
                self.lastName.alpha = 0.0
                self.email.alpha = 0.0
                self.password.alpha = 0.0
                self.confirm.alpha = 0.0
                self.submit.alpha = 0.0
                
            }, completion: {_ in
                self.firstName.text = nil
                self.lastName.text = nil
                self.email.text = nil
                self.password.text = nil
                self.confirm.text = nil
                self.scrollView.removeFromSuperview()
                
                self.view.addSubview(self.email)
                self.view.addSubview(self.password)
                self.view.addSubview(self.submit)
                self.view.addSubview(self.forgot)
                self.displayLoginForm(duration: 0.15, completion: {_ in self.switchingMenu = false})
            })
        }
    }
    
    @objc func registerPressed(sender: UIButton) {
        if !loginActive || switchingMenu { return } else {
            
            loginActive = false
            switchingMenu = true
            currentTextField?.resignFirstResponder()
            login.backgroundColor = highlightColor
            register.backgroundColor = redColor
            
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                self.email.alpha = 0.0
                self.password.alpha = 0.0
                self.submit.alpha = 0.0
                self.forgot.alpha = 0.0
                
            }, completion: {_ in
                self.email.text = nil
                self.password.text = nil
                self.email.removeFromSuperview()
                self.password.removeFromSuperview()
                self.submit.removeFromSuperview()
                self.forgot.removeFromSuperview()
                
                self.view.addSubview(self.scrollView)
                self.scrollView.addSubview(self.email)
                self.scrollView.addSubview(self.password)
                self.scrollView.addSubview(self.submit)
                self.displayRegisterForm(duration: 0.15, completion: {_ in self.switchingMenu = false})
            })
        }
    }
    
    @objc func previousPressed() {
        let nextField = currentTextField?.superview?.viewWithTag((currentTextField?.tag)! - 1) as! UITextField
        nextField.becomeFirstResponder()
        
    }
    
    @objc func nextPressed() {
        let nextField = currentTextField?.superview?.viewWithTag((currentTextField?.tag)! + 1) as! UITextField
        nextField.becomeFirstResponder()
    }
    
    @objc func donePressed() {
        currentTextField?.resignFirstResponder()
        if !loginActive {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
}

extension SignInVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        
        if loginActive {
            
            // first field (email)
            if currentTextField?.tag == 3 {
                navigationAccessory.previousButton.isEnabled = false
            } else {
                navigationAccessory.previousButton.isEnabled = true
            }
            
            // last field (password)
            if currentTextField?.tag == 4 {
                navigationAccessory.nextButton.isEnabled = false
            } else {
                navigationAccessory.nextButton.isEnabled = true
            }
            
            // currently registering
        } else {
            
            // at first field (first name)
            if currentTextField?.tag == 1 {
                navigationAccessory.previousButton.isEnabled = false
            } else {
                navigationAccessory.previousButton.isEnabled = true
            }
            
            // at last field (confirmation)
            if currentTextField?.tag == 5 {
                navigationAccessory.nextButton.isEnabled = false
            } else {
                navigationAccessory.nextButton.isEnabled = true
            }
            
            // changing positioning of scrollView
            if currentTextField?.tag == 1 || currentTextField?.tag == 2 || currentTextField?.tag == 3 {
                scrollView.setContentOffset(CGPoint.zero, animated: true)
            } else if currentTextField?.tag == 4 {
                scrollView.setContentOffset(CGPoint(x: 0, y: view.frame.height/10), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: view.frame.height/5), animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitPressed(sender: submit)
        return true
    }
}
