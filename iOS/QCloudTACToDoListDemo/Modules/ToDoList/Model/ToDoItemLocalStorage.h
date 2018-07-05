//
//  ToDoItemLocalStorage.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToDoItem.h"
#import "ToDoItemStorage.h"
@interface ToDoItemLocalStorage : ToDoItemStorage

+ (instancetype) sharedInstance;

@property (nonatomic, strong) NSMutableArray<ToDoItem *>* itemsArray;

@end
