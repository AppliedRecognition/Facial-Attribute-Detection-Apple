// The Swift Programming Language
// https://docs.swift.org/swift-book
import VerIDCommonTypes
import UIKit
import CoreML

open class FacialAttributeDetector<T>: FacialAttributeDetection where T: Hashable & RawRepresentable, T.RawValue == String {
    
    public typealias AttributeType = T
    public var confidenceThreshold: Float = 0.5
    let model: MLModel
    
    public init(model: MLModel) {
        self.model = model
    }
    
    public func detect(in face: Face, image: Image) async throws -> FacialAttributeDetectionResult<T>? {
        let alignedFaceImage = try FaceAlignment.alignFace(face, image: image)
        let multiArray = try Preprocessing.modelInputFromAlignedFaceImage(alignedFaceImage)
        let featureProvider = self.featureProviderFromMultiArray(multiArray)
        let output = try self.model.prediction(from: featureProvider)
        let result = try self.resultFromFeatureProvider(output)
        return result.confidence >= self.confidenceThreshold ? result : nil
    }
    
    @_spi(Internal) open func featureProviderFromMultiArray(_ multiArray: MLMultiArray) -> MLFeatureProvider {
        fatalError("Method not implemented")
    }
    
    @_spi(Internal) open func resultFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> FacialAttributeDetectionResult<T> {
        fatalError("Method not implemented")
    }
}
