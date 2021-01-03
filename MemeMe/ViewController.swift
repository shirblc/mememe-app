//
//  ViewController.swift
//  MemeMe
//
//  Created by Shir Bar Lev on 03/01/2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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

