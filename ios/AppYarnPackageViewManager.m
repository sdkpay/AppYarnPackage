//
//  AppYarnPackageViewManager.m
//  demo-project
//
//  Created by Гладкий Сергей Игоревич on 13.09.2024.
//

#import <React/RCTViewManager.h>
#import <SPaySdk/SPaySdk.h>

@interface AppYarnPackageViewManager : RCTViewManager
@end

@implementation AppYarnPackageViewManager

RCT_EXPORT_MODULE(AppYarnPackageView)

- (UIView *)view
{
	return [[SBPButton alloc] init];
}

@end
