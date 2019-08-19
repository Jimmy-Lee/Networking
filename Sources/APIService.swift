import Combine
import Foundation

public struct OperationQueueConfiguration {
    var maxConcurrentOperationCount: Int
    var qualityOfService: QualityOfService

    public init(
        maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount,
        qualityOfService: QualityOfService = .default
    ) {
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.qualityOfService = qualityOfService
    }
}

extension OperationQueue {
    convenience init(configuration: OperationQueueConfiguration) {
        self.init()

        maxConcurrentOperationCount = configuration.maxConcurrentOperationCount
        qualityOfService = configuration.qualityOfService
    }
}

public enum APIError: Error {
    case cannotBuildURL
}

public enum URLSessionError: Error {
    case notHttpResponse(URLResponse)
    case errorCode(Int)
}

public class APIService {
    private let session: URLSession
    private let queue: OperationQueue

    public init(
        queueConfiguration: OperationQueueConfiguration = .init(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        queue = OperationQueue()
        session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: queue)
    }

    func validate(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.notHttpResponse(response)
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            throw URLSessionError.errorCode(httpResponse.statusCode)
        }

        return data
    }

    public func request(request: URLRequest) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap(validate)
            .eraseToAnyPublisher()
    }

    public func request<T: Decodable>(
        request: URLRequest,
        decode: @escaping (Data) throws -> T = { try JSONDecoder().decode(T.self, from: $0) }
    ) -> AnyPublisher<T, Error> {
        return self.request(request: request)
            .tryMap(decode)
            .eraseToAnyPublisher()
    }

    public func query(api: API) -> AnyPublisher<Data, Error> {
        if let urlRequest = api.urlRequest {
            return request(request: urlRequest)
        } else {
            return Fail(error: APIError.cannotBuildURL)
                .eraseToAnyPublisher()
        }
    }

    public func query<T: Decodable>(
        api: API,
        decode: @escaping (Data) throws -> T = { try JSONDecoder().decode(T.self, from: $0) }
    ) -> AnyPublisher<T, Error> {
        return self.query(api: api)
            .tryMap(decode)
            .eraseToAnyPublisher()
    }
}
