//
//  ViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 03/01/2021.
//

import UIKit
import AVFoundation
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var memePhoto: UIImageView!
    let userPhotoLibrary = PHPhotoLibrary.shared()
    var alertController = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
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
            // TODO: Display only selected assets
            case .limited:
                openPhotos()
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
                PHImageManager.default().requestImage(for: image[0], targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: nil, resultHandler: {
                    ( finalImage, info ) in self.memePhoto.image = finalImage
                })
            }
        }
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
        picker.dismiss(animated: true, completion: nil)
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
}

