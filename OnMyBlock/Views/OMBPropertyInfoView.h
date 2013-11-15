//
//  OMBPropertyInfoView.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/18/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMBResidence;
@class OMBResidencePartialView;

@interface OMBPropertyInfoView : UIView
{
  OMBResidencePartialView *residencePartialView;
}

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) OMBResidence *residence;

#pragma mark - Methods

#pragma mark Instance Methods

- (void) loadResidenceData: (OMBResidence *) object;

@end
