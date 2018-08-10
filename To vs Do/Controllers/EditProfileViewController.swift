//
//  EditProfileViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 8/9/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var tapToEditLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!

    let limitLength = 12
    let photoHelper = TVDPhotoHelper()
    var imageHolder: UIImage? {
        didSet {
            profilePicImageView.image = imageHolder
        }
    }
    var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicImageView.isUserInteractionEnabled = true
        profilePicImageView.image = originalImage!
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.usernameTextField.inputAccessoryView = toolbar
        
        photoHelper.completionHandler = { image in
            self.imageHolder = image
        }
    }
    
    @objc func doneButtonAction() {
        usernameTextField.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = usernameTextField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.text = User.current.username
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func pictureTapped(_ sender: UITapGestureRecognizer) {
        photoHelper.presentActionSheet(from: self)
        let ref = Database.database().reference().child("users").child(User.current.uid).child("image_url")

        ref.observeSingleEvent(of: .value) { (snapshot) in
            let key = snapshot.value as? String
            if let key = key {
                let image = URL(string: key)
                self.profilePicImageView.af_setImage(withURL: image!)
            }
        }
    }
    
    
    
    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
        
        if(usernameTextField.text != "") {
            let ref = Database.database().reference().child("users").child(User.current.uid).child("username")
            ref.setValue(usernameTextField.text)
            User.current.username = usernameTextField.text!
            User.setCurrent(User.current, writeToUserDefaults: true)
        }
        
        if(imageHolder != nil) {
            ProfilePicService.create(for: imageHolder!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "saveChanges":
            let destination = segue.destination as! UserProfileViewController
            destination.image = profilePicImageView.image!
            
        default:
            print("unexpected segue identifier")
        }
    }
    
}
