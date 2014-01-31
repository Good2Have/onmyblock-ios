//
//  OMBAllResidenceStore.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 1/24/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBAllResidenceStore.h"

#import "OMBResidence.h"

@implementation OMBAllResidenceStore

#pragma mark - Initializer

- (id) init
{
  if (!(self = [super init])) return nil;

  _residences = [NSMutableDictionary dictionary];

  return self;
}

#pragma mark - Methods

#pragma mark - Class Methods

+ (OMBAllResidenceStore *) sharedStore
{
  static OMBAllResidenceStore *store = nil;
  if (!store)
    store = [[OMBAllResidenceStore alloc] init];
  return store;
}

#pragma mark - Instance Methods

- (void) addResidence: (OMBResidence *) residence
{
  [_residences setObject: residence forKey: 
    [NSNumber numberWithInt: residence.uid]];
}

- (OMBResidence *) residenceForUID: (NSInteger) uid
{
  return [_residences objectForKey: [NSNumber numberWithInt: uid]];
}

@end