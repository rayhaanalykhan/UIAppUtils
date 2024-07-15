//
//  AppUtils.swift
//
//  Created by rayhaanalykhan on 11/06/2024.
//
//  This file is part of AppUtils. For licensing information, see the LICENSE file.
//

import AVFoundation

/// Utility class for logical encapsulation of custom types/enums within the `UIAppUtils` namespace, ignore this class.
///
/// Ignore this class as it is made so that the user doesn't see unnecessary things in autocomplete of Xcode.
public class ZippedUIAppUtils {
    
    private init() { }
    
    /// Enum representing different types of media.
    public enum MediaType: String {
        
        /// Represents access to the microphone.
        case audio = "Microphone"
        
        /// Represents access to the camera.
        case video = "Camera"
        
        /// Converts the media type to the corresponding `AVMediaType`.
        var avMediaType: AVMediaType {
            switch self {
            case .audio:
                return .audio
            case .video:
                return .video
            }
        }
    }
    
    /// Enum representing different options for handling mail if device is not capable of sending emails using MFMailComposeViewController.
    public enum ExternalMailOption: String {
        
        /// Show a confirmation prompt before accessing external mail.
        case showConfirmationPrompt
        
        /// Go directly to external mail without confirmation.
        case goDirectlyToExternalMail
        
        /// Do not go to external mail.
        case doNotGoToExternalMail
    }
    
    /// Enum representing different options for handling previously denied permissions.
    public enum PreviouslyDeniedOption: String {
        
        /// Show an alert to the user.
        case showAlert
        
        /// Show an option to navigate to app settings.
        case showGoToSettingsOption
        
        /// Do nothing and continue without any prompt.
        case doNothing
    }
}
