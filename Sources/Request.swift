import Foundation

public enum ParameterType {
    case queryItem
    case json
    case form
}

public enum AuthType {
    case none
    case oauth2(String)
}

public protocol Request {
    associatedtype Response: Decodable

    var endPoint: URL { get }
    var path: String { get }

    var parameters: [String: String] { get }
    var parameterType: ParameterType { get }

    var httpMethod: HTTPMethod { get }

    var authType: AuthType { get }
}

extension Request {
    public var parameters: [String: String] {
        [:]
    }

    public var parameterType: ParameterType {
        .queryItem
    }

    public var httpMethod: HTTPMethod {
        .get
    }

    public var authType: AuthType {
        .none
    }
}
