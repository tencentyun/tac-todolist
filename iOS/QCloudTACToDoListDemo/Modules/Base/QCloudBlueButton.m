//
//  QCloudBlueButton.m
//  QCloudTPGDemo
//
//  Created by erichmzhang(张恒铭) on 17/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudBlueButton.h"
#import "UIColor+ColorCategory.h"

#define  kBackgroundColor  [UIColor colorWithHex:0x006eff]
#define  kTextColor       [UIColor colorWithHex:0xffffff]
#define  kFontSize         18.f
@implementation QCloudBlueButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = kBackgroundColor;
    [self setTitleColor:kTextColor forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
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
