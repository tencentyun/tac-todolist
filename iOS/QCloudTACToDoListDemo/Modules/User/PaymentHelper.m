//
//  PaymentHelper.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 22/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#define ORDER_URL @"http://carsonxu.com/tac/todo_list_demo_iOS_release.php"
#define kPaymentAppID @"TC102083"
#define kUserID @"rickenwang"
#import "PaymentHelper.h"
@import QCloudCore;
@implementation PaymentHelper
+ (void)placeOrder:(NSString *)channel completion:(GetPayInfoCompletion)competionBlock {
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = ORDER_URL;
    __weak typeof(request) weakRequest = request;
    
    
    NSString* orderNo;
    NSNumber* orderNumberValue;
    orderNumberValue = @((NSInteger)[[NSDate date] timeIntervalSince1970] + arc4random()%10000000 );
    orderNo = [NSString stringWithFormat:@"open_%@",orderNumberValue/*@"151999759238"?*/];
    
    
    NSDate* currentDate = [NSDate date];
    int64_t timeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval offset = destinationGMTOffset - sourceGMTOffset;
    NSString* UTCTimeInterval = [NSNumber numberWithLongLong:timeInterval-offset].stringValue;
    
    
    NSDictionary *paramters = @{@"domain":@"api.openmidas.com",
                                @"appid":kPaymentAppID,
                                @"user_id":kUserID,
                                @"out_trade_no":orderNo,
                                @"product_id":@"product_test",
                                @"currency_type":@"cny",
                                @"channel":channel,
                                @"amount":@"1",
                                @"original_amount":@"10",
                                @"product_name":@"test",
                                @"product_detail":@"iOS_ToDo_List",
                                @"ts":UTCTimeInterval,
                                @"sign":@"aaaaaaa"
                                };
    
    
    
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        requestSerializer.serializerBlocks = @[QCloudURLFuseWithURLEncodeParamters];
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil],nil),
                                                QCloudResponseJSONSerilizerBlock];
        
        if ( nil != paramters) {
            [paramters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [weakRequest.requestData setParameter:obj withKey:key];
            }];
        }
        
        
        [weakRequest setFinishBlock:^(id outputObject, NSError *error) {
            NSLog(@"outputObject:%@\nerror:%@\n",outputObject,error);
            if ([outputObject isKindOfClass:[NSDictionary class]]) {
                NSString *payInfo = [outputObject valueForKey:@"pay_info"];
                competionBlock(payInfo,nil);
            } else {
                competionBlock(nil, error);
            }
        }];
    }];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
}
@end
