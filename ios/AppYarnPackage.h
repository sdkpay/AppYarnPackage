
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNAppYarnPackageSpec.h"

@interface AppYarnPackage : NSObject <NativeAppYarnPackageSpec>
#else
#import <React/RCTBridgeModule.h>

@interface AppYarnPackage : NSObject <RCTBridgeModule>
#endif

@end
