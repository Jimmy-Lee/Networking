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
