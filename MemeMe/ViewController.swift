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
                        print("Photos access has been denied. Please enable Photos access in Settings -> Privacy -> Photos.")
                    }
                })
            // If the user denied Photos access, alert the user they've denied permission.
            case .denied:
                print("Photos access has been denied. Please enable Photos access in Settings -> Privacy -> Photos.")
            // If the app has limited photo access, show the library.
            // TODO: Display only selected assets
            case .limited:
                openPhotos()
            // If Photos access has been restricted, alert the user.
            case .restricted:
                print("Photos access has been restricted. Please enable Photos access in Settings -> Privacy -> Photos.")
            // For any other authorization status, alert the user that something went wrong.
            @unknown default:
                print("An unknown error occurred.")
        }
    }
    
    // openPhotos
    // Presents the Photos library for the user to select a photo.
    func openPhotos() {
        // Configuration for the picker
        var pickerConfig = PHPickerConfiguration()
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
        print("picked")
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
                        print("Camera access has been denied. Please enable camera access in Settings -> Privacy -> Camera.")
                    }
                })
            // If the user denied camera access, alert the user they've denied permission.
            case .denied:
                print("Camera access has been denied. Please enable camera access in Settings -> Privacy -> Camera.")
            // If camera access has been restricted, alert the user.
            case .restricted:
                print("Camera access has been restriced. Please adjust camera access settings in Settings -> Privacy -> Camera.")
            // For any other authorization status, alert the user that something went wrong.
            @unknown default:
                print("An unknown error occurred.")
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
            print("Camera is not currently available.")
        }
    }
}

