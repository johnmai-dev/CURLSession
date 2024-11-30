//
//  CURLSession.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/17.
//
import CurlSwift
import Foundation

public struct CURLSession: Sendable {
    public static let shared = CURLSession()

    let configuration: CURLSessionConfiguration

    public init(configuration: CURLSessionConfiguration = .default) {
        self.configuration = configuration
        curl_global_init(Int(CURL_GLOBAL_ALL))
    }

    public func data(for request: URLRequest) async throws -> URLResponse {
        var response: URLResponse = .init()

        guard let curl = curl_easy_init() else {
            throw URLError(.badServerResponse)
        }

        defer {
            curl_easy_cleanup(curl)
        }

        guard let url = request.url else {
            throw URLError(.badURL)
        }

        curlEasySetoptString(curl, CURLOPT_URL, url.absoluteString)
        curlEasySetoptLong(curl, CURLOPT_FOLLOWLOCATION, 1)
        curlEasySetoptLong(curl, CURLOPT_NOBODY, 1)
        curlEasySetoptString(curl, CURLOPT_CUSTOMREQUEST, request.httpMethod)

        configureProxy(for: curl)

        let headersList = configureHeaders(curl, request.allHTTPHeaderFields)
        defer {
            if headersList != nil {
                curl_slist_free_all(headersList)
            }
        }

        final class Userdata {
            var headers: Data = .init()
        }

        let userdata = Userdata()

        let opaqueUserdata = Unmanaged.passRetained(userdata).toOpaque()
        defer {
            Unmanaged<Userdata>.fromOpaque(opaqueUserdata).release()
        }

        let headerCallback: curl_write_callback = { buffer, size, nitems, userdata in
            let length = size * nitems
            if let buffer, let userdata {
                let data = Data(bytes: buffer, count: length)
                let unretainedUserdata = Unmanaged<Userdata>.fromOpaque(userdata).takeUnretainedValue()
                unretainedUserdata.headers.append(data)
            }
            return length
        }

        curlEasySetoptHeaderCallback(curl, headerCallback)
        curlEasySetoptVoid(curl, CURLOPT_HEADERDATA, opaqueUserdata)

        let res = curl_easy_perform(curl)
        if res != CURLE_OK {
            let errorDescription = String(cString: curl_easy_strerror(res))
            throw URLError(.cannotLoadFromNetwork, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }

        var httpCode = 0
        curlEasyGetInfoLong(curl, CURLINFO_RESPONSE_CODE, &httpCode)

        response = HTTPURLResponse(
            url: url,
            statusCode: httpCode,
            httpVersion: nil,
            headerFields: parseHeaders(String(data: userdata.headers, encoding: .utf8) ?? "")
        ) ?? URLResponse()

        return response
    }

    private func configureHeaders(_ curl: UnsafeMutableRawPointer, _ headers: [String: String]?) -> UnsafeMutablePointer<curl_slist>? {
        var headersList: UnsafeMutablePointer<curl_slist>?
        headers?.forEach { key, value in
            headersList = curl_slist_append(headersList, "\(key): \(value)")
        }
        if headersList != nil {
            curlEasySetoptSlist(curl, CURLOPT_HTTPHEADER, headersList)
        }
        return headersList
    }

    private func configureProxy(for curl: UnsafeMutableRawPointer) {
        if let connectionProxyDictionary = configuration.connectionProxyDictionary {
            configureProxySettings(for: curl, proxyDictionary: connectionProxyDictionary)
        } else if let systemProxySettingsUnmanaged = CFNetworkCopySystemProxySettings() {
            configureProxySettings(for: curl, proxyDictionary: systemProxySettingsUnmanaged.takeRetainedValue() as! [AnyHashable: Any])
        }
    }

    private func configureProxySettings(for curl: UnsafeMutableRawPointer, proxyDictionary: [AnyHashable: Any]) {
        if let proxyHost = proxyDictionary[kCFProxyHostNameKey as String] as? String, let proxyPort = proxyDictionary[kCFProxyPortNumberKey as String] as? Int {
            curlEasySetoptString(curl, CURLOPT_PROXY, "\(proxyHost):\(proxyPort)")
        } else if let proxyHost = proxyDictionary[kCFNetworkProxiesHTTPProxy as String] as? String, let proxyPort = proxyDictionary[kCFNetworkProxiesHTTPPort as String] as? Int {
            curlEasySetoptString(curl, CURLOPT_PROXY, "\(proxyHost):\(proxyPort)")
        }
//        else if let proxyHost = proxyDictionary[kCFNetworkProxiesHTTPSProxy as String] as? String, let proxyPort = proxyDictionary[kCFNetworkProxiesHTTPSPort as String] as? Int {
//            curlEasySetoptString(curl, CURLOPT_PROXY, "\(proxyHost):\(proxyPort)")
//        } else if let proxyHost = proxyDictionary[kCFNetworkProxiesSOCKSProxy as String] as? String, let proxyPort = proxyDictionary[kCFNetworkProxiesSOCKSPort as String] as? Int {
//            curlEasySetoptString(curl, CURLOPT_PROXY, "\(proxyHost):\(proxyPort)")
//        }

        let proxyType = proxyDictionary[kCFNetworkProxiesProxyAutoConfigEnable as String] as? String

        if proxyType == kCFProxyTypeHTTP as String {
            curlEasySetoptProxytype(curl, CURLOPT_PROXYTYPE, CURLPROXY_HTTP)
        } else if proxyType == kCFProxyTypeHTTPS as String {
            curlEasySetoptProxytype(curl, CURLOPT_PROXYTYPE, CURLPROXY_HTTPS)
        } else if proxyType == kCFProxyTypeSOCKS as String {
            curlEasySetoptProxytype(curl, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5)
        }

        if let proxyUsername = proxyDictionary[kCFProxyUsernameKey as String] as? String,
           let proxyPassword = proxyDictionary[kCFProxyPasswordKey as String] as? String
        {
            curlEasySetoptString(curl, CURLOPT_PROXYUSERNAME, proxyUsername)
            curlEasySetoptString(curl, CURLOPT_PROXYPASSWORD, proxyPassword)
        }
    }

    private func parseHeaders(_ headerString: String) -> [String: String] {
        var headers: [String: String] = [:]
        let lines = headerString.components(separatedBy: "\r\n")
        for line in lines {
            if let range = line.range(of: ": ") {
                let key = String(line[..<range.lowerBound])
                let value = String(line[range.upperBound...])
                headers[key] = value
            }
        }
        return headers
    }
}
