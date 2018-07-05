//
//  ToDoItem.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

@import Foundation;
@import UIKit;
@class ToDoItemAttachment;
@interface ToDoItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSMutableArray *attachments;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) NSDate *deadline;
@property (nonatomic, strong) NSDate *remindDate;
@property (nonatomic, assign) BOOL isDeleted;
- (void)addAttachment:(ToDoItemAttachment *)attachment;

/**
 This Method might take a long time if the image is not storaged in local

 @param attributes attributed string
 @return attributedString
 */
//- (NSAttributedString *)attributedStringWithAttributes:(NSDictionary *)attributes;

- (NSAttributedString *)attributedStringWithAttributes:(NSDictionary *)attributes completionBlock:(void(^)(NSAttributedString* attributedString))completion;
@end
