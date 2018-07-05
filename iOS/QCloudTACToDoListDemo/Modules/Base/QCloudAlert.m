//
//  QCloudAlert.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 15/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudAlert.h"
#import "AppDelegate.h"
@implementation QCloudAlert

+ (void)showAlertWithTitle:(NSString *)title content:(NSString *)content buttonText:(NSString *)buttonText {
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    UIViewController *currentViewController = [AppDelegate sharedInstance].window.rootViewController;
    [currentViewController presentViewController:alertController animated:YES completion:nil];
}

@end
