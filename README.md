<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/nerdsupremacist">
        <img src="https://img.shields.io/badge/twitter-@nerdsupremacist-blue.svg?style=flat" alt="Twitter: @nerdsupremacist" />
    </a>
</p>

# Protected

Access control can't always be static. 
Sometimes the mutability, nullability and access of variables depends on context. 
When dealing with these scenarios, we usually end up writing wrappers or duplicate the class for each different context. Well no more!

Protected is a Swift Package that allows you to specify the read and write rights for any type, depending on context by using Phantom types. 
Here's a taste of the syntax (we will explain everything in time):

```swift
struct MyRights: RightsManifest {
    typealias ProtectedType = Book
    
    let title = Write(\.title)
    let author = Read(\.author)
}

func work(book: Protected<Book, MyRights>) {
    book.title // ✅ works
    book.title = "Don Quixote" // ✅ works
    book.author // ✅ works
    book.author = "" // ❌ will not compile
    book.isbn // ❌ will not compile
}
```

This project is heavily inspired by [@sellmair](https://github.com/sellmair)'s [post on Phantom Read Rights](https://medium.com/@sellmair/phantom-read-rights-in-kotlin-modelling-a-pipeline-eef3523db857).
For those curious Protected relies on phantom types and [dynamic member look up](https://github.com/apple/swift-evolution/blob/main/proposals/0252-keypath-dynamic-member-lookup.md) to provide an easy API for specifying read and write rights for any type in Swift.

## Installation
### Swift Package Manager

You can install Sync via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Protected.git", from: "1.0.0")
    ]
)
```

## Usage
So let's imagine that you run a Book publishing company. Your codebase works with information about books at different stages of publishing. 
Most of the code revolves entirely around the following class:

```swift
public class Book {
    public var title: String?
    public var author: String?
    public var isbn: String?
}
```

So what's wrong with this code? Well plenty of things:
1. Everything is nullable. Despite the fact that there's places in our code where we can be sure that they're not null anymore.
1. Everyting can be read publicly.
1. Everything is mutable, all of the time. And if anything is mutable, you can bet someone will mutate it, and probably in a part of code where you are not expecting it.

These things might not look to bad when it comes to a simple class with three attributes, but as your classes get more complicated, keeping track of what can be read and mutated where becomes very difficult.

Enter our package Protected. When working with Protected we are mainly working with two things:
1. `RightsManifest`s: basically a type that specifies to what you have access to and how much.
2. `Protected`: a wrapper that will enforce at compile time that you only read and write what's allowed by the manifest.

So for our book example, we can consider that we want to safely handle the pre-publishing stage of a book. 
At this stage the author name is already set and should be changed. 
The title is also set, but is open to change. The ISBN should not be read at all. For this case we can write a `RightsManifest`

```swift
struct PrePublishRights: RightsManifest {
    typealias ProtectedType = Book

    // a) Declare that we can read and write the title
    let title = Write(\.title!) // b) with the ! enforce that at this stage it's no longer optional
    // c) Declare that we can only read the name of the author
    let author = Read(\.author!)
    
    // Do not include any declaration for the ISBN
}
```

A RightsManifest is a type that includes variables pointing to either:
- `Write`: can be read be written to 
- `Read`: can only be read

Each attribute you declare in the manifest can then be read in that context. So let's try to use it:

```swift
let book = Protected(Book(), by: PrePublishRights())
book.title // ✅ works
book.title = "Don Quixote" // ✅ works
book.author // ✅ works
book.author = "" // ❌ will not compile
book.isbn // ❌ will not compile
```

### More Advanced Features

#### Protecting nested types
If your object contains nested types, you can specify in your manifest, the manifest that corresponds to that value, and Protected will in that case return a `Protected` Value
For example, let's say that your books point to an Author object where you quite insecurely store the password (I've seen worse security):

```swift
class Author {
    var name: String?
    var password: String?
}

class Book {
    var title: String?
    var author: Author?
}
```

And let's say that you want to make sure that when someone grabs the author object from your book, that they can't see the password either. 
For that you can start by creating the manifests for both types. And when it comes to specifying the read right to the author, you can include that it should be protected by your other Manifest:

```swift
struct AuthorBasicRights: RightsManifest {
    typealias ProtectedType = Author
    
    let name = Read(\.name)
}

struct BookBasicRights: RightsManifest {
    typealias ProtectedType = Book
    
    let title = Write(\.title)
    // specify that for the author you want the result to be protected by AuthorBasicRights
    let author = Read(\.author).protected(by: AuthorBasicRights())
}
```

With this when you try to use it, you won't be able to access the password:
```swift
let book = Protected(Book(), by: BookBasicRights())
book.title // ✅ works
let author = book.author // returns a Protected<Author, AuthorBasicRights>?
author?.name // ✅ works
author?.password // ❌ will not compile
```

#### Manipulating Values and Changing Rights

All `Protected` values are designed to be changed. If you use the same object at different stages, you would like to change the rights associated with that object at any given time.
That's why `Protected` comes with a couple of functions prefixed by `unsafeX` to signal that you really should know what it is that you're doing with the object here.

For example let's imagine that you're writing a piece of code that will create an ISBN for a book and move it to the post publishing stage. So you can imagine that your rights look as follows:
```swift
struct PrePublishRights: RightsManifest {
    typealias ProtectedType = Book

    let title = Write(\.title!)
    let author = Read(\.author!)
}

struct PostPublishRights: RightsManifest {
    typealias ProtectedType = Book

    let title = Read(\.title!)
    let author = Read(\.author!)
    let isbn = Read(\.isbn!)
}
```

When you publish the book, you will efectively transition your object to be governed by the pre publish rights to the post publish rights. You can do this with the method: `unsafeMutateAndChangeRights`:

```swift
func publish(book: Protected<Book, PrePublishRights>) -> Protected<Book, PostPublishRights> {
    return book.unsafeMutateAndChangeRights(to: PostPublishRights()) { book in 
        // here you have complete unsafe access to the underlying `book` object, absolutely no limitations
        book.isbn = generateISBN()
    }
}
```

Other `unsafeX` functions to deal with the underlying data when needed include:
- `unsafeMutate`: let's you mutate the underlying value however you like.
- `unsafeChangeRights`: let's you create a new version of the protected, governed by a new manifest.
- `unsafeMapAndChangeRights`: let's you map the value onto a new one, and wrap it in a new protected governed by a different manifest.
- `unsafeBypassRights`: just get the value no matter what the manifest says.

#### More elaborate Read rights
Read rights don't necessarily need to be a keypath. For Read Rights you have multiple options for dealing with them. 
For example you can provide a more elaborate getter logic:

```swift
struct AuthorBasicRights: RightsManifest {
    typealias ProtectedType = Author
    
    let name = Read(\.name)
    let password = Read { obfuscate($0.password) }
}
```

You can also include a `.map` after any `Read` to manipulate the value:

```swift
struct AuthorBasicRights: RightsManifest {
    typealias ProtectedType = Author
    
    let name = Read(\.name)
    let password = Read(\.password).map { obfuscate($0) }
}
```

### Caveats

This is not a perfect protection for no one to be able to access things they shouldn't. 
Protected is not a security framework, it will not prevent people from accessing or mutating anything. 
It is intended as an easy way to make safe usage clear and simple depending on context.

1. A code can always access everything using the `unsafeX` methods provided.
2. You can (but really shouldn't) include more rights whithin the extension of a manifest. This allows you to include more rights than intended while still appearing to be safe. Do not do this! Protected cannot protect you from doing this. 

## Contributions
Contributions are welcome and encouraged!

## License
Protected is available under the MIT license. See the LICENSE file for more info.
