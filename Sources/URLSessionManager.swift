import Combine
import Foundation

public class URLSessionManager {
    private let queue: OperationQueue
    private let session: URLSession

    private let validation: (Data, URLResponse) throws -> Data

    public init(
        queueConfiguration: OperationQueueConfiguration = .init(),
        sessionConfiguration: URLSessionConfiguration = .default,
        validation: @escaping (Data, URLResponse) throws -> Data = { data, _ in data }
    ) {
        queue = OperationQueue()
        session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: queue)
        self.validation = validation
    }
}

extension URLSessionManager {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func send(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        #if DEBUG
        log(request: request)
        #endif

        return session.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }

    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func send(request: URLRequest) -> AnyPublisher<Data, Error> {
        return send(request: request)
            .tryMap(validation)
            .eraseToAnyPublisher()
    }
}

extension URLSessionManager {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func request(api: URLBuilding) -> AnyPublisher<Data, Error> {
        return send(request: api.urlRequest)
    }

    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func request<T: Decodable>(api: URLBuilding) -> AnyPublisher<T, Error> {
        return request(api: api)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

#if DEBUG
private func log(request: URLRequest) {
    let method = request.httpMethod ?? "GET"
    let url = request.url?.absoluteString ?? "<unknown url>"
    print("\(method) \(url)")
}

private func log(url: URL?, data: Data) {
    print("response of: \(url?.absoluteString ?? "<unknown url>")")

    do {
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        print(String(decoding: prettyData, as: UTF8.self))
    } catch {
        print("cannot serialize json")
        print(error.localizedDescription)
    }
}
#endif
