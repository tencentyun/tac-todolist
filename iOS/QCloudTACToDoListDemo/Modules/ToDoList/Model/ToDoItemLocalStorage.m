//
//  ToDoItemLocalStorage.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoItemLocalStorage.h"



@implementation ToDoItemLocalStorage
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ToDoItemLocalStorage *instance;
    dispatch_once(&onceToken, ^{
        instance = [[ToDoItemLocalStorage alloc] init];
    });
    return instance;
}


- (instancetype)init {
    self = [super init];
    _itemsArray = [NSMutableArray array];
//    for (int i = 0; i < 20; i ++) {
//        ToDoItem *item = [[ToDoItem alloc] init];
//        item.title = [NSString stringWithFormat:@"here is %i",i];
//        [_itemsArray addObject:item];
//    }
    return self;
}


@end
