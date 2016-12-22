//
//  ViewController.swift
//  Filterer
//
//  Created by Jo Jangmi on 12/14/16.
//  Copyright © 2016 Jo Jangmi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var filteredImage: UIImage?
    var originalImage: UIImage?
    var rgbaImage: RGBAImage?
    var red = 0, green = 0, blue = 0
    var intensity = 5;
    
    @IBAction func intensity(sender: UISlider) {
        intensity = Int(sender.value)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!

    @IBOutlet weak var compareButton: UIButton!
    
    @IBAction func handleImageTapped(sender: UITapGestureRecognizer) {
        imageView.image = originalImage
        if sender.state == UIGestureRecognizerState.Ended {
            imageView.image = filteredImage
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
        self.processImageToRGBA()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onShare(sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func onNewPhoto(sender: UIButton) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {
            action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {
            action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage = image
            filteredImage = nil
            compareButton.enabled = false
            self.processImageToRGBA()
            
            self.changeImageWithAnimation(imageView.image!, to: image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(bottomMenu.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(bottomMenu.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func changeImageWithAnimation(from: UIImage, to: UIImage) {
        let crossFade:CABasicAnimation = CABasicAnimation(keyPath: "contents");
        crossFade.duration = 1.0;
        crossFade.fromValue = from.CGImage;
        crossFade.toValue = to.CGImage;
        imageView.layer.addAnimation(crossFade, forKey:"animateContents");
        imageView.image = to
    }
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
        }) { completed in
            if completed == true {
                self.secondaryMenu.removeFromSuperview()
            }
        }
    }
    
    
    @IBAction func onCompare(sender: UIButton) {
        if (sender.selected) {
            self.changeImageWithAnimation(originalImage!, to: filteredImage!)
            sender.selected = false
        } else {
            self.changeImageWithAnimation(filteredImage!, to: originalImage!)
            sender.selected = true
        }
    }
    
    func processImageToRGBA() {
        rgbaImage = RGBAImage(image: originalImage!)!
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                var pixel = rgbaImage!.pixels[idx]
                red += Int(pixel.red)
                green += Int(pixel.green)
                blue += Int(pixel.blue)
            }
        }
        let count = rgbaImage!.width * rgbaImage!.height
        red /= count
        green /= count
        blue /= count
    }
    
    func loadFilteredImage() {
        filteredImage = rgbaImage!.toUIImage()
        compareButton.enabled = true
        self.changeImageWithAnimation(imageView.image!, to: filteredImage!)
        rgbaImage = RGBAImage(image: originalImage!)!
    }
    
    @IBAction func onPurple(sender: UIButton) {
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[idx]
                let redDiff = Int(pixel.red) - red
                let blueDiff = Int(pixel.blue) - blue
                rgbaImage!.pixels[idx].red = redDiff > 0 ? UInt8( max(0, min(255, red + redDiff * intensity))) : pixel.red
                rgbaImage!.pixels[idx].blue = blueDiff > 0 ? UInt8( max(0, min(255, blue + blueDiff * intensity))) : pixel.blue
            }
        }
        self.loadFilteredImage()
    }
    
    
    @IBAction func onYellow(sender: UIButton) {
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[idx]
                let redDiff = Int(pixel.red) - red
                let greenDiff = Int(pixel.green) - green
                rgbaImage!.pixels[idx].green = greenDiff > 0 ? UInt8( max(0, min(255, green + greenDiff * intensity))) : pixel.green
                rgbaImage!.pixels[idx].red = redDiff > 0 ? UInt8( max(0, min(255, red + redDiff * intensity))) : pixel.red
            }
        }
        self.loadFilteredImage()
    }
    
    
    @IBAction func onBlue(sender: UIButton) {
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[idx]
                let blueDiff = Int(pixel.blue) - blue
                rgbaImage!.pixels[idx].blue = blueDiff > 0 ? UInt8( max(0, min(255, blue + blueDiff * intensity))) : pixel.blue
            }
        }
        self.loadFilteredImage()
    }

    @IBAction func onGreen(sender: UIButton) {
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[idx]
                let greenDiff = Int(pixel.green) - green
                rgbaImage!.pixels[idx].green = greenDiff > 0 ? UInt8( max(0, min(255, green + greenDiff * intensity))) : pixel.green
            }
        }
        self.loadFilteredImage()
    }
    
    @IBAction func onRed(sender: UIButton) {
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let idx = y * rgbaImage!.width + x
                let pixel = rgbaImage!.pixels[idx]
                let redDiff = Int(pixel.red) - red
                rgbaImage!.pixels[idx].red = redDiff > 0 ? UInt8( max(0, min(255, red + redDiff * intensity))) : pixel.red
            }
        }
        self.loadFilteredImage()
    }
    
    
}

