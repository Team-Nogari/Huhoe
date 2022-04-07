//
//  NetworkError.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidRequest
    case invalidResponse
    case abnormalStatusCode(_ statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "ERROR: Invalid Request"
        case .invalidResponse:
            return "ERROR: Invalid Response"
        case .abnormalStatusCode(let statusCode):
            return "ERROR: Abnormal Status Code \(statusCode)"
        }
    }
}
