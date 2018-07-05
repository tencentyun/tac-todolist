//
//  ToDoListTableViewCell.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kBodyViewHeight 80.f
#define kBodyViewTopSpacing 10.f
@interface ToDoListTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^completeButtonHandler)(UIButton *button , UITableViewCell *cell);
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString* content;

@property (nonatomic, assign) BOOL isEditting;

@end
