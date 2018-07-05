//
//  OnlineImageLoader.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OnlineImageLoader : NSObject

+ (instancetype)sharedInstance;

- (void) loadImageWithURL:(NSString *)url completionHandler:(void(^)(UIImage *image, NSError *error))completion;

@end
