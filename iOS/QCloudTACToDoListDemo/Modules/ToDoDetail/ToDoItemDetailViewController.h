//
//  ToDoItemDetailViewController.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 13/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToDoItem;
@interface ToDoItemDetailViewController : UIViewController
@property (nonatomic, strong) ToDoItem *todoItem;
@end
