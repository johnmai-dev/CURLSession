//
//  CURLSessionConfiguration.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/17.
//

struct CURLSessionConfiguration: @unchecked Sendable {
    let timeout: Int
    let connectionProxyDictionary: [AnyHashable: Any]?

    static let `default` = CURLSessionConfiguration(
        timeout: 60,
        connectionProxyDictionary: nil
    )
}
