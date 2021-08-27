//
//  ViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 8/21/21.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIToolbarDelegate, FontProtocol {
    
    // MARK: - Varibles

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var upperText: UITextField!
    @IBOutlet weak var lowerText: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var activityButton: UIBarButtonItem! {
        didSet {
            activityButton.isEnabled = false
        }
    }
    @IBOutlet weak var coverImage: UIImageView!
    
    var shouldMoveViewForTextField = false
    
    var memeTextAttributes: [NSMutableAttributedString.Key : Any] = [
        NSAttributedString.Key.font : UIFont(name: "Impact", size: 30)!,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.strokeWidth : -2.0
    ]
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upperText.delegate = self
        lowerText.delegate = self
        
        upperText.text = "Welcome to MemeMe"
        lowerText.text = "Dont get any funny ideas!"
        
        configureTextField()
        view.sendSubviewToBack(coverImage)
        view.sendSubviewToBack(imagePickerView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
//        for family in UIFont.familyNames {
//
//            let sName: String = family as String
//            print("family: \(sName)")
//                    
//            for name in UIFont.fontNames(forFamilyName: sName) {
//                print("name: \(name as String)")
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        subscribeToKeyboardWillHideNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Image Methods
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickedAnImageFromCamera(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            activityButton.isEnabled = true
            coverImage.isHidden = true
            upperText.text = "click to edit"
            lowerText.text = "click to edit"
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
//        imagePickerView.image.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
//    }
    
    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view else {
          return
        }

        gestureView.transform = gestureView.transform.scaledBy(
          x: gesture.scale,
          y: gesture.scale
        )
        gesture.scale = 1
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
      let translation = gesture.translation(in: view)
        guard let gestureView = gesture.view else {
        return
      }

      gestureView.center = CGPoint(
        x: gestureView.center.x + translation.x,
        y: gestureView.center.y + translation.y
      )
      
      gesture.setTranslation(.zero, in: view)
    }
    
    
    //MARK: - Textfield Methods
    
    func configureTextField() {
        upperText.defaultTextAttributes = memeTextAttributes
        lowerText.defaultTextAttributes = memeTextAttributes
        
        upperText.textAlignment = .center
        lowerText.textAlignment = .center
        
        lowerText.backgroundColor = .clear
        upperText.backgroundColor = .clear
        
        upperText.borderStyle = .none
        lowerText.borderStyle = .none
        
        view.bringSubviewToFront(upperText)
        view.bringSubviewToFront(lowerText)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Text Field begin editing")
        textField.text = ""
        
        shouldMoveViewForTextField = textField == lowerText ? true : false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Keyboard Notification Section
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardWillHideNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromHideKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if shouldMoveViewForTextField == true {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: - MemeMe Methods
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(upperText: upperText.text!, lowerText: lowerText.text!, image: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        toolBar.isHidden = true
        navigationBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let memedImage = [generateMemedImage()]
        let activityViewController = UIActivityViewController(activityItems: memedImage, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                return
            }
            self.save()
        }
        present(activityViewController, animated: true)
    }
    
    // MARK: - Font Methods
    
    @IBAction func fontButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "fontTableID") as? FontTableViewController else {
            return
        }
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
    }
    
    func getFont(font: String) {
        print("This font =", font)
        memeTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: font, size: 30)!,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.strokeWidth : -2.0
        ]
        configureTextField()
    }
    
    
}
