//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 03/01/2021.
//

import UIKit
import AVFoundation
import PhotosUI

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UITextFieldDelegate, LimitedLibraryViewControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var memePhoto: UIImageView!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var memeView: UIView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet var bottomTextFieldConstraint: NSLayoutConstraint!
    
    // Variables & Constants
    let userPhotoLibrary = PHPhotoLibrary.shared()
    var alertController = UIAlertController()
    var myMemes: [Meme] = []
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var finalMeme: UIImage
    }

    // MARK: View-related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the text fields
        setUpTextField(textField: topTextField, value: "TOP")
        setUpTextField(textField: bottomTextField, value: "BOTTOM")
        NotificationCenter.default.addObserver(self, selector: #selector(moveView(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Once the transition has completed, update the text fields' constraints to ensure they're shown correctly.
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in if let image = self.memePhoto.image {
                self.setConstraints(finalImage: image)
            }
        })
    }
    
    // MARK: Meme from Photos methods
    // checkPhotosPermission
    // Checks that the app has permission to access the user's Photos library.
    @IBAction func checkPhotosPermission(_ sender: Any) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            // If the app has permission for accessing Photos, open the picker
            case .authorized:
                openPhotos()
            // If the user hasn't given/denied permission, ask for permission. If Photos access is granted, open Photos
            // for the user to select a photo. If the user selected limited access, show them the limited picker in order
            // to select photos. Otherwise alert the user they've denied permission.
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
                    if status == .authorized {
                        self.openPhotos()
                    }
                    else if status == .limited {
                        let selectPhotos = PHPhotoLibrary.shared()
                        selectPhotos.presentLimitedLibraryPicker(from: self)
                    }
                    else {
                        self.createErrorAlert(message: "Photos access has been denied. Please enable Photos access in Settings -> Privacy -> Photos.")
                    }
                })
            // If the user denied Photos access, alert the user they've denied permission.
            case .denied:
                createErrorAlert(message: "Photos access has been denied. Please enable Photos access in Settings -> Privacy -> Photos.")
            // If the app has limited photo access, show the library.
            case .limited:
                openLimitedPicker()
            // If Photos access has been restricted, alert the user.
            case .restricted:
                createErrorAlert(message: "Photos access has been restricted. Please enable Photos access in Settings -> Privacy -> Photos.")
            // For any other authorization status, alert the user that something went wrong.
            @unknown default:
                createErrorAlert(message: "An unknown error occurred.")
        }
    }
    
    // openPhotos
    // Presents the Photos library for the user to select a photo.
    func openPhotos() {
        // Configuration for the picker
        var pickerConfig = PHPickerConfiguration(photoLibrary: userPhotoLibrary)
        pickerConfig.filter = .images
        pickerConfig.selectionLimit = 1
        // Create and launch photo picker
        let photoPicker = PHPickerViewController(configuration: pickerConfig)
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
    // picker
    // Protocol: PHPickerViewControllerDelegate
    // Responsible for handling the photo the user picked.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Check the user made a selection
        if results.count > 0 {
            // Check there's an identifier for the selected photo
            if let asset = results[0].assetIdentifier {
                // Fetch the selected photo and display it
                let image = PHAsset.fetchAssets(withLocalIdentifiers: [ asset ], options: nil)
                PHImageManager.default().requestImage(for: image[0], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {
                    ( finalImage, info ) in self.memePhoto.image = finalImage
                    // set the text constraints according to the image size
                    if let finalImage = finalImage, let _ = self.memePhoto.image {
                        self.setConstraints(finalImage: finalImage)
                    }
                })
                self.toggleTextFields(visible: true)
                self.toggleButtons(enable: true)
            }
        }
    }
    
    // openLimitedPicker
    // If the app was given limited Photos permission (iOS14+), shows the LimitedLibraryViewController. This controller automatically shows only assets to which the app was given permission.
    func openLimitedPicker() {
        var collectionView: LimitedLibraryViewController
        collectionView = self.storyboard?.instantiateViewController(withIdentifier: "LimitedLibraryVC") as! LimitedLibraryViewController
        collectionView.delegate = self
        
        present(collectionView, animated: true, completion: nil)
    }
    
    // userDidSelectImage
    // Protocol: LimitedLibraryViewControllerDelegate
    // Responsible for handling the photo the user picked.
    func userDidSelectImage(_ controller: LimitedLibraryViewController) {
        if let image = controller.selectedImage {
            PHImageManager.default().requestImage(for: image, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {
                ( finalImage, info ) in
                // Check if the image is in the cloud; in limited library access the app can't fetch the full-size picture from the cloud, so the user needs to be alerted to download the photo and try again.
                if let info = info, let _ = info[AnyHashable("PHImageResultIsInCloudKey")] {
                    self.createErrorAlert(message: "The image is in the cloud. Please download it and then try again.")
                }
                // Otherwise, set the UI with the newly selected image
                else {
                    self.memePhoto.image = finalImage
                    // set the text constraints according to the image size
                    if let finalImage = finalImage, let _ = self.memePhoto.image {
                        self.setConstraints(finalImage: finalImage)
                    }
                    self.toggleTextFields(visible: true)
                    self.toggleButtons(enable: true)
                }
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    // userDidCancel
    // Protocol: LimitedLibraryViewControllerDelegate
    // Responsible for dismissing the LimitedLibraryViewController upon user cancellation.
    func userDidCancel(_ controller: LimitedLibraryViewController, sender: Any) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: Meme from camera methods
    // checkCameraPermission
    // Checks that the app has permission to access the camera.
    @IBAction func checkCameraPermission(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            // If the app has permission for camera usage, open the camera
            case .authorized:
                openCamera()
            // If the user hasn't given/denied permission, ask for permission. If camera access is granted, open the
            // camera. Otherwise alert the user they've denied permission.
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                    if granted {
                        self.openCamera()
                    }
                    else {
                        self.createErrorAlert(message: "Camera access has been denied. Please enable camera access in Settings -> Privacy -> Camera.")
                    }
                })
            // If the user denied camera access, alert the user they've denied permission.
            case .denied:
                createErrorAlert(message: "Camera access has been denied. Please enable camera access in Settings -> Privacy -> Camera.")
            // If camera access has been restricted, alert the user.
            case .restricted:
                createErrorAlert(message: "Camera access has been restriced. Please adjust camera access settings in Settings -> Privacy -> Camera.")
            // For any other authorization status, alert the user that something went wrong.
            @unknown default:
                createErrorAlert(message: "An unknown error occurred.")
        }
    }
    
    // openCamera
    // Presents the Camera Image Picker Controller for the user to take a photo
    func openCamera() {
        // Check that the camera is available; if it is, present the camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPickerController = UIImagePickerController()
            cameraPickerController.delegate = self
            cameraPickerController.sourceType = .camera
            present(cameraPickerController, animated: true, completion: nil)
        }
        // Otherwise alert the user the camera isn't avilable.
        else {
            createErrorAlert(message: "Camera is not currently available.")
        }
    }
    
    // imagePickerController
    // Protocol: UIImagePickerControllerDelegate
    // Gets the selected image and dismisses the picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        memePhoto.image = selectedImage
        self.toggleTextFields(visible: true)
        self.toggleButtons(enable: true)
        // set the text constraints according to the image size
        if let selectedImage = selectedImage, let _ = self.memePhoto.image {
            self.setConstraints(finalImage: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Textfield-related methods
    // setUpTextField
    // Sets up the text fields to their initial state.
    func setUpTextField(textField: UITextField, value: String) {
        textField.autocapitalizationType = .allCharacters
        textField.textAlignment = .center
        textField.isHidden = true
        textField.text = value
        textField.delegate = self
        textField.textColor = .white
        
        let textFieldAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "impact", size: 40),
            NSAttributedString.Key.strokeWidth: -1
        ]
        textField.defaultTextAttributes = textFieldAttributes
    }
    
    // toggleTextFields
    // Turns the text fields visible / hidden (depending on the user's state).
    func toggleTextFields(visible: Bool) {
        topTextField.isHidden = !visible
        bottomTextField.isHidden = !visible
    }
    
    // textFieldShouldReturn
    // Protocol: UITextFieldDelegate
    // Dismisses the keyboard upon pressing 'return'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.frame.origin.y = 0
        return true
    }
    
    // moveView
    // Moves the view to ensure the keyboard isn't covering the text field.
    @objc func moveView(keyboardNotification notification:Notification) {
        if let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey], bottomTextField.isEditing {
            view.frame.origin.y -= (keyboard as? CGRect)?.height ?? 0
        }
    }
    
    // MARK: Meme Methods
    // createMeme
    // Creates the meme based on the image and text currently onscreen.
    func createMeme() -> UIImage {
        // Create the meme
        UIGraphicsBeginImageContext(self.view.frame.size)
        memeView.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let meme = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return meme
    }
    
    // shareMeme
    // Shares the current edit as an image.
    @IBAction func shareMeme() {
        let meme = createMeme()
        let shareViewController = UIActivityViewController(activityItems: [ meme ], applicationActivities: nil)
        // Only save the meme if the meme was shared.
        shareViewController.completionWithItemsHandler = {
            (activity, completed, info, error) in
            if completed {
                self.myMemes.append(Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.memePhoto.image!, finalMeme: meme))
            }
        }
        present(shareViewController, animated: true, completion: nil)
    }
    
    // cancelMeme
    // Cancels the current edit.
    @IBAction func cancelMeme() {
        memePhoto.image = nil
        self.toggleTextFields(visible: false)
        self.toggleButtons(enable: false)
    }
    
    // MARK: Convenience Methods
    // createErrorAlert
    // Creates an error alert with the given message.
    func createErrorAlert(message: String) {
        alertController.title = "Error!"
        alertController.message = message
        // Check that there are no actions and only then add the "understood" button, in order to ensure there's only one button.
        if alertController.actions.isEmpty {
            let dismissAction = UIAlertAction(title: "Understood", style: .default, handler: {
                action in self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(dismissAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    // toggleButtons
    // Disables/enables the share and cancel buttons, depending on whether the user is editing an image.
    func toggleButtons(enable: Bool) {
        self.cancelButton.isEnabled = enable
        self.shareButton.isEnabled = enable
    }
    
    // setConstraints
    // Update the text fields' constraints.
    func setConstraints(finalImage: UIImage) {
        // If the device is currently in portrait mode.
        if self.view.frame.height > self.view.frame.width {
            // If the image is in landscape mode (meaning, wider than its height), get its actual height on the device and set the constraints.
            if(finalImage.size.width > finalImage.size.height) {
                // The photo's height * its resize value (by how much it was resized in order to fit into the screen).
                // Since landscape photos' width is always set to the maximum value the screen can afford (in portrait mode), the resize value is calculated by dividing the width of the UIImageView by the image's actual width.
                let imageHeight = self.memePhoto.image!.size.height * (self.memePhoto.frame.width / self.memePhoto.image!.size.width)
                self.topTextFieldConstraint.constant = -(imageHeight / 2) + 50
                self.bottomTextFieldConstraint.constant = (imageHeight / 2) - 50
            }
            // If the image is in portrait mode (meaning, higher than its width), set the constraints according to the UIImageView's height.
            else {
                self.topTextFieldConstraint.constant = -(self.memePhoto.frame.height / 2) + 50
                self.bottomTextFieldConstraint.constant = (self.memePhoto.frame.height / 2) - 50
            }
        }
        // If the device is currently in landscape mode, set the text fields' constraits according to the UIImageView's height.
        else {
            self.topTextFieldConstraint.constant = -(self.memePhoto.frame.height / 2) + 40
            self.bottomTextFieldConstraint.constant = (self.memePhoto.frame.height / 2) - 40
        }
    }
}

