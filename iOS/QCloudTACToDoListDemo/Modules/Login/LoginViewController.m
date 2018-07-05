//
//  LoginViewController.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginView.h"
@import TACSocialShare;
@import TACAuthorizationQQ;
@import TACAuthorizationWechat;
#import "ToDoListViewController.h"
#import "QCloudAlert.h"
#import "User.h"

#define DEBUG_

@interface LoginViewController ()<LoginViewDelegate>

@property (nonatomic, strong) LoginView *loginView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginView = [[LoginView alloc] initWithFrame:self.view.bounds];
    self.loginView.delegate = self;
    self.view.backgroundColor = UIColor.whiteColor;
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.loginView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void) onHandleLoginSuccessWithInfo:(TACOpenUserInfo *)info {
    User *currentUser = [[User alloc] initWithOpenUserInfo:info];
    [User setCurrentUser:currentUser];
    [self presentToDoListViewController];
}


- (void) onHandleLoginFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [QCloudAlert showAlertWithTitle:@"登录失败" content:[NSString stringWithFormat:@"%@",error] buttonText:@"确定"];
    });
}

- (void)onHandleQQLoginButtonClicked:(UIButton *)button {
    TACQQAuthProvider* provider = [[TACAuthoriztionService defaultService] qqCredentialProvider];
    [provider requestCredential:^(TACQQCredential*credential, NSError *error) {
        if (error) {
            TACLogError(@"ERROR %@", error);
        } else {
            [provider requestUserInfoWithCredential:credential completation:^(TACOpenUserInfo *userInfo, NSError *error) {
                if (error) {
                    [self onHandleLoginFailWithError:error];
                } else {
                    [self onHandleLoginSuccessWithInfo:userInfo];
                }
            }];
            
            TACLogDebug(@"Credential %@", credential);
        }
    }];
}

- (void)onHandleWechatLoginButtonClicked:(UIButton *)button {
    TACWechatAuthProvider* provider = [[TACAuthoriztionService defaultService] wechatCredentialProvider];
    [provider requestCredential:^(TACWechatCredential *credential, NSError *error) {
        if (error) {
            TACLogError(@"ERROR %@", error);
        } else {
            [provider requestUserInfoWithCredential:credential completation:^(TACOpenUserInfo *userInfo, NSError *error) {
                if (error) {
                    [self onHandleLoginFailWithError:error];
                } else {
                    [self onHandleLoginSuccessWithInfo:userInfo];
                }
            }];
            TACLogDebug(@"Credential %@", credential);
        }
    }];
}

- (void)presentToDoListViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        ToDoListViewController *vc = [[ToDoListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
