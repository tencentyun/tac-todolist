//
//  QCloudWhiteButton.m
//  QCloudTPGDemo
//
//  Created by erichmzhang(张恒铭) on 17/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudWhiteButton.h"
#import "UIColor+ColorCategory.h"
#define  kFontSize         18.f
#define  kBackgroundColor  [UIColor whiteColor]
#define  kTextColor        [UIColor blackColor]
#define  kBorderColor       [UIColor colorWithHex:0xe5e5e5]
@implementation QCloudWhiteButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:kBackgroundColor];
    [self setTitleColor:kTextColor forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = kBorderColor.CGColor;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
