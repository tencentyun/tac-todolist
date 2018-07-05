//
//  User.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "User.h"
static User *instance;
@implementation User
+ (User *)currentUser {
    return instance;
}

+ (void) setCurrentUser:(User *)currentUser {
    instance = currentUser;
}

- (instancetype) initWithOpenUserInfo:(TACOpenUserInfo *)userInfo {
    self = [super init];
    _openUserInfo = userInfo;
    return self;
}


@end
