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
                                                                            redirectUri:@"sberPayExampleapp"
                                                                          merchantLogin:@"Test shop"
                                                                                 amount:*(_totalCost)
                                                                               currency:@""
                                                                            mobilePhone:@""
                                                                            orderNumber:@""
                                                                       recurrentExipiry:@""
                                                                     recurrentFrequency:0];

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
    [SBPay payWith:request completion:^(enum SBPayState state, NSString * _Nonnull info) {
        switch(state) {
            case SBPayStateSuccess:
                NSLog(@"Успешный результат");
                break;
            case SBPayStateWaiting:
                NSLog(@"Необходимо проверить статус оплаты");
                break;
            case SBPayStateError:
                NSLog(@"%@ - описание ошибки", info);
                break;
        }
    }];
}

-(void)fullPay {
    SBFullPaymentRequest *request = [[SBFullPaymentRequest alloc]
                                     initWithApiKey: @"awdawdawdajkdmdkladmka"
                                     merchantLogin: @"Test shop"
                                     orderId: @"12312312"
                                     language:nil
                                     redirectUri: @"sberPayExampleapp://sberidauth"
    ];
    [SBPay payWithOrderIdWithPaymentRequest:request completion:^(enum SBPayState state, NSString * _Nonnull info) {
        switch(state) {
            case SBPayStateSuccess:
                NSLog(@"Успешный результат");
                break;
            case SBPayStateWaiting:
                NSLog(@"Необходимо проверить статус оплаты");
                break;
            case SBPayStateError:
                NSLog(@"%@ - описание ошибки", info);
                break;
        }
    }];
}

-(void)completePayment {
    [SBPay completePaymentWithPaymentState: SBPayStateSuccess completion:^{
        // Блок отработает после закрытия окна SDK
    }];
}

@end

