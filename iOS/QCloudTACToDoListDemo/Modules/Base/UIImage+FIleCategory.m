//
//  UIImage+FIleCategory.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UIImage+FIleCategory.h"

@implementation UIImage (FIleCategory)
+ (UIImage *)tacImageWithName:(NSString *)name {
    return [self tacImageWithName:name type:@"png"];
}

+ (UIImage *)tacImageWithName:(NSString *)name type:(NSString*) type {
    NSString *imageURL = [[NSBundle mainBundle] pathForResource:name ofType:type];
    UIImage *result = [UIImage imageWithContentsOfFile:imageURL];
    return result;
}
@end
