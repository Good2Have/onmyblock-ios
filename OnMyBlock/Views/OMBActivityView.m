//
//  OMBActivityView.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/16/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBActivityView.h"

#import "OMBCurvedLineView.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@implementation OMBActivityView

#pragma mark - Initializer

- (id) init
{
  if (!(self = [super init])) return nil;

  CGRect screen = [[UIScreen mainScreen] bounds];
  CGFloat screenHeight = screen.size.height; 
  CGFloat screenWidth  = screen.size.width;

  self.alpha = 0.0f;
  self.backgroundColor = [UIColor clearColor];
  self.frame = screen;
  // Allow users to click through
  self.userInteractionEnabled = NO;

  CGFloat spinnerViewSize = screenWidth * 0.3f;
  spinnerView = [UIView new];
  spinnerView.frame = CGRectMake((screenWidth - spinnerViewSize) * 0.5f,
    (screenHeight - spinnerViewSize) * 0.5f, spinnerViewSize, spinnerViewSize);
  spinnerView.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.5f];
  spinnerView.layer.cornerRadius = 5.0f;
  [self addSubview: spinnerView];

  spinner = [UIView new];
  spinner.frame = self.frame;
  [self addSubview: spinner];

  CGFloat circleSize = spinner.frame.size.width * 0.05f;
  circle = [UIView new];
  circle.frame = CGRectMake((spinner.frame.size.width - circleSize) * 0.5f,
    (spinner.frame.size.height - circleSize) * 0.5f, circleSize, circleSize);
  circle.layer.borderColor = [UIColor whiteColor].CGColor;
  circle.layer.borderWidth = 1.0f;
  circle.layer.cornerRadius = circle.frame.size.width * 0.5f;
  [spinner addSubview: circle];

  line = [[OMBCurvedLineView alloc] initWithFrame: spinner.frame];
  [spinner addSubview: line];

  return self;
}

- (id) initWithAppleSpinner
{
  if (!(self = [super init])) return nil;

  CGRect screen = [[UIScreen mainScreen] bounds];

  CGFloat activityViewSize = 100.0f;
  self.alpha = 0.0f;
  self.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.5f];
  self.frame = CGRectMake((screen.size.width - activityViewSize) * 0.5,
    (screen.size.height - activityViewSize) * 0.5, 
      activityViewSize, activityViewSize);
  self.layer.cornerRadius = 5.0f;

  activityIndicatorView = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
      UIActivityIndicatorViewStyleWhiteLarge];
  activityIndicatorView.color = [UIColor whiteColor];
  activityIndicatorView.frame = CGRectMake(
    (activityViewSize - activityIndicatorView.frame.size.width) * 0.5,
      (activityViewSize - activityIndicatorView.frame.size.height) * 0.5,
        activityIndicatorView.frame.size.width,
          activityIndicatorView.frame.size.height);
  [self addSubview: activityIndicatorView];

  [activityIndicatorView startAnimating];

  return self;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) startSpinning
{
  [UIView animateWithDuration: 0.1 animations: ^{
    self.alpha = 1.0f;
  } completion: ^(BOOL finished) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:
      @"transform.rotation"];
    animation.duration  = 0.8f;
    animation.toValue = [NSNumber numberWithFloat: DEGREES_TO_RADIANS(-360.0)];
    animation.repeatCount  = HUGE_VALF;
    [[spinner layer] addAnimation: animation 
      forKey: @"transformRotationAnimation"];

    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:
      @"transform.scale"];
    scale.autoreverses = YES;
    scale.duration = 0.8f;
    scale.fromValue = [NSNumber numberWithFloat: 1.0f];
    scale.toValue = [NSNumber numberWithFloat: 1.1f];
    scale.repeatCount = HUGE_VALF;
    [[circle layer] addAnimation: scale forKey: @"transformScaleAnimation"];
  }];
}

- (void) stopSpinning
{
  [UIView animateWithDuration: 0.1 animations: ^{
    self.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    [[spinner layer] removeAnimationForKey: @"transformRotationAnimation"];
    [[circle layer] removeAnimationForKey: @"transformScaleAnimation"];
  }];
}

@end