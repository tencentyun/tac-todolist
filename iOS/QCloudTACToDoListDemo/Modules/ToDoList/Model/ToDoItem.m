//
//  ToDoItem.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoItem.h"
#import "ToDoItemAttachment.h"

@import QCloudCore;
@import SDWebImage;

#define kQCloudSubfix @"myqcloud"
@implementation ToDoItem

- (instancetype)init {
    self = [super init];
    _attachments = [NSMutableArray array];
    _isDeleted = NO;
    _uuid = @"";
    _title = @"";
    _content = @"";
    return self;
}
- (void)addAttachment:(ToDoItemAttachment *)attachment {
    @synchronized(self) {
        [self.attachments addObject:attachment];
    }
}

- (NSAttributedString *)attributedStringWithAttributes:(NSDictionary *)attributes completionBlock:(void(^)(NSAttributedString* attributedString))completion {
    __block NSMutableAttributedString *attributedString;
    if (self.title) {
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.title attributes:attributes];
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    for (ToDoItemAttachment *attachment in self.attachments) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        if (nil != attachment.image) {
            textAttachment.bounds = CGRectMake(0, 0, attachment.image.size.width/scale,attachment.image.size.height/scale);
            textAttachment.image = attachment.image;
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                
                void (^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                QCloudLogDebug(@"Image %@ download Progress :%.2f",targetURL,(double)receivedSize/(double)expectedSize);
                };
                
                void (^completionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (error) {
                        QCloudLogDebug(@"Download Image Error is %@",error);
                        completion(nil);
                        return ;
                    }
                    attachment.image = image;
                    textAttachment.bounds = CGRectMake(0, 0, attachment.image.size.width/scale,attachment.image.size.height/scale);
                    textAttachment.image = attachment.image;
                    completion(attributedString);
                };
                
                
                NSString *downloadURL = [self.attachments.firstObject imageAddress];
//                if ([downloadURL containsString:kQCloudSubfix]) {
//                    //Tencent Cloud Link
//                } else {
                [self downloadViaSDWebImageWithURL:downloadURL ProgressBlock:progressBlock completionBlock:completionBlock];
//                }
                
               
                
            });
            textAttachment.bounds = CGRectMake(0, 0, 50,50);
            textAttachment.image = nil;
        }
        NSAttributedString *attachmentAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString appendAttributedString:attachmentAttributedString];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];
    }
    return attributedString;
}


- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    ToDoItem *item = object;
    return [self.uuid isEqualToString:item.uuid] && [self.title isEqual:item.title];
}


- (void)downloadViaSDWebImageWithURL:(NSString *)url
                       ProgressBlock:( void (^)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL))progressBlock
                     completionBlock:(  void (^)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) ) completionBlock {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [[manager imageDownloader] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderUseNSURLCache progress:progressBlock completed:completionBlock];
    
}


- (void) downloadViaTACStorageWithURL:(NSString *)url
                        ProgressBlock:( void (^)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL))progressBlock
                      completionBlock:(  void (^)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) ) completionBlock {
}


@end
