// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FingerprintPackage",
    products: [
        .library(
            name: "FingerprintPackage",
            targets: ["FingerprintPackage"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(name: "Fingerprint",
                      path: "Fingerprint.xcframework"
        ),
        .binaryTarget(name: "BizoneCore",
                      path: "BizoneCore.xcframework"
        ),
        .target(name: "FingerprintPackage",
                dependencies: [
                    .target(name: "Fingerprint"),
                    .target(name: "BizoneCore")
                ],
                path: "./"
    )
    ]
)
