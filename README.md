# AppUtils

AppUtils is a robust UIKit utility library specializing in app-wide functionalities, designed to simplify app development.

## Features

- Retrieve app version and build numbers.
- Get the topmost view controller in the app's view hierarchy.
- Take a screenshot of the current key window.
- Open the Settings app or the app-specific settings.
- Check media permissions for camera and microphone.
- Request an app rating from the user.

## Installation

### Swift Package Manager (SPM) using Xcode

To integrate AppUtils into your Xcode project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Navigate to the menu bar and click `File` > `Swift Packages` > `Add Package Dependency...`.
3. In the search bar of the new window that appears, paste the following URL: `https://github.com/rayhaanalykhan/AppUtils.git`
4. Follow the on-screen instructions to choose the package options and the version you want to integrate.
5. Once completed, Xcode will download the package and add it to your project navigator.

## Usage

To use AppUtils in your project, you can call its static methods directly:

1. **Retrieve App Version and Build:**

    Get the current version and build number of the app:

    ```swift
    print("App Version: \(AppUtils.appVersion)")
    ```    
    ```swift
    print("App Build: \(AppUtils.appBuild)")
    ```
    
2. **Get Topmost View Controller:** 
    
    Retrieve the topmost view controller in the app's current key window's view hierarchy.

    ```swift 
    if let topVC = AppUtils.getTopMostViewController() { 
        topVC.present(someVC, animated: true, completion: nil)
     } else { 
        print("No view controller found.")
     }
    ```
    ```swift 
    // Alternate
    AppUtils.getTopMostViewController()?.present(UIViewController(), animated: true, completion: nil) // replace UIViewController() with the controller you want to show
    ```

3. **Take a Screenshot:** 

    Capture a screenshot of the app's current key window's view hierarchy.

    ```swift 
    if let screenshot = AppUtils.takeScreenshot() { 
        // someImageView.image = screenshot
        print("Screenshot taken.") 
    } else { 
        print("Could not take screenshot.") 
    }
    ```
    ```swift 
    // Alternate
    UIImageView().image = AppUtils.takeScreenshot() ?? UIImage() // replace UIImageView() with the your imageView.
    ```

4. **Open Settings:**

    Open the main settings app or the app-specific settings.

    ```swift
    AppUtils.goToSettingsApp() // Open the 'Settings' app of your device

    AppUtils.goToAppSettings() // Open the settings of your app
    ```
    
5. **Check Media Permissions:** 

    Check for camera or microphone permissions and handle the response.

    The function handles all authorization statuses and shows appropriate alert messages for all cases (not determine, first-time denied, previously denied, restricted, and unknown).

    ```swift 
    AppUtils.checkMediaPermission(mediaType: .video) { granted in // video or audio permission
        if granted { 
            print("Camera access granted.") 
        } else { 
            print("Camera access denied.") 
        } 
    }
    ```

6. **Request App Review:** 

    Prompt the user to rate your app. 

    ```swift 
    AppUtils.requestReview()
    ```

## License

AppUtils is released under the MIT License. See the [LICENSE](https://github.com/rayhaanalykhan/AppUtils/blob/main/LICENSE.md) file for further details.

## Contribution

Contributors are welcomed to fork the project and submit pull requests. Please include unit tests if possible for any new or existing functionality. Also, update the README accordingly.

## Contact

For further information, contact me via email [rayhaanalykhan@gmail.com](mailto:rayhaanalykhan@gmail.com).

