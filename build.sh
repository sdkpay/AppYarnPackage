#!/bin/bash

rm -r ./build/*

xcodebuild archive \
    -scheme SberPay \
    -archivePath "./build/ios.xcarchive" \
    -sdk iphoneos \
    ONLY_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO

xcodebuild archive \
    -scheme SberPay \
    -archivePath "./build/ios_sim.xcarchive" \
    -sdk iphonesimulator \
     ONLY_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO

xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/SberPaySDK.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/SberPaySDK.framework" \
    -output "./build/SberPaySDK.xcframework"
open "./build"
