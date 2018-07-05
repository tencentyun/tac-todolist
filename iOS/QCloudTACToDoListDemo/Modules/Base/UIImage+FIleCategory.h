//
//  UIImage+FIleCategory.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FIleCategory)

/**
 Only image type with PNG is supported

 @param name image file name
 @return iamge instance 
 */
+ (UIImage *)tacImageWithName:(NSString *)name;
+ (UIImage *)tacImageWithName:(NSString *)name type:(NSString*) type;
@end
