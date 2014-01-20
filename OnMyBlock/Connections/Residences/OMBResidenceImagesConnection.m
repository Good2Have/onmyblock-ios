//
//  OMBResidenceImagesConnection.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/25/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBResidenceImagesConnection.h"

#import "OMBCenteredImageView.h"
#import "OMBResidence.h"
#import "OMBResidenceDetailViewController.h"
#import "OMBResidenceGoogleStaticImageDownloader.h"
#import "OMBResidenceImageDownloader.h"
#import "OMBTemporaryResidence.h"
#import "UIImage+Resize.h"

@implementation OMBResidenceImagesConnection

#pragma mark - Initializer

- (id) initWithResidence: (OMBResidence *) object
{
  if (!(self = [super init])) return nil;

  residence = object;
  
  NSString *resource = @"places";
  if ([residence isKindOfClass: [OMBTemporaryResidence class]])
    resource = @"temporary_residences";

  NSString *string = [NSString stringWithFormat:
    @"%@/%@/%i/show_images/?access_token=%@", 
      OnMyBlockAPIURL, resource, residence.uid, 
        [OMBUser currentUser].accessToken];

  [self setRequestFromString: string];

  return self;
}

#pragma mark - Protocol NSURLConnectionDataDelegate

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
  // Sample JSON
  // {
  //   images: [
  //     {
  //       image: '/uploads/residence_images/1234/man.jpg',
  //       position: 18
  //     }
  //   ]
  // }  
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData: container
    options: 0 error: nil];
  NSArray *array = (NSArray *) [json objectForKey: @"images"];
  if ([self.delegate isKindOfClass: [OMBResidenceDetailViewController class]]) {
    OMBResidenceDetailViewController *viewController = 
      (OMBResidenceDetailViewController *) self.delegate;
    if ([viewController.imageViewArray count] == 0) {
      // CGSize size = CGSizeMake(
      //   viewController.imagesScrollView.frame.size.width,
      //     viewController.imagesScrollView.frame.size.height);
      // If the residence has no image, use the cover photo
      // which is most likely the Google Static street view image
      if ([array count] == 0) {
        // This will set the cover photo as the first and probably
        // only image in the residence's image scroll view
        void (^block) (void) = ^(void) {
          OMBCenteredImageView *imageView = [[OMBCenteredImageView alloc] init];
          imageView.image = [residence coverPhoto];
          [viewController.imageViewArray addObject: imageView];
          [viewController addImageViewsToImageScrollView];
          viewController.pageOfImagesLabel.text = 
            [NSString stringWithFormat: @"%i/%i",
              [viewController currentPageOfImages], 
                (int) [[residence imagesArray] count]];
          [viewController adjustPageOfImagesLabelFrame];
        };
        // If residence has a cover photo
        if ([residence coverPhoto]) {
          block();
        }
        else {
          // Download the Google Static street view image
          OMBResidenceGoogleStaticImageDownloader *downloader =
            [[OMBResidenceGoogleStaticImageDownloader alloc] initWithResidence:
              residence url: [residence googleStaticStreetViewImageURL]];
          downloader.completionBlock = ^(NSError *error) {
            block();
            [super connectionDidFinishLoading: connection];
          };
          [downloader startDownload];
        }
      }
      // Or loop through the array of JSON hashes
      for (NSString *jsonString in array) {
        // Create X number of image views 
        // for the residence detail view controller
        OMBCenteredImageView *imageView = [[OMBCenteredImageView alloc] init];
        [viewController.imageViewArray addObject: imageView];
        // Download the image
        NSData *data = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data
          options: 0 error: nil];
        NSString *originalString = [dict objectForKey: @"image"];
        NSString *string         = [dict objectForKey: @"image"];
        int position;
        if ([dict objectForKey: @"position"] == [NSNull null]) {
          residence.lastImagePosition += 1;
          position = residence.lastImagePosition;
        }
        else {
          position = [[dict objectForKey: @"position"] intValue];
        }
        // If URL is something like this //ombrb-prod.s3.amazonaws.com
        if ([string hasPrefix: @"//"]) {
          string = [@"http:" stringByAppendingString: string];
        }
        else if (![string hasPrefix: @"http"]) {
          NSString *baseURLString = 
            [[OnMyBlockAPIURL componentsSeparatedByString: 
              OnMyBlockAPI] objectAtIndex: 0];
          string = [NSString stringWithFormat: @"%@%@", baseURLString, string];
        }
        OMBResidenceImageDownloader *downloader = 
          [[OMBResidenceImageDownloader alloc] initWithResidence: residence];
        downloader.completionBlock = ^(NSError *error) {
          // When the download is complete, set the image for the image view
          imageView.image = [residence imageAtPosition: position];
          // Update the number of pages for the images scroll view
          viewController.pageOfImagesLabel.text = [NSString stringWithFormat:
            @"%i/%i", [viewController currentPageOfImages], 
              (int) [[residence imagesArray] count]];
          [viewController adjustPageOfImagesLabelFrame];
          [super connectionDidFinishLoading: connection];
        };
        downloader.imageURL       = [NSURL URLWithString: string];
        downloader.originalString = originalString;
        downloader.position       = position;
        downloader.residenceImageUID = [[dict objectForKey: @"id"] intValue];
        [downloader startDownload];
      }
      [viewController addImageViewsToImageScrollView];
    }
  }
  else {
    // Loop through the array full of image json
    for (NSString *jsonString in array) {
      // Download the image
      NSData *data = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data
        options: 0 error: nil];
      NSString *originalString = [dict objectForKey: @"image"];
      NSString *string         = [dict objectForKey: @"image"];
      // Set the position of the image
      int position;
      if ([dict objectForKey: @"position"] == [NSNull null]) {
        residence.lastImagePosition += 1;
        position = residence.lastImagePosition;
      }
      else {
        position = [[dict objectForKey: @"position"] intValue];
      }
      // If URL is something like this //ombrb-prod.s3.amazonaws.com
      if ([string hasPrefix: @"//"]) {
        string = [@"http:" stringByAppendingString: string];
      }
      else if (![string hasPrefix: @"http"]) {
        NSString *baseURLString = 
          [[OnMyBlockAPIURL componentsSeparatedByString: 
            OnMyBlockAPI] objectAtIndex: 0];
        string = [NSString stringWithFormat: @"%@%@", baseURLString, string];
      }
      // Download image
      OMBResidenceImageDownloader *downloader = 
        [[OMBResidenceImageDownloader alloc] initWithResidence: residence];
      downloader.completionBlock = self.completionBlock;
      downloader.imageURL       = [NSURL URLWithString: string];
      downloader.originalString = originalString;
      downloader.position       = position;
      downloader.residenceImageUID = [[dict objectForKey: @"id"] intValue];
      [downloader startDownload];
    }
    self.completionBlock = nil;
  }
  [super connectionDidFinishLoading: connection];
}

@end