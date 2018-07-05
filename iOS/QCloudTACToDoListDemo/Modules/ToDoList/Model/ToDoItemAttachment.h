//
//  ToDoItemAttachment.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 20/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface ToDoItemAttachment : NSObject

/**
 This property might be nil if the image is never loaded. With imageAddress exsited, you can still retrieve image data from this property but it might take some time. Dont's access it at main thred according to that.
 */
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageAddress;

@end
