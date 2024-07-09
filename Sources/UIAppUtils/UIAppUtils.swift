//
//  AppUtils.swift
//
//  Created by rayhaanalykhan on 31/05/2024.
//
//  This file is part of AppUtils. For licensing information, see the LICENSE file.
//

#if canImport(UIKit)
import UIKit
import StoreKit
import AVFoundation
import MessageUI
import CoreLocation

public class UIAppUtils {
    
    private init() { }
    
    private static var emailCompletion: ((_ result: MFMailComposeResult) -> Void)?
    
    private static var locationCompletion: ((_ granted: Bool) -> Void)?
    
    /// Returns the current version number of the app, or a default message if not found.
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Version not available"
    }
    
    /// Returns the current build number of the app, or a default message if not found.
    static var appBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Build number not available"
    }
    
    /// Retrieve the topmost view controller in the app's current key window's view hierarchy.
    ///
    /// This function traverses the view controller hierarchy starting from the root view controller of the key window,
    /// and iteratively finds the topmost view controller. It considers navigation controllers, tab bar controllers,
    /// and presented view controllers to determine the topmost view controller.
    ///
    /// - Warning: This function may not behave as expected on iPads with multiple scenes/windows, as it captures only
    ///            the first window in the application's `windows` array.
    ///
    /// - Returns: The topmost view controller, or nil if no view controller is found.
    public static func getTopMostViewController() -> UIViewController? {
        
        var currentViewController = UIApplication.shared.windows.first?.rootViewController
        
        while true {
            if let nav = currentViewController as? UINavigationController {
                currentViewController = nav.visibleViewController
            } else if let tab = (currentViewController as? UITabBarController)?.selectedViewController {
                currentViewController = tab
            } else if let presented = currentViewController?.presentedViewController {
                currentViewController = presented
            } else {
                break
            }
        }
        return currentViewController
    }
    
    /// Capture a screenshot of the app's current key window's view hierarchy.
    ///
    /// This function captures the visual content of the key window by drawing its view hierarchy into an image context.
    /// The resulting image is returned as a `UIImage`.
    ///
    /// - Warning: This function may not behave as expected on iPads with multiple scenes/windows, as it captures only
    ///            the first window in the application's `windows` array.
    ///
    /// - Returns: An optional `UIImage` representing the screenshot of the current key window's view hierarchy.
    public static func takeScreenshot() -> UIImage? {
        
        guard let window = UIApplication.shared.windows.first else {
            print("UIAppUtils -> Error: No window found")
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    /// Opens the Settings app.
    ///
    /// This function opens the main settings screen of the device.
    ///
    public static func goToSettingsApp() {
        
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else {
            print("UIAppUtils -> Error: Failed to create URL for settings app")
            return
        }
        openURL(url: settingsAppURL)
    }
    
    /// Opens the settings for the current app within the Settings app.
    ///
    /// This function navigates to the specific settings for your app within the Settings app.
    ///
    public static func goToAppSettings() {
        
        guard let appBundleIdentifier = Bundle.main.bundleIdentifier,
              let appSettingsURL = URL(string: UIApplication.openSettingsURLString + appBundleIdentifier) else {
            print("UIAppUtils -> Error: Failed to retrieve app bundle identifier or create URL for app settings")
            return
        }
        openURL(url: appSettingsURL)
    }
    
    /// Opens the given URL if it can be opened.
    ///
    /// This function checks if the provided URL can be opened using the `canOpenURL(_:)` method.
    /// If the URL can be opened, it is opened using the `open(_:options:completionHandler:)` method.
    /// If the URL cannot be opened or the device does not support opening it, nothing happens.
    ///
    /// - Parameter url: The URL to be opened.
    /// - Returns: A boolean value indicating whether the URL could be opened (`true`) or not (`false`).
    ///
    /// - Note: This function allows your app to open various types of URLs, including external URLs (e.g., web links) and custom URL schemes.
    /// It first checks if the device is capable of opening the given URL using the `canOpenURL(_:)` method.
    /// If the device supports opening the URL, it is opened using the `open(_:options:completionHandler:)` method.
    /// The behavior of opening the URL depends on the type of URL being opened:
    /// - HTTP/HTTPS URLs typically open in the default web browser app outside of your app.
    /// - Custom URL schemes are registered by your app to perform specific actions or open specific content within your app.
    /// - Settings URLs are used to open specific sections of the Settings app on the device.
    /// - Deep links are URLs that are designed to navigate to a specific piece of content within your app.
    /// - Third-Party App URLs allow opening specific content or performing actions within third-party apps, if installed on the device.
    ///
    /// - SeeAlso: `canOpenURL(_:)`, `open(_:options:completionHandler:)`
    ///
    /// - Important: The return value of this function is `@discardableResult`, indicating that it can be safely ignored if not needed.
    @discardableResult
    public static func openURL(url: URL) -> Bool {
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
            
        } else {
            print("UIAppUtils -> Error: Cannot open URL \(url.absoluteString)")
            return false
        }
    }
    
    /// Checks the permission status for accessing media hardware.
    ///
    /// This function handles all authorization statuses, including authorized, denied, not determined,
    /// and restricted. If permission is denied or restricted, appropriate alert messages are displayed
    /// to the user. If the authorization status is not determined, the user is prompted for permission.
    ///
    /// - Parameters:
    ///   - mediaType: The type of media hardware to check permission for, such as video or audio.
    ///   - showGoToAppSettingsOption: A boolean value indicating whether to show an option to navigate to app settings
    ///                             for granting permission if permission has been previously denied.
    ///   - permission: A closure to be called with the result of the permission check, returning true if permission
    ///                 was granted and false otherwise.
    ///
    public static func checkMediaPermission(mediaType: ZippedUIAppUtils.MediaType, showGoToAppSettingsOption: Bool, permission: @escaping(_ granted: Bool) -> Void) {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType.avMediaType)
        
        switch authorizationStatus {
            
        case .authorized:
            permission(true)
            break
            
        case .denied:
            
            if showGoToAppSettingsOption {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "Permission Denied",
                        message: "You previously denied \(mediaType.rawValue) permission. Would you like to grant the \(mediaType.rawValue) permission now?\n\nNote: Changing permission will cause your app to refresh.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                        goToAppSettings()
                    })
                    alert.addAction(UIAlertAction(title: "No", style: .default))
                    
                    getTopMostViewController()?.present(alert, animated: true, completion: nil)
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "Permission Denied",
                        message: "You previously denied \(mediaType.rawValue) permission. Please go to settings and grant the \(mediaType.rawValue) permission to continue",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    getTopMostViewController()?.present(alert, animated: true, completion: nil)
                }
            }
            
            permission(false)
            
            break
            
        case .notDetermined:
            
            DispatchQueue.main.async {
                
                AVCaptureDevice.requestAccess(for: mediaType.avMediaType) { granted in
                    
                    if granted {
                        permission(true)
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(
                                title: "Permission Denied",
                                message: "Cannot proceed without granting \(mediaType.rawValue) permission",
                                preferredStyle: .alert
                            )
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            getTopMostViewController()?.present(alert, animated: true, completion: nil)
                        }
                        
                        permission(false)
                    }
                }
            }
            break
            
        case .restricted:
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(
                    title: "Hardware Access Restricted",
                    message: "Your \(mediaType.rawValue) access is restricted. Please contact your device administrator or adjust your settings to grant the necessary access",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
            permission(false)
            
            break
            
            // Handle any future unknown cases
        @unknown default:
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(
                    title: "Unknown Error",
                    message: "An unknown error occurred while checking \(mediaType.rawValue) permissions. Please try again later or contact support for assistance.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
            permission(false)
            
            break
        }
    }

    
    /// Shows the app rating prompt to the user.
    ///
    /// - Note: This method should be called from the main thread and it may not always display the prompt immediately.
    ///         Depending on various factors determined by Apple, such as user engagement and frequency of requests,
    ///         the prompt may be displayed after a delay.
    /// - Warning: This function may not behave as expected on iPads with multiple scenes/windows, as it captures only
    ///            the first window in the application's `windows` array.
    public static func requestReview() {
        
        // Check if the device is running iOS 14 or later
        if #available(iOS 14.0, *) {
            
            guard let windowScene = UIApplication.shared.windows.first?.windowScene else {
                print("UIAppUtils -> Error: No windowScene found")
                return
            }
            SKStoreReviewController.requestReview(in: windowScene)
            
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    /**
     Opens the email intent from the specified view controller or the topmost view controller if not provided.
     
     - Parameters:
        - viewController: The view controller from which to present the mail compose view controller. Defaults to the topmost view controller.
        - externalMailOptions: An enum representing different options for handling mail if the device is not capable of sending emails using MFMailComposeViewController.
        - emailAddresses: An array of email addresses to set as recipients.
        - subject: The subject of the email.
        - body: The body of the email.
        - completion: An optional completion handler that is called with the result of the mail composition.
     
     The switch statement handles different outcomes of the mail composition:
        - `cancelled`: Mail cancelled
        - `saved`: Mail saved
        - `sent`: Mail sent
        - `failed`: Mail failed
        - `unknown`: Unknown mail compose result
     
     This function attempts to present the system's email composition interface (`MFMailComposeViewController`) from the specified or topmost view controller. If the device is not capable of sending emails using MFMailComposeViewController, you can specify alternative options using the `externalMailOptions` parameter. If `externalMailOptions` is set to proceed externally and no mail app is found, it prompts the user accordingly.
     
     - Important: The completion handler will only trigger if the email is sent within the app using `MFMailComposeViewController`.
     */
    public static func openEmailIntent(from viewController: UIViewController? = getTopMostViewController(), externalMailOptions: ZippedUIAppUtils.ExternalMailOptions, with emailAddresses: [String], subject: String?, body: String?, completion: ((_ result: MFMailComposeResult) -> Void)? = nil) {
        
        guard let viewController else {
            print("UIAppUtils -> Error: View controller is nil.")
            return
        }
        
        // Check if the device is capable of sending emails using MFMailComposeViewController.
        if MFMailComposeViewController.canSendMail() {
            
            // Store the completion handler to be used later.
            emailCompletion = completion
            
            let composeVC = MFMailComposeViewController()
            
            // Set the delegate to handle mail compose result callbacks.
            let mailDelegate = MailComposeDelegateHandler.shared
            mailDelegate.completionHandler = completion
            composeVC.mailComposeDelegate = mailDelegate
            
            composeVC.setToRecipients(emailAddresses)
            composeVC.setSubject(subject ?? "")
            composeVC.setMessageBody(body ?? "", isHTML: false)
            
            viewController.present(composeVC, animated: true)
            
        } else {
            
            switch externalMailOptions {
                
            case .showConfirmationPrompt:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "Mail Services Unavailable",
                        message: "It seems you've not setup mail services on your device. Would you like to open the mail app externally to send an email?",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                        sendMailOnExternalApp(viewController: viewController, emailAddresses: emailAddresses, subject: subject ?? "", body: body ?? "")
                    })
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default))
                    
                    viewController.present(alert, animated: true, completion: nil)
                }
                
            case .goDirectlyToExternalMail:
                
                sendMailOnExternalApp(viewController: viewController, emailAddresses: emailAddresses, subject: subject ?? "", body: body ?? "")
                
            case .doNotGoToExternalMail:
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Your device is currently unable to send emails using the default email app. Please configure your email settings or try again later.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    viewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Private static function to send an email using the external mail app if device is not capable of sending emails using MFMailComposeViewController.
    private static func sendMailOnExternalApp(viewController: UIViewController, emailAddresses: [String], subject: String, body: String) {
        
        // Create URL components for the mailto scheme.
        var urlComponents = URLComponents()
        
        urlComponents.scheme = "mailto"
        urlComponents.path = emailAddresses.joined(separator: ",")
        urlComponents.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        
        if let emailURL = urlComponents.url {
            
            if openURL(url: emailURL) == false {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "No Email App Found",
                        message: "No email app was found on this device",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    viewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    public static func checkLocationPermission(from viewController: UIViewController? = UIAppUtils.getTopMostViewController(), permission: @escaping(_ granted: Bool) -> Void) {
        
        guard let viewController else {
            print("UIAppUtils -> Error: View controller is nil.")
            return
        }
        
        // Store the completion handler to be used later.
//        locationCompletion = permission
        
//        let locationManager = CLLocationManager()
//        
//        // Set the delegate to handle mail compose result callbacks.
        LocationPermissionDelegateHandler.shared.completionHandler = permission
//        locationManager.delegate = locationDelegate
        
//        DispatchQueue.main.async {
//            locationManager.requestWhenInUseAuthorization()
//        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate Methods

// Internal delegate handler class to manage MFMailComposeViewControllerDelegate methods
class LocationPermissionDelegateHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationPermissionDelegateHandler()
    
    var completionHandler: ((_ granted: Bool) -> Void)?
    
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        
        
        
        
        
        DispatchQueue.main.async { [self] in
            locationManager.requestWhenInUseAuthorization()
            
            locationManager.delegate = self
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(status: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationChange(status: status)
    }
    
    func handleAuthorizationChange(status: CLAuthorizationStatus) {
        
        switch status {
            
        case .authorizedAlways, .authorizedWhenInUse:
            // Permission granted
            completionHandler?(true)
            
        case .denied:
            // Permission denied
            DispatchQueue.main.async {
                
                let alert = UIAlertController(
                    title: "Location Permission Denied",
                    message: "You denied location permission. Please go to settings and grant location permission to continue",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                UIAppUtils.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
            completionHandler?(true)
            
        case .notDetermined, .restricted:
            // Do nothing here, continue to handle in original function
            break
            
        @unknown default:
            // Handle any future unknown cases
            DispatchQueue.main.async {
                
                let alert = UIAlertController(
                    title: "Unknown Error",
                    message: "An unknown error occurred while checking location permissions. Please try again later or contact support for assistance.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                UIAppUtils.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
            completionHandler?(false)
        }
        
    }
}

// MARK: - MFMailComposeViewControllerDelegate Methods

// Internal delegate handler class to manage MFMailComposeViewControllerDelegate methods
class MailComposeDelegateHandler: NSObject, MFMailComposeViewControllerDelegate {
    
    static let shared = MailComposeDelegateHandler()
    
    var completionHandler: ((_ result: MFMailComposeResult) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) {
            
            if let error {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(
                        title: "Mail Compose Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    UIAppUtils.getTopMostViewController()?.present(alert, animated: true, completion: nil)
                }
                
            } else {
                self.completionHandler?(result)
            }
        }
    }
}


#endif
