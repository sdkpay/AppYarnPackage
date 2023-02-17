//
//  FingerprintWrapper.h
//  FingerprintWrapper
//
//  Created by Guseinov Artur on 23.07.2020.
//  Copyright © 2020 BIZONE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CachingTime
{
    CACHE_DISABLED = 0,
    TEST_PERIOD_FOR_20_SECS = 20000,
    ONE_DAY = 86400000,
    TWO_DAYS = 172800000,
    THREE_DAYS = 259200000,
    FOUR_DAYS = 345600000
} CachingTime;


@interface FingerprintWrapper : NSObject
{
    @public
    enum CachingTime cachingTime;
}

+ (instancetype)sharedInstance;
- (NSString*)getDeviceName;
- (NSString*)oldJsonBasicData;
- (NSString*)oldJsonBasicDataWithCoord;
- (NSString*)extOldJsonBasicData;
- (NSString*)mixOldJsonBasicData;
- (NSString*)mixOldJsonBasicDataWithCoord;
- (NSString*)activeFingerprintData;
- (NSString*)customJsonData:(NSArray *)metrics;
- (NSDictionary*)customRawData:(NSArray *)metrics;

@property (nonatomic,assign) BOOL useRSAAppKey;

@property (nonatomic,assign) NSString* keyForHMACHash;

@property (nonatomic,assign) BOOL useAdvertiserID;

@property (nonatomic,assign) BOOL useBluetoothMetrics;

@property (nonatomic,assign) BOOL useLAContext;

@property (nonatomic,strong) NSDictionary* patches;

@property (nonatomic,strong) NSMutableArray* parameters;

@end

