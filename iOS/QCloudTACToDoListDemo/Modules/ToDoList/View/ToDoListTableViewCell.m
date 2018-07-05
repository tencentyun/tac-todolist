//
//  ToDoListTableViewCell.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 11/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoListTableViewCell.h"
#import "UIDefine.h"
#define KCellCornerRadius 9.0f
#define KBodyViewWidth  ([[UIScreen mainScreen] bounds].size.width - 40)
#define kTextColor UIColor.whiteColor
#define KCompleteButtonColor [UIColor colorWithHex:0x85D5B2]
#define kTextFieldLeading 20.f
#define kTextFieldTrailing 50.f
@interface ToDoListTableViewCell()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *bodyView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *completeButton;

@end

@implementation ToDoListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor    = kBackgroundColor;
    [self.contentView addSubview:self.bodyView];
//    [self addSubview:self.textField];
    [self.bodyView addSubview:self.titleLabel];
    return self;
}


- (void)setIsEditting:(BOOL)isEditting {
    _isEditting = isEditting;
    if (isEditting) {
        [self.textField becomeFirstResponder];
    } else {
        [self.textField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
// 监听键盘Return事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.returnKeyType) {
            // 键盘为done的Case
        case UIReturnKeyDone:
            [textField resignFirstResponder];
            break;
            
        default:
            break;
    }
    return YES;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor    = kBackgroundColor;
    [self.contentView addSubview:self.bodyView];
    [self.bodyView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.textField];
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
//    [self.textField setText:title];
    [self.titleLabel setText:title];
}

- (void)onHandleCompleteButtonClicked:(UIButton *)button {
    if (self.completeButtonHandler) {
        self.completeButtonHandler(button, self);
    }
}

#pragma mark - Getters

- (UIView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[UIView alloc] initWithFrame:CGRectMake( ([[UIScreen mainScreen] bounds].size.width - KBodyViewWidth)/2, 10, KBodyViewWidth, kBodyViewHeight)];
        _bodyView.backgroundColor = kThemeColor;
        _bodyView.layer.masksToBounds = YES;
        _bodyView.layer.cornerRadius = KCellCornerRadius;
    }
    return _bodyView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat height = self.bodyView.bounds.size.height;
        CGFloat width  = self.bodyView.bounds.size.width;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextFieldLeading, 0, width - kTextFieldLeading - kTextFieldTrailing, height)];
        [_titleLabel setBackgroundColor:kThemeColor];
    }
    return _titleLabel;
    
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:self.bodyView.frame];
        
        [_textField  setBackgroundColor:kThemeColor   ];
        _textField.placeholder  = @"placeholder";

        
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = KCellCornerRadius;
        _textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kTextFieldLeading, 0)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        self.completeButton.frame = CGRectMake(0, 0, kTextFieldTrailing, 0);
        _textField.rightView = self.completeButton;
        _textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        _textField.delegate = self;
        _textField.enabled = NO;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
}

- (UIButton *)completeButton {
    if (!_completeButton) {
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeButton setTitle:@"✔️" forState:UIControlStateNormal];
        [_completeButton addTarget:self action:@selector(onHandleCompleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

@end
