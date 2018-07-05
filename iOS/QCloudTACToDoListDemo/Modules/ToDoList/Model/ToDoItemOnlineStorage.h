//
//  ToDoItemOnlineStorage.h
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToDoItemStorage.h"
#import "ToDoItem.h"

@interface ToDoItemOnlineStorage : ToDoItemStorage

+ (void) requestOnlineToDoItemWithFinishBlock:(void(^)(NSArray* todoItems, NSError *error))finishBlock;

//+ (void) pushTodoItemsWithArray:(NSArray <ToDoItem *>* )todoItems  finishBlock:(void(^)(NSArray* todoItems, NSError *error))finishBlock;

+ (void) addItem:(ToDoItem *)item withFinishBlock:(void(^)(NSDictionary* outputObject,NSError *error))finishBlock;

+ (void) deleteItem:(ToDoItem *)item withFinishBlock:(void(^)(NSError *error))finishBlock;


+ (void) updateItem:(ToDoItem *)item WithFinishBlock:(void(^)( NSError *error))finishBlock;

@end
