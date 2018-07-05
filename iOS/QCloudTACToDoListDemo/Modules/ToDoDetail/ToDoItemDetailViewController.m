//
//  ToDoItemDetailViewController.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 13/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoItemDetailViewController.h"
#import "ToDoItemDetailView.h"
#import "ToDoItem.h"
#import "UIDefine.h"
#import "UIImage+FIleCategory.h"
#import "ToDoItemOnlineStorage.h"
#import "ToDoItemAttachment.h"
#import <QCloudCore/QCloudCredential.h>
#import <TACSocialShare/TACShareDataUploader.h>
@import TACSocialShare;
@import QCloudCore;
@import QCloudCOSXML;
@import TACStorage;
@interface ToDoItemDetailViewController ()<ToDoItemViewDelegate,UIImagePickerControllerDelegate,QCloudCredentailFenceQueueDelegate>

@property (nonatomic, strong) ToDoItemDetailView *detailView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) TACShareDialog *shareDialog;
@end

@implementation ToDoItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.detailView];
    self.title = @"Detail";
    self.shareDialog = [[TACShareDialog alloc] init];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(onHandleSaveButtonClicked:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(onHandleShareButtonClicked:)];
    self.navigationItem.rightBarButtonItems = @[finishButton,shareButton];
    
    [TACStorageService defaultStorage].credentailFenceQueue.delegate = self;
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TACShareDataUploader trackShareViewOpen];
    if (self.todoItem) {
//        [self.detailView setText:[self.todoItem attributedStringWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.f]}]];
        
        __weak typeof(self.detailView) weakView = self.detailView;
        [self.detailView setText:[self.todoItem attributedStringWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.f]} completionBlock:^(NSAttributedString *string) {
            if (string) {
                [weakView setText:string];
            }
        }]];
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ToDoItemOnlineStorage updateItem:self.todoItem WithFinishBlock:^(NSError *error) {
        if (!error) {
            NSLog(@"Update item imformation fail! item id %@,error %@",self.todoItem.uuid,error);
        }
    }];
}

- (void)fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock {
    QCloudHTTPRequest* request = [QCloudHTTPRequest new];
    request.requestData.serverURL = [NSString stringWithFormat:@"https://tac.cloud.tencent.com/client/sts?bucket=%@",[TACStorageService defaultStorage].rootReference.bucket];
    [request setConfigureBlock:^(QCloudRequestSerializer *requestSerializer, QCloudResponseSerializer *responseSerializer) {
        responseSerializer.serializerBlocks = @[QCloudAcceptRespnseCodeBlock([NSSet setWithObjects:@(200), nil], nil),
                                                QCloudResponseJSONSerilizerBlock];
    }];
    void(^NetworkCall)(id response, NSError* error) = ^(id response, NSError* error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            NSInteger code  = [response[@"code"] integerValue];
            if (response[@"code"] && code == 0) {
                QCloudCredential* crendential = [[QCloudCredential alloc] init];
                crendential.secretID = response[@"credentials"][@"tmpSecretId"];
                crendential.secretKey = response[@"credentials"][@"tmpSecretKey"];
                crendential.experationDate = [NSDate dateWithTimeIntervalSinceNow:[response[@"expiredTime"] intValue]];
                crendential.token = response[@"credentials"][@"sessionToken"];;
                QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:crendential];
                continueBlock(creator, nil);
            } else {
                error = [NSError errorWithDomain:@"com.tac.test" code:-1111 userInfo:@{NSLocalizedDescriptionKey:@"没有获取到临时密钥"}];
                continueBlock(nil, error);
            }
        }
    };
    
    [request setFinishBlock:NetworkCall];
    [[QCloudHTTPSessionManager shareClient] performRequest:request];
    
    
}

- (void)textDidChagne:(NSString *)text {
    self.todoItem.title = text;
}

- (void)onHandleAttachmentChanged:(UIImage *)attachments action:(AttachmentAction)action {
    
    switch (action) {
        case ATTACHMENT_ACTION_DELETE: {
            if ( nil != attachments) {
                [self.todoItem.attachments enumerateObjectsUsingBlock:^(ToDoItemAttachment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.image == attachments) {
                        obj.image = nil;
                        obj.imageAddress = nil;
                    }
                }];
            }
        }
            break;
        case ATTACHMENT_ACTION_INSERT: {
            NSString *imageName = [NSUUID UUID].UUIDString;
            TACStorageReference *reference = [[TACStorageService defaultStorage] referenceWithPath:imageName];
            TACStorageUploadTask *uploadTask = [reference putData:UIImagePNGRepresentation(attachments) metaData:nil completion:^(TACStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                QCloudLogDebug(@"Uplode image error %@",error);
                if (!error) {
                    [self.todoItem.attachments enumerateObjectsUsingBlock:^(ToDoItemAttachment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.image == attachments) {
                            obj.imageAddress = metadata.downloadURL.absoluteString;
                        }
                    }];
                }
            }];
            [uploadTask enqueue];
        }
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onHandleSaveButtonClicked:(UIBarButtonItem *)saveButton {
    [self.detailView setIsEditting:NO];
}

- (void)onHandleShareButtonClicked:(UIBarButtonItem *)shareButton {
    TACSharePlainTextObject *plainTextObject = [TACSharePlainTextObject new];
    plainTextObject.text = self.todoItem.title;
    [self.shareDialog share:plainTextObject inViewController:self];
    
}

- (void)onHandleAddPictureButtonClicked:(UIButton *)button {
    self.detailView.isEditting = NO;
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        
    }];
}

- (ToDoItem *) generateToDoItem {
    ToDoItem* item;
    return item;
}
#pragma mark - UIImagePickerController delegate
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    ToDoItemAttachment *attachemnt = [[ToDoItemAttachment alloc] init];
    attachemnt.image = image;
    [self.todoItem.attachments    removeAllObjects];
    [self.todoItem addAttachment:attachemnt];
    [self onHandleAttachmentChanged:image action:ATTACHMENT_ACTION_INSERT];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Getters

- (ToDoItemDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[ToDoItemDetailView alloc] initWithFrame:self.view.bounds];
        _detailView.delegate = self;
    }
    return _detailView;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController   = [UIImagePickerController new];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}


@end
