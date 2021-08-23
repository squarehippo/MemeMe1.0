//
//  ViewController.swift
//  MemeMeWarmUp
//
//  Created by Brian Wilson on 8/21/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIToolbarDelegate {
    
    // MARK: - Varibles

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var upperText: UITextField!
    @IBOutlet weak var lowerText: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var shouldMoveViewForTextField = false
    
    let memeTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.strokeWidth : -2.0
    ]
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upperText.delegate = self
        lowerText.delegate = self
        
        
        configureTextField()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Textfield Methods
    
    func configureTextField() {
        upperText.defaultTextAttributes = memeTextAttributes
        lowerText.defaultTextAttributes = memeTextAttributes
        
        upperText.textAlignment = .center
        lowerText.textAlignment = .center
        
        lowerText.backgroundColor = .clear
        upperText.backgroundColor = .clear
        
        upperText.text = "upper"
        lowerText.text = "lower"
        
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
        let ac = UIActivityViewController(activityItems: memedImage, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}



