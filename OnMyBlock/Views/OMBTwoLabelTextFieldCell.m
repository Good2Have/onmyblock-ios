//
//  OMBTwoLabelTextFieldCell.m
//  OnMyBlock
//
//  Created by Paul Aguilar on 2/18/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBTwoLabelTextFieldCell.h"

#import "NSString+Extensions.h"
#import "OMBViewController.h"

@interface OMBTwoLabelTextFieldCell ()
{
  UIView *middleDivider;
}

@end

@implementation OMBTwoLabelTextFieldCell

#pragma mark - Initializer

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *)reuseIdentifier
{
  if (!(self = [super initWithStyle: style reuseIdentifier: reuseIdentifier]))
    return nil;
  
  _firstIconImageView = [UIImageView new];
  [self.contentView addSubview: _firstIconImageView];
  
  _firstTextFieldLabel = [UILabel new];
  _firstTextFieldLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light"
                                              size: 15];
  _firstTextFieldLabel.textColor = [UIColor textColor];
  [self.contentView addSubview: _firstTextFieldLabel];
  
  _firstTextField = [[TextFieldPadding alloc] init];
  _firstTextField.font = _firstTextFieldLabel.font;
  _firstTextField.returnKeyType = UIReturnKeyDone;
  _firstTextField.textColor = [UIColor textColor];
  [self.contentView addSubview: _firstTextField];
  
  _secondIconImageView = [UIImageView new];
  //[self.contentView addSubview: _secondIconImageView];
  
  _secondTextFieldLabel = [UILabel new];
  _secondTextFieldLabel.font = _firstTextFieldLabel.font;
  _secondTextFieldLabel.textColor = _firstTextFieldLabel.textColor;
  [self.contentView addSubview: _secondTextFieldLabel];
  
  _secondTextField = [[TextFieldPadding alloc] init];
  _secondTextField.font = _secondTextFieldLabel.font;
  _secondTextField.returnKeyType = UIReturnKeyDone;
  _secondTextField.textColor = _firstTextField.textColor;
  [self.contentView addSubview: _secondTextField];

  middleDivider = [UIView new];
  middleDivider.backgroundColor = [UIColor grayLight];
  [self.contentView addSubview: middleDivider];
  
  return self;
}

#pragma mark - Methods

#pragma mark - Class Methods

+ (CGFloat) heightForCell
{
  return OMBStandardHeight;
}

+ (CGFloat) heightForCellWithIconImageView
{
  return OMBStandardButtonHeight;
}

#pragma mark - Instance Methods

- (void) setFrameUsingIconImageView
{
  CGRect screen       = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screen.size.width;
  CGFloat padding = OMBPadding;
  CGFloat height = [OMBTwoLabelTextFieldCell heightForCellWithIconImageView];
  CGFloat iconSize = height * 0.5f;
  _firstIconImageView.alpha = 0.3f;
  _firstIconImageView.frame = CGRectMake(padding, (height - iconSize) * 0.5f,
                                    iconSize, iconSize);
  
  CGFloat textWidth = (screenWidth - 4 * padding - iconSize) * 0.5;
  CGFloat originX1 = _firstIconImageView.frame.origin.x +
  _firstIconImageView.frame.size.width + padding;
  _firstTextField.frame = CGRectMake(originX1, 0.0f,
                                     textWidth, height);
  
  CGFloat originX2 = _firstTextField.frame.origin.x + _firstTextField.frame.size.width + padding;
  _secondTextField.frame = CGRectMake(originX2, 0.0f,
                                     textWidth, height);

  CGFloat middleDividerWidth = 0.5f;
  middleDivider.frame = CGRectMake(_firstTextField.frame.origin.x + 
    _firstTextField.frame.size.width - middleDividerWidth,
      _secondTextField.frame.origin.y, middleDividerWidth, 
        _secondTextField.frame.size.height);
}


@end