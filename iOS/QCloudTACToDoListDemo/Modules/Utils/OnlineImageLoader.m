//
//  OnlineImageLoader.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "OnlineImageLoader.h"
@import QCloudCore;
@interface OnlineImageLoader()
@property (nonatomic, strong) NSCache *cache;
@end


@implementation OnlineImageLoader

+ (instancetype)sharedInstance {
    static OnlineImageLoader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OnlineImageLoader alloc] init];
    });
    return instance;
}

- (void) loadImageWithURL:(NSString *)url completionHandler:(void(^)(UIImage *image, NSError *error))completion {
    NSData *imageData = [self.cache objectForKey:url];
        if (nil != imageData) {
            completion([UIImage imageWithData:imageData], nil);
        return ;
    }
    
    
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = url;
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil], nil)];
    }];
    [request setFinishBlock:^(id outputObject, NSError *error) {
        if ( nil == error) {
            UIImage *resultImage = [UIImage imageWithData:outputObject];
            completion(resultImage,nil);
            [self.cache setObject:outputObject forKey:url];
        } else {
            completion (nil,error);
        }
        
    }];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.totalCostLimit = 10;
    }
    return _cache;
}


@end
