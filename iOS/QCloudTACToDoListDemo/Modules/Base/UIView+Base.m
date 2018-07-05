//
//  UIView+Base.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 14/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UIView+Base.h"

@implementation UIView (Base)
- (CGFloat)bottom {
    return self.frame.size.height + self.frame.origin.y;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}


- (void)setBottom:(CGFloat)bottom {
    self.frame = CGRectMake(self.frame.origin.x, bottom - self.frame.size.height, self.frame.size.width,self.frame.size.height);
}

- (void)setTop:(CGFloat)top {
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width,self.frame.size.height);
}

- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(left, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}


- (void)setRight:(CGFloat)right {
    self.frame = CGRectMake(right - self.frame.size.width, self.frame.origin.y, self.frame.size.width,self.frame.size.height );
}


- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,width,self.frame.size.height );
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width,height);
}



@end
