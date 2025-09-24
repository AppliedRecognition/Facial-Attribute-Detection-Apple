//
//  EyewearDetector.swift
//
//
//  Created by Jakub Dolejs on 15/09/2025.
//

import Foundation
import VerIDCommonTypes
import CoreML
@_spi(Internal) import FacialAttributeDetectionCore

public class EyewearDetector: FacialAttributeDetector<EyewearType> {
    
    public init() throws {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = true
        let model = try Glasses(configuration: config).model
        super.init(model: model)
    }
    
    @_spi(Internal) public override func featureProviderFromMultiArray(_ multiArray: MLMultiArray) -> MLFeatureProvider {
        return GlassesInput(x: multiArray)
    }
    
    @_spi(Internal) public override func resultFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> FacialAttributeDetectionResult<EyewearType> {
        guard let output = featureProvider.featureValue(for: "var_303")?.multiArrayValue else {
            throw NSError()
        }
        if output[1].floatValue >= self.confidenceThreshold {
            return FacialAttributeDetectionResult(confidence: output[1].floatValue, type: .sunglasses)
        } else {
            return FacialAttributeDetectionResult(confidence: output[0].floatValue, type: .glasses)
        }
    }
}

public enum EyewearType: String {
    case glasses, sunglasses
}
