//
//  OMBResidenceDetailMapCell.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/17/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBResidenceDetailCell.h"

@interface OMBResidenceDetailMapCell : OMBResidenceDetailCell

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *streetView;

#pragma mark - Methods

#pragma mark - Class Methods

+ (CGRect) frameForMapView;

@end
