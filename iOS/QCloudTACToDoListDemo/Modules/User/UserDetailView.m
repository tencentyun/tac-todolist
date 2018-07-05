//
//  UserDetailView.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UserDetailView.h"
#import "UIView+Base.h"
#import "UIDefine.h"
#define kAvatarViewWidth 100
#define kAvatarViewY     160.f

#define kVerticalSpacingBetweenNickNameLabelAndAvatarView 50.f
#define kNickNameLabelHeight 50.f


#define kButtonCornerRadius 9.0f
#define kPayButtonLeft 30.f
#define kPayButtonRight 30.f
#define kPayButtonHeight 50.f
@interface UserDetailView()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nicknameLabel;
    
    
@property (nonatomic, strong) UIButton *payButton;

@end

@implementation UserDetailView



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.avatarView];
    [self addSubview:self.nicknameLabel];
    [self addSubview:self.payButton];
    return self;
}


- (void)onHandlePayButtonClicked:(UIButton *)button {
    if (self.payButtonAction) {
        self.payButtonAction(button);
    }
}

- (void)setAvatar:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.avatarView setImage:image];
    });
    
}
- (void)setNickName:(NSString *)nickName {
    [self.nicknameLabel  setText:nickName];
}



#pragma mark - Getters
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.left = (kScreenWidth-kAvatarViewWidth)/2;
        _avatarView.top = kAvatarViewY;
        _avatarView.width = _avatarView.height = kAvatarViewWidth;
        _avatarView.layer.cornerRadius = _avatarView.width/2;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel   = [[UILabel alloc] initWithFrame:CGRectMake(0, self.avatarView.bottom + kVerticalSpacingBetweenNickNameLabelAndAvatarView, kScreenWidth, kNickNameLabelHeight)];
        _nicknameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nicknameLabel;
}
    
- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _payButton.frame = CGRectMake(kPayButtonLeft, self.nicknameLabel.top + 50.f, kScreenWidth-kPayButtonRight-kPayButtonLeft, kPayButtonHeight);
        _payButton.backgroundColor = UIColor.blackColor;
        _payButton.layer.cornerRadius = kButtonCornerRadius;
        _payButton.clipsToBounds = YES;
        [_payButton setTitle:@"支付开通会员" forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(onHandlePayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}

@end
