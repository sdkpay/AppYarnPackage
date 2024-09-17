
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNAppYarnPackageSpec.h"

@interface AppYarnPackage : NSObject <NativeAppYarnPackageSpec>
#else
#import <React/RCTBridgeModule.h>
#import <SPaySdk/SPaySdk.h>

@interface AppYarnPackage : NSObject <RCTBridgeModule>
#endif

@end
