//
//  LoginView.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "LoginView.h"
#import "UIImage+FIleCategory.h"
#import "UIColor+ColorCategory.h"
#import "UIDefine.h"

#define kLogoViewWidith 121.f
#define kLogoViewHeight 121.f
#define kLogoViewY  135.f

#define kButtonWidthLeading 30.f
#define KButtonTailing 30.f
#define kButtonHeight 44.f
#define kSpaceBetweenLogoAndButton 130.f
#define kSpaceBetweenButotns 30.f
//#define kButtonBackgroundColor [UIColor colorWithHex:0x006eff]
#define kButtonBackgroundColor kThemeColor
#define kButtonCornerRadius 9.0f

@interface LoginView()
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIButton *qqLoginButton;
@property (nonatomic, strong) UIButton *wechatLoginButton;

@end

@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self manageSubviews];
    self.backgroundColor = UIColor.whiteColor;
    return self;
}


- (void) manageSubviews {
    [self addSubview:self.logoView];
    [self addSubview:self.qqLoginButton];
    [self addSubview:self.wechatLoginButton];
    
    
    
    
    
    NSMutableArray* logoViewConstraints = [NSMutableArray array];
    [logoViewConstraints addObject:[self.logoView.widthAnchor constraintEqualToConstant:kLogoViewWidith]];
    
    [logoViewConstraints addObject:[self.logoView.heightAnchor constraintEqualToConstant:kLogoViewHeight]];
    
    [logoViewConstraints  addObject:[self.logoView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    
    [logoViewConstraints addObject:[self.logoView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kLogoViewY]];
    
    for (NSLayoutConstraint* constraint in logoViewConstraints) {
        constraint.active = YES;
        [self addConstraint:constraint];
    }
    
    NSMutableArray* qqLoginButtonConstraints = [NSMutableArray array];
    [qqLoginButtonConstraints addObject:[self.qqLoginButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kButtonWidthLeading]];
    [qqLoginButtonConstraints addObject:[self.qqLoginButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-KButtonTailing]];
    [qqLoginButtonConstraints addObject:[self.qqLoginButton.heightAnchor constraintEqualToConstant:kButtonHeight]];
    [qqLoginButtonConstraints addObject: [self.qqLoginButton.topAnchor constraintEqualToAnchor:self.logoView.bottomAnchor constant:kSpaceBetweenLogoAndButton]];
    for ( NSLayoutConstraint* constraint in qqLoginButtonConstraints ) {
        constraint.active = YES;
        [self addConstraint:constraint];
    }
    
    NSMutableArray* wechatLoginButtonConstraints = [NSMutableArray array];
    [wechatLoginButtonConstraints addObject:[self.wechatLoginButton.leadingAnchor constraintEqualToAnchor:self.qqLoginButton.leadingAnchor]];
    [wechatLoginButtonConstraints addObject: [self.wechatLoginButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-KButtonTailing]];
    [wechatLoginButtonConstraints addObject: [self.wechatLoginButton.heightAnchor constraintEqualToConstant:kButtonHeight]];
    [wechatLoginButtonConstraints addObject:[self.wechatLoginButton.topAnchor constraintEqualToAnchor:self.qqLoginButton.bottomAnchor constant:kSpaceBetweenButotns]];
    
    for ( NSLayoutConstraint* constraint in wechatLoginButtonConstraints ) {
        constraint.active = YES;
        [self addConstraint:constraint];
    }
    
}


#pragma mark - Button actions

- (void) onHandleQQLoginButtonClicked:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate performSelector:_cmd withObject:button];
    }
}
- (void) onHandleWechatLoginButtonClicked:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate performSelector:_cmd withObject:button];
    }
}


#pragma mark - Getters


- (UIImageView *)logoView {
    if (!_logoView) {
        _logoView = [[UIImageView alloc] init];
        _logoView.translatesAutoresizingMaskIntoConstraints = NO;
//        [_logoView setBackgroundColor:[UIColor blackColor]];
        [_logoView setImage:[UIImage tacImageWithName:@"tencent_cloud_logo" type:@"jpg"]];
    }
    return  _logoView;
}


- (UIButton *)qqLoginButton {
    if (!_qqLoginButton) {
        _qqLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qqLoginButton addTarget:self action:@selector(onHandleQQLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_qqLoginButton setBackgroundColor:UIColor.blackColor];
        [_qqLoginButton setBackgroundColor:kButtonBackgroundColor];
        _qqLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_qqLoginButton  setTitle:@"QQ登录" forState:UIControlStateNormal];
        _qqLoginButton.layer.cornerRadius = kButtonCornerRadius;
    }
    return  _qqLoginButton;
}

- (UIButton *)wechatLoginButton {
    if (!_wechatLoginButton) {
        _wechatLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_wechatLoginButton  addTarget:self action:@selector(onHandleWechatLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_wechatLoginButton setBackgroundColor:UIColor.blackColor];
        _wechatLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_wechatLoginButton setTitle:@"微信登录" forState:UIControlStateNormal];
        [_wechatLoginButton setBackgroundColor:kButtonBackgroundColor];
        _wechatLoginButton.layer.cornerRadius = kButtonCornerRadius;
    }
    return  _wechatLoginButton;
}

@end
