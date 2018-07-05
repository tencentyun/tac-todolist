//
//  QCloudAlert.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCloudAlert : NSObject

+ (void) showAlertWithTitle:(NSString *)title content:(NSString *)content buttonText:(NSString *)buttonText;

@end
