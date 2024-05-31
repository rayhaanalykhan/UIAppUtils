//
//  AppUtils.swift
//
//  Created by rayhaanalykhan on 31/05/2024.
//
//  This file is part of AppUtils. For licensing information, see the LICENSE file.
//

#if canImport(UIKit)
import UIKit
import AVFoundation
import StoreKit

/// `AppUtils` is a utility class providing various methods for common tasks related to the UI and app permissions and functionality.
public class AppUtils {
    
    private init() { }
    
    /// Returns the current version number of the app, or a default message if not found.
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Version not available"
    }
    
    /// Returns the current build number of the app, or a default message if not found.
    static var appBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Build number not available"
    }
    
    /// Returns the topmost view controller in the app's view hierarchy.
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
    
    /// Takes a screenshot of the current key window's view hierarchy.
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
            return
        }
        openURL(url: appSettingsURL)
    }
    
    /// Opens the given URL if it can be opened.
    ///
    /// This function checks if the provided URL can be opened using the `canOpenURL(_:)` method.
    /// If the URL can be opened, it is opened using the `open(_:options:completionHandler:)` method.
    ///
    /// - Parameter url: The URL to be opened.
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
    /// If the URL cannot be opened or the device does not support opening it, nothing happens.
    ///
    /// - SeeAlso: `canOpenURL(_:)`, `open(_:options:completionHandler:)`
    public static func openURL(url: URL) {
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    ///                             for granting permission if permission has been previously denied (default is true).
    ///   - permission: A closure to be called with the result of the permission check, returning true if permission
    ///                 was granted and false otherwise.
    ///
    public static func checkMediaPermission(mediaType: AVMediaType, showGoToAppSettingsOption: Bool = true, permission: @escaping(_ granted: Bool) -> Void) {
        
        // Check the authorization status for the specified media type
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        
        // Define a variable to hold the hardware type based on the media type
        var permissionHardware: String?
        
        // Determine the hardware type based on the media type
        switch mediaType {
            
        case .video:
            permissionHardware = "Camera"
            
        case .audio:
            permissionHardware = "Microphone"
            
        default:
            permissionHardware = mediaType.rawValue
        }
        
        // If the permission hardware type is not defined, display an error alert and return
        guard let permissionHardware else {
            
            let alert = UIAlertController(title: "Error", message: "Hardware configuration is not defined", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
            
            permission(false)
            
            return
        }
        
        // Handle different authorization statuses
        switch authorizationStatus {
            
            // If media permission is authorized, call the completion handler with true
        case .authorized:
            permission(true)
            break
            
            // If media permission is denied, show appropriate alerts and call the completion handler with false
        case .denied:
            
            if showGoToAppSettingsOption {
                
                let alert = UIAlertController(title: "Permission Denied", message: "You previously denied \(permissionHardware) permission. Would you like to grant the \(permissionHardware) permission now?\n\nNote: Changing permission will cause your app to refresh.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                    AppUtils.goToAppSettings()
                })
                alert.addAction(UIAlertAction(title: "No", style: .default))
                getTopMostViewController()?.present(alert, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "Permission Denied", message: "You previously denied \(permissionHardware) permission. Please go to settings and grant the \(permissionHardware) permission to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
            
            permission(false)
            
            break
            
            // If media permission is undetermined, prompt the user for permission and call the completion handler accordingly
        case .notDetermined:
            
            DispatchQueue.main.async {
                
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    
                    if granted {
                        permission(true)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Permission Denied", message: "Cannot proceed without granting \(permissionHardware) permission", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        getTopMostViewController()?.present(alert, animated: true, completion: nil)
                        
                        permission(false)
                    }
                }
            }
            break
            
            // If media permission is restricted, show an appropriate alert and call the completion handler with false
        case .restricted:
            
            let alert = UIAlertController(title: "Hardware Access Restricted", message: "Your \(permissionHardware) access is restricted. Please contact your device administrator or adjust your settings to grant the necessary access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
            
            permission(false)
            
            break
            
            // Handle any future unknown cases
        @unknown default:

            let alert = UIAlertController(title: "Unknown Error", message: "An unknown error occurred while checking \(permissionHardware) permissions. Please try again later or contact support for assistance.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
            
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
        
        if #available(iOS 14.0, *) {
            
            guard let windowScene = UIApplication.shared.windows.first?.windowScene else {
                return
            }
            
            SKStoreReviewController.requestReview(in: windowScene)
            
        } else {
            
            SKStoreReviewController.requestReview()
        }
    }
}
#endif
