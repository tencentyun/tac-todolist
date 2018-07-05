//
//  User.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@import TACAuthorization;
@interface User : NSObject
+ (User *)currentUser;
+ (void) setCurrentUser:(User *)currentUser;
- (instancetype) initWithOpenUserInfo:(TACOpenUserInfo *)userInfo;
- (instancetype) init NS_UNAVAILABLE;
@property (nonatomic, readonly) TACOpenUserInfo *openUserInfo;
@end
