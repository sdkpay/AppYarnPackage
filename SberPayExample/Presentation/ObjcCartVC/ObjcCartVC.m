//
//  ObjcCartVC.m
//  SPayExample
//
//  Created by Alexander Ipatov on 14.11.2022.
//

#import <UIKit/UIKit.h>
#import "ObjcCartVC.h"
#import "SPaySdkDEBUG.h"

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
    if ([SPay isReadyForSPay]) {
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
    if (SPay.isReadyForSPay) {

    }
    
    SConfig *config = [[SConfig alloc] initWithSbp:true creditCard:true debitCard:true];
    
     [SPay setupWithBnplPlan:true
              spasiboBonuses:true
            resultViewNeeded: true
                    helpers:true
                    needLogs: true
               helperConfig: config
                environment: SEnvironmentProd
                  completion:nil];
    
}

-(void)pay {
}

-(void)fullPay {
    SBankInvoiceIdPaymentRequest *request = [[SBankInvoiceIdPaymentRequest alloc] initWithMerchantLogin: @"Test shop"
                                                                                          bankInvoiceId:@"12312312"
                                                                          orderNumber:@"12312312"
                                                                             language:nil
                                                                          redirectUri:@"testapp://test"
                                                                               apiKey: @"a12312"];
    
    [SPay payWithBankInvoiceIdWith:self paymentRequest:request completion:^(enum SPayState state,
                                                                            NSString * _Nonnull info,
                                                                            NSString * _Nonnull localSessionId) {
        switch(state) {
            case SPayStateSuccess:
                NSLog(@"Успешный результат");
                break;
            case SPayStateWaiting:
                NSLog(@"Необходимо проверить статус оплаты");
                break;
            case SPayStateCancel:
                NSLog(@"Отмена");
                break;
            case SPayStateError:
                NSLog(@"%@ - описание ошибки", info);
                break;
        }
    }];
}

-(void)completePayment {
}

@end

