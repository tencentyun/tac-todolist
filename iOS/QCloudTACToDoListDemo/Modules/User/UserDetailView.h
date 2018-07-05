//
//  UserDetailView.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailView : UIView
@property (nonatomic, copy)void(^payButtonAction)(UIButton *button);

- (void)setAvatar:(UIImage *)image;
- (void)setNickName:(NSString *)nickName;

@end
