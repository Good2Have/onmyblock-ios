//
// Created by Tommy DANGerous on 8/4/14.
// Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBGroup.h"

// Models
#import "OMBSentApplication.h"
#import "OMBUser.h"

@implementation OMBGroup

#pragma mark - Accessors

#pragma mark - Getters

- (NSMutableDictionary *)sentApplications
{
  if (!_sentApplications) {
    _sentApplications = [NSMutableDictionary dictionary];
  }
  return _sentApplications;
}

- (NSMutableDictionary *)users
{
  if (!_users) {
    _users = [NSMutableDictionary dictionary];
  }
  return _users;
}

#pragma mark - Methods

#pragma mark - Class Methods

#pragma mark - Public

+ (NSString *)modelName
{
  return @"group";
}

+ (NSString *)resourceName
{
  return [NSString stringWithFormat:@"%@s", [OMBGroup modelName]];
}

#pragma mark - Instance Methods

#pragma mark - Public

- (void)addUser:(OMBUser *)user
{
  [self.users setObject:user forKey:@(user.uid)];
}

- (void)readFromDictionary:(NSDictionary *)dictionary
{
  // Name
  id name = [dictionary objectForKey:@"name"];
  if (name != [NSNull null]) {
    self.name = name;
  }

  // Owner ID
  id ownerId = [dictionary objectForKey:@"owner_id"];
  if (ownerId != [NSNull null]) {
    self.ownerId = [ownerId intValue];
  }

  // UID
  id uid = [dictionary objectForKey:@"id"];
  if (uid != [NSNull null]) {
    self.uid = [uid intValue];
  }

  // Users
  id users = [dictionary objectForKey:@"users"];
  if (users != [NSNull null]) {
    for (NSDictionary *dict in users) {
      OMBUser *user = [[OMBUser alloc] init];
      [user readFromDictionary: dict];
      [self addUser:user];
    }
  }
}

- (void)createSentApplicationWithDictionary:(NSDictionary *)dictionary
accessToken:(NSString *)accessToken delegate:(id<OMBGroupDelegate>)delegate
{
  [[self sessionMananger] POST:@"transaction-process/apply" parameters:@{
    @"access_token":   accessToken,
    @"created_source": @"ios",
    @"residence_id":   dictionary[@"residenceId"]
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    OMBSentApplication *sentApplication = [[OMBSentApplication alloc] init];
    [sentApplication readFromDictionary: responseObject];
    [self addSentApplication:sentApplication];
    if ([delegate respondsToSelector:
      @selector(createSentApplicationSucceeded)]) {
      [delegate createSentApplicationSucceeded];
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if ([delegate respondsToSelector:
      @selector(createSentApplicationFailed:)]) {
      [delegate createSentApplicationFailed:error];
    }
  }];
}

- (void)createUserWithDictionary:(NSDictionary *)dictionary 
accessToken:(NSString *)accessToken delegate:(id<OMBGroupDelegate>)delegate
{
  NSString *email = [dictionary objectForKey:@"email"] ?
    [dictionary objectForKey:@"email"] : @"";
  NSString *firstName = [dictionary objectForKey:@"firstName"] ?
    [dictionary objectForKey:@"firstName"] : @"";
  NSString *lastName = [dictionary objectForKey:@"lastName"] ?
    [dictionary objectForKey:@"lastName"] : @"";
    
  [[self sessionMananger] POST:@"groups/add_user" parameters:@{
    @"access_token":   accessToken,
    @"created_source": @"ios",
    @"email":          email,
    @"first_name":     firstName,
    @"last_name":      lastName
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    [self readFromDictionary:responseObject];
    if ([delegate respondsToSelector:@selector(saveUserSucceeded)]) {
      [delegate saveUserSucceeded];
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if ([delegate respondsToSelector:@selector(saveUserFailed:)]) {
      [delegate saveUserFailed:error];
    }
  }];
}

- (void)deleteUser:(OMBUser *)user accessToken:(NSString *)accessToken
delegate:(id<OMBGroupDelegate>)delegate
{
  [[self sessionMananger] POST:@"groups/remove_user" parameters:@{
    @"access_token": accessToken,
    @"user_id":      @(user.uid)
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    if ([delegate respondsToSelector:@selector(deleteUserSucceeded)]) {
      [self removeUser:user];
      [delegate deleteUserSucceeded];
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if ([delegate respondsToSelector:@selector(deleteUserFailed:)]) {
      [delegate deleteUserFailed:error];
    }
  }];
}

#pragma mark - Private

- (void)addSentApplication:(OMBSentApplication *)sentApplication
{
  [self.sentApplications setObject:sentApplication 
    forKey:@(sentApplication.uid)];
}

- (void)removeUser:(OMBUser *)user
{
  [self.users removeObjectForKey:@(user.uid)];
}

@end
