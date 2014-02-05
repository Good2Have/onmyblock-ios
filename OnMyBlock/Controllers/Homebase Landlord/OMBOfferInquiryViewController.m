//
//  OMBOfferInquiryViewController.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 1/5/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBOfferInquiryViewController.h"

#import "AMBlurView.h"
#import "NSString+Extensions.h"
#import "OMBAlertView.h"
#import "OMBAlertViewBlur.h"
#import "OMBCenteredImageView.h"
#import "OMBCoapplicantCell.h"
#import "OMBResidenceConfirmDetailsDatesCell.h"
#import "OMBCosigner.h"
#import "OMBCosignerCell.h"
#import "OMBEmploymentCell.h"
#import "OMBGradientView.h"
#import "OMBLegalQuestion.h"
#import "OMBLegalQuestionAndAnswerCell.h"
#import "OMBLegalQuestionStore.h"
#import "OMBMessageDetailViewController.h"
#import "OMBMessageStore.h"
#import "OMBOffer.h"
#import "OMBOfferInquiryResidenceCell.h"
#import "OMBPayoutMethod.h"
#import "OMBPayoutMethodsViewController.h"
#import "OMBPayoutTransaction.h"
#import "OMBPayPalVerifyMobilePaymentConnection.h"
#import "OMBPreviousRentalCell.h"
#import "OMBRenterProfileViewController.h"
#import "OMBResidence.h"
#import "OMBResidenceDetailViewController.h"
#import "OMBViewControllerContainer.h"
#import "UIColor+Extensions.h"
#import "UIFont+OnMyBlock.h"
#import "UIImage+Color.h"

@implementation OMBOfferInquiryViewController

#pragma mark - Initializer

- (id) initWithOffer: (OMBOffer *) object
{
  if (!(self = [super init])) return nil;

  dateFormatter1 = [NSDateFormatter new];
  dateFormatter1.dateFormat = @"MMM d, yyyy";

  offer = object;

  // Student
  if ([self offerBelongsToCurrentUser]) {
    // Expired
    if ([offer isExpiredForStudent]) {
      self.title = @"Offer Expired";
    }
    else {
      if ([offer statusForStudent] == OMBOfferStatusForStudentOfferPaid) {
        self.title = @"Moved In";
      }
      else {
        self.title = [[offer statusStringForStudent] capitalizedString];
      }
    }
  }
  // Landlord
  else {
    // Expired
    if ([offer isExpiredForLandlord]) {
      self.title = @"Offer Expired";
    }
    else {
      if ([offer statusForLandlord] == OMBOfferStatusForLandlordOfferPaid) {
        self.title = @"Confirmed Tenant";
      }
      else {
        self.title = [[offer statusStringForLandlord] capitalizedString];
      }
    }
  }

  return self;
}

#pragma mark - Override

#pragma mark - Override UIViewController

- (void) loadView
{
  [super loadView];

  selectedSegmentIndex = 0;

  CGRect screen = [[UIScreen mainScreen] bounds];
  self.view     = [[UIView alloc] initWithFrame: screen];
  self.view.backgroundColor = [UIColor grayUltraLight];

  CGFloat screenHeight = screen.size.height;
  CGFloat screenWidth  = screen.size.width;
  CGFloat padding      = 20.0f;
  CGFloat standardHeight = 44.0f;

  backViewOffsetY = padding + standardHeight;
  // The image in the back
  backView = [UIView new];
  backView.frame = CGRectMake(0.0f, backViewOffsetY, 
    screenWidth, screenHeight * 0.4f);
  [self.view addSubview: backView];
  // Image of user
  userImageView = 
    [[OMBCenteredImageView alloc] init];
  userImageView.frame = CGRectMake(0.0f, 0.0f, backView.frame.size.width,
    backView.frame.size.height);  
  [backView addSubview: userImageView];

  gradient = [[OMBGradientView alloc] init];
  gradient.frame = userImageView.frame;
  gradient.colors = @[
    [UIColor colorWithWhite: 0.0f alpha: 0.0f],
    [UIColor colorWithWhite: 0.0f alpha: 0.5f]
  ];
  [backView addSubview: gradient];

  // Buttons
  buttonsView = [UIView new];
  buttonsView.clipsToBounds = YES;
  buttonsView.frame = CGRectMake(padding, 
    (backView.frame.origin.y + backView.frame.size.height) - 
    (standardHeight + padding), 
      screenWidth - (padding * 2), standardHeight);
  buttonsView.layer.borderColor = [UIColor whiteColor].CGColor;
  buttonsView.layer.borderWidth = 1.0f;
  buttonsView.layer.cornerRadius = buttonsView.frame.size.height * 0.5f;
  [self.view addSubview: buttonsView];

  CGFloat buttonWidth = buttonsView.frame.size.width / 3.0f;

  UIView *border1 = [UIView new];
  border1.backgroundColor = [UIColor whiteColor];
  border1.frame = CGRectMake(buttonWidth * 1, 0.0f, 
    1.0f, buttonsView.frame.size.height);
  [buttonsView addSubview: border1];
  UIView *border2 = [UIView new];
  border2.backgroundColor = [UIColor whiteColor];
  border2.frame = CGRectMake(buttonWidth * 2, 0.0f, 
    1.0f, buttonsView.frame.size.height);
  [buttonsView addSubview: border2];

  // Offer button
  offerButton = [UIButton new];
  offerButton.frame = CGRectMake(0.0f, 0.0f, 
    buttonWidth, buttonsView.frame.size.height);
  offerButton.tag = 0;
  offerButton.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light"
    size: 15];
  [offerButton addTarget: self action: @selector(segmentButtonSelected:)
    forControlEvents: UIControlEventTouchUpInside];
  [offerButton setTitle: @"Offer" forState: UIControlStateNormal];
  [offerButton setTitleColor: [UIColor whiteColor] 
    forState: UIControlStateNormal];
  [buttonsView addSubview: offerButton];

  // Profile button
  profileButton = [UIButton new];
  profileButton.frame = CGRectMake(
    offerButton.frame.origin.x + offerButton.frame.size.width, 
      offerButton.frame.origin.y, 
        offerButton.frame.size.width, offerButton.frame.size.height);
  profileButton.tag = 1;
  profileButton.titleLabel.font = offerButton.titleLabel.font;
  [profileButton addTarget: self action: @selector(segmentButtonSelected:)
    forControlEvents: UIControlEventTouchUpInside];
  [profileButton setTitle: @"Profile" forState: UIControlStateNormal];
  [profileButton setTitleColor: [UIColor whiteColor] 
    forState: UIControlStateNormal];
  [buttonsView addSubview: profileButton];

  // Contact button
  contactButton = [UIButton new];
  contactButton.frame = CGRectMake(
    profileButton.frame.origin.x + profileButton.frame.size.width, 
      profileButton.frame.origin.y, 
        profileButton.frame.size.width, profileButton.frame.size.height);
  contactButton.tag = 2;
  contactButton.titleLabel.font = profileButton.titleLabel.font;
  [contactButton addTarget: self action: @selector(segmentButtonSelected:)
    forControlEvents: UIControlEventTouchUpInside];
  [contactButton setTitle: @"Contact" forState: UIControlStateNormal];
  [contactButton setTitleColor: [UIColor whiteColor] 
    forState: UIControlStateNormal];
  [buttonsView addSubview: contactButton];

  CGFloat tableViewOriginY = backView.frame.origin.y +
    padding + buttonsView.frame.size.height + padding;
  CGRect tableViewFrame = CGRectMake(0.0f, tableViewOriginY,
    screenWidth, screenHeight - tableViewOriginY);
  // Offer table view
  _offerTableView = [[UITableView alloc] initWithFrame: tableViewFrame
    style: UITableViewStylePlain];
  _offerTableView.alwaysBounceVertical = YES;
  _offerTableView.backgroundColor      = [UIColor clearColor];
  _offerTableView.dataSource           = self;
  _offerTableView.delegate             = self;
  _offerTableView.separatorColor       = [UIColor grayLight];
  _offerTableView.separatorInset = UIEdgeInsetsMake(0.0f, padding, 
    0.0f, 0.0f);
  _offerTableView.showsVerticalScrollIndicator = NO;
  [self.view insertSubview: _offerTableView belowSubview: buttonsView];
  // Offer table header view
  UIView *offerHeader = [UIView new];
  offerHeader.frame = CGRectMake(0.0f, 0.0f, _offerTableView.frame.size.width, 
    (backView.frame.origin.y + backView.frame.size.height) - tableViewOriginY);
  _offerTableView.tableHeaderView = offerHeader;

  // Profile table view
  _profileTableView = [[UITableView alloc] initWithFrame: tableViewFrame
    style: UITableViewStylePlain];
  _profileTableView.alwaysBounceVertical = _offerTableView.alwaysBounceVertical;
  _profileTableView.backgroundColor = _offerTableView.backgroundColor;
  _profileTableView.dataSource = self;
  _profileTableView.delegate = self;
  _profileTableView.hidden = YES;
  _profileTableView.separatorColor = _offerTableView.separatorColor;
  _profileTableView.separatorInset = _offerTableView.separatorInset;
  _profileTableView.showsVerticalScrollIndicator = 
    _offerTableView.showsVerticalScrollIndicator;
  [self.view insertSubview: _profileTableView belowSubview: buttonsView];
  // Profile table header view
  UIView *profileHeader = [UIView new];
  profileHeader.frame = offerHeader.frame;
  _profileTableView.tableHeaderView = profileHeader;

  // Respond view
  respondView = [UIView new];
  respondView.backgroundColor = [UIColor blueAlpha: 0.95f];
  respondView.clipsToBounds = YES;
  respondView.frame = CGRectMake(0.0f, screenHeight - standardHeight,
    screenWidth, standardHeight);
  // respondView.frame = CGRectMake(padding, 
  //   screenHeight - (standardHeight + padding), screenWidth - (padding * 2),
  //     standardHeight);
  // respondView.layer.borderColor = [UIColor blue].CGColor;
  // respondView.layer.borderWidth = 1.0f;
  // respondView.layer.cornerRadius = respondView.frame.size.height * 0.5f;
  [self.view addSubview: respondView];

  // Respond button
  respondButton = [UIButton new];
  respondButton.frame = CGRectMake(0.0f, 0.0f, 
    respondView.frame.size.width, respondView.frame.size.height);
  respondButton.titleLabel.font = 
    [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15];
  [respondButton addTarget: self action: @selector(respond)
    forControlEvents: UIControlEventTouchUpInside];
  [respondButton setBackgroundImage: 
    [UIImage imageWithColor: [UIColor blueHighlighted]] 
      forState: UIControlStateHighlighted];
  [respondButton setTitleColor: [UIColor whiteColor] 
    forState: UIControlStateNormal];
  [respondView addSubview: respondButton];

  // Countdown timer label
  countDownTimerLabel = [[UILabel alloc] init];
  countDownTimerLabel.backgroundColor = [UIColor greenAlpha: 0.8f];
  countDownTimerLabel.font = [UIFont normalTextFontBold];
  countDownTimerLabel.frame = CGRectMake(0.0f, 
    respondView.frame.origin.y - padding, screenWidth, padding);
  countDownTimerLabel.textColor = [UIColor whiteColor];
  countDownTimerLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview: countDownTimerLabel];

  // Offer table footer view
  _offerTableView.tableFooterView = [[UIView alloc] initWithFrame:
    CGRectMake(0.0f, 0.0f, 
      screenWidth, countDownTimerLabel.frame.size.height + 
        respondView.frame.size.height + padding)];
  // Profile table footer view
  _profileTableView.tableFooterView = [[UIView alloc] initWithFrame:
    _offerTableView.tableFooterView.frame];
  previouslySelectedIndex = selectedSegmentIndex = 0;

  // Alert view
  alert = [[OMBAlertView alloc] init];
  [alert addTarget: self action: @selector(alertCancelSelected)
    forButton: alert.alertCancel];
  [alert addTarget: self action: @selector(alertConfirmSelected)
    forButton: alert.alertConfirm];

  // Alert view blur
  alertBlur = [[OMBAlertViewBlur alloc] init];

  [self changeTableView];
}

- (void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
}

- (void) viewDidDisappear: (BOOL) animated
{
  [super viewDidDisappear: animated];
}

- (void) viewWillAppear: (BOOL) animated
{
  [super viewWillAppear: animated];

  // Size for offer note
  sizeForOfferNotes = [offer.note boundingRectWithSize: 
    CGSizeMake(_offerTableView.frame.size.width - (OMBPadding * 2), 9999) 
      font: [UIFont smallTextFont]].size;

  // Student
  if ([self offerBelongsToCurrentUser]) {
    switch ([offer statusForStudent]) {
      // Accepted
      case OMBOfferStatusForStudentAccepted: {
        if ([offer isExpiredForStudent]) {
          [self hideCountdownAndRespondButton];
        }
        else {
          [respondButton setTitle: @"Confirm and Pay or Reject"
            forState: UIControlStateNormal];
        }
        break;
      }
      // Waiting for landlord
      case OMBOfferStatusForStudentWaitingForLandlordResponse: {
        respondButton.backgroundColor = [UIColor blueLight];
        respondButton.userInteractionEnabled = NO;
        [respondButton setTitle: @"Waiting for landlord response" forState:
          UIControlStateNormal];
        break;
      }
      default: {
        [self hideCountdownAndRespondButton];
        break;
      }
    }
  }
  // Landlord
  else {
    switch ([offer statusForLandlord]) {
      // Accepted
      case OMBOfferStatusForLandlordAccepted: {
        if ([offer isExpiredForStudent]) {
          [self hideCountdownAndRespondButton];
        }
        else {
          respondButton.backgroundColor = [UIColor blueLight];
          respondButton.userInteractionEnabled = NO;
          [respondButton setTitle: @"Waiting for student response" forState:
            UIControlStateNormal];
        }
        break;
      }
      // Landlord needs to do something
      case OMBOfferStatusForLandlordResponseRequired: {
        [respondButton setTitle: @"Accept or Decline"
          forState: UIControlStateNormal];
        break;
      }
      default: {
        [self hideCountdownAndRespondButton];
        break;
      }
    }
  }

  // User image view
  if (offer.user.image) {
    userImageView.image = offer.user.image;
  }
  else {
    [offer.user downloadImageFromImageURLWithCompletion: ^(NSError *error) {
      userImageView.image = offer.user.image;   
    }];
  }

  // After setting up a payout method
  if (cameFromSettingUpPayoutMethods) {
    // If student
    if ([self offerBelongsToCurrentUser]) {
      [alertBlur showBothButtons];
      [self confirmOfferFinalAnswer];
    }
    // If landlord
    else {
      [alertBlur showBothButtons];
      [self acceptOfferFinalAnswer];
    }
    alertBlur.hidden = NO;
    [UIView animateWithDuration: 0.25f animations: ^{
      alertBlur.alpha = 1.0f;
    }];
    cameFromSettingUpPayoutMethods = NO;
  }

  // Fetch questions
  // [[OMBLegalQuestionStore sharedStore] fetchLegalQuestionsWithCompletion:
  //   ^(NSError *error) {
  //     legalQuestions = 
  //       [[OMBLegalQuestionStore sharedStore] questionsSortedByQuestion];
  //     [_profileTableView reloadSections: [NSIndexSet indexSetWithIndex: 6]
  //       withRowAnimation: UITableViewRowAnimationFade];
  //   }
  // ];

  // Fetch offer's user's renter application info

  // Timer
  [self timerFireMethod: nil];
  countdownTimer = [NSTimer timerWithTimeInterval: 1 target: self
    selector: @selector(timerFireMethod:) userInfo: nil repeats: YES];
  // NSRunLoopCommonModes, mode used for tracking events
  [[NSRunLoop currentRunLoop] addTimer: countdownTimer
    forMode: NSRunLoopCommonModes];
}

#pragma mark - Protocol

#pragma mark - Protocol PayPalPaymentDelegate

- (void) payPalPaymentDidComplete: (PayPalPayment *) completedPayment
{
  // Payment was processed successfully; 
  // send to server for verification and fulfillment.
  OMBPayPalVerifyMobilePaymentConnection *conn =
    [[OMBPayPalVerifyMobilePaymentConnection alloc] initWithOffer: 
      offer paymentConfirmation: completedPayment.confirmation];
  conn.completionBlock = ^(NSError *error) {
    // Start spinning until it is done or incomplete
    if (offer.payoutTransaction && 
        offer.payoutTransaction.charged && 
        offer.payoutTransaction.verified && !error) {
      // Congratulations

      [alertBlur setTitle: @"Payment Confirmed!"];
      [alertBlur setMessage: [NSString stringWithFormat:
        @"You have successfully paid a total of %@ for the 1st month's "
        @"rent and deposit. We will be emailing you a confirmation "
        @"of your payment and move-in details.", 
          [NSString numberToCurrencyString: [offer totalAmount]]]];
      [alertBlur resetQuestionDetails];
      [alertBlur hideQuestionButton];
      // Buttons
      [alertBlur setConfirmButtonTitle: @"Celebrate"];
      [alertBlur addTargetForConfirmButton: self
        action: @selector(celebrateAfterPayment)];
      [alertBlur showOnlyConfirmButton];
      [alertBlur animateChangeOfContent];
    }
    else {
      [self showAlertViewWithError: error];
      // Try again
      [self confirmOfferFinalAnswer];
    }
    [[self appDelegate].container stopSpinning];
  };
  [[self appDelegate].container startSpinning];
  [conn start];

  // Dismiss the PayPalPaymentViewController.
  [self dismissViewControllerAnimated: YES completion: nil];

  [alertBlur setTitle: @"Confirming Payment"];
  [alertBlur setMessage: 
    @"One moment as we charge and verify your PayPal account."];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];
  // Buttons
  [alertBlur setConfirmButtonTitle: @"Charging and Verifying"];
  [alertBlur addTargetForConfirmButton: self action: nil];
  [alertBlur showOnlyConfirmButton];
  [alertBlur animateChangeOfContent];

  // Send the entire confirmation dictionary
  // NSData *confirmation = [NSJSONSerialization dataWithJSONObject:
  //   completedPayment.confirmation options: 0 error: nil];

  // Send confirmation to your server; 
  // your server should verify the proof of payment
  // and give the user their goods or services. 
  // If the server is not reachable, save the confirmation and try again later.
}

- (void) payPalPaymentDidCancel
{
  // The payment was canceled; dismiss the PayPalPaymentViewController.
  [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Protocol UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
  CGFloat padding        = 20.0f;
  CGFloat standardHeight = 44.0f;
  CGFloat y = scrollView.contentOffset.y;
  if (scrollView == _offerTableView || scrollView == _profileTableView) {
    CGFloat originalButtonsViewOriginY = 
      (backViewOffsetY + backView.frame.size.height) - 
        (buttonsView.frame.size.height + padding);
    CGFloat minOriginY = padding + standardHeight + padding;
    CGFloat maxDistanceForBackView = originalButtonsViewOriginY - minOriginY;

    CGFloat newOriginY = originalButtonsViewOriginY - y;
    if (newOriginY > originalButtonsViewOriginY)
      newOriginY = originalButtonsViewOriginY;
    else if (newOriginY < minOriginY)
      newOriginY = minOriginY;
    // Move the buttons
    CGRect buttonsViewRect = buttonsView.frame;
    buttonsViewRect.origin.y = newOriginY;
    buttonsView.frame = buttonsViewRect;

    // Move view up
    CGFloat adjustment = y / 3.0f;
    // Adjust the header image view
    CGRect backViewRect = backView.frame;
    CGFloat newOriginY2 = backViewOffsetY - adjustment;
    if (newOriginY2 > backViewOffsetY)
      newOriginY2 = backViewOffsetY;
    else if (newOriginY2 < backViewOffsetY - (maxDistanceForBackView / 3.0f))
      newOriginY2 = backViewOffsetY - (maxDistanceForBackView / 3.0f);
    backViewRect.origin.y = newOriginY2;
    backView.frame = backViewRect;

    // Scale the background image
    CGFloat newScale = 1 + ((y * -3.0f) / userImageView.frame.size.height);
    if (newScale < 1)
      newScale = 1;
    gradient.transform = CGAffineTransformScale(
      CGAffineTransformIdentity, newScale, newScale);
    userImageView.transform = CGAffineTransformScale(
      CGAffineTransformIdentity, newScale, newScale);
  }
}

#pragma mark - Protocol UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  // Offer
  if (tableView == _offerTableView) {
    return 1;
  }
  // Profile
  else if (tableView == _profileTableView) {
    // Name, school, about
    // Co-signers
    // Co-applicants
    // Pets
    // Rental history
    // Work history
    // Legal stuff
    return 1;
    // return 7;
  }
  return 0;
}

- (UITableViewCell *) tableView: (UITableView *) tableView
cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  CGFloat padding        = OMBPadding;
  CGFloat standardHeight = OMBStandardHeight;

  static NSString *CellIdentifier = @"CellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
    CellIdentifier];
  if (!cell)
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
      reuseIdentifier: CellIdentifier];
  cell.detailTextLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light" 
    size: 15];
  cell.detailTextLabel.text = @"";
  cell.detailTextLabel.textColor = [UIColor blueDark];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.textLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
  cell.textLabel.numberOfLines = 1;
  cell.textLabel.text = @"";
  cell.textLabel.textColor = [UIColor textColor];
  // Offer
  if (tableView == _offerTableView) {
    if (indexPath.section == OMBOfferInquirySectionOffer) {
      // Residence
      if (indexPath.row == OMBOfferInquirySectionOfferRowResidence) {
        static NSString *ResidenceCellIdentifier = @"ResidenceCellIdentifier";
        OMBOfferInquiryResidenceCell *cell1 = 
          [tableView dequeueReusableCellWithIdentifier: 
            ResidenceCellIdentifier];
        if (!cell1)
          cell1 = [[OMBOfferInquiryResidenceCell alloc] initWithStyle: 
            UITableViewCellStyleDefault
              reuseIdentifier: ResidenceCellIdentifier];
        [cell1 loadResidence: offer.residence];
        return cell1;
      }
      // Move-in date, move-out date, lease months
      else if (indexPath.row == OMBOfferInquirySectionOfferRowDates) {
        static NSString *DatesID = @"DatesID";
        OMBResidenceConfirmDetailsDatesCell *cell1 =
          [tableView dequeueReusableCellWithIdentifier: DatesID];
        if (!cell1) {
          cell1 = [[OMBResidenceConfirmDetailsDatesCell alloc] initWithStyle:
            UITableViewCellStyleDefault reuseIdentifier: DatesID];
          [cell1 loadResidence: offer.residence];
          NSDateFormatter *dateFormmater = [NSDateFormatter new];
          dateFormmater.dateFormat = @"MMM d, yy";
          [cell1.moveInDateLabel setTitle: 
            [dateFormmater stringFromDate: 
              [NSDate dateWithTimeIntervalSince1970: 
                offer.residence.moveInDate]] forState: UIControlStateNormal];
          NSDate *moveOutDate = [offer.residence moveOutDateDate];
          if (offer.residence.moveOutDate)
            moveOutDate = [NSDate dateWithTimeIntervalSince1970: 
              offer.residence.moveOutDate];
          [cell1.moveOutDateLabel setTitle: 
            [dateFormmater stringFromDate: moveOutDate]
              forState: UIControlStateNormal];
        }
        return cell1;
      }
      // Spacing below dates
      else if (indexPath.row == OMBOfferInquirySectionOfferSpacingBelowDates) {
        cell.backgroundColor = [UIColor grayUltraLight];
        cell.separatorInset  = UIEdgeInsetsMake(0.0f, 
          tableView.frame.size.width, 0.0f, 0.0f);
      }
      // Price breakdown, security deposit, offer
      else if (
        indexPath.row == OMBOfferInquirySectionOfferRowPriceBreakdown ||
        indexPath.row == OMBOfferInquirySectionOfferRowSecurityDeposit ||
        indexPath.row == OMBOfferInquirySectionOfferRowOffer) {
        
        static NSString *PriceCellIdentifier = @"PriceCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
          PriceCellIdentifier];
        if (!cell) {
          cell = [[UITableViewCell alloc] initWithStyle:
            UITableViewCellStyleValue1 reuseIdentifier: PriceCellIdentifier];
        }
        UIView *bor = [cell.contentView viewWithTag: 9999];
        if (!bor) {
          bor = [UIView new];
          bor.backgroundColor = [UIColor grayLight];
          bor.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
          bor.tag = 9999;
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.font = 
          [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == OMBOfferInquirySectionOfferRowPriceBreakdown) {
          cell.textLabel.font = [UIFont normalTextFontBold];
          [bor removeFromSuperview];
          [cell.contentView addSubview: bor];
        }
        else
          cell.textLabel.font = [UIFont normalTextFont];
        cell.detailTextLabel.text = @"";
        cell.detailTextLabel.textColor = [UIColor textColor];
        cell.textLabel.textColor = [UIColor textColor];
        if (indexPath.row == OMBOfferInquirySectionOfferRowPriceBreakdown) {
          cell.textLabel.text = @"Price Breakdown";
        }
        else if (indexPath.row == 
          OMBOfferInquirySectionOfferRowSecurityDeposit) {

          CGFloat deposit = 0.0f;
          if (offer.residence.deposit)
            deposit = offer.residence.deposit;
          cell.detailTextLabel.text = [NSString numberToCurrencyString: 
            deposit];
          cell.textLabel.text = @"Security Deposit";
        }
        else if (indexPath.row == OMBOfferInquirySectionOfferRowOffer) {
          cell.detailTextLabel.text = [NSString numberToCurrencyString:
            offer.amount];
          cell.textLabel.text = @"Offer";
        }
        return cell;
      }
      // Total
      else if (indexPath.row == OMBOfferInquirySectionOfferRowTotal) {
        static NSString *TotalCellIdentifier = @"TotalCellIdentifier";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:
          TotalCellIdentifier];
        if (!cell1) {
          cell1 = [[UITableViewCell alloc] initWithStyle:
            UITableViewCellStyleValue1 reuseIdentifier: TotalCellIdentifier];
          // Bottom border
          UIView *bor = [UIView new];
          bor.backgroundColor = [UIColor grayLight];
          bor.frame = CGRectMake(0.0f, (padding + 36.0f + padding) - 0.5f,
            tableView.frame.size.width, 0.5f);
          [cell1.contentView addSubview: bor];
        }
        cell1.backgroundColor = [UIColor whiteColor];
        cell1.detailTextLabel.font = 
          [UIFont fontWithName: @"HelveticaNeue-Medium" size: 27];
        cell1.detailTextLabel.text = [NSString numberToCurrencyString:
          [offer totalAmount]];
        cell1.detailTextLabel.textColor = [UIColor green];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        cell1.textLabel.font = 
          [UIFont fontWithName: @"HelveticaNeue-Light" size: 27];
        cell1.textLabel.text = @"Total";
        cell1.textLabel.textColor = [UIColor textColor];
        return cell1;
      }
      // Spacing below total
      else if (indexPath.row == OMBOfferInquirySectionOfferSpacingBelowTotal) {
        cell.backgroundColor = [UIColor grayUltraLight];
        cell.separatorInset  = UIEdgeInsetsMake(0.0f, 
          tableView.frame.size.width, 0.0f, 0.0f);
      }
      // Notes
      else if (indexPath.row == OMBOfferInquirySectionOfferRowNotes) {
        static NSString *OfferNoteIdentifier = @"OfferNoteIdentifier";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:
          OfferNoteIdentifier];
        if (!cell1) {
          cell1 = [[UITableViewCell alloc] initWithStyle: 
            UITableViewCellStyleDefault reuseIdentifier: OfferNoteIdentifier];
          UILabel *label = [UILabel new];
          label.font = [UIFont smallTextFont];
          label.numberOfLines = 0;
          label.text = offer.note;
          label.textColor = [UIColor textColor];
          label.frame = CGRectMake(padding, padding, 
            tableView.frame.size.width - (padding * 2), 
              sizeForOfferNotes.height);
          [cell1.contentView addSubview: label];

          UIView *bor = [UIView new];
          bor.backgroundColor = [UIColor grayLight];
          bor.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
          [cell1.contentView addSubview: bor];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
      }
    }
  }
  // Profile
  else if (tableView == _profileTableView) {
    // Name, school, about
    if (indexPath.section == 0) {
      // Name and school
      if (indexPath.row == 0) {
        static NSString *NameCellIdentifier = @"NameCellIdentifier";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:
          NameCellIdentifier];
        if (!cell1)
          cell1 = [[UITableViewCell alloc] initWithStyle: 
            UITableViewCellStyleSubtitle reuseIdentifier: NameCellIdentifier];
        cell1.detailTextLabel.font = 
          [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
        cell1.detailTextLabel.text = offer.user.school;
        cell1.detailTextLabel.textColor = [UIColor grayMedium];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        cell1.textLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium"
          size: 18];
        cell1.textLabel.text = [offer.user fullName];
        cell1.textLabel.textColor = [UIColor blueDark];
        return cell1;
      }
      // About
      else if (indexPath.row == 1) {
        cell.textLabel.attributedText = 
          [offer.user.about attributedStringWithFont: cell.textLabel.font 
            lineHeight: 22.0f];
        cell.textLabel.numberOfLines = 0;
      }
    }
    // Co-signers
    else if (indexPath.section == 1) {
      static NSString *CosignerCellIdentifier = @"CosignerCellIdentifier";
      OMBCosignerCell *cell1 = 
        [tableView dequeueReusableCellWithIdentifier: CosignerCellIdentifier];
      if (!cell1)
        cell1 = [[OMBCosignerCell alloc] initWithStyle: 
          UITableViewCellStyleDefault
            reuseIdentifier: CosignerCellIdentifier];
      OMBCosigner *cosigner = [[OMBCosigner alloc] init];
      cosigner.email = @"drew@onmyblock.com";
      cosigner.firstName = @"Drew";
      cosigner.lastName = @"Houston";
      cosigner.phone = @"4088581234";
      cosigner.uid = indexPath.row;
      [cell1 loadData: cosigner];
      return cell1;
    }
    // Co-applicants
    else if (indexPath.section == 2) {
      static NSString *CoapplicantCellIdentifier = @"CoapplicantCellIdentifier";
      OMBCoapplicantCell *cell1 = 
        [tableView dequeueReusableCellWithIdentifier: 
          CoapplicantCellIdentifier];
      if (!cell1)
        cell1 = [[OMBCoapplicantCell alloc] initWithStyle: 
          UITableViewCellStyleDefault
            reuseIdentifier: CoapplicantCellIdentifier];
      if (indexPath.row % 2) {
        [cell1 loadUserData];
      }
      else {
        [cell1 loadUnregisteredUserData];
      }
      return cell1;
    }
    // Pets
    else if (indexPath.section == 3) {
      static NSString *PetCellIdentifier = @"PetCellIdentifier";
      UITableViewCell *cell1 = 
        [tableView dequeueReusableCellWithIdentifier: 
          PetCellIdentifier];
      if (!cell1) {
        cell1 = [[UITableViewCell alloc] initWithStyle: 
          UITableViewCellStyleDefault
            reuseIdentifier: PetCellIdentifier];
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(padding, padding, 
          standardHeight, standardHeight);
        if (indexPath.row % 2) {
          imageView.image = [UIImage imageNamed: @"dogs_icon.png"];
        }
        else {
          imageView.image = [UIImage imageNamed: @"cats_icon.png"];
        }
        [cell1.contentView addSubview: imageView];
      }
      return cell1;
    }
    // Rental History
    else if (indexPath.section == 4) {
      static NSString *RentalCellIdentifier = @"RentalCellIdentifier";
      OMBPreviousRentalCell *cell1 = 
        [tableView dequeueReusableCellWithIdentifier: 
          RentalCellIdentifier];
      if (!cell1)
        cell1 = [[OMBPreviousRentalCell alloc] initWithStyle: 
          UITableViewCellStyleDefault
            reuseIdentifier: RentalCellIdentifier];
      if (indexPath.row % 2) {
        [cell1 loadFakeData1];
      }
      else {
        [cell1 loadFakeData2];
      }
      return cell1;
    }
    // Work History
    else if (indexPath.section == 5) {
      // View Linkedin Profile
      if (indexPath.row == 0) {
        static NSString *LinkedinCellIdentifier = @"LinkedinCellIdentifier";
        UITableViewCell *cell1 = 
          [tableView dequeueReusableCellWithIdentifier: 
            LinkedinCellIdentifier];
        if (!cell1) {
          cell1 = [[UITableViewCell alloc] initWithStyle: 
            UITableViewCellStyleDefault
              reuseIdentifier: LinkedinCellIdentifier];
          // Button
          UIButton *button = [UIButton new];
          button.backgroundColor = [UIColor linkedinBlue];
          button.frame = CGRectMake(padding, padding, 
            tableView.frame.size.width - (padding * 2), standardHeight);
          button.layer.cornerRadius = 5.0f;
          CGFloat imageSize = standardHeight - (padding * 0.5f);
          button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, padding * 0.5f, 
            0.0f, 0.0f);
          button.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium"
            size: 15];
          [button setTitle: @"View Linkedin Profile"
            forState: UIControlStateNormal];
          [cell1.contentView addSubview: button];
          // Image
          UIImageView *imageView = [UIImageView new];
          imageView.frame = CGRectMake(padding * 0.5f, padding * 0.25f, 
            imageSize, imageSize);
          imageView.image = [UIImage imageNamed: @"linkedin_icon.png"];
          [button addSubview: imageView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
      }
      else {
        static NSString *EmploymentCellIdentifier = @"EmploymentCellIdentifier";
        OMBEmploymentCell *cell1 = 
          [tableView dequeueReusableCellWithIdentifier: 
            EmploymentCellIdentifier];
        if (!cell1)
          cell1 = [[OMBEmploymentCell alloc] initWithStyle: 
            UITableViewCellStyleDefault
              reuseIdentifier: EmploymentCellIdentifier];
        [cell1 loadFakeData];
        return cell1;
      }
    }
    // Legal Stuff
    else if (indexPath.section == 6) {
      static NSString *LegalCellIdentifier = @"LegalCellIdentifier";
      OMBLegalQuestionAndAnswerCell *cell1 = 
        [tableView dequeueReusableCellWithIdentifier: 
          LegalCellIdentifier];
      if (!cell1)
        cell1 = [[OMBLegalQuestionAndAnswerCell alloc] initWithStyle: 
          UITableViewCellStyleDefault
            reuseIdentifier: LegalCellIdentifier];
      [cell1 loadData: [legalQuestions objectAtIndex: indexPath.row] 
        atIndexPath: indexPath];
      return cell1;
    }
  }
  return cell;
}

- (NSInteger) tableView: (UITableView *) tableView
numberOfRowsInSection: (NSInteger) section
{
  // Offer
  if (tableView == _offerTableView) {
    // Residence
    // Dates
    // Spacing below dates
    // Price breakdown
    // Security deposit
    // Offer
    // Total
    // Spacing below total
    // Notes
    return 9;
  }
  // Profile
  else if (tableView == _profileTableView) {
    // Name & school, about
    if (section == 0) {
      return 2;
    }
    // Co-signers
    else if (section == 1) {
      return 0;
    }
    // Co-applicants
    else if (section == 2) {
      return 0;
    }
    // Pets
    else if (section == 3) {
      return 0;
    }
    // Rental History
    else if (section == 4) {
      return 0;
    }
    // Work History
    else if (section == 5) {
      // View Linkedin Profile
      // Previous Employment
      return 1 + 0;
    }
    // Legal Stuff
    else if (section == 6) {
      return [legalQuestions count];
    }
  }
  return 0;
}

#pragma mark - Protocol UITableViewDelegate

- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  // Offer
  if (tableView == _offerTableView) {
    if (indexPath.section == OMBOfferInquirySectionOffer) {
      // Residence
      if (indexPath.row == OMBOfferInquirySectionOfferRowResidence) {
        [self.navigationController pushViewController: 
          [[OMBResidenceDetailViewController alloc] initWithResidence: 
            offer.residence] animated: YES];
      }
    }
  }
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat) tableView: (UITableView *) tableView 
heightForHeaderInSection: (NSInteger) section
{
  // Profile
  if (tableView == _profileTableView) {
    if (section > 0) {
      return 13.0f * 2;
    }
  }
  return 0.0f;
}

- (CGFloat) tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  CGFloat padding        = OMBPadding;
  CGFloat standardHeight = OMBStandardHeight;
  // Offer
  if (tableView == _offerTableView) {
    if (indexPath.section == OMBOfferInquirySectionOffer) {
      // Residence
      if (indexPath.row == OMBOfferInquirySectionOfferRowResidence) {
        return [OMBOfferInquiryResidenceCell heightForCell];
      }
      // Move-in date, move-out date, lease months
      else if (indexPath.row == OMBOfferInquirySectionOfferRowDates) {
        return [OMBResidenceConfirmDetailsDatesCell heightForCell];
      }
      // Spacing below dates
      else if (indexPath.row == OMBOfferInquirySectionOfferSpacingBelowDates) {
        return standardHeight;
      }
      // Price breakdown
      else if (indexPath.row == OMBOfferInquirySectionOfferRowPriceBreakdown) {
        return standardHeight;
      }
      // Security deposit
      else if (indexPath.row == OMBOfferInquirySectionOfferRowSecurityDeposit) {
        return standardHeight;
      }
      // Offer
      else if (indexPath.row == OMBOfferInquirySectionOfferRowOffer) {
        return standardHeight;
      }
      // Total
      else if (indexPath.row == OMBOfferInquirySectionOfferRowTotal) {
        return padding + 36.0f + padding;
      }
      // Spacing below total
      else if (indexPath.row == OMBOfferInquirySectionOfferSpacingBelowTotal) {
        return standardHeight;
      }
      // Notes
      else if (indexPath.row == OMBOfferInquirySectionOfferRowNotes) {
        if (offer.note && [offer.note length]) {
          return padding + sizeForOfferNotes.height + padding;
        }
      }
    }
  }
  // Profile
  else if (tableView == _profileTableView) {
    // Name & school, about
    if (indexPath.section == 0) {
      // Name & school
      if (indexPath.row == 0) {
        return padding + 23.0f + 20.0f + padding;
      }
      // About
      else if (indexPath.row == 1) {
        return padding + [offer.user heightForAboutTextWithWidth: 
          tableView.frame.size.width - (padding * 2)] + padding;
      }
    }
    // Co-signers
    else if (indexPath.section == 1) {
      return [OMBCosignerCell heightForCell];
    }
    // Co-applicants
    else if (indexPath.section == 2) {
      return [OMBCoapplicantCell heightForCell];
    }
    // Pets
    else if (indexPath.section == 3) {
      return padding + standardHeight + padding;
    }
    // Rental History
    else if (indexPath.section == 4) {
      return [OMBPreviousRentalCell heightForCell];
    }
    // Work History
    else if (indexPath.section == 5) {
      // View Linkedin Profile
      if (indexPath.row == 0) {
        return padding + standardHeight + padding;
      }
      // Previous Employment
      else {
        return padding + (22.0f * 3) + padding;
      }
    }
    // Legal Stuff
    else if (indexPath.section == 6) {
      OMBLegalQuestion *legalQuestion = [legalQuestions objectAtIndex: 
        indexPath.row];
      CGRect rect = [legalQuestion.question boundingRectWithSize:
        CGSizeMake([OMBLegalQuestionAndAnswerCell widthForQuestionLabel], 9999)
          font: [OMBLegalQuestionAndAnswerCell fontForQuestionLabel]];
      return padding + rect.size.height + (padding * 0.5) + 22.0f + padding;
    }
  }
  return 0.0f;
}

- (UIView *) tableView: (UITableView *) tableView 
viewForHeaderInSection: (NSInteger) section
{
  CGFloat padding = 20.0f;
  AMBlurView *blurView = [[AMBlurView alloc] init];
  blurView.blurTintColor = [UIColor blueLight];
  blurView.frame = CGRectMake(0.0f, 0.0f, 
    tableView.frame.size.width, 13.0f * 2);
  UILabel *label = [UILabel new];
  label.font = [UIFont fontWithName: @"HelveticaNeue-Medium" size: 13];
  label.frame = CGRectMake(padding, 0.0f, 
    blurView.frame.size.width - (padding * 2), blurView.frame.size.height);
  label.textColor = [UIColor blueDark];
  [blurView addSubview: label];
  NSString *titleString = @"";
  // Profile
  if (tableView == _profileTableView) {
    // Co-signers
    if (section == 1) {
      titleString = @"Co-signers";
    }
    // Co-applicants
    else if (section == 2) {
      titleString = @"Co-applicants";
    }
    // Pets
    else if (section == 3) {
      titleString = @"Pets";
    }
    // Rental History
    else if (section == 4) {
      titleString = @"Rental History";
    }
    // Work History
    else if (section == 5) {
      titleString = @"Work History";
    }
    // Legal Stuff
    else if (section == 6) {
      titleString = @"Legal Stuff";
    }
  }
  label.text = titleString;
  return blurView;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) acceptOfferCanceled
{
  [alertBlur close];
}

- (void) acceptOfferConfirmed
{
  // If user has a primary payout method
  if ([[OMBUser currentUser] primaryDepositPayoutMethod]) {
    [[OMBUser currentUser] acceptOffer: offer withCompletion: 
      ^(NSError *error) {
        // If offer is accepted and no error
        if (offer.accepted && !error) {
          [alertBlur setTitle: @"Offer Accepted!"];
          [alertBlur setMessage: [NSString stringWithFormat: 
            @"%@ will have 48 hours to sign the lease and pay the 1st "
            @"month's rent and deposit.",
              [offer.user.firstName capitalizedString]]];
          [alertBlur resetQuestionDetails];
          [alertBlur hideQuestionButton];
          // Buttons
          [alertBlur setConfirmButtonTitle: @"Okay"];
          [alertBlur addTargetForConfirmButton: self
            action: @selector(offerAcceptedConfirmed)];
          [alertBlur showOnlyConfirmButton];
          [alertBlur animateChangeOfContent];

          // Decline and put other offers on hold
          [[OMBUser currentUser] declineAndPutOtherOffersOnHold: offer];
        }
        else {
          [self showAlertViewWithError: error];
        }
        [[self appDelegate].container stopSpinning];
      }
    ];
    [[self appDelegate].container startSpinning];
  }
  // If user has not set up a primary payout method
  else {
    [alertBlur setTitle: @"Payout Method Setup"];
    [alertBlur setMessage: @"You have not yet set up a payout method to "
      @"receive the 1st month's rent and deposit payments."];
    [alertBlur resetQuestionDetails];
    [alertBlur hideQuestionButton];
    // Buttons
    [alertBlur setConfirmButtonTitle: @"Set up payout method"];
    [alertBlur addTargetForConfirmButton: self
      action: @selector(setupPayoutMethod)];
    [alertBlur showOnlyConfirmButton];
    [alertBlur animateChangeOfContent];
  }
}

- (void) acceptOfferFinalAnswer
{
  [alertBlur setTitle: @"Accepting Offer"];
  [alertBlur setMessage: [NSString stringWithFormat:
    @"Ready to accept %@'s offer? If yes, all other offers will be placed "
    @"on hold until %@ signs the lease and pays the 1st "
    @"month's rent and deposit.", 
      [offer.user.firstName capitalizedString], 
        [offer.user.firstName capitalizedString]]];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];
  // Buttons
  [alertBlur setCancelButtonTitle: @"No"];
  [alertBlur setConfirmButtonTitle: @"Yes"];
  [alertBlur addTargetForCancelButton: self 
    action: @selector(acceptOfferCanceled)];
  [alertBlur addTargetForConfirmButton: self
    action: @selector(acceptOfferConfirmed)];
  [alertBlur animateChangeOfContent];
}

- (void) alertCancelSelected
{
  [alert hideAlert];

  if (!accepted && !acceptedConfirmed) {
    [[OMBUser currentUser] declineOffer: offer 
      withCompletion: ^(NSError *error) {
        if (offer.declined && !error) {
          // Remove the offer from the user's received offers
          [[OMBUser currentUser] removeReceivedOffer: offer];

          [self.navigationController popViewControllerAnimated: YES];
        }
        else {
          NSString *message = @"Please try again.";
          if (error)
            message = error.localizedDescription;
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: 
            @"Unsuccessful" message: message delegate: nil 
              cancelButtonTitle: @"Try again" otherButtonTitles: nil];
          [alertView show];
        }
        [[self appDelegate].container stopSpinning];
      }
    ];
    [[self appDelegate].container startSpinning];
  }

  accepted          = NO;
  acceptedConfirmed = NO;

  [alert addTarget: self action: @selector(alertCancelSelected)
    forButton: alert.alertCancel];
  [alert addTarget: self action: @selector(alertConfirmSelected)
    forButton: alert.alertConfirm];
}

- (void) alertConfirmSelected
{
  [alert showBothButtons];

  // User added a payout method already and accepted; last step
  if (accepted && acceptedConfirmed) {
    [self.navigationController pushViewController:
      [[OMBPayoutMethodsViewController alloc] init] animated: YES];
    [self alertCancelSelected];
  }
  // Steps before
  else {
    // Step 1
    if (!accepted) {
      accepted = YES;

      // Alert buttons
      [alert.alertConfirm setTitle: @"Yes" forState: UIControlStateNormal];
      [alert.alertCancel setTitle: @"No" forState: UIControlStateNormal];
      [alert addTarget: self action: @selector(alertConfirmSelected)
        forButton: alert.alertConfirm];
      // Alert message
      alert.alertMessage.text = [NSString stringWithFormat: 
        @"Accepting %@'s offer will automatically decline all other offers.",
          [offer.user.firstName capitalizedString]];
      // Alert title
      alert.alertTitle.text = @"Are You Sure?";
    }
    // Step 2
    else if (!acceptedConfirmed) {
      // If user has
      if ([[OMBUser currentUser] primaryDepositPayoutMethod]) {
        [[OMBUser currentUser] acceptOffer: offer 
          withCompletion: ^(NSError *error) {
            // If offer is accepted and no error
            if (offer.accepted && !error) {
              acceptedConfirmed = YES;
              
              [alert addTarget: self action: @selector(alertCancelSelected)
                forButton: alert.alertCancel];
              [alert onlyShowOneButton: alert.alertCancel];
              // Alert buttons
              [alert.alertCancel setTitle: @"Ok" forState: 
                UIControlStateNormal];
              // Alert message
              alert.alertMessage.text = @"Once the student confirms, "
                @"you'll receive money within 24 hours.";
              // Alert title
              alert.alertTitle.text = @"Offer Accepted!";
              
              // Decline all other offers from the user's received offers
              // for the offers that are related to the same residence
              [[OMBUser currentUser] removeAllReceivedOffersWithOffer: offer];

              // Hide the respond button at the bottom 
              // and change the height of the table footer views
              [UIView animateWithDuration: 0.25f animations: ^{
                respondView.alpha = 0.0f;
                _offerTableView.tableFooterView = [[UIView alloc] initWithFrame:
                  CGRectZero];
                _profileTableView.tableFooterView = 
                  [[UIView alloc] initWithFrame: CGRectZero];
                [_offerTableView beginUpdates];
                [_offerTableView endUpdates];
                [_profileTableView beginUpdates];
                [_profileTableView endUpdates];
              }];
            }
            else {
              [self showAlertViewWithError: error];
            }
            [[self appDelegate].container stopSpinning];
          }
        ];
        [[self appDelegate].container startSpinning];
      }
      // If user has not set up a primary deposit payout method
      else {
        // Alert buttons
        [alert.alertConfirm setTitle: @"Setup" forState: UIControlStateNormal];
        [alert.alertCancel setTitle: @"Cancel" forState: UIControlStateNormal];
        [alert addTarget: self action: @selector(showPayoutMethods)
          forButton: alert.alertConfirm];
        // Alert message
        alert.alertMessage.text = @"Please add at least one way to get paid.";
        // Alert title
        alert.alertTitle.text = @"Payout Method Required";
      }
    }
    [alert animateChangeOfContent];
  }
}

- (void) changeTableView
{
  CGFloat padding = 20.0f;
  CGFloat threshold = backView.frame.size.height -
    (padding + buttonsView.frame.size.height + padding);
  if (selectedSegmentIndex == 0) {
    previouslySelectedIndex = 0;

    offerButton.backgroundColor   = [UIColor colorWithWhite: 1.0f alpha: 0.5f];
    profileButton.backgroundColor = [UIColor clearColor];
    contactButton.backgroundColor = [UIColor clearColor];

    _offerTableView.hidden   = NO;
    _profileTableView.hidden = YES;

    // If the offer table view content size height minus the
    // respond view's height is less than the offer table's height
    if (_offerTableView.contentSize.height - respondView.frame.size.height <=
      _offerTableView.frame.size.height) {
      [_profileTableView setContentOffset: CGPointZero animated: YES];
    }
    else if (_profileTableView.contentOffset.y < threshold) {
      _offerTableView.contentOffset = _profileTableView.contentOffset;
    }
    // If activity table view content offset is less than threshold
    else if (_offerTableView.contentOffset.y < threshold) {
      _offerTableView.contentOffset = CGPointMake(
        _offerTableView.contentOffset.x, threshold);
    }
  }
  else if (selectedSegmentIndex == 1) {
    // previouslySelectedIndex = 1;

    // offerButton.backgroundColor   = [UIColor clearColor];
    // profileButton.backgroundColor = [UIColor colorWithWhite: 1.0f alpha: 0.5f];
    // contactButton.backgroundColor = [UIColor clearColor];

    // _offerTableView.hidden   = YES;
    // _profileTableView.hidden = NO;

    // // If the profile table view content size height minus the
    // // respond view's height is less than the profile table's height
    // if (_profileTableView.contentSize.height - respondView.frame.size.height <= 
    //   _profileTableView.frame.size.height) {

    //   [_offerTableView setContentOffset: CGPointZero animated: YES];
    // }
    // else if (_offerTableView.contentOffset.y < threshold) {
    //   _profileTableView.contentOffset = _offerTableView.contentOffset;
    // }
    // // If payments table view content offset is less than threshold
    // else if (_profileTableView.contentOffset.y < threshold) {
    //   _profileTableView.contentOffset = CGPointMake(
    //     _profileTableView.contentOffset.x, threshold);
    // }

    OMBRenterProfileViewController *vc =
      [[OMBRenterProfileViewController alloc] init];
    [vc loadUser: offer.user];
    [self.navigationController pushViewController: vc animated: YES];

    selectedSegmentIndex = previouslySelectedIndex;
  }
  // Contact
  else if (selectedSegmentIndex == 2) {
    if ([self offerBelongsToCurrentUser])
      [self.navigationController pushViewController: 
        [[OMBMessageDetailViewController alloc] initWithUser: 
          offer.landlordUser] animated: YES];
    else
      [self.navigationController pushViewController: 
        [[OMBMessageDetailViewController alloc] initWithUser: offer.user]
          animated: YES];
    selectedSegmentIndex = previouslySelectedIndex;
    // [self changeTableView];
  }
}

- (void) celebrateAfterPayment
{
  [self hideAlertBlurAndPopController];
}

- (void) closeAlertBlur
{
  [alertBlur close];
}

- (void) confirmOfferAndShowAlert
{
  [alert hideAlert];
  [[OMBUser currentUser] confirmOffer: offer withCompletion:
    ^(NSError *error) {
      if (offer.confirmed && 
        offer.payoutTransaction && 
        offer.payoutTransaction.charged && !error) {

        [self.navigationController popViewControllerAnimated: YES];
        // Congratulations
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: 
          @"Check Your Venmo" message: 
            @"Please confirm the charge in Venmo to complete the transaction." 
              delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alertView show];
      }
      else {
        [self showAlertViewWithError: error];
      }
      [[self appDelegate].container stopSpinning];
    }
  ];
  [[self appDelegate].container startSpinning];
}

- (void) confirmOffer
{
  // Alert buttons
  [alert.alertCancel setTitle: @"Cancel" forState: UIControlStateNormal];
  [alert.alertConfirm setTitle: @"Confirm" 
    forState: UIControlStateNormal];

  // Alert title
  alert.alertTitle.text = @"Confirm Payment";
  // Alert message
  alert.alertMessage.text = 
    @"After you confirm and pay, you will be charged within 24 hours.";

  [alert addTarget: self action: @selector(hideAlert)
    forButton: alert.alertCancel];
  [alert addTarget: self action: @selector(confirmOfferConfirm)
    forButton: alert.alertConfirm]; 

  [alert animateChangeOfContent];
}

- (void) confirmOfferConfirm
{
  OMBPayoutMethod *payoutMethod = 
    [[OMBUser currentUser] primaryPaymentPayoutMethod];
  // If user has a primary payout method that is for payment
  if (payoutMethod) {
    // If primary payment method is PayPal
    if ([payoutMethod type] == OMBPayoutMethodPayoutTypePayPal) {
      // Show PayPal payment viewcontroller
      [self showPayPalPayment];
    }
    // If primary payment method is Venmo
    else {
      [self confirmOfferAndShowAlert];
    }
  }
  // If user does not have a primary payout method that is for payments
  else {
    // Alert buttons
    [alert.alertCancel setTitle: @"Cancel" forState: UIControlStateNormal];
    [alert.alertConfirm setTitle: @"Setup" forState: UIControlStateNormal];
    [alert addTarget: self action: @selector(showPayoutMethods)
      forButton: alert.alertConfirm];
    // Alert message
    alert.alertMessage.text = @"Please add at least one method of payment " 
      @"before confirming.";
    // Alert title
    alert.alertTitle.text = @"Set Up Payment";
    [alert animateChangeOfContent];
  }
}

- (void) confirmOfferCanceled
{
  [alertBlur close];
}

- (void) confirmOfferConfirmed
{
  // If user has a primary payout method
  OMBPayoutMethod *payoutMethod = 
    [[OMBUser currentUser] primaryPaymentPayoutMethod];
  if (payoutMethod) {
    // PayPal
    if ([payoutMethod type] == OMBPayoutMethodPayoutTypePayPal) {
      [self showPayPalPayment];
    }
    // Venmo
    else if ([payoutMethod type] == OMBPayoutMethodPayoutTypeVenmo) {
      // If the total is over 3000
      if ([offer totalAmount] > [OMBPayoutMethod maximumVenmoTransfer]) {
        [alertBlur setTitle: @"Venmo Transfer Limit"];
        [alertBlur setMessage: [NSString stringWithFormat: @"Venmo does not "
          @"allow for payment transfers over %@ a week. Please choose another "
          @"payment method.", [NSString numberToCurrencyString:
            [OMBPayoutMethod maximumVenmoTransfer]]]];
        [alertBlur resetQuestionDetails];
        [alertBlur hideQuestionButton];
        // Buttons
        [alertBlur setConfirmButtonTitle: @"Select New Payment Method"];
        [alertBlur addTargetForConfirmButton: self
          action: @selector(setupPayoutMethod)];
        [alertBlur showOnlyConfirmButton];
        [alertBlur animateChangeOfContent];
      }
      // Charge Venmo
      else {
        [[OMBUser currentUser] confirmOffer: offer withCompletion:
          ^(NSError *error) {
            // Start spinning until it is done or incomplete
            if (
              offer.confirmed &&
              offer.payoutTransaction && 
              offer.payoutTransaction.charged && !error) {
              // Congratulations
              [alertBlur setTitle: @"Venmo Charge Created!"];
              [alertBlur setMessage: [NSString stringWithFormat:
                @"We have placed a charge on your Venmo account for a total "
                @"of %@ for the 1st month's rent and deposit. Please log into "
                @"Venmo and complete the charge to confirm payment.", 
                  [NSString numberToCurrencyString: [offer totalAmount]]]];
              [alertBlur resetQuestionDetails];
              [alertBlur hideQuestionButton];
              // Buttons
              [alertBlur setConfirmButtonTitle: @"Celebrate"];
              [alertBlur addTargetForConfirmButton: self
                action: @selector(celebrateAfterPayment)];
              [alertBlur showOnlyConfirmButton];
              [alertBlur animateChangeOfContent];
            }
            else {
              [self showAlertViewWithError: error];
              // Try again
              [self confirmOfferFinalAnswer];
            }
            [[self appDelegate].container stopSpinning];
          }
        ];
        [[self appDelegate].container startSpinning];

        [alertBlur setTitle: @"Confirming Payment"];
        [alertBlur setMessage: 
          @"One moment as we make the charge to your Venmo account."];
        [alertBlur resetQuestionDetails];
        [alertBlur hideQuestionButton];
        // Buttons
        [alertBlur setConfirmButtonTitle: @"Charging and Verifying"];
        [alertBlur addTargetForConfirmButton: self action: nil];
        [alertBlur showOnlyConfirmButton];
        [alertBlur animateChangeOfContent];
      }
    }
  }
  // If user has not set up a primary payout method
  else {
    [alertBlur setTitle: @"Payout Method Setup"];
    [alertBlur setMessage: @"You have not yet set up a payout method to "
      @"make your 1st month's rent and deposit payment."];
    [alertBlur resetQuestionDetails];
    [alertBlur hideQuestionButton];
    // Buttons
    [alertBlur setConfirmButtonTitle: @"Set up payout method"];
    [alertBlur addTargetForConfirmButton: self
      action: @selector(setupPayoutMethod)];
    [alertBlur showOnlyConfirmButton];
    [alertBlur animateChangeOfContent];
  }
}

- (void) confirmOfferFinalAnswer
{
  CGFloat deposit = 0.0f;
    if (offer.residence.deposit)
      deposit = offer.residence.deposit;
    CGFloat total = offer.amount + deposit;
  [alertBlur setTitle: @"Confirm and Pay"];
  [alertBlur setMessage: [NSString stringWithFormat: @"Ready to pay the "
    @"1st month's rent and deposit? If so, we will charge the total "
    @"amount of %@ from your primary payout method.",
      [NSString numberToCurrencyString: total]]];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];
  // Buttons
  [alertBlur setCancelButtonTitle: @"No"];
  [alertBlur setConfirmButtonTitle: @"Yes"];
  [alertBlur addTargetForCancelButton: self 
    action: @selector(confirmOfferCanceled)];
  [alertBlur addTargetForConfirmButton: self
    action: @selector(confirmOfferConfirmed)];
  [alertBlur animateChangeOfContent];
}

- (void) declineOfferCanceled
{
  [alertBlur close];
}

- (void) declineOfferConfirmed
{
  [[OMBUser currentUser] declineOffer: offer 
    withCompletion: ^(NSError *error) {
      if (offer.declined && !error) {
        [UIView animateWithDuration: OMBStandardDuration animations: ^{
          alertBlur.alpha = 0.0f;
        } completion: ^(BOOL finished) {
          if (finished) {
            [self.navigationController popViewControllerAnimated: YES];
            [alertBlur close];
          }
        }];
      }
      else {
        [self showAlertViewWithError: error];
      }
      [[self appDelegate].container stopSpinning];
    }
  ];
  [[self appDelegate].container startSpinning];
}

- (void) declineOfferFinalAnswer
{
  [alertBlur setTitle: @"Decline Offer"];
  [alertBlur setMessage: [NSString stringWithFormat:
    @"Are you sure you want to decline %@'s offer?", 
      [offer.user.firstName capitalizedString]]];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];
  // Buttons
  [alertBlur setCancelButtonTitle: @"No"];
  [alertBlur setConfirmButtonTitle: @"Yes"];
  [alertBlur addTargetForCancelButton: self 
    action: @selector(declineOfferCanceled)];
  [alertBlur addTargetForConfirmButton: self
    action: @selector(declineOfferConfirmed)];
  [alertBlur animateChangeOfContent];
}

- (void) hideAlert
{
  [alert hideAlert];
}

- (void) hideAlertBlurAndPopController
{
  [UIView animateWithDuration: OMBStandardDuration animations: ^{
    alertBlur.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    if (finished) {
      [self.navigationController popViewControllerAnimated: YES];
      [alertBlur close];
    }
  }];
}

- (void) hideCountdownAndRespondButton
{
  countDownTimerLabel.alpha = 0.0f;
  respondView.alpha = 0.0f;
  _offerTableView.tableFooterView = [[UIView alloc] initWithFrame:
    CGRectZero];
  _profileTableView.tableFooterView = [[UIView alloc] initWithFrame:
    CGRectZero];
}

- (void) offerAcceptedConfirmed
{
  [UIView animateWithDuration: OMBStandardDuration animations: ^{
    alertBlur.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    if (finished) {
      [self.navigationController popViewControllerAnimated: YES];
      [alertBlur close];
    }
  }];
}

- (BOOL) offerBelongsToCurrentUser
{
  return offer.user.uid == [OMBUser currentUser].uid;
}

- (void) rejectOffer
{
  alert.alertTitle.text   = @"Reject Offer";
  alert.alertMessage.text = @"Are you sure?";
  [alert.alertCancel setTitle: @"Cancel" forState: UIControlStateNormal];
  [alert.alertConfirm setTitle: @"Yes" forState: UIControlStateNormal];

  [alert addTarget: self action: @selector(hideAlert)
    forButton: alert.alertCancel];
  [alert addTarget: self action: @selector(rejectOfferConfirm)
    forButton: alert.alertConfirm];

  [alert animateChangeOfContent];
}

- (void) rejectOfferConfirm
{
  [[OMBUser currentUser] rejectOffer: offer 
    withCompletion: ^(NSError *error) {
      if (offer.rejected && !error) {
        [self.navigationController popViewControllerAnimated: YES];
      }
      else {
        [self showAlertViewWithError: error];
      }
      [[self appDelegate].container stopSpinning];
    }
  ];
  [[self appDelegate].container startSpinning];
  [alert hideAlert];
}

- (void) rejectOfferCanceled
{
  [alertBlur close];
}

- (void) rejectOfferConfirmed
{
  [[OMBUser currentUser] rejectOffer: offer 
    withCompletion: ^(NSError *error) {
      if (offer.rejected && !error) {
        [self hideAlertBlurAndPopController];
      }
      else {
        [self showAlertViewWithError: error];
      }
      [[self appDelegate].container stopSpinning];
    }
  ];
  [[self appDelegate].container startSpinning];
}

- (void) rejectOfferFinalAnswer
{
  [alertBlur setTitle: @"Reject Offer"];
  [alertBlur setMessage: @"Are you sure you would like to notify the "
    @"landlord you are no longer interested in this place?"];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];
  // Buttons
  [alertBlur setCancelButtonTitle: @"No"];
  [alertBlur setConfirmButtonTitle: @"Yes"];
  [alertBlur addTargetForCancelButton: self 
    action: @selector(rejectOfferCanceled)];
  [alertBlur addTargetForConfirmButton: self
    action: @selector(rejectOfferConfirmed)];
  [alertBlur animateChangeOfContent];
}

- (void) respond
{
  // Student
  if ([self offerBelongsToCurrentUser]) {
    CGFloat deposit = 0.0f;
    if (offer.residence.deposit)
      deposit = offer.residence.deposit;
    CGFloat total = offer.amount + deposit;
    [alertBlur setTitle: @"Confirm and Pay"];
    [alertBlur setMessage: @"The landlord has accepted your offer! "
      @"You will be able to move-in after you pay and sign the lease we "
      @"email you."];
    [alertBlur setQuestionDetails: [NSString stringWithFormat:
      @"Confirm: Charges %@ for the 1st month's rent and deposit from "
      @"your primary payout method.\n\n"
      @"Reject: Tells the landlord that you are no longer interested",
        [NSString numberToCurrencyString: total]]];
    // Buttons
    [alertBlur setCancelButtonTitle: @"Reject"];
    [alertBlur setConfirmButtonTitle: @"Confirm"];
    [alertBlur addTargetForCancelButton: self 
      action: @selector(rejectOfferFinalAnswer)];
    [alertBlur addTargetForConfirmButton: self 
      action: @selector(confirmOfferFinalAnswer)];
    [alertBlur showInView: self.view]; 
  }
  // Landlord
  else {
    NSString *moveInDateString = [dateFormatter1 stringFromDate:
      [NSDate dateWithTimeIntervalSince1970: offer.residence.moveInDate]];
    NSDate *moveOutDate = [offer.residence moveOutDateDate];
    if (offer.residence.moveOutDate)
      moveOutDate = [NSDate dateWithTimeIntervalSince1970: 
        offer.residence.moveOutDate];
    NSString *moveOutDateString = [dateFormatter1 stringFromDate:
      moveOutDate];
    [alertBlur setTitle: @"Respond Now"];
    [alertBlur setMessage: 
      [NSString stringWithFormat: 
        @"%@ would like to rent your place from %@ - %@ for %@.",
          [offer.user.firstName capitalizedString], moveInDateString,
            moveOutDateString, 
              [NSString numberToCurrencyString: offer.amount]]];
    [alertBlur setQuestionDetails: 
      @"Accept: Gives the student 48 hours to sign the lease and pay the "
      @"1st month's rent and deposit.\n\n"
      @"Decline: Tells the student to look for another place to rent."];

    // Buttons
    [alertBlur setCancelButtonTitle: @"Decline"];
    [alertBlur setConfirmButtonTitle: @"Accept"];
    [alertBlur addTargetForCancelButton: self 
      action: @selector(declineOfferFinalAnswer)];
    [alertBlur addTargetForConfirmButton: self 
      action: @selector(acceptOfferFinalAnswer)];
    [alertBlur showInView: self.view];
  }
}

- (void) respond_old
{
  // Student
  if ([self offerBelongsToCurrentUser]) {
    // Alert buttons
    [alert.alertCancel setTitle: @"Reject" forState: UIControlStateNormal];
    [alert.alertConfirm setTitle: @"Confirm" forState: UIControlStateNormal];

    // Alert title
    alert.alertTitle.text = @"Confirm Offer";
    // Alert message
    alert.alertMessage.text = 
      @"You've been accepted, please confirm and pay to secure your place.";

    [alert addTarget: self action: @selector(rejectOffer)
      forButton: alert.alertCancel];
    [alert addTarget: self action: @selector(confirmOffer)
      forButton: alert.alertConfirm];

    [alert showAlert];
  }
  // Landlord
  else {
    // Alert buttons
    [alert.alertCancel setTitle: @"Decline" forState: UIControlStateNormal];
    [alert.alertConfirm setTitle: @"Accept" forState: UIControlStateNormal];

    // Alert title
    alert.alertTitle.text = @"Respond to Offer";
    // Alert message
    alert.alertMessage.text = [NSString stringWithFormat: 
      @"%@ would like to rent this place for %@ a month", 
        [offer.user.firstName capitalizedString], 
          [NSString numberToCurrencyString: (int) offer.amount]];

    [alert addTarget: self action: @selector(alertCancelSelected)
      forButton: alert.alertCancel];
    [alert addTarget: self action: @selector(alertConfirmSelected)
      forButton: alert.alertConfirm];

    [alert showAlert];
  }
}

- (void) segmentButtonSelected: (UIButton *) button
{
  if (selectedSegmentIndex != button.tag) {
    selectedSegmentIndex = button.tag;
    [self changeTableView];
  }
}

- (void) setupPayoutMethod
{
  [UIView animateWithDuration: 0.25f animations: ^{
    alertBlur.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    if (finished)
      alertBlur.hidden = YES;
  }];
  cameFromSettingUpPayoutMethods = YES;
  [[self appDelegate].container showPayoutMethods]; 
}

- (void) showPayoutMethods
{
  [UIView animateWithDuration: 0.25f animations: ^{
    alert.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    if (finished)
      alert.hidden = YES;
  }];
  cameFromSettingUpPayoutMethods = YES;
  [[self appDelegate].container showPayoutMethods];
}

- (void) showPayPalPayment
{
  // Use these credentials for logging in and paying in SandBox
  // Email: quazarventures@gmail.com
  // Password: onmyblock

  // Create a PayPalPayment
  PayPalPayment *payment = [[PayPalPayment alloc] init];
  #warning Change this to the actual amount eventually
  payment.amount = [[NSDecimalNumber alloc] initWithString: @"0.01"];
  // payment.amount = [[NSDecimalNumber alloc] initWithString: 
  //   [NSString stringWithFormat: @"%0.2f", offer.amount]];
  payment.currencyCode     = @"USD";
  payment.shortDescription = 
    [offer.residence.address capitalizedString];

  // Check whether payment is processable.
  if (!payment.processable) {
    // If, for example, the amount was negative or 
    // the shortDescription was empty, then
    // this payment would not be processable. 
    // You would want to handle that here.
  }
  
  // Provide a payerId that uniquely identifies a user 
  // within the scope of your system, such as an email address or user ID.
  NSString *aPayerId = [NSString stringWithFormat: @"user_%i",
    [OMBUser currentUser].uid];

  // Create a PayPalPaymentViewController with the credentials and payerId, 
  // the PayPalPayment from the previous step, 
  // and a PayPalPaymentDelegate to handle the results.
  
  NSString *cliendId = 
    @"AYF4PhAsNUDPRLYpTmTqtoo04_n7rmum1Q1fgpmApKJOF_eTrtxajPEFDK4Y";
  NSString *receiverEmail = @"tommydangerouss@gmail.com";
  
  // Sandbox account
  // NSString *cliendId = 
  //   @"AetqKxBgNs-WXu7L7mhq_kpihxGdOUSo0mgLppw0wvTw_pCdP6n3ANLYt4X6";
  // NSString *receiverEmail = @"tommydangerouss-facilitator@gmail.com";

  // Start out working with the test environment! 
  // When you are ready, remove this line to switch to live.
  // [PayPalPaymentViewController setEnvironment: PayPalEnvironmentSandbox];

  PayPalPaymentViewController *paymentViewController = 
    [[PayPalPaymentViewController alloc] initWithClientId: cliendId 
      receiverEmail: receiverEmail payerId: aPayerId payment: payment 
        delegate: self];

  // paymentViewController.defaultUserEmail = [OMBUser currentUser].email;
  // paymentViewController.defaultUserPhoneCountryCode = @"1";
  // paymentViewController.defaultUserPhoneNumber = [OMBUser currentUser].phone;

  // Will only support paying with PayPal, not with credit cards
  paymentViewController.hideCreditCardButton = YES;

  [UIView animateWithDuration: 0.25f animations: ^{
    alertBlur.alpha = 0.0f;
  } completion: ^(BOOL finished) {
    if (finished)
      alertBlur.hidden = YES;
  }];
  cameFromSettingUpPayoutMethods = YES;

  // This improves user experience
  // by preconnecting to PayPal to prepare the device for
  // processing payments
  [PayPalPaymentViewController prepareForPaymentUsingClientId: cliendId];

  // Present the PayPalPaymentViewController.
  [self presentViewController: paymentViewController animated: YES 
    completion: nil];
}

- (void) timerFireMethod: (NSTimer *) timer
{
  // Student
  if ([self offerBelongsToCurrentUser]) {
    // Waiting on the landlord
    if ([offer statusForStudent] == 
      OMBOfferStatusForStudentWaitingForLandlordResponse) {

      if (![offer isExpiredForLandlord]) {
        countDownTimerLabel.text = [offer timeLeftStringForLandlord];
      }
    }
    // Waiting on the student
    else if ([offer statusForStudent] == OMBOfferStatusForStudentAccepted) {
      if (![offer isExpiredForStudent]) {
        countDownTimerLabel.text = [offer timeLeftStringForStudent];
      }
    }
  }
  // Landlord
  else {
    if ([offer isExpiredForLandlord])
      countDownTimerLabel.text = @"expired";
    else {
      // Waiting for the student
      if (offer.accepted && !offer.rejected && !offer.confirmed) {
        countDownTimerLabel.text = [offer timeLeftStringForStudent];
      }
      // Landlord response required
      else {
        countDownTimerLabel.text = [offer timeLeftStringForLandlord];
      }
    }
  }
}

@end
