//
//  OMBRoommate.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 3/17/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OMBUser;

@interface OMBRoommate : NSObject

@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) OMBUser *roommate;
@property (nonatomic) NSUInteger uid;
@property (nonatomic) NSTimeInterval updatedAt;
@property (nonatomic, strong) OMBUser *user;

@end