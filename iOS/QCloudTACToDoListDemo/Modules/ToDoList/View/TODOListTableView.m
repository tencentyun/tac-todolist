//
//  TODOListTableView.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TODOListTableView.h"
#import "ToDoListTableViewCell.h"
@implementation TODOListTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ToDoListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (void)scrollToBottom {
    NSInteger s = [self numberOfSections];
    if (s<1) return;
    NSInteger r = [self numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
