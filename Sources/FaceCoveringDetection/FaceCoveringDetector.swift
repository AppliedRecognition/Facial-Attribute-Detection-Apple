//
//  FaceCoveringDetector.swift
//
//
//  Created by Jakub Dolejs on 15/09/2025.
//

import Foundation
import VerIDCommonTypes
import CoreML
@_spi(Internal) import FacialAttributeDetectionCore

public class FaceCoveringDetector: FacialAttributeDetector<FaceCoveringType> {
    
    public init() throws {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = true
        let model = try FaceCovering(configuration: config).model
        super.init(model: model)
    }
    
    @_spi(Internal) public override func featureProviderFromMultiArray(_ multiArray: MLMultiArray) -> MLFeatureProvider {
        return FaceCoveringInput(x: multiArray)
    }
    
    @_spi(Internal) public override func resultFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> FacialAttributeDetectionResult<FaceCoveringType> {
        guard let output = featureProvider.featureValue(for: "var_114")?.multiArrayValue else {
            throw NSError()
        }
        return FacialAttributeDetectionResult(confidence: output[0].floatValue, type: .faceCovering)
    }
}

public enum FaceCoveringType: String {
    case faceCovering
}
