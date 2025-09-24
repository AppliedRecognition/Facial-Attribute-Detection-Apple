# Facial Attribute Detection for iOS

iOS library with modules that detect facial attributes. Currently the library contains modules for face covering detection and glasses/sunglasses detection.

## Installation

The library is distributed using Swift Package Manager. Add package from `https://github.com/AppliedRecognition/Facial-Attribute-Detection-Apple.git`.

## Usage

All detectors in the library adopt the [FacialAttributeDetection](https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple/blob/main/Sources/VerIDCommonTypes/FacialAttributeDetection.swift) protocol from the [VerIDCommonTypes](https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple) library.

First you have to detect a face. You can use any library that implements the [FaceDetection](https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple/blob/main/Sources/VerIDCommonTypes/FaceDetection.swift) protocol, for example [FaceDetectionRetinaFace](https://github.com/AppliedRecognition/Face-Detection-RetinaFace-Apple).

Pass the detected face along with the image in which the face was detected to the `detect` function of the facial attribute detector.

```swift
// Import dependencies
import FaceDetectionRetinaFace
import VerIDCommonTypes
import FacialAttributeDetectionCore
import FaceCoveringDetection
import EyewearDetection

// Detect face covering and eyewear in image
func detectFaceAttributesInImage(_ image: CGImage) async throws -> FaceAttributeDetectionResult {
    
    // Create Ver-ID image from CGImage
    guard let verIDImage = Image(image) else {
    	throw FacialAttributeDetectionError("Failed to convert image to Ver-ID image")
    }
    
    // Create face detection
    let faceDetection = try FaceDetectionRetinaFace()
    
    // Detect face
    guard let face = try await faceDetection.detectFacesInImage(verIDImage, limit: 1).first else {
        return FaceAttributeDetectionResult(
        	hasFaceCovering: false, 
            hasEyewear: false, 
            eyewearType = nil
        )
    }
    
    // Create face covering detector
    let faceCoveringDetector = try FaceCoveringDetector()
    
    // Detect face covering
    let faceCoveringResult = try await faceCoveringDetector.detect(in: face, image: verIDImage)
    
    // Create eyewear detector
    let eyewearDetector = try EyewearDetector()
    
    // Detect eyewear
    let eyewearResult = try await eyewearDetector.detect(in: face, image: verIDImage)

    // Results are nil if the attribute is not detected
    return FaceAttributeDetectionResult(
    	hasFaceCovering: faceCoveringResult != nil, 
        hasEyewear: eyewearResult != nil, 
        eyewearType = eyewearResult?.type.rawValue
    )
}

// Struct that encapsulates results from 
// the face covering and eyewear detectors
struct FaceAttributeDetectionResult {
    let hasFaceCovering: Bool
    let hasEyewear: Bool
    let eyewearType: String?
}

// Custom error type
struct FacialAttributeDetectionError: LocalizedError {
    var errorDescription: String?
    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}
```