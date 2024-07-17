// swift-tools-version: 5.7
//
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// This file is part of AppUtils. For licensing information, see the LICENSE file.
//

import PackageDescription

let package = Package(
    
    name: "UIAppUtils",
    
    platforms: [
        .iOS(.v13)
    ],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UIAppUtils",
            targets: ["UIAppUtils"]
        ),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UIAppUtils",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"])
            ]
        ),
        
        
        
        
        
//        .testTarget(
//            name: "AppUtilsTests",
//            dependencies: ["AppUtils"]),
    ]
)
