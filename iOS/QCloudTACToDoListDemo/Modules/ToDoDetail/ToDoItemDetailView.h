//
//  ToDoItemDetailView.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 13/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AttachmentAction) {
    ATTACHMENT_ACTION_DELETE,
    ATTACHMENT_ACTION_INSERT
};

@protocol ToDoItemViewDelegate<NSObject>



- (void)textDidChagne:(NSString *)text;

/**
 Every time attachment change (like inserting or deleting img) will trigger this method. The entity instance should commit correspoding change

 @param attachments attachments array
 */
- (void)onHandleAttachmentChanged:(UIImage *)attachments action:(AttachmentAction)action;

- (void)onHandleAddPictureButtonClicked:(UIButton *)button;

@end

@interface ToDoItemDetailView : UIView

@property (nonatomic, strong) id text;

@property (nonatomic, assign) BOOL isEditting;

@property (nonatomic, weak) id delegate;


/**
 Append attachment at the end of text

 @param attachment attachment image
 */
- (void) appendAttachment:(UIImage *)attachment;

@end
