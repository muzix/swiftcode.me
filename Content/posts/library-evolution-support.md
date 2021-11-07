---
date: 2021-10-31 01:08
title: Library Evolution Support
description: Library Evolution Support.
tags: library, evolution, swift, abi, stability, xcframework
excerpt: This article is my explanation about Library Evolution Support and why does it matter.
---

<br/>

This article is my explanation about Library Evolution Support and why does it matter.

Before dive into the main topic, let's start with a few terms that might confuse us: **ABI Stability** and **Module Stability**

### ABI Stability

Let first find out what is **ABI**:

> In computer software, an application binary interface (ABI) is an interface between two binary program modules
> -- <cite>Wikipedia</cite>

It sounds similar to Application Programming Interface (API). But while API provides an abstract interface at a high-level, hardware-independent, often in human-readable format, ABI provides an interface at a lower level, hardware-dependent, including implementation details about the program.

Before Swift 5.0, an app written in Swift will be bundled with Swift standard libraries (a bunch of libSwift*.dylib files). And an app can run on any past, present, and future OS releases.

<img src="/assets/pre-abi-stability.jpg" alt="before ABI stability" width="500"/>

Then Swift 5.0 released with ABI Stability

> ABI stability means locking down the ABI to the point that future compiler versions can produce binaries conforming to the stable ABI. 
> 
> ABI stability enables binary compatibility between applications and libraries compiled with different Swift versions.
> 
> -- [Swift ABI Stability Manifesto](https://github.com/apple/swift/blob/main/docs/ABIStabilityManifesto.md#what-is-abi-stability)

As a result, Swift runtime is now a part of the Operating System, rather than embedded into the app

<img src="/assets/abi-stability.jpg" alt="ABI stability" width="500"/>

Advantages of ABI stability:

- App size reduced (all libSwift*.dylib files removed from app bundle). Much faster to download an app.
- Because Swift runtime is an integrated part of the host OS, it can be optimized and delivered along with the host OS release. An app will automatically get those benefits from each new OS release.
- Because all Swift runtime version > 5.0 conform to the same stable ABI, an app built with one version of Swift compiler continue to run smoothly on all future OS version.

In short, it's all about how an application talks to Swift libraries at runtime through an ABI and how important it is to have ABI stability. 

Next, we will talk about **Module Stability**.

### Module Stability

```
Module compiled with Swift 5.0.1 cannot be imported by the Swift 5.1 compiler
```

You will see this error when importing a binary framework built with an old version of the Swift compiler.

To resolve this, from Swift 5.1, you can enable **Module stability** by turning on a new flag. Then you can distribute your pre-built framework without worrying about compiler version incompatible.


```
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

With this flag enabled, Swift compiler will generate a new header file with suffix **swiftinterface** instead of the **swiftmodule** header file. **swiftinterface** file is in text-based format & is forward-compatible with any Swift compiler version >= 5.1.

But that's not over, `BUILD_LIBRARY_FOR_DISTRIBUTION` also enable **Library Evolution**. Let's find out what it is. 

### Library Evolution

Without Library Evolution, it's very hard for the library to be **Binary compatible** in each release. It's a common problem called [fragile binary interface problem](https://en.wikipedia.org/wiki/Fragile_binary_interface_problem), in which even a tiny internal change will break ABI and require recompiling of everything upstream.

In the first part, we know ABI contains implementation details of the binary program, such as Data Layout, Type Metadata, Name mangling, etc... For example, a memory layout of a `struct` depends on its properties. So adding a new property, renaming a property, and even changing the order of their declaration, will break the ABI.

In the next part, I will demonstrate this problem with a small demo.

### The Shopping App

Imagine we are building and maintaining an iOS shopping app. It's a common practice to break down an app into several small modules, each module built into a separated framework.

<img src="/assets/shopping-app-1.jpg" alt="shopping app modular" width="300"/>

In the above diagram, there is a `PaymentModule` which imports `NetworkModule` to make API call to a payment gateway. At the same time, the shopping app imports the `NetworkModule` directly to make API calls as need.

All these modules are prebuilt binaries. `PaymentModule` (v1.0.0) was compiled and linked against `NetworkModule` (v1.0.0). `Library Evolution` mode is disabled by default.

<img src="/assets/paymentmodule-library-evolution-off.png" alt="payment module library evolution off" width="500"/>

Inside `NetworkModule`, I created a `Config` struct with a bool `isDebugMode` for network logging purpose.

```swift
public struct Config {
    public let isDebugMode: Bool

    public init(isDebugMode: Bool) {
        self.isDebugMode = isDebugMode
    }
}
```

That's all for `NetworkModule`. Let's move to the `PaymentModule`.

<img src="/assets/paymentmodule-project-structure.png" alt="payment module project structure" width="300"/>

Inside `PaymentModule`, I created a singleton `PaymentManager` class

```
import NetworkModule

public final class PaymentManager {
    public static let shared = PaymentManager()

    public func setup(isDebugMode: Bool = false) {
        let networkConfig = Config(isDebugMode: isDebugMode)
        print("Debug mode: \(networkConfig.isDebugMode)")
    }

    public func tellMeAboutNetworkConfigType() {
        print(
        """
        Size: \(MemoryLayout<Config>.size)
        Stride: \(MemoryLayout<Config>.stride)
        Alignment: \(MemoryLayout<Config>.alignment)
        """
        )
    }
}
```

Method `setup` accept the boolean param, init the `Config` struct with that param, then print out the boolean property of `Config`.

We have another method named `tellMeAboutNetworkConfigType` which simply prints out the Memory Layout of `Config` struct. For more information about struct `MemoryLayout`, this article explained it all: [https://swiftunboxed.com/internals/size-stride-alignment/](https://swiftunboxed.com/internals/size-stride-alignment/)

Next step, we build each module into an `XCFramework`. Project was archived with `Library Evolution` disabled

```
SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=NO
```

Then we use `xcodebuild -create-xcframework -allow-internal-distribution` to generate an xcframework without `Module stability` and `Library Evolution`

Now we can drag those frameworks into the Shopping App.

First, we make a copy of `tellMeAboutNetworkConfigType` method inside `Shopping App`

Then in `viewDidLoad`, we call `setup` passed `isDebugMode` as true, and call `tellMeAboutNetworkConfigType` from `PaymentModule` and from the Shopping App itself.

```
private func setup() {
    print("----- PAYMENT MODULE -----")
    PaymentManager.shared.tellMeAboutNetworkConfigType()
    print("--------------------------")

    print("------ SHOPPING APP ------")
    tellMeAboutNetworkConfigType()
    print("--------------------------")

    PaymentManager.shared.setup(isDebugMode: true)
}

private func tellMeAboutNetworkConfigType() {
    print(
    """
    Size: \(MemoryLayout<Config>.size)
    Stride: \(MemoryLayout<Config>.stride)
    Alignment: \(MemoryLayout<Config>.alignment)
    """
    )
}
```

Let's run and see what console output is:

```
----- PAYMENT MODULE -----
Size: 1
Stride: 1
Alignment: 1
--------------------------
------ SHOPPING APP ------
Size: 1
Stride: 1
Alignment: 1
--------------------------
Debug mode: true
```

Everything is normal. The `Config` struct has its size equal to the size of the `isDebugMode` boolean, which is 1 byte.
We passed `isDebugMode` as `true`, so the `PaymentModule` printed it out as `true`.

Next is the fun part. We want to add a logging level to the `NetworkModule`. So we add one `Int` property with default value set to 0. This minor change is backward compatible because no public interface changed.

```
public struct Config {
    public var logLevel: Int = 0
    public let isDebugMode: Bool

    public init(isDebugMode: Bool) {
        self.isDebugMode = isDebugMode
    }
}
```

We rebuild the `NetworkModule`, and update our `Shopping App` with the new framework binary (v1.0.1)

<img src="/assets/shopping-app-2.jpg" alt="shopping app with new networkmodule version" width="300"/>

Now we do a clean build and run the `Shopping App` again. Let's see what happens.

```
----- PAYMENT MODULE -----
Size: 1
Stride: 1
Alignment: 1
--------------------------
------ SHOPPING APP ------
Size: 9
Stride: 16
Alignment: 8
--------------------------
Debug mode: false
```

Wait, they are telling different things. And why debug mode is `false`! 😨

This scenario is an example of `Binary incompatible`. `PaymentModule` was linked against the old version of `NetworkModule`. When linking, it relies on the old ABI of `NetworkModule`. Later on, we updated the `NetworkModule` in `Shopping App` without recompiling `PaymentModule`. So, when `PaymentModule` tried to read `isDebugMode`, it accessed the first byte, which is now the first byte of the `logLevel` integer (default to zero), representing `false` bool value.

Now let's turn on `Library Evolution`. 

- First, I edited all build scripts to enable `BUILD_LIBRARY_FOR_DISTRIBUTION` & removed the `-allow-internal-distribution` build param.
- Revert `NetworkModule` to v1.0.0 and build `PaymentModule`. 
- Then I added `logLevel` again and built `NetworkModule` to the new version `v1.0.1`. 
- Finally, import `PaymentModule` (v1.0.0) and `NetworkModule` (v1.0.1) into `ShoppingApp`.

This time, `PaymentModule`, despite of linking against `NetworkModule` v1.0.0, printed out the correct Memory Layout of `Config` struct in v1.0.1 of `NetworkModule`, thanks to `Library Evolution`.

```
----- PAYMENT MODULE -----
Size: 9
Stride: 16
Alignment: 8
--------------------------
------ SHOPPING APP ------
Size: 9
Stride: 16
Alignment: 8
--------------------------
Debug mode: true
```

### In the end

If you are distributing library as a binary package, then you should be aware of `Binary Compatible` and turn on `Library Evolution` & `Module Stability`. 
Also, please check out [here](https://github.com/apple/swift-evolution/blob/main/proposals/0260-library-evolution.md) for more optimization with `@frozen` keyword.

### References

- [https://www.swift.org/blog/abi-stability-and-more/](https://www.swift.org/blog/abi-stability-and-more/)
- [https://www.swift.org/blog/library-evolution/](https://www.swift.org/blog/library-evolution/)
- [https://github.com/apple/swift/blob/main/docs/ABIStabilityManifesto.md](https://github.com/apple/swift/blob/main/docs/ABIStabilityManifesto.md)
- [https://github.com/apple/swift-evolution/blob/main/proposals/0260-library-evolution.md](https://github.com/apple/swift-evolution/blob/main/proposals/0260-library-evolution.md)