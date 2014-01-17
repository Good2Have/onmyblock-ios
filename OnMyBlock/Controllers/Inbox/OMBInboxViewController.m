//
//  OMBInboxViewController.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/24/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBInboxViewController.h"

#import "OMBConversationMessageStore.h"
#import "OMBInboxCell.h"
#import "OMBMessage.h"
#import "OMBMessageDetailViewController.h"
#import "OMBMessageNewViewController.h"
#import "OMBNavigationController.h"
#import "UIColor+Extensions.h"

@implementation OMBInboxViewController

#pragma mark - Initializer

- (id) init
{
  if (!(self = [super init])) return nil;

  self.screenName = self.title = @"Inbox";

  return self;
}

#pragma mark - Override

#pragma mark - Override UIViewController

- (void) loadView
{
  [super loadView];

  [self setupForTable];

  // [self.table removeFromSuperview];

  // self.navigationItem.rightBarButtonItem = 
  //   [[UIBarButtonItem alloc] initWithBarButtonSystemItem: 
  //     UIBarButtonSystemItemCompose target: self action: 
  //       @selector(newMessage)];

  CGRect screen = [[UIScreen mainScreen] bounds];

  self.table.backgroundColor = [UIColor backgroundColor];
  self.table.separatorInset  = UIEdgeInsetsMake(0.0f, 
    10.0f + (screen.size.width * 0.2) + 10.0f, 0.0f, 0.0f);
  self.table.showsVerticalScrollIndicator = YES;

  // self.button = [UIButton new];
  // self.button.backgroundColor = [UIColor blueColor];
  // self.button.frame = CGRectMake(100, -110, 110, 110);
  // [self.button addTarget: self action: @selector(fall)
  //   forControlEvents: UIControlEventTouchUpInside];
  // [self.view addSubview: self.button];
}

// Testing dynamics
- (void) viewDidAppear1: (BOOL) animated
{
  [super viewDidAppear: animated];
  // [self tableView: self.table didSelectRowAtIndexPath: 
  //   [NSIndexPath indexPathForRow: 0 inSection: 0]];

  self.redSquare = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 110, 110)];
  self.redSquare.backgroundColor = [UIColor redColor];
  [self.view addSubview: self.redSquare];

  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView: self.view];

  // Gravity falling (acceleration)
  UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:
    @[self.redSquare]];
  [self.animator addBehavior: gravityBehavior];

  // Bounces
  UICollisionBehavior* collisionBehavior = 
  [[UICollisionBehavior alloc] initWithItems: @[self.redSquare]];
  collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
  [self.animator addBehavior: collisionBehavior];

  // More bouncing
  UIDynamicItemBehavior *elasticityBehavior = 
    [[UIDynamicItemBehavior alloc] initWithItems: @[self.redSquare]];
  elasticityBehavior.elasticity = 0.7f;
  [self.animator addBehavior: elasticityBehavior];

  // Snap the button in the middle
  self.snapBehavior = [[UISnapBehavior alloc] initWithItem: 
    self.button snapToPoint: [self appDelegate].window.center];
  // We decrease the damping so the view has a little less spring.
  self.snapBehavior.damping = 0.65f;
  [self.animator addBehavior: self.snapBehavior];
}

- (void) viewWillAppear: (BOOL) animated
{
  [super viewWillAppear: animated];

  // [[OMBMessageStore sharedStore] createFakeMessages];

  // Homebase landlord presents this controller
  // We only want to show the menu icon on the inbox from the side menu
  if ([self.navigationController.viewControllers count] == 1) {
    [self setMenuBarButtonItem];
  }

  [self.table reloadData];
  [self reloadTable];
}

- (void) viewWillDisappear: (BOOL) animated
{
  [super viewWillDisappear: animated];

  self.fetching = YES;
}

#pragma mark - Protocol

#pragma mark - Protocol UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
  CGFloat scrollViewHeight = scrollView.frame.size.height;
  CGFloat contentHeight    = scrollView.contentSize.height;
  CGFloat totalContentOffset = contentHeight - scrollViewHeight;
  CGFloat limit = totalContentOffset - (scrollViewHeight / 1.0f);
  if (!self.fetching && scrollView.contentOffset.y > limit &&
    self.maxPages > self.currentPage) {

    self.currentPage += 1;
    self.fetching = YES;
    [self reloadTable];
  }
}

#pragma mark - Protocol UITableViewDataSource

- (UITableViewCell *) tableView: (UITableView *) tableView
cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *CellIdentifier = @"CellIdentifier";
  OMBInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:
    CellIdentifier];
  if (!cell)
    cell = [[OMBInboxCell alloc] initWithStyle: UITableViewCellStyleDefault
      reuseIdentifier: CellIdentifier];
  return cell;
}

- (NSInteger) tableView: (UITableView *) tableView
numberOfRowsInSection: (NSInteger) section
{
  return [[[OMBConversationMessageStore sharedStore].messages allKeys] count];
}

#pragma mark - Protocol UITableViewDelegate

- (void) tableView: (UITableView *) tableView 
didEndDisplayingCell: (UITableViewCell *) cell 
forRowAtIndexPath: (NSIndexPath *) indexPath
{
  
}

- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  OMBMessage *message = [self messageAtIndexPath: indexPath];
  message.viewed = YES;
  messageDetailViewController = 
    [[OMBMessageDetailViewController alloc] initWithUser: message.sender];
  [self.navigationController pushViewController: messageDetailViewController 
    animated: YES];
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat) tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  return [OMBInboxCell heightForCell];
}

- (void) tableView: (UITableView *) tableView 
willDisplayCell: (UITableViewCell *) cell 
forRowAtIndexPath: (NSIndexPath *) indexPath
{
  OMBMessage *message = [self messageAtIndexPath: indexPath];
  [(OMBInboxCell *) cell loadMessageData: message];
  // [[OMBUser currentUser] fetchMessagesAtPage: 1 withUser: message.sender
  //   delegate: nil completion: nil];
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) fall
{
  [self.animator removeBehavior: self.snapBehavior];

  UIGravityBehavior *gravityBehaviour = 
    [[UIGravityBehavior alloc] initWithItems: @[self.button]];
  gravityBehaviour.gravityDirection = CGVectorMake(0, 10);
  [self.animator addBehavior: gravityBehaviour];
 
  UIDynamicItemBehavior *itemBehaviour = 
    [[UIDynamicItemBehavior alloc] initWithItems: @[self.button]];
  [itemBehaviour addAngularVelocity: -M_PI_2 forItem: self.button];
  [self.animator addBehavior: itemBehaviour];
}

- (OMBMessage *) messageAtIndexPath: (NSIndexPath *) indexPath
{
  return 
    [[[OMBConversationMessageStore sharedStore] sortedMessages] objectAtIndex:
      indexPath.row];
}

- (void) newMessage
{
  [self presentViewController: 
    [[OMBNavigationController alloc] initWithRootViewController: 
      [[OMBMessageNewViewController alloc] init]]
        animated: YES completion: nil];
}

- (void) reloadTable
{
  [super reloadTable];

  [OMBConversationMessageStore sharedStore].delegate = self;
  for (int i = self.currentPage; i > 0; i--) {
  // NSInteger currentCount =
  //   [[[OMBConversationMessageStore sharedStore].messages allKeys] count];

    [[OMBConversationMessageStore sharedStore] fetchMessagesAtPage: i 
      completion: ^(NSError *error) {
        [self.table reloadData];
        // NSInteger newCount = 
        //   [[[OMBConversationMessageStore sharedStore].messages 
        //     allKeys] count];
        // NSInteger difference = newCount - currentCount;
        // NSLog(@"CURRENT COUNT: %i", currentCount);
        // NSLog(@"NEW COUNT: %i", newCount);

        // if (difference > 0) {
        //   [self.table beginUpdates];
        //   for (int i = currentCount; i < newCount; i++) {
        //     [self.table insertRowsAtIndexPaths: @[
        //       [NSIndexPath indexPathForRow: i inSection: 0]
        //     ] withRowAnimation: UITableViewRowAnimationFade];
        //   }
        //   [self.table endUpdates];
        // }
        self.fetching = NO;
      }
    ];
  }
}

@end
