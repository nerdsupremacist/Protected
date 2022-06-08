import XCTest
@testable import Protected

final class ProtectedTests: XCTestCase {
    func testSampleRights() throws {
        let planning = createBook()
        XCTAssertEqual(planning.title, "Don Quixote")
        XCTAssertEqual(planning.title?.first, "D")
        XCTAssertEqual(planning.author?.name, "Miguel de Cervantes")
        XCTAssertEqual(planning.isbn, "0060188707")
        planning.author?.name = "Cervantes"
        XCTAssertEqual(planning.author?.name, "Cervantes")

        let prePublish = planning.unsafeChange().prePublish()

        prePublish.title = "La cueva de salamanca"
        XCTAssertEqual(prePublish.title, "La cueva de salamanca")
        XCTAssertEqual(prePublish.author, "Cervantes")
        prePublish.unsafeMutate { $0.isbn = nil }
        XCTAssertEqual(prePublish.isbn?.first, nil)
    }
}

func createBook() -> Protected<Book, PlanningRights> {
    return protect(Book())
        .mutate { book in
            let author = Author()
            author.name = "Miguel de Cervantes"
            author.password = "password"
            book.title = "Don Quixote"
            book.author = author
            book.isbn = "0060188707"
        }
        .planning()
}

class Author {
    var name: String?
    var password: String?
}

class Book {
  var title: String?
  var author: Author?
  var isbn: String?
}

extension Rights {
    var planning: PlanningRights {
        return PlanningRights()
    }

    var prePublish: PrePublishRights {
        return PrePublishRights()
    }

    var basic: AuthorBasicRights {
        return AuthorBasicRights()
    }
}

struct PrePublishRights: RightsManifest {
    typealias ProtectedType = Book

    let title = Write(\.title!)
    let author = Read(\.author!.name!)
    let isbn = Read(\.isbn)
}

struct PlanningRights: RightsManifest {
    typealias ProtectedType = Book

    let title = Write(\.title)
    let author = Read(\.author).basic()
    let isbn = Read(\.isbn)
}

struct AuthorBasicRights: RightsManifest {
    typealias ProtectedType = Author

    let name = Write(\.name)
}
