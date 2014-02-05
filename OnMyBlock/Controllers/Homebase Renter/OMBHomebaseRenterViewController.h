//
//  OMBHomebaseBuyerViewController.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 1/6/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBViewController.h"

#import "PayPalMobile.h"

@class DRNRealTimeBlurView;
@class OMBAlertView;
@class OMBBlurView;
@class OMBCenteredImageView;
@class OMBHomebaseRenterRoommateImageView;
@class OMBOffer;
@class OMBScrollView;

@interface OMBHomebaseRenterViewController : OMBViewController
<PayPalPaymentDelegate, UIScrollViewDelegate, UITableViewDataSource, 
  UITableViewDelegate>
{
  UIButton *activityButton;
  UIButton *addRemoveRoommatesButton;
  OMBAlertView *alert;
  OMBBlurView *backView;
  CGFloat backViewOffsetY;
  DRNRealTimeBlurView *blurView;
  UIView *buttonsView;
  BOOL cameFromSettingUpPayoutMethods;
  BOOL charging;
  UIBarButtonItem *editBarButtonItem;
  OMBScrollView *imagesScrollView;
  NSMutableArray *imageViewArray;
  UIView *middleDivider; // For the buttons view
  UIButton *paymentsButton;
  OMBCenteredImageView *residenceImageView;
  OMBOffer *selectedOffer;
  int selectedSegmentIndex;
  UITapGestureRecognizer *tapGesture;
  OMBHomebaseRenterRoommateImageView *userImageView;
}

// Tables
@property (nonatomic, strong) UITableView *activityTableView;
@property (nonatomic, strong) UITableView *paymentsTableView;

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) switchToPaymentsTableView;

@end
