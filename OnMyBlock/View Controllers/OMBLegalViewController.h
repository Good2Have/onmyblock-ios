//
//  OMBLegalViewController.h
//  OnMyBlock
//
//  Created by Morgan Schwanke on 12/2/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBRenterApplicationSectionViewController.h"

@class OMBActivityViewFullScreen;

@interface OMBLegalViewController : 
  OMBRenterApplicationSectionViewController
<UITextViewDelegate>
{
  NSMutableDictionary *legalAnswers;
  OMBActivityViewFullScreen *activityViewFullScreen;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) endEditingIfEditing;
- (void) setLegalAnswer: (OMBLegalAnswer *) object;

@end
