import Foundation

public protocol URLBuilding {
    var url: URL? { get }
    var urlRequest: URLRequest? { get }
}

public struct EndPoint {
    public let scheme: String
    public let host: String
    public let port: Int?

    public init(scheme: String, host: String, port: Int? = nil) {
        self.scheme = scheme
        self.host = host
        self.port = port
    }
}

public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
}

open class API {
    public let endPoint: EndPoint

    public var path: String = ""
    public var parameters: [(String, Any)]?

    public var httpMethod: HTTPMethod = .get
    public var header: [String: String]?

    public init(endPoint: EndPoint) {
        self.endPoint = endPoint
    }
}

extension API: URLBuilding {
    open var url: URL? {
        var components = URLComponents()

        components.scheme = endPoint.scheme
        components.host = endPoint.host
        components.port = endPoint.port

        components.path = path
        components.queryItems = queryItems

        return components.url
    }

    open var urlRequest: URLRequest? {
        guard let url = url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = header
        return request
    }

    open var queryItems: [URLQueryItem]? {
        guard let parameters = parameters else { return nil }

        return parameters.compactMap { (key, value) in
            switch value {
            case let string as LosslessStringConvertible:
                return URLQueryItem(name: key, value: string.description)
            case let stringArray as [LosslessStringConvertible]:
                let joinedValue = stringArray
                    .map { $0.description }
                    .joined(separator: ",")
                return URLQueryItem(name: key, value: joinedValue)
            default:
                return nil
            }
        }
    }
}
