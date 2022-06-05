import XCTest
@testable import Protected

final class ProtectedTests: XCTestCase {
    func testSampleRights() throws {
        let book = createBook()
        XCTAssertEqual(book.title, "Don Quixote")
        XCTAssertEqual(book.title.first, "D")
        XCTAssertEqual(book.author, "Miguel de Cervantes")
        XCTAssertEqual(book.isbn, "0060188707")

        book.title = "La cueva de salamanca"
        XCTAssertEqual(book.title, "La cueva de salamanca")
        book.unsafeMutate { $0.isbn = nil }
        XCTAssertEqual(book.isbn?.first, nil)
    }
}

func createBook() -> Protected<Book, PrePublishRights> {
    let book = Book()
    book.title = "Don Quixote"
    book.author = "Miguel de Cervantes"
    book.isbn = "0060188707"
    return Protected(book, by: .prePublish)
}

class Book {
  var title: String?
  var author: String?
  var isbn: String?
}

extension RightsManifest where Self == PrePublishRights {
    static var prePublish: PrePublishRights {
        return PrePublishRights()
    }
}

struct PrePublishRights: RightsManifest {
    typealias ProtectedType = Book

    let title = Write(\.title!)
    let author = Read(\.author!)
    let isbn = Read(\.isbn)
}

struct FirstCharacterOnly: RightsManifest {
    typealias ProtectedType = String

    let first = Read(\.first)
}

