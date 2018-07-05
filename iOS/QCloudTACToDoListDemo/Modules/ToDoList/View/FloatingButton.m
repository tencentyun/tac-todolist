//
//  FloatingButton.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "FloatingButton.h"
#define kSuspendBtnWidth self.bounds.size.width

@implementation FloatingButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UIPanGestureRecognizer *panRcognize=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panRcognize setMinimumNumberOfTouches:1];
    [panRcognize setEnabled:YES];
    [panRcognize delaysTouchesEnded];
    [panRcognize cancelsTouchesInView];
    self.backgroundColor = UIColor.blackColor;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    [self addGestureRecognizer:panRcognize];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGFloat susScreenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat susScreenW = [UIScreen mainScreen].bounds.size.width;
    UIGestureRecognizerState recState =  recognizer.state;
    
    switch (recState) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:[UIApplication sharedApplication].windows.firstObject];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint stopPoint = CGPointMake(0, susScreenH / 2.0);
            
            if (recognizer.view.center.x < susScreenW / 2.0) {
                if (recognizer.view.center.y <= susScreenH/2.0) {
                    if (recognizer.view.center.x  >= recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, kSuspendBtnWidth/2.0);
                    }else{
                        stopPoint = CGPointMake(kSuspendBtnWidth/2.0, recognizer.view.center.y);
                    }
                }else{
                    if (recognizer.view.center.x  >= susScreenH - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, susScreenH - kSuspendBtnWidth/2.0);
                    }else{
                        stopPoint = CGPointMake(kSuspendBtnWidth/2.0, recognizer.view.center.y);
                    }
                }
            }else{
                if (recognizer.view.center.y <= susScreenH/2.0) {
                    if (susScreenW - recognizer.view.center.x  >= recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, kSuspendBtnWidth/2.0);
                    }else{
                        stopPoint = CGPointMake(susScreenW - kSuspendBtnWidth/2.0, recognizer.view.center.y);
                    }
                }else{
                    if (susScreenW - recognizer.view.center.x  >= susScreenH - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, susScreenH - kSuspendBtnWidth/2.0);
                    }else{
                        stopPoint = CGPointMake(susScreenW - kSuspendBtnWidth/2.0,recognizer.view.center.y);
                    }
                }
            }
            
            if (stopPoint.x - kSuspendBtnWidth/2.0 <= 0) {
                stopPoint = CGPointMake(kSuspendBtnWidth/2.0, stopPoint.y);
            }
            
            if (stopPoint.x + kSuspendBtnWidth/2.0 >= susScreenW) {
                stopPoint = CGPointMake(susScreenW - kSuspendBtnWidth/2.0, stopPoint.y);
            }
            
            if (stopPoint.y - kSuspendBtnWidth/2.0 <= 0) {
                stopPoint = CGPointMake(stopPoint.x, kSuspendBtnWidth/2.0);
            }
            
            if (stopPoint.y + kSuspendBtnWidth/2.0 >= susScreenH) {
                stopPoint = CGPointMake(stopPoint.x, susScreenH - kSuspendBtnWidth/2.0);
            }
            
            [UIView animateWithDuration:0.5 animations:^{
                recognizer.view.center = stopPoint;
            }];
        }
            break;
            
        default:
            break;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

@end
