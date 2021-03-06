//
//  OMBCosignerCell.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/5/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBCosignerCell.h"

#import "OMBCosigner.h"
#import "NSString+Extensions.h"
#import "NSString+PhoneNumber.h"
#import "UIColor+Extensions.h"
#import "UIFont+OnMyBlock.h"

@implementation OMBCosignerCell

#pragma mark - Initializer

- (id) initWithStyle: (UITableViewCellStyle) style 
reuseIdentifier: (NSString *) reuseIdentifier
{ 
  if (!(self = [super initWithStyle: style 
    reuseIdentifier: reuseIdentifier])) return nil;

  CGRect screen     = [[UIScreen mainScreen] bounds];
  float screenWidth = screen.size.width;

  float padding = 20.0f;
  self.contentView.frame = CGRectMake(0, 0, 
    screenWidth, padding + (22 * 3) + padding);

  nameLabel = [[UILabel alloc] init];
  nameLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15];
  nameLabel.frame = CGRectMake(padding, padding, 
    screenWidth - (padding * 2), 22);
  nameLabel.textColor = [UIColor textColor];
  [self.contentView addSubview: nameLabel];

  _emailButton = [[UIButton alloc] init];
  _emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  _emailButton.frame = CGRectMake(nameLabel.frame.origin.x,
    nameLabel.frame.origin.y + nameLabel.frame.size.height,
      nameLabel.frame.size.width, nameLabel.frame.size.height);
  _emailButton.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
  [_emailButton setTitleColor:[UIColor blue] forState:UIControlStateNormal];
  [self.contentView addSubview: _emailButton];

  _phoneButton = [[UIButton alloc] init];
  _phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  _phoneButton.titleLabel.font = _emailButton.titleLabel.font;
  _phoneButton.frame = CGRectMake(nameLabel.frame.origin.x,
    _emailButton.frame.origin.y + _emailButton.frame.size.height,
      nameLabel.frame.size.width, nameLabel.frame.size.height);
  [_phoneButton setTitleColor:
    [UIColor blue] forState:UIControlStateNormal];
  [self.contentView addSubview: _phoneButton];

  return self;
}

#pragma mark - Override

#pragma mark - Override UITableViewCell

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
  [super setSelected:selected animated:animated];
}

#pragma mark - Methods

#pragma mark - Class Methods

+ (CGFloat) heightForCell
{
  return 20.0f + (22.0f * 3.0f) + 20.0f;
}

#pragma mark - Instance Methods

- (void) loadData: (OMBCosigner *) object
{
  self.cosigner = object;
  NSString *fullName = [NSString stringWithFormat: @"%@ %@",
    [self.cosigner.firstName capitalizedString], 
      [self.cosigner.lastName capitalizedString]];
  
  NSString *relationshipType = @"";
  if (self.cosigner.relationshipType)
    relationshipType = [NSString stringWithFormat: @"(%@)",
      self.cosigner.relationshipType];
  nameLabel.attributedText = [NSString attributedStringWithStrings: 
    @[fullName, relationshipType] 
      fonts: @[[UIFont normalTextFontBold], [UIFont smallTextFont]] 
        colors: @[[UIColor textColor], [UIColor grayMedium]]];
  [_emailButton setTitle:[self.cosigner.email lowercaseString] forState:UIControlStateNormal];
  if (self.cosigner.phone) {
    if ([[self.cosigner.phone phoneNumberString] length] > 0) {
      [_phoneButton setTitle:
        [self.cosigner.phone phoneNumberString]
          forState:UIControlStateNormal];
      [_phoneButton setTitleColor:[UIColor blue]
        forState:UIControlStateNormal];
    }
  }
  else {
    [_phoneButton setTitle: @"no phone number"
      forState:UIControlStateNormal];
    [_phoneButton setTitleColor:[UIColor grayMedium]
      forState:UIControlStateNormal];
  }
}

@end
