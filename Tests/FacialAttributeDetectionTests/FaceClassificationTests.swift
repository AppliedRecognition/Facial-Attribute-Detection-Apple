import XCTest
import FaceDetectionRetinaFace
import VerIDCommonTypes
@testable import FacialAttributeDetectionCore
@testable import FaceCoveringDetection
@testable import EyewearDetection

final class FaceClassificationTests: XCTestCase {
    
    var faceDetection: FaceDetectionRetinaFace!
    
    override func setUpWithError() throws {
        self.faceDetection = try FaceDetectionRetinaFace()
    }
    
    func testCreateFaceCoveringClassifier() throws {
        XCTAssertNoThrow(try FaceCoveringDetector())
    }
    
    func testCreateGlassesClassifier() throws {
        XCTAssertNoThrow(try EyewearDetector())
    }
    
    func testDetectFaceCovering() async throws {
        let (image, face) = try await self.imageAndFace(fromJpegResourceNamed: "face-covering")
        let detector = try FaceCoveringDetector()
        let result = try await detector.detect(in: face, image: image)
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result!.confidence, detector.confidenceThreshold)
    }
    
    func testMissFaceCovering() async throws {
        let (image, face) = try await self.imageAndFace(fromJpegResourceNamed: "clear")
        let detector = try EyewearDetector()
        let result = try await detector.detect(in: face, image: image)
        XCTAssertNil(result)
    }
    
    func testDetectGlasses() async throws {
        let (image, face) = try await self.imageAndFace(fromJpegResourceNamed: "glasses")
        let detector = try EyewearDetector()
        let result = try await detector.detect(in: face, image: image)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.type, .glasses)
        XCTAssertGreaterThanOrEqual(result!.confidence, detector.confidenceThreshold)
    }
    
    func testDetectSunglasses() async throws {
        let (image, face) = try await self.imageAndFace(fromJpegResourceNamed: "sunglasses")
        let detector = try EyewearDetector()
        let result = try await detector.detect(in: face, image: image)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.type, .sunglasses)
        XCTAssertGreaterThanOrEqual(result!.confidence, detector.confidenceThreshold)
    }
    
    func testMissGlasses() async throws {
        let (image, face) = try await self.imageAndFace(fromJpegResourceNamed: "clear")
        let detector = try EyewearDetector()
        let result = try await detector.detect(in: face, image: image)
        XCTAssertNil(result)
    }
    
    private func imageAndFace(fromJpegResourceNamed name: String) async throws -> (Image, Face) {
        guard let url = Bundle.module.url(forResource: name, withExtension: "jpg") else {
            throw NSError()
        }
        let data = try Data(contentsOf: url)
        guard let uiImage = UIImage(data: data), let cgImage = uiImage.cgImage else {
            throw NSError()
        }
        let orientation: CGImagePropertyOrientation
        switch uiImage.imageOrientation {
        case .up:
            orientation = .up
        case .upMirrored:
            orientation = .upMirrored
        case .down:
            orientation = .down
        case .downMirrored:
            orientation = .downMirrored
        case .left:
            orientation = .left
        case .leftMirrored:
            orientation = .leftMirrored
        case .right:
            orientation = .right
        case .rightMirrored:
            orientation = .rightMirrored
        default:
            orientation = .up
        }
        guard let image = Image(cgImage: cgImage, orientation: orientation) else {
            throw NSError()
        }
        guard let face = try await self.faceDetection.detectFacesInImage(image, limit: 1).first else {
            throw NSError()
        }
        return (image, face)
    }
}
