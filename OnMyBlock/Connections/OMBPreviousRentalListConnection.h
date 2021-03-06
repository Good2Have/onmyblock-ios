//
//  OMBPreviousRentalListConnection.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/9/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBConnection.h"

@interface OMBPreviousRentalListConnection : OMBConnection
{
  OMBUser *user;
}

#pragma mark - Initializer

- (id) initWithUser: (OMBUser *) object;

@end
