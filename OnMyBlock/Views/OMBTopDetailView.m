//
//  OMBTopDetailView.m
//  OnMyBlock
//
//  Created by Paul Aguilar on 3/11/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBTopDetailView.h"

#import "OMBCenteredImageView.h"

@implementation OMBTopDetailView

#pragma mark - Initializer

- (id) init
{
  if (!(self = [self initWithFrame: CGRectZero])) return nil;
  
  return self;
}

- (id) initWithFrame: (CGRect) rect
{
  if (!(self = [super initWithFrame: rect])) return nil;
  
  CGFloat padding = 15.f;
  CGFloat sizeImage = self.frame.size.height * 0.4;
  
  // Background view
  UIView *backView = [UIView new];
  backView.alpha = 0.3;
  backView.backgroundColor = UIColor.blackColor;
  backView.frame = self.frame;
  [self addSubview: backView];
  
  // Sign up label
  signup = [UILabel new];
  CGFloat heightLabel = (sizeImage + padding);
  signup.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 18];
  signup.frame = CGRectMake(padding,
    self.frame.size.height - heightLabel * 0.9f, self.frame.size.width * 0.5, heightLabel);
  signup.hidden = YES;
  signup.text = @"Sign up or Sign in";
  signup.textAlignment = NSTextAlignmentLeft;
  signup.textColor = UIColor.whiteColor;
  [self addSubview: signup];

  // Image
  imageView = [[OMBCenteredImageView alloc]
    initWithFrame: CGRectMake(padding,
      self.frame.size.height - sizeImage - padding * 0.5f, sizeImage, sizeImage)];
  imageView.hidden = YES;
  imageView.layer.borderColor = [UIColor whiteColor].CGColor;
  imageView.layer.borderWidth = 1.0;
  imageView.layer.cornerRadius = sizeImage * 0.5f;
  [self addSubview: imageView];
  
  // Name
  nameLabel = [UILabel new];
  nameLabel.font = [UIFont fontWithName: @"HelveticaNeue" size: 17];
  nameLabel.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + padding * 0.5f,
    imageView.frame.origin.y, self.frame.size.width * 0.5 , sizeImage);
  nameLabel.hidden = YES;
  nameLabel.textAlignment = NSTextAlignmentLeft;
  nameLabel.textColor = UIColor.whiteColor;
  [self addSubview: nameLabel];
  
  // Setting Button
  settingsButton = [[UIButton alloc] init];
  settingsButton.frame = CGRectMake(self.frame.size.width - sizeImage - padding,
    self.frame.size.height - sizeImage - padding * 0.5f, sizeImage, sizeImage);
  settingsButton.hidden = YES;
  [settingsButton setImage:[UIImage imageNamed:
    @"account_icon.png"] forState:UIControlStateNormal];
  [self addSubview: settingsButton];
  
  // Account
  _account = [[UIButton alloc] init];
  _account.frame = CGRectMake(0, 0, self.frame.size.width,
    self.frame.size.height);
  [self addSubview: _account];
  
  return self;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) removeTargets
{
  [_account removeTarget:nil
    action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void) setImage: (UIImage *) object{
  [imageView setImage: object];
}

- (void) setName:(NSString *)name{
  nameLabel.text = name;
}

- (void) setupForLoggedInUser
{
  [self removeTargets];
  [self setViewOn: YES];
}

- (void) setupForLoggedOutUser
{
  [self removeTargets];
  [self setViewOn: NO];
}

- (void) setViewOn:(BOOL) hide
{
  imageView.hidden = !hide;
  nameLabel.hidden = !hide;
  settingsButton.hidden = !hide;
  signup.hidden = hide;
}
@end
