//
//  ToDoItemDetailView.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 13/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoItemDetailView.h"
#import "UIDefine.h"
#import "FloatingButton.h"
#import "UIView+Base.h"
#define kDaateLabelHeight           30.f
#define kDateLabelVerticalSpacing   5.f

#define kAddPictureButtonWidth     50.f
@interface ToDoItemDetailView()<UITextViewDelegate>
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIImageView *attachmentView;
@property (nonatomic, strong) UIButton *attachmentButton;
@property (nonatomic, strong) FloatingButton *addPictureButton;
@end

@implementation ToDoItemDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.dateLabel];
    [self addSubview:self.textView];
    [self addSubview:self.addPictureButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)appendAttachment:(UIImage *)attachment {
    NSMutableAttributedString *attributedString;
    NSDictionary *attributes = @{NSFontAttributeName:self.textView.font};
    if (self.textView.attributedText == nil) {
        attributedString = self.textView.attributedText.mutableCopy;
    } else if (nil != self.textView.text) {
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    } else {
        attributedString = [[NSMutableAttributedString alloc] init];
    }
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds = CGRectMake(0, 0, attachment.size.width,attachment.size.height);
    textAttachment.image = attachment;
    NSAttributedString *attachmentAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:attachmentAttributedString];
    [self.textView setAttributedText:attributedString];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onHandleAttachmentChanged:action:)]) {
        [self.delegate onHandleAttachmentChanged:attachment action:ATTACHMENT_ACTION_INSERT];
    }
    
}

#pragma mark - UIControl Actions

- (void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textDidChagne:)]) {
        [self.delegate textDidChagne:textView.text];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    __weak typeof(self) weakSelf = self;
    [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                             inRange:NSMakeRange(0, self.textView.attributedText.length)
                                             options:0
                                          usingBlock:^(id value, NSRange imageRange, BOOL *stop){
                                              if (NSEqualRanges(range, imageRange) && [text isEqualToString:@""] && value != nil ){
                                                  NSTextAttachment *attachment = value;
                                                  if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onHandleAttachmentChanged:action:)]) {
                                                      [weakSelf.delegate onHandleAttachmentChanged:attachment.image action:ATTACHMENT_ACTION_DELETE];
                                                  }
                                              }
                                          }];
    return YES;
}


- (void)onHandleAddPictureButtonClicked:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate onHandleAddPictureButtonClicked:button];
    }
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat addPictureButtonBottom = self.addPictureButton.bottom;
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat verticalSpacingBetweenButtonAndKeyboard = (kScreenHeight - addPictureButtonBottom) - keyboardHeight;
        double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            self.textView.height = kScreenHeight - kNavigationBarHeight - kStatusBarHeight - keyboardHeight;
            if (verticalSpacingBetweenButtonAndKeyboard < 0) {
                self.addPictureButton.top += verticalSpacingBetweenButtonAndKeyboard;
            }
        }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.textView.frame = CGRectMake(0, kNavigationBarHeight + kStatusBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight - kStatusBarHeight);
    }];
}


- (void)setText:(id)text {
    if ([text isKindOfClass:[NSAttributedString class]]) {
        self.textView.attributedText = (NSAttributedString *)text;
    } else {
        self.textView.text = text;
    }
}


- (void)setIsEditting:(BOOL)isEditting {
    if (isEditting) {
        [self.textView becomeFirstResponder];
    } else {
        [self. textView  resignFirstResponder];
    }
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

#pragma mark - Getters
- (UITextView *)textView {
    if (!_textView) {
        _textView  = [[UITextView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + kStatusBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight - kStatusBarHeight)];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:16.f];
        _textView.spellCheckingType = UITextSpellCheckingTypeNo;
    }
    return _textView;
}
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
    }
    return _dateLabel;
}

- (FloatingButton *)addPictureButton {
    if (!_addPictureButton) {
        _addPictureButton = [[FloatingButton alloc] initWithFrame: CGRectMake(kScreenWidth - kAddPictureButtonWidth,kScreenHeight*2/3, kAddPictureButtonWidth, kAddPictureButtonWidth)];
        [_addPictureButton setTitle:@"+" forState:UIControlStateNormal];
        [_addPictureButton setBackgroundColor:UIColor.blackColor];
        [_addPictureButton addTarget:self action:@selector(onHandleAddPictureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPictureButton;
}

- (BOOL)isEditting {
    return self.textView.isFirstResponder;
}

- (id)text {
    
    if (self.textView.text) {
        return self.textView.text;
    } else {
        return [self.textView.attributedText string];//todo translate attributed text into normal text
    }
}

@end
