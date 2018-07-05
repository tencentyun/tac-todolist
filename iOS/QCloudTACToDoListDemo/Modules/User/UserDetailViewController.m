//
//  UserDetailViewController.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UserDetailViewController.h"
#import "UserDetailView.h"
#import "OnlineImageLoader.h"
#import "PaymentHelper.h"
@import TACPayment;
@import TACPaymentPluginQQ;
@import TACPaymentPluginWechat;
@interface UserDetailViewController ()

@property (nonatomic, strong) UserDetailView *detailView;



@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _detailView = [[UserDetailView alloc] initWithFrame:self.view.bounds];
    __weak typeof(self) weakSelf = self;
    _detailView.payButtonAction = ^(UIButton *button) {
        [weakSelf showPayAlert];
    };
    [self.view addSubview:_detailView];
    
    [[TACApplication defaultApplication] bindUserIdentifier:@"TAC_TODOLIST_TEST"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.detailView setNickName:self.user.openUserInfo.nickName];
    [[OnlineImageLoader sharedInstance] loadImageWithURL:self.user.openUserInfo.avatar.absoluteString completionHandler:^(UIImage *image, NSError *error) {
        if ( nil == error ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.detailView setAvatar:image];
            });
        }
    }];
}


- (void)showPayAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"充值0.01" message:@"充值开通会员" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *QQpayButton = [UIAlertAction actionWithTitle:@"QQ支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PaymentHelper placeOrder:@"qqwallet" completion:^(NSString *payInfo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TACPaymentService defaultService] pay:payInfo appMeataData:nil completation:^(TACPaymentResult *result) {
                    TACLogDebug(@"支付结果 %d %@", result.resultCode, result.resultMsg);
                }];
            });
        }];
    }];
    
    UIAlertAction *wechatButton = [UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PaymentHelper placeOrder:@"wechat" completion:^(NSString *payInfo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TACPaymentService defaultService] pay:payInfo appMeataData:nil completation:^(TACPaymentResult *result) {
                    TACLogDebug(@"支付结果 %d %@", result.resultCode, result.resultMsg);
                }];
            });
        }];
    }];
    
    [alertController addAction:QQpayButton];
    [alertController addAction:wechatButton];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (User *)user {
    if (!_user) {
        _user = [User currentUser];
    }
    return _user;
}

@end
