import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    let sessionManager = APIService()

    func testValidate() {
        let url = URL(string: "https://www.synology.com")!

        XCTAssertThrowsError(try sessionManager.validate(data: Data(), response: URLResponse()))

        let http404Response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        XCTAssertThrowsError(try sessionManager.validate(data: Data(), response: http404Response))

        let http200Response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        XCTAssertNoThrow(try sessionManager.validate(data: Data(), response: http200Response))
    }
}
