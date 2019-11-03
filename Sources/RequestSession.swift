import Combine
import Foundation

public class RequestSession {
    private let queue: OperationQueue
    private let session: URLSession

    private let validation: (Data, URLResponse) throws -> Data

    public init(
        queueConfiguration: OperationQueueConfiguration = .init(),
        sessionConfiguration: URLSessionConfiguration = .default,
        validation: @escaping (Data, URLResponse) throws -> Data = { data, _ in data }
    ) {
        queue = OperationQueue(configuration: queueConfiguration)
        session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: queue)
        self.validation = validation
    }

    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func send<T: Request>(_ request: T) -> AnyPublisher<T.Response, Error> {
        session.dataTaskPublisher(for: buildURLRequest(request))
            .tryMap(validation)
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

extension RequestSession {
    private func buildURLRequest<T: Request>(_ request: T) -> URLRequest {
        var urlRequest = URLRequest(url: buildURL(request))

        urlRequest.httpMethod = request.httpMethod.rawValue

        switch request.parameterType {
        case .json:
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: request.parameters)
        case .form:
            urlRequest.httpBody = formDataBody(parameters: request.parameters)
        default:
            break
        }

        return urlRequest
    }

    private func buildURL<T: Request>(_ request: T) -> URL {
        guard var components = URLComponents(url: request.endPoint, resolvingAgainstBaseURL: false) else {
            fatalError("cannot form URLComponents from \(request.endPoint)")
        }

        components.path = request.path

        if request.parameterType == .queryItem {
            components.queryItems = queryItems(from: request.parameters)
        }

        guard let url = components.url else {
            fatalError("incorrect url from \(components.debugDescription)")
        }

        return url
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
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            return Data(parameterString.utf8)
        }
    }
}
