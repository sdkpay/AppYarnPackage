#!/bin/bash

xcodebuild \
-project SPaySdk.xcodeproj \
-scheme SPaySdkExample \
-archivePath ./buildApp/Archive/SPaySdkExample.xcarchive archive

xcodebuild \
-exportArchive \
-archivePath ./buildApp/Archive/SPaySdkExample.xcarchive \
-exportPath ./buildApp/ipa \
-exportOptionsPlist ./BuildOptions/ExportOptions.plist
