//
//  OMBCloseButtonView.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 1/15/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBCloseButtonView.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@implementation OMBCloseButtonView

#pragma mark - Initializer

- (id) initWithFrame: (CGRect) rect color: (UIColor *) color
{
  if (!(self = [super initWithFrame: rect])) return nil;

  UIView *forwardSlash = [[UIView alloc] init];
  forwardSlash.backgroundColor = color;
  forwardSlash.frame = CGRectMake((self.frame.size.width - 1) * 0.5f, 0.0f, 
    1.0f, self.frame.size.height);
  [self addSubview: forwardSlash];

  UIView *backSlash = [[UIView alloc] init];
  backSlash.backgroundColor = forwardSlash.backgroundColor;
  backSlash.frame = forwardSlash.frame;
  [self addSubview: backSlash];

  forwardSlash.transform = 
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
  backSlash.transform = 
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45));

  _closeButton = [UIButton new];
  _closeButton.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width,
    self.frame.size.height);
  [self addSubview: _closeButton];

  return self;
}

@end
