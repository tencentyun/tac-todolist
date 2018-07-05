//
//  LoginView.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewDelegate<NSObject>

- (void) onHandleQQLoginButtonClicked:(UIButton *)button;
- (void) onHandleWechatLoginButtonClicked:(UIButton *)button;

@end

@interface LoginView : UIView

@property (nonatomic, weak) id<LoginViewDelegate> delegate;

@end
