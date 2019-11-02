import Foundation

public enum ParameterType {
    case queryItem
    case json
    case form
}

open class API {
    public let endPoint: EndPoint

    public var path: String = ""

    public var parameters: [String: String] = [:]
    public var parameterType: ParameterType = .queryItem

    public var httpMethod: HTTPMethod = .get

    public var header: [String: String] = [:]

    public init(endPoint: EndPoint) {
        self.endPoint = endPoint
    }
}
