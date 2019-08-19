import Combine
import Networking
import UIKit

extension EndPoint {
    static var jsonPlaceholder: EndPoint {
        return .init(scheme: "https", host: "jsonplaceholder.typicode.com")
    }
}

class JSONPlaceholderAPI: API {
    init() {
        super.init(endPoint: .jsonPlaceholder)
    }
}

final class PostListAPI: JSONPlaceholderAPI {
    typealias Response = [Post]

    override init() {
        super.init()

        path = "/posts"
    }
}

final class GetPostAPI: JSONPlaceholderAPI {
    typealias Response = Post

    init(postID: Int) {
        super.init()

        path = "/posts/\(postID)"
    }
}

final class GetCommentAPI: JSONPlaceholderAPI {
    typealias Response = [Comment]

    init(postID: Int) {
        super.init()

        path = "/posts/\(postID)/comments"
    }
}

extension APIService {
    func listPost() -> AnyPublisher<PostListAPI.Response, Error> {
        return query(api: PostListAPI())
    }

    func getPost(postID: Int) -> AnyPublisher<GetPostAPI.Response, Error> {
        return query(api: GetPostAPI(postID: postID))
    }

    func getCommentOfPost(postID: Int) -> AnyPublisher<GetCommentAPI.Response, Error> {
        return query(api: GetCommentAPI(postID: postID))
    }
}

struct Post: Codable {
    let userID, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }
}

struct Comment: Codable {
    let postID, id: Int
    let name, email, body: String

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case id, name, email, body
    }
}

final class ViewController: UIViewController {
    private let apiService = APIService()

    private var task: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        task = apiService.getCommentOfPost(postID: 1)
//        task = apiService.getPost(postID: 1)
//        task = apiService.listPost()
            .sink(
                receiveCompletion: { (completion) in
                    print(completion)
                },
                receiveValue: { (response) in
                    print(response)
                }
            )
    }
}
