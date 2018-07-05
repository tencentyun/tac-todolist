//
//  PaymentHelper.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 22/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^GetPayInfoCompletion)(NSString * payInfo, NSError * error);

@interface PaymentHelper : NSObject
+ (void)placeOrder:(NSString *)channel completion:(GetPayInfoCompletion)competionBlock;
@end
