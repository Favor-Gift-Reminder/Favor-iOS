// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FavorKit",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "FavorKit",
      targets: ["FavorKit"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
    .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
    .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.37.0")),
    .package(url: "https://github.com/AliSoftware/Reusable.git", from: "4.1.2"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "FavorKit",
      dependencies: [
        "RxSwift",
        .product(name: "RxCocoa", package: "RxSwift"),
        "SnapKit",
        .product(name: "RealmSwift", package: "realm-swift"),
        "Reusable"
      ],
      resources: [
        .process("Resources")
      ]),
    .testTarget(
      name: "FavorKitTests",
      dependencies: ["FavorKit"]),
  ]
)
