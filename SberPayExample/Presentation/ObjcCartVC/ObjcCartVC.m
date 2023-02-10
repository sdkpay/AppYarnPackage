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
    SBPaymentTokenRequest *requestModel = [[SBPaymentTokenRequest alloc] initWithApiKey:@""
                                                                               clientId:@""
                                                                             clientName: @"Test shop"
                                                                                 amount:1
                                                                               currency:@""
                                                                            mobilePhone:@""
                                                                            orderNumber:@""
                                                                       orderDescription:@""
                                                                               language:@""
                                                                       recurrentEnabled:YES
                                                                       recurrentExipiry:@""
                                                                     recurrentFrequency:1
                                                                            redirectUri:@"sberPayExample.app"];
    
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
                                     currency: @"RUB"
                                     mobilePhone: nil
                                     orderId: @"12312312"
                                     orderDescription:nil
                                     language:nil
                                     redirectUri: @"sberPayExample.app://sberidauth"
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

