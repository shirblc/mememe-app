#  MemeMe

## Description

MemeMe is an app designed to let you turn any photo into a meme. Simply open the photo in the app, add your text and share it with your friends!

## Requirements

- macOS
- Xcode
- Optional: an iPhone/iPad, if you want to test it on an actual device (rather than the simulator).

* The app was tested on a device running the latest iOS 14.4 Developer Beta. It should work with versions prior to iOS 14, though, so if you encounter any issues, feel free to open an issue so that I can look into it.

## Installaton and Usage

1. Download or clone the repo.
2. cd into the project directory.
3. Open MemeMe.xcodeproj.
4. Click the build button and use the app on your device / in the built-in simulator.

## Contents

The project currently contains two ViewControllers, with two custom classes:

1. **MemeViewController** - The main ViewController. Contains the the meme creator: the image, the text fields, the buttons and all of their functionality.
2. **LimitedLibraryViewController** - The LimitedLibrary ViewController. Meant for cases in which the user gives the app access only to specific photos (iOS14+). When given limited access, the ViewController displays all the images the user chose to give access to. It also handles user selection or cancellation, using a delegate (see `LimitedLibraryViewControllerDelegate` for details).

## Known Issues

There are no current issues at the time.


