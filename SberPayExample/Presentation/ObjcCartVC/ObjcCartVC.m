//
//  ObjcCartVC.m
//  SberPayExample
//
//  Created by Alexander Ipatov on 14.11.2022.
//

#import <UIKit/UIKit.h>
#import "ObjcCartVC.h"
#import "SberPaySDK.h"

@interface ObjcCartVC ()

@property (assign, nonatomic) NSInteger* totalCost;
@property (assign, nonatomic) NSString* apiKey;
@property (assign, nonatomic) NSString* orderId;
@property (assign, nonatomic) BOOL autoMode;
@property (assign, nonatomic) BOOL mocksOn;
@property (assign, nonatomic) BOOL sslOn;

@end

@implementation ObjcCartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Objc";
    self.view.backgroundColor = UIColor.whiteColor;
    if ([SBPay isReadyForSberPay]) {
        [self setupSBPayButton];
    }
}

- (instancetype)initWithTotalCost:(NSInteger *)totalCost
                           apiKey:(NSString *)apiKey
                          orderId:(NSString *)orderId
                         autoMode:(BOOL *)autoMode
                          mocksOn:(BOOL *)mocksOn
                            sslOn:(BOOL *)sslOn {
    self = [super init];
    if (self) {
        self.totalCost = totalCost;
        self.apiKey = apiKey;
        self.orderId = orderId;
        self.autoMode = autoMode;
        self.mocksOn = mocksOn;
        self.sslOn = sslOn;
    }
    
    return self;
}

- (void)setupSBPayButton {
    SBPButton* button = [[SBPButton alloc] init];
    button.tapAction = ^{
        [self sbButtonTapped];
    };
    button.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview: button];
    [button.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant: 20.0].active = YES;
    [button.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant: -20.0].active = YES;
}

-(void)sbButtonTapped {
    if (SBPay.isReadyForSberPay) {
        
    }
    SBPaymentTokenRequest *requestModel = [[SBPaymentTokenRequest alloc] initWithApiKey:_apiKey
                                                                               clientId:@""
                                                                             clientName:@"Test shop"
                                                                                 amount:*(_totalCost)
                                                                               currency:@""
                                                                                orderId:_orderId
                                                                            mobilePhone:@""
                                                                            orderNumber:@""
                                                                       orderDescription:@""
                                                                               language:@""
                                                                       recurrentEnabled:false
                                                                       recurrentExipiry:@""
                                                                     recurrentFrequency:1
                                                                            redirectUri:@"sberPayExampleapp"];

    [SBPay getPaymentTokenWith: requestModel  completion:^(SBPaymentTokenResponse * _Nonnull response) {
        if (response.error) {
            // Обработка ошибки
            NSLog(@"%@ - описание ошибки", response.error.errorDescription);
        } else {
            // Обработка успешно полученных данных
        }
    }];
}

-(void)pay {
    SBPaymentRequest *request = [[SBPaymentRequest alloc] initWithApiKey: @""
                                                                 orderId: @""
                                                            paymentToken: @""];
    
    [SBPay payWith:request completion:^(SBPError * _Nullable error) {
        if (error) {
            // Обработка ошибки
            NSLog(@"%@ - описание ошибки", error.errorDescription);
        } else {
            // Успешный результат
        }
    }];
}

-(void)fullPay {
    SBFullPaymentRequest *request = [[SBFullPaymentRequest alloc]
                                     initWithApiKey: @"awdawdawdajkdmdkladmka"
                                     clientId: @"123123"
                                     clientName: @"Test shop"
                                     amount: 123123
                                     currency: @"643"
                                     mobilePhone: nil
                                     orderId: @"12312312"
                                     orderDescription:nil
                                     language:nil
                                     redirectUri: @"sberPayExampleapp://sberidauth"
    ];
    [SBPay payWithOrderIdWithPaymentRequest:request completion:^(SBPError * _Nullable error) {
        if (error) {
            // Обработка ошибки
            NSLog(@"%@ - описание ошибки", error.errorDescription);
        } else {
            // Успешный результат
        }
    }];
}

-(void)completePayment {
    [SBPay completePaymentWithPaymentSuccess:YES completion:^{
            // Блок отработает после закрытия окна SDK
    }];
}

@end

