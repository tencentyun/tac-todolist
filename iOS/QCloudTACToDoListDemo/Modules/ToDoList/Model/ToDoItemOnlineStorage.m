//
//  ToDoItemOnlineStorage.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoItemOnlineStorage.h"
#import "User.h"
#import "ToDoItemAttachment.h"
@import QCloudCore;
NSString* const listURLPrefix = @"http://tac.cloud.tencent.com/client/todo/list";
NSString* const updateURLPrefix = @"http://tac.cloud.tencent.com/client/todo/update";
NSString* const addURLPrefix = @"http://tac.cloud.tencent.com/client/todo/add";
NSString* const removeURLPrefix  = @"http://tac.cloud.tencent.com/client/todo/remove";
NSString* const kUserIDKey = @"user_id";
NSString* const kContentKey = @"content";
NSString* const kIDKey = @"id";


//#define DEBUG_USER 1
@implementation ToDoItemOnlineStorage


+ (void)requestOnlineToDoItemWithFinishBlock:(void(^)(NSArray* todoItems, NSError *error))finishBlock {
#ifdef DEBUG_USER
    NSString * user = @"demo";
#else
    NSString *user = User.currentUser.openUserInfo.openID;
#endif
    NSDictionary *paramters = @{kUserIDKey:user};
    [self performRequestWithURL:listURLPrefix Paramters:paramters headers:nil finishBlock:^(id outputObject, NSError *error) {
        if (nil != error) {
            finishBlock(nil,error);
        } else {
            NSMutableArray *todoItemsArray = [NSMutableArray array];
            NSArray *tempArray = [outputObject valueForKey:@"data"];
            if ( tempArray && [tempArray isKindOfClass:NSArray.class] && (tempArray.count > 0) ) {
                for ( NSDictionary *dict in tempArray) {
                    ToDoItem *item = [ToDoItem new];
                    item.title = dict [@"content"];
                    ToDoItemAttachment *attachment = [[ToDoItemAttachment alloc] init];
                    [item.attachments addObject:attachment];
                    attachment.imageAddress = dict[@"url"];
                    item.uuid = [NSString stringWithFormat:@"%@",dict[@"id"]];
                    [todoItemsArray addObject:item];
                }
            }
            finishBlock (todoItemsArray, nil);
        }
    }];
    

}

+ (void)addItem:(ToDoItem *)item withFinishBlock:(void (^)(NSDictionary *,NSError *))finishBlock {
#ifdef DEBUG_USER
    NSString * user = @"demo";
#else
    NSString *user = User.currentUser.openUserInfo.openID;
#endif
    NSDictionary *paramters = @{kUserIDKey:user,kContentKey:item.content};
    [self performRequestWithURL:addURLPrefix Paramters:paramters headers:nil finishBlock:^(id outputObject, NSError *error) {
        finishBlock(outputObject,error);
    }];
}


+ (void)deleteItem:(ToDoItem *)item withFinishBlock:(void (^)(NSError *))finishBlock {
#ifdef DEBUG_USER
    NSString * user = @"demo";
#else
    NSString *user = User.currentUser.openUserInfo.openID;
#endif
    NSDictionary *paramters = @{kUserIDKey:user,kIDKey:item.uuid};
    [self performRequestWithURL:removeURLPrefix Paramters:paramters headers:nil finishBlock:^(id outputObject, NSError *error) {
        finishBlock(error);
    }];
}


+ (void) updateItem:(ToDoItem *)item WithFinishBlock:(void(^)(NSError *error))finishBlock {
#ifdef DEBUG_USER
    NSString * user = @"demo";
#else
    NSString *user = User.currentUser.openUserInfo.openID;
#endif
    NSString *content = @"";
    if (!item.title) {
        content = item.title;
    }
    
    NSMutableDictionary *paramters = [[NSMutableDictionary alloc] initWithDictionary: @{kUserIDKey:user,kIDKey:item.uuid,kContentKey:item.title}];
    if (item.attachments.count > 0) {
        paramters[@"url"] = [item.attachments.firstObject imageAddress];
        QCloudLogDebug(@"Image Address %@",paramters[@"url"]);
    }
    QCloudLogDebug(@"Update Item :%@\nTitle:%@\n",item.uuid,item.title);
    [self performRequestWithURL:updateURLPrefix Paramters:paramters headers:nil finishBlock:^(id outputObject, NSError *error) {
        finishBlock(error);
    }];

}


+ (void) performRequestWithURL:(NSString *)URL
                     Paramters:(NSDictionary *)paramters
                                headers:(NSDictionary *)headers
                            finishBlock:(void(^)(id outputObject, NSError *error))finishBlock {
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = URL;
    __weak typeof(request) weakRequest = request;
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        requestSerializer.serializerBlocks = @[QCloudURLFuseWithURLEncodeParamters];
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil],nil),
                                                QCloudResponseJSONSerilizerBlock];
        
        if ( nil != paramters) {
            [paramters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [weakRequest.requestData setParameter:obj withKey:key];
            }];
        }
        
        if (nil != headers) {
            [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [weakRequest.requestData setValue:obj forHTTPHeaderField:key];
            }];
        }
        
        [weakRequest setFinishBlock:finishBlock];
    }];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
}

//+ (NSArray *)mergeLocalItems:(NSArray <ToDoItem*>*)localItems WithOnlineItems:(NSArray<ToDoItem*>*)onlineItems {
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    __block   NSMutableArray *result = [NSMutableArray array];
//    [self requestOnlineToDoItemWithFinishBlock:^(NSArray *todoItems, NSError *error) {
//        if (nil == error) {
//            QCloudLogDebug(@"Fetch online data fail!");
//        } else {
//            for (ToDoItem *localItem in localItems ) {
//                if (!localItem.isDeleted) {
//                    [result addObject:localItem];
//                }
//            }
//            for (ToDoItem *onlineItem in onlineItems) {
//                NSString *uuid = onlineItem.uuid;
//                BOOL existed = NO;
//                for (ToDoItem *localItem in localItems ) {
//                    if ([localItem.uuid isEqualToString:uuid]) {
//                        existed = YES;
//                        break;
//                    }
//                }
//                if (!existed) {
//                    [result addObject:onlineItem];
//                }
//            }
//        }
//    }];
//    dispatch_semaphore_wait(semaphore, 5*NSEC_PER_SEC);
//    return [result copy];
//}


@end
