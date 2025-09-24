//
//  Errors.swift
//
//
//  Created by Jakub Dolejs on 15/09/2025.
//

import Foundation

public struct FaceClassificationError: LocalizedError {
    
    public var errorDescription: String?
    
    public init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}
