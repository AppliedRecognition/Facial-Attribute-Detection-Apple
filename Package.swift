// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FacialAttributeDetection",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FacialAttributeDetectionCore",
            targets: ["FacialAttributeDetectionCore"]),
        .library(name: "FaceCoveringDetection", targets: ["FaceCoveringDetection"]),
        .library(name: "EyewearDetection", targets: ["EyewearDetection"])
    ],
    dependencies: [
        .package(url: "https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/AppliedRecognition/Face-Detection-RetinaFace-Apple.git", .upToNextMajor(from: "1.0.5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FacialAttributeDetectionCore",
            dependencies: [
                .product(name: "VerIDCommonTypes", package: "Ver-ID-Common-Types-Apple")
            ]),
        .target(
            name: "FaceCoveringDetection",
            dependencies: [
                "FacialAttributeDetectionCore"
            ],
            resources: [.process("Resources")]),
        .target(
            name: "EyewearDetection",
            dependencies: [
                "FacialAttributeDetectionCore"
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "FacialAttributeDetectionTests",
            dependencies: [
                "FacialAttributeDetectionCore",
                "FaceCoveringDetection",
                "EyewearDetection",
                .product(name: "VerIDCommonTypes", package: "Ver-ID-Common-Types-Apple"),
                .product(name: "FaceDetectionRetinaFace", package: "Face-Detection-RetinaFace-Apple")
            ],
            resources: [
                .process("Resources")
            ]),
    ]
)
