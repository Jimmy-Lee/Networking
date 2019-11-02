import Foundation

extension String {
    var percentEncoded: Self {
        let characterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        return self.addingPercentEncoding(withAllowedCharacters: characterSet) ?? self
    }
}

public protocol URLBuilding {
    var url: URL { get }
    var urlRequest: URLRequest { get }
}

extension API: URLBuilding {
    open var url: URL {
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.host
        components.port = endPoint.port

        components.path = path

        if parameterType == .queryItem {
            components.queryItems = queryItems(from: parameters)
        }

        guard let url = components.url else {
            fatalError("incorrect url from \(components.debugDescription)")
        }

        return url
    }

    open var urlRequest: URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        switch parameterType {
        case .json:
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        case .form:
            request.httpBody = formDataBody(parameters: parameters)
        default:
            break
        }

        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func queryItems(from parameters: [String: String]) -> [URLQueryItem]? {
        if parameters.isEmpty {
            return nil
        } else {
            return parameters.map { .init(name: $0.key, value: $0.value) }
        }
    }

    private func formDataBody(parameters: [String: String]) -> Data? {
        if parameters.isEmpty {
            return nil
        } else {
            let parameterString = parameters
                .map { "\($0.key.percentEncoded)=\($0.value.percentEncoded)" }
                .joined(separator: "&")
            return Data(parameterString.utf8)
        }
    }
}
