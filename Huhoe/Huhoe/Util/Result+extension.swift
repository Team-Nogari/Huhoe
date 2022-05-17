//
//  Result+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/27.
//

import Foundation

extension Result {
    var value: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
}
