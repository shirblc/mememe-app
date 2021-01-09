//
//  MemeEditViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 03/01/2021.
//

import UIKit
import AVFoundation
import PhotosUI

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UITextFieldDelegate, LimitedLibraryViewControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var memePhoto: UIImageView!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var memeView: UIView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet var bottomTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet var topTFWidthConstraint: NSLayoutConstraint!
    @IBOutlet var bottomTFWidthConstraint: NSLayoutConstraint!
    
    // Variables & Constants
    let userPhotoLibrary = PHPhotoLibrary.shared()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alertController = UIAlertController()
    var memeIndex: Int?

    // MARK: View-related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(moveView(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Set up the text fields
        let topText: String = (memeIndex != nil && memeIndex! < appDelegate.memes.count) ? appDelegate.memes[memeIndex!].topText : "TOP"
        let bottomText: String = (memeIndex != nil && memeIndex! < appDelegate.memes.count) ? appDelegate.memes[memeIndex!].bottomText : "BOTTOM"
        
        setUpTextField(textField: topTextField, value: topText)
        setUpTextField(textField: bottomTextField, value: bottomText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set up the existing meme, if there is one
        if let memeIndex = memeIndex, memeIndex < appDelegate.memes.count {
            setUpMemeArea(finalImage: appDelegate.memes[memeIndex].originalImage)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // If the user is going back to the root view controller, reload the table/collection's data.
        if(self.isMovingFromParent) {
            let rootViewController = self.navigationController?.viewControllers[0]
            var tabBarController: UITabBarController
            
            // If the root view controller is the table view, set the tab bar controller to its tab bar controller
            if rootViewController is SentMemesTableViewController {
                tabBarController = (rootViewController as! SentMemesTableViewController).tabBarController!
            }
            // Otherwise it's the collection view controller, so set the tab bar controller to its tab bar controller
            else {
                tabBarController = (rootViewController as! SentMemesCollectionViewController).tabBarController!
            }
            
            // Get the table and collection view. The Sent Memes View Controllers are root VCs of navigation controllers, which are in turn controlled by a tab bar controller For each controller. So in order to get to the Sent Memes VC, we need to get through the Tab Bar Controller and then the UI Navigation Controller in order to get to the Sent Memes controller.
            let tableViewController = ((tabBarController.viewControllers![0]) as! UINavigationController).viewControllers[0] as! SentMemesTableViewController
            let collectionViewController = ((tabBarController.viewControllers![1]) as! UINavigationController).viewControllers[0] as! SentMemesCollectionViewController
            
            // Reload both the table's and the collection's data.
            tableViewController.tableView.reloadData()
            collectionViewController.collectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Once the transition has completed, update the text fields' constraints to ensure they're shown correctly.
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in if let _ = self.memePhoto.image {
                self.setConstraints()
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
                        DispatchQueue.main.async {
                            self.openPhotos()
                        }
                    }
                    else if status == .limited {
                        let selectPhotos = PHPhotoLibrary.shared()
                        selectPhotos.presentLimitedLibraryPicker(from: self)
                    }
                    else {
                        DispatchQueue.main.async {
                            self.createErrorAlert(message: "Photos access has been denied. Please enable Photos access in Settings -> Privacy -> Photos.")
                        }
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
                    ( finalImage, info ) in
                    // set up the meme area
                    if let finalImage = finalImage {
                        self.setUpMemeArea(finalImage: finalImage)
                    }
                })
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
                    // set up the meme area
                    if let finalImage = finalImage {
                        self.setUpMemeArea(finalImage: finalImage)
                    }
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
        // Check that the camera is available; if it is, check for the required permissions.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
                // If the app has permission for camera usage, open the camera
                case .authorized:
                    openCamera()
                // If the user hasn't given/denied permission, ask for permission. If camera access is granted, open the
                // camera. Otherwise alert the user they've denied permission.
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                        if granted {
                            DispatchQueue.main.async {
                                self.openCamera()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.createErrorAlert(message: "Camera access has been denied. Please enable camera access in Settings -> Privacy -> Camera.")
                            }
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
        // Otherwise alert the user the camera isn't avilable.
        else {
            createErrorAlert(message: "Camera is not currently available.")
        }
    }
    
    // openCamera
    // Presents the Camera Image Picker Controller for the user to take a photo
    func openCamera() {
        let cameraPickerController = UIImagePickerController()
        cameraPickerController.delegate = self
        cameraPickerController.sourceType = .camera
        present(cameraPickerController, animated: true, completion: nil)
    }
    
    // imagePickerController
    // Protocol: UIImagePickerControllerDelegate
    // Gets the selected image and dismisses the picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        // set up the meme area
        if let selectedImage = selectedImage {
            setUpMemeArea(finalImage: selectedImage)
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
            NSAttributedString.Key.font: UIFont(name: "impact", size: 40)!,
            NSAttributedString.Key.strokeWidth: -1
        ]
        textField.defaultTextAttributes = textFieldAttributes
        textField.adjustsFontSizeToFitWidth = true
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
                // If the user is editing an existing meme, edit the object.
                if self.memeIndex != nil {
                    self.appDelegate.memes.remove(at: self.memeIndex!)
                    self.appDelegate.memes.insert(Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.memePhoto.image!, finalMeme: meme), at: self.memeIndex!)
                }
                // Otherwise add a new one to the collection.
                else {
                    self.appDelegate.memes.append(Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.memePhoto.image!, finalMeme: meme))
                }
            }
        }
        present(shareViewController, animated: true, completion: nil)
    }
    
    // cancelMeme
    // Cancels the current edit.
    @IBAction func cancelMeme() {
        memePhoto.image = nil
        self.toggleUI(enable: false)
        
        self.navigationController?.popViewController(animated: true)
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
    
    // toggleUI
    // Disables/enables the share and cancel buttons, depending on whether the user is editing an image.
    // Turns the text fields visible / hidden (depending on the user's state).
    func toggleUI(enable: Bool) {
        // enable the buttons when the text fields are on, disable them when they're hidden
        self.cancelButton.isEnabled = enable
        self.shareButton.isEnabled = enable
        self.topTextField.isHidden = !enable
        self.bottomTextField.isHidden = !enable
    }
    
    // setConstraints
    // Update the text fields' constraints.
    func setConstraints() {
        var imageWidth: CGFloat;
        var imageHeight: CGFloat;
        
        // If the relation between the image's and the UIImageView's widths is larger than the one between their heights, that means the image's height is maxed. Thus, the actual width should be calculated using the heights.
        // In that case, the image's height will be identical to the frame's height.
        if self.memePhoto.frame.width / self.memePhoto.image!.size.width > self.memePhoto.frame.height / self.memePhoto.image!.size.height {
            // Get the actual width of the image on the screen.
            imageWidth = self.memePhoto.image!.size.width * (self.memePhoto.frame.height / self.memePhoto.image!.size.height)
            imageHeight = self.memePhoto.frame.height
        }
        // Otherwise, it's the width that's maxed, so just use the UIImageView's width.
        // In this case, the photo's height is calculated with: The photo's height * its resize value (by how much it was resized in order to fit into the screen). The resize value is calculated by dividing the width of the UIImageView by the image's actual width.
        else {
            imageWidth = self.memePhoto.frame.width
            // Get the actual height of the image on the screen.
            imageHeight = self.memePhoto.image!.size.height * (self.memePhoto.frame.width / self.memePhoto.image!.size.width)
        }
        
        // Set the width constraints.
        self.topTFWidthConstraint.constant = imageWidth
        self.bottomTFWidthConstraint.constant = imageWidth
        // Set the distance constraints to place the text fields appropriately.
        self.topTextFieldConstraint.constant = -(imageHeight / 2) + 50
        self.bottomTextFieldConstraint.constant = (imageHeight / 2) - 50
    }
    
    // setUpMemeArea
    // Set up the meme image, the text fields and the buttons.
    func setUpMemeArea(finalImage: UIImage) {
        self.memePhoto.image = finalImage
        
        // set the text constraints according to the image size
        if let _ = self.memePhoto.image {
            self.setConstraints()
        }
        
        // Enable the text fields and buttons
        self.toggleUI(enable: true)
    }
}

