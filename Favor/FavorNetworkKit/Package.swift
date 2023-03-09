// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FavorNetworkKit",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "FavorNetworkKit",
      targets: ["FavorNetworkKit"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.3")),
    .package(path: "../FavorCoreKit")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "FavorNetworkKit",
      dependencies: [
        "Moya",
        .product(name: "RxMoya", package: "Moya"),
        "FavorCoreKit"
      ]),
    .testTarget(
      name: "FavorNetworkKitTests",
      dependencies: ["FavorNetworkKit"]),
  ]
)
