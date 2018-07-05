//
//  UIColor+ColorCategory.m
//  QCloudTPGDemo
//
//  Created by erichmzhang(张恒铭) on 17/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UIColor+ColorCategory.h"

@implementation UIColor (ColorCategory)
+ (instancetype)colorWithHex:(u_int32_t)hex {
    
    int red = (hex & 0xFF0000) >> 16;
    
    int green = (hex & 0x00FF00) >> 8;
    
    int blue = hex & 0x0000FF;
    
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
    
}
@end
