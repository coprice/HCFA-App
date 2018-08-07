//
//  ProfileVC.swift
//  HCFA
//
//  Created by Collin Price on 7/26/18.
//  Copyright © 2018 Collin Price. All rights reserved.
//

import Eureka
import InteractiveSideMenu
import AWSCore
import AWSS3

class ProfileVC: FormViewController, SideMenuItemContent {
    
    let save = UIButton()
    let picture = UIButton()
    
    var hostVC: HostVC!
    var sideMenu: SideMenuVC!
    var profileCell: ProfileCell!
    var navBar: UINavigationBar!
    var camera: DSCameraHandler!
    var loadingView: LoadingView!
    var cameraLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        
        navBar = navigationController!.navigationBar
        hostVC = navigationController?.viewControllers.first as! HostVC
        sideMenu = hostVC.menuViewController as! SideMenuVC
        profileCell = sideMenu.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileCell

        navigationAccessoryView.barTintColor = redColor
        
        loadingView = LoadingView(frame: CGRect(x: view.frame.width*0.375,
                                                y: view.frame.height/2 - view.frame.width*0.125,
                                                width: view.frame.width*0.25, height: view.frame.width*0.25))
        
        save.frame = CGRect(x: navBar.frame.width*0.8, y: 0,
                            width: navBar.frame.width*0.2, height: navBar.frame.height)
        save.setTitle("Save", for: .normal)
        save.titleLabel?.textColor = .white
        save.titleLabel?.font = UIFont(name: "Georgia", size: navBar.frame.width/21)
        save.setTitleColor(barHighlightColor, for: .highlighted)
        save.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)
        
        picture.frame = CGRect(x: view.frame.width*0.25, y: view.frame.width*0.05,
                               width: view.frame.width*0.5, height: view.frame.width*0.5)
        picture.setImage(UIImage(named: "generic"), for: .normal)
        picture.imageView?.contentMode = .scaleAspectFill
        picture.layer.masksToBounds = true
        picture.layer.cornerRadius = picture.frame.width/2
        picture.layer.borderColor = UIColor.black.cgColor
        picture.layer.borderWidth = 1
        picture.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(self.imageTapped)))
        if let urlString = defaults.string(forKey: "image") {
            if let data = defaults.object(forKey: "profile") as? Data {
                picture.setImage(UIImage(data: data), for: .normal)
            } else if let url = URL(string: urlString) {
                downloadImage(url: url, button: picture)
            }
        }
        
        form +++ Section(){ section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { self.view.frame.width*0.6 }
            header.onSetupView = { view, _ in
                view.backgroundColor = .clear
                view.addSubview(self.picture)
            }
            section.header = header
        }
        
        <<< NameRow() { row in
            row.title = "First Name"
            row.tag = "first"
            row.value = defaults.string(forKey: "first")!
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
            row.onChange({ row in
                self.handleChange()
            })
        }
        
        <<< NameRow() { row in
            row.title = "Last Name"
            row.tag = "last"
            row.value = defaults.string(forKey: "last")!
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
            row.onChange({ row in
                self.handleChange()
            })
        }
        
        <<< EmailRow() { row in
            row.title = "Email"
            row.tag = "email"
            row.value = defaults.string(forKey: "email")!
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
                cell.textField.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
            row.onCellHighlightChanged { cell, row in
                cell.textLabel?.textColor = redColor
            }
            row.onChange({ row in
                self.handleChange()
            })
        }
        
        <<< ButtonRowWithPresent<PasswordViewController>() { row in
            row.title = "Password"
            row.presentationMode = PresentationMode<PasswordViewController>.show(controllerProvider: ControllerProvider.callback {
                return PasswordViewController()
            }, onDismiss: nil)
            row.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont(name: "Baskerville", size: self.view.frame.width/20)
            }
        }
        
        animateScroll = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !cameraLoaded {
            camera = DSCameraHandler(delegate_: self)
            cameraLoaded = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if hostVC.slider.superview == nil {
            navBar.addSubview(hostVC.slider)
        }
        hostVC.slider.addTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
        navBar.topItem?.title = "Profile"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let first = form.rowBy(tag: "first") as! NameRow
        let last = form.rowBy(tag: "last") as! NameRow
        let email = form.rowBy(tag: "email") as! EmailRow
        first.value = defaults.string(forKey: "first")
        last.value = defaults.string(forKey: "last")
        email.value = defaults.string(forKey: "email")
        first.updateCell()
        last.updateCell()
        email.updateCell()
        
        hostVC.slider.removeTarget(self, action: #selector(self.sliderTapped), for: .touchUpInside)
        save.removeFromSuperview()
        picture.isUserInteractionEnabled = true
        tableView.endEditing(true)
    }
    
    func handleChange() {
        if valuesAllSame() {
            if save.superview != nil {
                save.removeFromSuperview()
                picture.isUserInteractionEnabled = true
            }
        } else {
            if save.superview == nil {
                navBar.addSubview(save)
                picture.isUserInteractionEnabled = false
            }
        }
    }
    
    func valuesAllSame() -> Bool {
        let values = form.values()
        
        if let first = values["first"] as? String, let last = values["last"] as? String,
           let email = values["email"] as? String {
            return first == defaults.string(forKey: "first")! && last == defaults.string(forKey: "last")! &&
                   email == defaults.string(forKey: "email")!
        }
        
        return false
    }
    
    func backToSignIn() {
        resetDefaults()
        let signInVC = self.navigationController!.presentingViewController!
        dismiss(animated: true, completion: {
            createAlert(title: "Session Expired", message: "", view: signInVC)
        })
    }
    
    func uploadImage(data: Data, setImages: @escaping () -> Void) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                
                setImages()
                self.loadingView.removeFromSuperview()
                self.navBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    print("Response: \(task.response?.statusCode ?? 0)")
                } else {
                    
                    if defaults.string(forKey: "image") == nil {
                        let uid = defaults.integer(forKey: "uid")
                        let imageURL = userImageURL(uid)

                        API.updateImage(uid: uid, token: defaults.string(forKey: "token")!, image: imageURL,
                                        completionHandler: { _, _ in })
                        defaults.set(imageURL, forKey: "image")
                    }
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data, bucket: S3BUCKET,
                                   key: userS3Key(defaults.integer(forKey: "uid")),
                                   contentType: "image/jpeg", expression: expression,
                                   completionHandler: completionHandler).continueWith {
                                    (task) -> AnyObject? in
                                    
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let _ = task.result {
                DispatchQueue.main.async {
                    // print("Upload Starting!")
                }
            }
            return nil;
        }
    }
    
    @objc func sliderTapped(sender: UIButton) {
        showSideMenu()
    }
    
    @objc func saveTapped(sender: UIButton) {
        
        tableView.endEditing(true)
        
        let values = form.values()
        
        let first = values["first"] as? String
        let last = values["last"] as? String
        let email = values["email"] as? String
        
        if first == nil {
            createAlert(title: "First Name Empty", message: "Your name cannot be empty", view: self)
        
        } else if last == nil {
            createAlert(title: "Last Name Empty", message: "Your name cannot be empty", view: self)
        
        } else if email == nil {
            createAlert(title: "Email Empty", message: "Your email cannot be empty", view: self)
        
        } else if !isValidEmail(testStr: email!) {
            createAlert(title: "Invalid Email", message: "Enter a valid email address", view: self)
        
        } else {
            
            let first = first!
            let last = last!
            let email = email!
            
            API.updateContact(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!,
                              first: first, last: last, email: email) { (response, data) in
                
                switch response {
                case .NotConnected:
                    createAlert(title: "Connection Error", message: "Unable to connect to the server",
                                view: self)
                case .Error:
                    createAlert(title: "Error", message: data as! String, view: self)
                case .InvalidSession:
                    self.backToSignIn()
                case .InternalError:
                    createAlert(title: "Internal Server Error", message: "Something went wrong", view: self)
                default:
                    defaults.set(first, forKey: "first")
                    defaults.set(last, forKey: "last")
                    defaults.set(email, forKey: "email")
                    self.save.removeFromSuperview()
                    self.picture.isUserInteractionEnabled = true
                    createAlert(title: "Account Updated", message: "",
                                view: self.navigationController!.viewControllers.last!)
                }
            }
        }
    }
    
    @objc func imageTapped(sender: UIButton) {
        tableView.endEditing(true)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            self.camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Libray", style: .default) { (alert : UIAlertAction!) in
            self.camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
        navBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
        view.addSubview(loadingView)
        
        API.validate(uid: defaults.integer(forKey: "uid"), token: defaults.string(forKey: "token")!) {
            response, _ in
            
            switch response {
            case .Success:
                if let data = UIImageJPEGRepresentation(image, 0.6) {
                    self.uploadImage(data: data, setImages: {
                        self.picture.setImage(image, for: .normal)
                        self.profileCell.picture.image = image
                        defaults.set(data, forKey: "profile")
                    })
                }
            default:
                self.backToSignIn()
            }
        }
    }
}
