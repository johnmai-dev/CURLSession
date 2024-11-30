import Testing
import Foundation
@testable import CURLSession

@Test func example() async throws {
//    let proxies = CFNetworkCopySystemProxySettings()?.takeUnretainedValue()
//    print(proxies)
//    
    var urlSessionConfiguration = URLSessionConfiguration.default
    print(urlSessionConfiguration)
//    urlSessionConfiguration.connectionProxyDictionary = proxies as? [AnyHashable: Any]
    var request = URLRequest(url: URL(string: "https://huggingface.co/HuggingFaceTB/SmolLM2-135M-Instruct/resolve/5a33ba103645800d7b3790c4448546c1b73efc71/model.safetensors")!)
//    var request = URLRequest(url: URL(string: "https://hf-mirror.com/HuggingFaceTB/SmolLM2-135M-Instruct/resolve/5a33ba103645800d7b3790c4448546c1b73efc71/model.safetensors")!)
    request.allHTTPHeaderFields = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"]
    
    
    let response = try await CURLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }

    for (key, value) in httpResponse.allHeaderFields {
        print(">>> \(key): \(value)")
    }

    print(httpResponse.allHeaderFields)
    print("X-Repo-Commit -> \(httpResponse.value(forHTTPHeaderField: "X-Repo-Commit") ?? "")")
    
    print(">>> \(URLSessionConfiguration.default.connectionProxyDictionary) ")
    print(">>> \(URLSessionConfiguration.default.timeoutIntervalForRequest)")
    print(">>> \(URLSessionConfiguration.default.timeoutIntervalForResource)")
    
}
