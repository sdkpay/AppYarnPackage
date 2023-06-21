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
    rm -r ./buildApp/*
}

buildArchive() {
    printStep "Build Archive"
    xcodebuild \
    -project SPaySdk.xcodeproj \
    -scheme SPaySdkExample \
    -archivePath ./buildApp/Archive/SPaySdkExample.xcarchive archive
}

makeIPA() {
    printStep "Make IPA"
    xcodebuild \
    -exportArchive \
    -archivePath ./buildApp/Archive/SPaySdkExample.xcarchive \
    -exportPath ./buildApp/ipa \
    -exportOptionsPlist ./BuildOptions/ExportOptions.plist
}

clear
buildArchive
makeIPA
