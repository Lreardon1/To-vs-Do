//
//  CropImageViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 8/6/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit

class CropImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            if(TVDPhotoHelper.photoType == "library") {
                scrollView.minimumZoomScale = 0.5
                scrollView.maximumZoomScale = 10.0
            } else {
                scrollView.minimumZoomScale = 0.2
                scrollView.maximumZoomScale = 5.0
            }
            
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var finishButton: UIButton!
    
    var imageToCrop: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setImageToCrop(image: imageToCrop!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setImageToCrop(image: UIImage) {
        imageView.image = image
        imageViewWidth.constant = image.size.width
        imageViewHeight.constant = image.size.height

        if (TVDPhotoHelper.photoType == "library") {
            scrollView.zoomScale = 0.5
        } else {
            scrollView.zoomScale = 0.2
        }
        
    }
    
    func crop() -> UIImage {
        let scale: CGFloat = 1/scrollView.zoomScale
        
        let x: CGFloat = scrollView.contentOffset.x * scale
        let y: CGFloat = scrollView.contentOffset.y * scale
        
        let width: CGFloat = scrollView.frame.size.width * scale
        let height: CGFloat = scrollView.frame.size.height * scale
        
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        
        var croppedImage: UIImage?
        
        if (TVDPhotoHelper.photoType == "library") {
            croppedImage = UIImage(cgImage: croppedCGImage!)
        } else {
            croppedImage = UIImage(cgImage: croppedCGImage!, scale: scale, orientation: UIImageOrientation.right)
        }
        
        return croppedImage!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newImage = crop()
        ProfilePicService.create(for: newImage)
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "submitCroppedImage":
            let destination = segue.destination as! UserProfileViewController
            destination.userProfileImageView.image = newImage
        default:
            print("unexpected segue identifier")
        }
    }
}
