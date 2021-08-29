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

    
    @IBOutlet weak var imageViewContainer: UIView!
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
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upperText.delegate = self
        lowerText.delegate = self
        
        upperText.text = "Welcome to MemeMe"
        lowerText.text = "Dont get any funny ideas!"
        
        configureTextField(textField: upperText, fontName: "Impact")
        configureTextField(textField: lowerText, fontName: "Impact")
        view.sendSubviewToBack(imageViewContainer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardHideAndShowNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardHideAndShowNotifications()
    }
    
    // MARK: - Image Methods
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if sender.title != "Album" {
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            activityButton.isEnabled = true
            upperText.text = "click to edit"
            lowerText.text = "click to edit"
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //These methods allow image to be zoomed in and out and panned
    
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
    
    func configureTextField(textField: UITextField, fontName: String) {
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.white
        shadow.shadowBlurRadius = 10
        
        let memeTextAttributes: [NSMutableAttributedString.Key : Any] = [
            .font : UIFont(name: fontName, size: 30)!,
            .foregroundColor : UIColor.white,
            .shadow : shadow,
            .strokeColor : UIColor.black,
            .strokeWidth : -2.0
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        
        view.bringSubviewToFront(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Text Field begin editing")
        textField.text = ""
        activityButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Keyboard Notification Section
    
    func subscribeToKeyboardHideAndShowNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardHideAndShowNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if lowerText.isFirstResponder == true {
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
    
    func toggleTopAndBottomBars() {
        toolBar.isHidden = !toolBar.isHidden
        navigationBar.isHidden = !navigationBar.isHidden
    }
    
    // MARK: - MemeMe Methods
    
    func save() {
        let memedImage = generateMemedImage()
        let _ = Meme(upperText: upperText.text!, lowerText: lowerText.text!, image: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        toggleTopAndBottomBars()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toggleTopAndBottomBars()
        
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
    // This method launches the Font menu so that users may select a different font.
    
    @IBAction func fontButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "fontTableID") as? FontTableViewController else {
            return
        }
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
    }
    
    // Uses the FontProtocal defined in the FontTableViewController to pass the selected font name back to this controller
    func getFont(font: String) {
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 100
        myShadow.shadowOffset = CGSize(width: 10, height: 10)
        myShadow.shadowColor = UIColor.black
        
        configureTextField(textField: upperText, fontName: font)
        configureTextField(textField: lowerText, fontName: font)
    }

}
