#!/bin/bash

PRINT_COUNT=1
ROW_STRING="==========================================="

printStep() {
    echo "${ROW_STRING}"
    echo "$PRINT_COUNT." $1
    echo "${ROW_STRING}"
    let "PRINT_COUNT+=1"
}

clear() {
    printStep "Clear build folder"
    rm -r ./build/*
}

buildDevice() {
    printStep "Build framework for device"
    xcodebuild archive \
    -scheme SPaySdkPROD \
    -archivePath "./build/ios.xcarchive" \
    -sdk iphoneos \
    ONLY_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO
}

buildSim() {
    printStep "Build framework for sim"
    xcodebuild archive \
    -scheme SPaySdkPROD \
    -archivePath "./build/ios_sim.xcarchive" \
    -sdk iphonesimulator \
    ONLY_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO
}

createXCFramework() {
    printStep "Create XCFramework"
    xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/SPaySdk.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/SPaySdk.framework" \
    -output "./build/SPaySdk.xcframework"
    open "./build"
}

clear
buildDevice
buildSim
createXCFramework
