//
//  OMBResidenceCell.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/23/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBResidenceCell.h"

#import "OMBConnection.h"
#import "OMBResidencePartialView.h"

@implementation OMBResidenceCell

@synthesize imageView = _imageView;
@synthesize residence = _residence;
@synthesize residencePartialView = _residencePartialView;

#pragma mark - Initializer

- (id) initWithStyle: (UITableViewCellStyle) style  
reuseIdentifier: (NSString *) reuseIdentifier
{
  if (!(self = [super initWithStyle: style reuseIdentifier: reuseIdentifier]))
    return nil;

  _residencePartialView = [[OMBResidencePartialView alloc] init];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  [self.contentView addSubview: _residencePartialView];

  return self;
}

#pragma mark - Override

#pragma mark - Override UITableViewCell

//- (void) prepareForReuse
//{
//  [super prepareForReuse];
//
//	[_residencePartialView resetFilmstrip];
//  if (_connection)
//    [_connection cancelConnection];
//}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) cancelResidenceCoverPhotoDownload
{
  if (_residencePartialView)
    [_residencePartialView cancelResidenceCoverPhotoDownload];
}

- (void) downloadResidenceImages
{
  if (_residencePartialView)
    [_residencePartialView downloadResidenceImages];
}

- (void) loadResidenceData: (OMBResidence *) object
{
  _residence = object;
  [_residencePartialView loadResidenceData: _residence];
}

@end
