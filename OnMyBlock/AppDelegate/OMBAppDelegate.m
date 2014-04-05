//
//  OMBAppDelegate.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/17/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import <NewRelicAgent/NewRelicAgent.h>
#import <Parse/Parse.h>
#import "GAI.h"
#import "TestFlight.h"

#import "NSError+OnMyBlock.h"
#import "NSString+Extensions.h"
#import "NSString+OnMyBlock.h"
#import "OMBAppDelegate.h"
#import "OMBConversation.h"
#import "OMBIntroStillImagesViewController.h"
#import "OMBLoginViewController.h"
#import "OMBMessageDetailViewController.h"
#import "OMBNavigationController.h"
#import "OMBOffer.h"
#import "OMBOfferVerifyVenmoConnection.h"
#import "OMBPayoutMethod.h"
#import "OMBResidence.h"
#import "OMBResidenceDetailViewController.h"
#import "OMBUser.h"
#import "OMBViewControllerContainer.h"
#import "PayPalMobile.h"
#import "UIColor+Extensions.h"

NSString *const FBSessionStateChangedNotification =
  @"com.onmyblock.Login:FBSessionStateChangedNotification";
NSString *const OMBUserDefaults = @"OMBUserDefaults";
NSString *const OMBUserDefaultsAPIKey = @"OMBUserDefaultsAPIKey";
NSString *const OMBUserDefaultsAPIKeyAccessToken =
  @"OMBUserDefaultsAPIKeyAccessToken";
NSString *const OMBUserDefaultsAPIKeyExpiresAt =
  @"OMBUserDefaultsAPIKeyExpiresAt";
NSString *const OMBUserDefaultsRenterApplication =
  @"OMBUserDefaultsRenterApplication";
NSString *const OMBUserDefaultsRenterApplicationCheckedCoapplicants =
  @"OMBUserDefaultsRenterApplicationCheckedCoapplicants";
NSString *const OMBUserDefaultsRenterApplicationCheckedCosigners =
  @"OMBUserDefaultsRenterApplicationCheckedCosigners";
NSString *const OMBUserDefaultsRenterApplicationCheckedLegalQuestions =
  @"OMBUserDefaultsRenterApplicationCheckedLegalQuestions";
NSString *const OMBUserDefaultsRenterApplicationCheckedRentalHistory =
  @"OMBUserDefaultsRenterApplicationCheckedRentalHistory";
NSString *const OMBUserDefaultsRenterApplicationCheckedWorkHistory =
  @"OMBUserDefaultsRenterApplicationCheckedWorkHistory";
NSString *const OMBUserDefaultsViewedIntro = @"OMBUserDefaultsViewedIntro";

@interface OMBAppDelegate ()
{
  void (^completionBlock) (void);
}

@end

@implementation OMBAppDelegate

- (BOOL) application: (UIApplication *) application
didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
  switch (__ENVIRONMENT__) {
    // Production
    case 3: {
      [self setupTracking];
      // #warning Remove this when submitting to the App Store
      // [self testFlightTakeOff];
      break;
    }
    // Staging
    case 2: {
      [self testFlightTakeOff];
      break;
    }
    // Development
    case 1: {
      break;
    }
    default: {
      break;
    }
  }

  CGRect screen = [[UIScreen mainScreen] bounds];
  self.window   = [[UIWindow alloc] initWithFrame: screen];

  self.container = [[OMBViewControllerContainer alloc] init];

  // Set root view controller for app
  self.window.backgroundColor    = [UIColor backgroundColor];
  self.window.rootViewController = _container;
  [self.window makeKeyAndVisible];

  // Facebook
  if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    // If current session has a valid Facebook token
    [self openSession];

  // #warning Remove fake login
  // [OMBUser fakeLogin]; // Fake login

  // Check to see if the user has a saved api key in the user defaults
  [[OMBUser currentUser] checkForUserDefaultsAPIKey];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  // NSLog(@"%@", [defaults objectForKey: @"OMBUserDefaultsAPIKey"]);

  BOOL shouldShowIntro = NO;

  id viewedIntro = [defaults objectForKey: OMBUserDefaultsViewedIntro];
  if (!viewedIntro) {
    [defaults setObject: [NSNumber numberWithBool: NO]
      forKey: OMBUserDefaultsViewedIntro];
  }
  NSNumber *number = [defaults objectForKey: OMBUserDefaultsViewedIntro];
  if (![number boolValue]) {
    if (![[OMBUser currentUser] loggedIn])
      shouldShowIntro = YES;
    [[NSUserDefaults standardUserDefaults] setObject:
      [NSNumber numberWithBool: YES] forKey: OMBUserDefaultsViewedIntro];
  }
  [defaults synchronize];

  if (shouldShowIntro)
    [_container showIntroAnimatedDissolve: NO];
  else
    [_container showDiscover];

  // #warning Remove container showing controller
  // [self.container showMyRenterProfile];

  // Parse setup
  [Parse setApplicationId: ParseApplicationId clientKey: ParseClientKey];
  // PayPal
  [PayPalMobile initializeWithClientIdsForEnvironments: @{
    PayPalEnvironmentProduction: PayPalClientID,
    PayPalEnvironmentSandbox:    PayPalClientIDSandbox
  }];
  // Venmo
  self.venmoClient = [VenmoClient clientWithAppId: VenmoClientID
    secret: VenmoClientSecret];

  // Handle push notification
  // Extract the notification data
  NSDictionary *notificationPayload =
    launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  [self handlePushNotification: notificationPayload];

  return YES;
}

- (void) application: (UIApplication *) application
didFailToRegisterForRemoteNotificationsWithError: (NSError *) error
{
  id vc = self.container.currentDetailViewController;
  if ([vc isKindOfClass: [OMBNavigationController class]]) {
    id topVc = [(OMBNavigationController *) vc topViewController];
    [(OMBViewController *) topVc showAlertViewWithError: error];
  }
  else if ([vc isKindOfClass: [OMBViewController class]]) {
    [(OMBViewController *) vc showAlertViewWithError: error];
  }
  NSLog(@"Application failed to register for remote notifications: %@",
    error.localizedDescription);
}

- (void) application: (UIApplication *) application
didReceiveRemoteNotification: (NSDictionary *) userInfo
{
  // In app alert view pop up
  // [PFPush handlePush: userInfo];

  // If user is in the program
  if (application.applicationState == UIApplicationStateActive) {
    [self updateAllCounts];
  }
  // If user is not in the program
  else {
    [self handlePushNotification: userInfo];
  }
}

- (void) application: (UIApplication *) application
didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) deviceToken
{
  // Store the deviceToken in the current installation and save it to Parse.
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData: deviceToken];
  [currentInstallation saveInBackground];
}

- (BOOL) application: (UIApplication *) application openURL: (NSURL *) url
sourceApplication: (NSString *) sourceApplication annotation: (id) annotation
{
  NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
  NSLog(@"URL scheme:%@", [url scheme]);
  NSLog(@"URL query: %@", [url query]);

  // OnMyBlock
  if ([[[url scheme] lowercaseString] isEqualToString: @"onmyblockios"]) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *param in [[url query] componentsSeparatedByString: @"&"]) {
      NSArray *array = [param componentsSeparatedByString: @"="];
      if ([array count] >= 2) {
        [parameters setObject: [array objectAtIndex: 1]
          forKey: [array objectAtIndex: 0]];
      }
      // Residence
      if ([parameters objectForKey: @"residence_id"]) {
        OMBResidence *residence = [[OMBResidence alloc] init];
        residence.uid = [[parameters objectForKey: @"residence_id"] intValue];
        [residence fetchDetailsWithCompletion: ^(NSError *error) {
          [self.container showDiscover];
          [(OMBNavigationController *)
            self.container.currentDetailViewController pushViewController:
              [[OMBResidenceDetailViewController alloc] initWithResidence:
                residence] animated: NO];
        }];
      }
    }
    return YES;
  }

  // Facebook
  if ([[url absoluteString] rangeOfString: @"facebook"].location !=
    NSNotFound) {

    return [FBSession.activeSession handleOpenURL: url];
  }

  // Venmo
  if ([[url absoluteString] rangeOfString: @"venmo"].location != NSNotFound) {
    NSDictionary *params = [[url absoluteString] dictionaryFromString];
    if ([params objectForKey: @"signed_request"]) {
      if ([[params objectForKey: @"signed_request"] rangeOfString:
        @"null"].location != NSNotFound) {

        [[NSNotificationCenter defaultCenter] postNotificationName:
          OMBOfferNotificationVenmoAppSwitchCancelled object: nil
            userInfo: nil];
        return NO;
      }
    }
    return [_venmoClient openURL: url completionHandler:
      ^(VenmoTransaction *transaction, NSError *error) {
        UINavigationController *nav =
          (UINavigationController *) _container.currentDetailViewController;
        if (transaction) {
          if (transaction.success && _currentOfferBeingPaidFor) {
            // If there is no transactionID,
            // then the user charged instead of paid
            if (transaction.transactionID) {
              OMBOfferVerifyVenmoConnection *conn =
                [[OMBOfferVerifyVenmoConnection alloc] initWithOffer:
                  _currentOfferBeingPaidFor dictionary: @{
                    @"amount": transaction.amountString,
                    @"note":   transaction.note,
                    @"transactionID": transaction.transactionID
                  }
                ];
              conn.completionBlock = ^(NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:
                  OMBOfferNotificationPaidWithVenmo object: nil
                    userInfo: @{
                      @"error": error ? error : [NSNull null]
                    }];
                // [_container stopSpinning];
              };
              // [_container startSpinning];
              [conn start];
              [[NSNotificationCenter defaultCenter] postNotificationName:
                OMBOfferNotificationProcessingWithServer object: nil
                  userInfo: nil];
            }
            // The current user charged OnMyBlock instead of paid
            else {
              error = [NSError errorWithDomain: VenmoErrorDomain
                code: VenmoErrorDomainCodeTransactionTypeIncorrect userInfo: @{
                  NSLocalizedDescriptionKey: @"Venmo Payment Failed",
                  NSLocalizedFailureReasonErrorKey:
                    @"You made a charge instead of a payment."
                }
              ];
            }
          }
          // The transaction was not successful
          else {
            error = [NSError errorWithDomain: VenmoErrorDomain
              code: VenmoErrorDomainCodeTransactionUnsuccessful userInfo: @{
                NSLocalizedDescriptionKey: @"Venmo Payment Failed",
                NSLocalizedFailureReasonErrorKey:
                  @"The transaction was not successful."
              }
            ];
          }
        }
        if (error)
          [(OMBViewController *) nav.topViewController showAlertViewWithError:
            error];
      }
    ];
  }
  return YES;
}

- (void) applicationWillResignActive: (UIApplication *) application
{
}

- (void) applicationDidEnterBackground: (UIApplication *) application
{
}

- (void) applicationWillEnterForeground: (UIApplication *) application
{
}

- (void) applicationDidBecomeActive: (UIApplication *) application
{
  // Stop all the spinners
  [[NSNotificationCenter defaultCenter] postNotificationName:
    OMBActivityIndicatorViewStopAnimatingNotification object: nil];
  [self.container stopSpinning];

  // Clearing the badge
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  if (currentInstallation.badge != 0) {
    currentInstallation.badge = 0;
    [currentInstallation saveEventually];
  }
}

- (void) applicationWillTerminate: (UIApplication *) application
{
  exit(0);
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) clearFacebookTokenInformation
{
  [FBSession.activeSession closeAndClearTokenInformation];
  // Need to clear the cookie stored in Safari
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (NSHTTPCookie *cookie in [storage cookies]) {
    NSString *domainName = [cookie domain];
    NSRange domainRange = [domainName rangeOfString: @"facebook"];
    if (domainRange.length > 0) {
      [storage deleteCookie:cookie];
    }
  }
}

- (void) handlePushNotification: (NSDictionary *) dictionary
{
  if (dictionary) {
    __weak typeof(self.container) weakContainer = self.container;
    // Conversations
    if (dictionary[@"conversation_id"]) {
      completionBlock = ^(void) {
        // Set the completion block to open the correct view controller
        OMBUser *otherUser = [[OMBUser alloc] init];
        otherUser.uid = [dictionary[@"user_id"] intValue];
        [otherUser fetchUserProfileWithCompletion: ^(NSError *error) {
          if (!error) {
            OMBConversation *conversation = [[OMBConversation alloc] init];
            conversation.nameOfConversation = dictionary[@"conversation_name"];
            conversation.otherUser = otherUser;
            conversation.uid = [dictionary[@"conversation_id"] intValue];
            [weakContainer showInbox];
            [weakContainer.inboxNavigationController pushViewController:
              [[OMBMessageDetailViewController alloc] initWithConversation:
                conversation] animated: NO];
          }
        }];
      };
    }
    // Offer
    else if (dictionary[@"offer_id"]) {
      completionBlock = ^(void) {
        OMBOffer *offer = [[OMBOffer alloc] init];
        offer.uid = [dictionary[@"offer_id"] intValue];
        [offer fetchDetailsWithCompletion: ^(NSError *error) {
          [weakContainer showOfferAccepted: offer];
        }];
      };
    }
    if ([[OMBUser currentUser] loggedIn]) {
      [self launchCompletionBlock];
    }
    else {
      // Add observer so when a user fetches their user info,
      // the proper view controller will show
      [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(launchCompletionBlock)
          name: OMBUserLoggedInNotification object: nil];
    }
  }
}

- (void) hideIntro
{
  [_container.introViewController dismissViewControllerAnimated: NO
    completion: nil];
}

- (void) hideLogin
{
  [_container.loginViewController dismissViewControllerAnimated: NO
    completion: nil];
}

- (void) launchCompletionBlock
{
  if (completionBlock)
    completionBlock();
}

- (void) openSession
{
  NSArray *facebookPermissions = @[
    @"email",
    @"user_education_history",
    @"user_location",
    @"user_work_history"
  ];
  [FBSession openActiveSessionWithReadPermissions: facebookPermissions
    allowLoginUI: YES completionHandler:
      ^(FBSession *session, FBSessionState state, NSError *error) {
        [self sessionStateChanged: session state: state error: error];
      }
    ];
}

- (void) registerForPushNotifications
{
  // Register for push notifications
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
}

- (void) sessionStateChanged: (FBSession *) session
state: (FBSessionState) state error: (NSError *) error
{
  NSLog(@"Session state changed");
  switch (state) {
    // If the user was or is logged in
    case FBSessionStateOpen: {
      [OMBUser currentUser];
      // Dismiss the intro view controller
      // [self hideIntro];
      // Dismiss login view controller
      // [self hideLogin];
      break;
    }
    case FBSessionStateClosed:
    case FBSessionStateClosedLoginFailed:
      [self clearFacebookTokenInformation];
      break;
    default:
      break;
  }
  // The user model listens for this notification
  [[NSNotificationCenter defaultCenter] postNotificationName:
    FBSessionStateChangedNotification object: session];
  if (error) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Error"
      message: error.localizedDescription delegate: nil
        cancelButtonTitle: @"Try again" otherButtonTitles: nil];
    [alertView show];
  }
}

- (void) setupTracking
{
  [NewRelicAgent startWithApplicationToken:
    @"AA232e12d9b2fba4fa3e73a8f3e6b102a75fc517a2"];

  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;
  // Optional: set Logger to VERBOSE for debug information.
  [[[GAI sharedInstance] logger] setLogLevel: kGAILogLevelVerbose];
  // Initialize tracker.
  id <GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:
    @"UA-45382533-1"];
  NSLog(@"GAITracker: %@", tracker);
}

- (void) showLogin
{
  [_container showLogin];
}

- (void) showSignUp
{
  [_container showSignUp];
}

- (void) testFlightTakeOff
{
  [TestFlight takeOff: @"c093afcb-4e1f-449d-8663-cfe23e1dbd74"];
}

- (void) updateAllCounts
{

}

@end
