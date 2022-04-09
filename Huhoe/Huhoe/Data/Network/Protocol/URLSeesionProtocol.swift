//
//  URLSeesionProtocol.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

protocol URLSeesionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSeesionProtocol { }
