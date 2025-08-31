---
date: 2025-09-01 04:30
title: Building Type-Safe Query Keys in SwiftUIQuery library
description: Building Type-Safe Query Keys in SwiftUIQuery library
tags: swiftuiquery, react, query, note, development, vibe coding
excerpt: Just another note while I'm vibe-coding SwiftUIQuery 
socialImageLink: assets/swiftuiquery-logo-min.png
twitterCardType: summary
---

<br/>

When working with React Query, one of the best practices is to use arrays for query keys with
multiple parameters:

```javascript
// React Query best practice
useQuery({
  queryKey: ['products', category, { featured: true, minRating: 4.5 }],
  queryFn: () => fetchProducts(category, { featured: true, minRating: 4.5 })
})
```

This gives you a hierarchical key structure that's easy to reason about and enables powerful
features like partial invalidation - you can invalidate all ['products'] queries or just
['products', 'electronics'].

### My First Attempt: Swift Tuples

When I started building SwiftUI Query, I thought Swift's native tuples would be perfect for
this:

```swift
typealias KeyTuple2<K1, K2> = (K1, K2)
typealias KeyTuple3<K1, K2, K3> = (K1, K2, K3)

// This should work, right?
UseQuery(
    queryKey: ("products", "electronics"),
    queryFn: { _ in ... }
)
```

It seemed elegant - leverage Swift's built-in tuple syntax for multi-parameter keys. But I quickly ran into problems:

**Problem 1: Codable Conformance**

> extension (K1, K2): Codable where K1: Codable, K2: Codable {}
> // ❌ Error: Cannot extend tuple types

Tuples can't conform to protocols in Swift, which meant I couldn't make them Codable for
serialization or hashing.

**Problem 2: No Custom Initializers**

```swift
// I wanted this convenience syntax:
KeyTuple2(Product.self, 123) // Product.Type -> "Product"

// But tuples can't have custom initializers
```

### The Struct Solution

After hitting these walls, I realized I needed to create actual struct types:

```swift
public struct KeyTuple2<K1: QueryKeyCodable, K2: QueryKeyCodable>: QueryKey, QueryKeyCodable {
    public let key1: K1
    public let key2: K2

    public init(_ key1: K1, _ key2: K2) {
        self.key1 = key1
        self.key2 = key2
    }

    // Convenience for types
    public init(_ key1: (some Any).Type, _ key2: K2) where K1 == String {
        self.key1 = String(describing: key1)
        self.key2 = key2
    }
}
```

This gave me everything I was missing:

✅ Protocol Conformance

```swift
// Now I can make it Codable and Equatable
extension KeyTuple2: Codable where K1: Codable, K2: Codable {}
```

✅ Meaningful Property Names

```swift
let key = KeyTuple3("products", Category.electronics, true)
// key.key1, key.key2, key.key3 - much clearer than .0, .1, .2
```

✅ Custom Initializers

```swift
let key = KeyTuple2(Product.self, 123)
// Automatically converts Product.Type to "Product" string
```

✅ Consistent Hashing

```swift
public var queryHash: String {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .sortedKeys
    guard let jsonData = try? jsonEncoder.encode(self) else {
        return "\(hashValue)"
    }
    return String(decoding: jsonData, as: UTF8.self)
}
```

### The Final API

Now I can create type-safe query keys that feel natural:

```swift
UseQuery(
    queryKey: .init(FetchProductsQuery.self, category, searchTerm),
    queryFn: { _ in
        fetchProducts(category, searchTerm)
    }
) { result in
    if result.isLoading {
        ProgressView()
    } else {
        ProductList(products: result.data)
    }
}
```

I ended up building KeyTuple2 through KeyTuple6, covering pretty much every realistic use case.
The struct approach gave me all the benefits of React Query's array-based keys while
leveraging Swift's type system for compile-time safety.

Sometimes the "obvious" solution (tuples) isn't the right one. The extra verbosity of structs
was worth it for the flexibility and safety they provided. Plus, the API still feels
lightweight enough that you don't mind using it everywhere.

More code at [https://github.com/muzix/SwiftUIQuery/](https://github.com/muzix/SwiftUIQuery/)
