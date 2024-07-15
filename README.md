# UIAppUtils

UIAppUtils is a robust UIKit utility library specializing in app-wide functionalities, designed to simplify app development.

## Features

- Retrieve app version and build numbers.
- Get the topmost view controller in the app's view hierarchy.
- Take a screenshot of the current key window.
- Open the Settings app or the app-specific settings.
- Open a given URL.
- Request an app rating from the user.
- Send an email.
- Check media permissions for camera and microphone.
- Check permission for notifications.
- Check permission for location.

## Installation

### Swift Package Manager (SPM) using Xcode

To integrate UIAppUtils into your Xcode project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Navigate to the menu bar and click `File` > `Swift Packages` > `Add Package Dependency...`.
3. In the search bar of the new window that appears, paste the following URL: `https://github.com/rayhaanalykhan/UIAppUtils.git`
4. Follow the on-screen instructions to choose the package options and the version you want to integrate.
5. Once completed, Xcode will download the package and add it to your project navigator.

## Usage

To use UIAppUtils in your project, you can call its static methods directly:

1. **Retrieve App Version and Build:**

    Get the current version and build number of the app:

    ```swift
    print("App Version: \(UIAppUtils.appVersion)")
    ```    
    ```swift
    print("App Build: \(UIAppUtils.appBuild)")
    ```
    
2. **Get Topmost View Controller:** 
    
    Retrieve the topmost view controller in the app's current key window's view hierarchy.

    ```swift 
    if let topVC = UIAppUtils.getTopMostViewController() {
        // replace UIViewController() with the controller you want to show 
        topVC.present(UIViewController(), animated: true, completion: nil) 
     } else { 
        print("No view controller found.")
     }
    ```
    ```swift 
    // Alternate
    // replace UIViewController() with the controller you want to show
    UIAppUtils.getTopMostViewController()?.present(UIViewController(), animated: true, completion: nil) 
    ```

3. **Take a Screenshot:** 

    Capture a screenshot of the app's current key window's view hierarchy.

    ```swift 
    if let screenshot = UIAppUtils.takeScreenshot() { 
        // replace UIImageView() with the your imageView.
        UIImageView().image = screenshot 
        print("Screenshot taken.") 
    } else { 
        print("Could not take screenshot.") 
    }
    ```
    ```swift 
    // Alternate
    // replace UIImageView() with the your imageView.
    UIImageView().image = UIAppUtils.takeScreenshot() ?? UIImage() 
    ```

4. **Open Settings:**

    Open the main settings app or the app-specific settings.

    ```swift
    UIAppUtils.goToSettingsApp() // Open the 'Settings' app of your device

    UIAppUtils.goToAppSettings() // Open the settings of your app
    ```
5. **Open a URL:**

    This function allows your app to open various types of URLs, including external URLs (e.g., web links) and custom URL schemes.
   
    ```swift 
    let url = URL(string: "https://github.com/rayhaanalykhan")!

    if UIAppUtils.openURL(url: url) {
        // Do something if url is opened
    } else {
        // Do something if url is cannot be opened
    }
    
    ```
    ```swift
    // Alternate
    let url = URL(string: "https://github.com/rayhaanalykhan")!
        
    UIAppUtils.openURL(url: url) // we can safely discard the result here.

    ```

6. **Request App Review:** 

    Prompt the user to rate your app. 

    ```swift 
    UIAppUtils.requestReview()
    ```
7. **Send an Email:**

    Enable users to compose and send emails directly from the app. Includes a delegate to report email status (saved, sent, cancelled, etc.). If the device cannot send emails using the default mail app or if it's not configured, provide an option to redirect to an external email app. For more details, see the [ExternalMailOptions](#external-mail-options) section.

    ```swift
    UIAppUtils.openEmailIntent(externalMailOptions: .showConfirmationPrompt, with: ["rayhaanalykhan@gmail.com"], subject: "", body: "") { result in
            
    switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Saved")
        case .sent:
            print("Sent")
        case .failed:
            print("Failed")
        @unknown default:
            print("Default")
        }
    }
    ```
    Note: The delegate method is not applicable when sending emails using an external mail app.

    ```swift
    // Alternate
    // You can even ignore the completion entirely.
    UIAppUtils.openEmailIntent(externalMailOptions: .showConfirmationPrompt, with: ["rayhaanalykhan@gmail.com"], subject: "", body: "")
    ```

8. **Check Media Permissions:** 

    Check for camera(video) or microphone(audio) permissions and handle the response.

    The function handles all authorization statuses and shows appropriate alert messages for all cases (not determine, first-time denied, previously denied, restricted, and unknown).

    ```swift 
    UIAppUtils.checkMediaPermission(mediaType: .video, showGoToAppSettingsOption: true) { granted in // show an option to navigate to app settings for if permission has been previously denied.
        if granted { 
            print("Camera access granted.") 
        } else { 
            print("Camera access denied.") 
        } 
    }
    ```

> ### ExternalMailOptions {#external-mail-options}
>
> The `ExternalMailOptions` enum provides options for managing email scenarios:
>
> - *showConfirmationPrompt*: Prompts for confirmation before accessing an external email app.
> - *goDirectlyToExternalMail*: Redirects to an external email app without confirmation.
> - *doNotGoToExternalMail*: Does not redirect to an external email app.
>
> Use these options to enhance user experience based on your app's needs.

## License

UIAppUtils is released under the MIT License. See the [LICENSE](https://github.com/rayhaanalykhan/UIAppUtils/blob/main/LICENSE.md) file for further details.

## Contribution

Contributors are welcomed to fork the project and submit pull requests. Please include unit tests if possible for any new or existing functionality. Also, update the README accordingly.

## Contact

For further information, contact me via email [rayhaanalykhan@gmail.com](mailto:rayhaanalykhan@gmail.com).

