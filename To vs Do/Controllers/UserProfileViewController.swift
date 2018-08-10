//
//  UserProfileViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/27/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class UserProfileViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendCountLabel: UILabel!
    @IBOutlet weak var editPhotoButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var toDoTodayLabel: UILabel!
    @IBOutlet weak var completedTodayLabel: UILabel!
    @IBOutlet weak var totalToDoLabel: UILabel!
    @IBOutlet weak var dailyAverageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 1.0
        }
    }
    @IBOutlet weak var statView: UIView!
    
    var toDoTodayCount: Int? {
        didSet {
            toDoTodayLabel.text = String(getToDoTodayCount())
        }
    }
    var completedTodayCount: Int? {
        didSet {
            completedTodayLabel.text = String(getCompletedTodayCount())
        }
    }
    var totalToDoCount: Int? {
        didSet{
            totalToDoLabel.text = String(getTotalToDoCount())
        }
    }
    var dailyAverage: Double? {
        didSet {
            dailyAverageLabel.text = String(getAverageCount())
        }
    }
    var friendCount: Int? {
        didSet {
            friendCountLabel.text = "You have \(String(getFriendCount())) friends"
        }
    }
    
    var image: UIImage? {
        didSet {
            self.userProfileImageView.image = image
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "editProfile":
            let destination = segue.destination as! EditProfileViewController
            destination.originalImage = userProfileImageView.image!
            
        default:
            print("unexpected segue identifier")
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return statView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = User.current.username
        friendCountLabel.text = "You have \(String(getFriendCount())) friends"
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.userProfileImageView.af_setImage(withURL: URL(string: User.current.profilePic)!)
        StatCalculatorService.calculateStats()
        usernameLabel.text = User.current.username
        friendCountLabel.text = "You have \(String(getFriendCount())) friends"
        toDoTodayLabel.text = String(getToDoTodayCount())
        completedTodayLabel.text = String(getCompletedTodayCount())
        totalToDoLabel.text = String(getTotalToDoCount())
        dailyAverageLabel.text = String(getAverageCount())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        })
        
        alertController.addAction(logoutAction)
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getToDoTodayCount() -> Int {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("toDoToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.toDoTodayCount = snapshot.value as? Int
        }
        if let count = self.toDoTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getCompletedTodayCount() -> Int {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("completedToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.completedTodayCount = snapshot.value as? Int
        }
        if let count = self.completedTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getTotalToDoCount() -> Int {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("totalToDo")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.totalToDoCount = snapshot.value as? Int
        }
        if let count = self.totalToDoCount {
            return count
        } else {
            return 0
        }
    }
    
    func getAverageCount() -> Double {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("dailyAverage")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.dailyAverage = snapshot.value as? Double
        }
        if let count = self.dailyAverage {
            return count
        } else {
            return 0
        }
    }
    
    func getFriendCount() -> Int{
        let ref = Database.database().reference().child("friends").child(User.current.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : Any]
                else { return }
            self.friendCount = snapshot.count
        }
        if let count = self.friendCount {
            return count
        } else {
            return 0
        }
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}
