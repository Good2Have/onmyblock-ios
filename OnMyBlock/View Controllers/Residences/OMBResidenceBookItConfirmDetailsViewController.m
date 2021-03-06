//
//  OMBResidenceBookItConfirmDetailsViewController.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 12/21/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBResidenceBookItConfirmDetailsViewController.h"

#import "AMBlurView.h"
#import "DRNRealTimeBlurView.h"
#import "LEffectLabel.h"
#import "NSString+Extensions.h"
#import "NSUserDefaults+OnMyBlock.h"
#import "OMBAlertView.h"
#import "OMBAlertViewBlur.h"
#import "OMBCenteredImageView.h"
#import "OMBGradientView.h"
#import "OMBHelpPopUpView.h"
#import "OMBInformationHowItWorksViewController.h"
#import "OMBMyRenterProfileViewController.h"
#import "OMBNavigationController.h"
#import "OMBOffer.h"
#import "OMBUserDetailViewController.h"
#import "OMBPayoutMethod.h"
#import "OMBPayoutMethodListCell.h"
#import "OMBPayoutMethodUpdateConnection.h"
#import "OMBRenterApplication.h"
#import "OMBRenterApplicationViewController.h"
#import "OMBRenterProfileViewController.h"
#import "OMBResidence.h"
#import "OMBResidenceAddPersonalNoteViewController.h"
#import "OMBResidenceBookItCalendarCell.h"
#import "OMBResidenceConfirmDetailsBuyerCell.h"
#import "OMBResidenceConfirmDetailsDatesCell.h"
#import "OMBResidenceConfirmDetailsPlaceOfferCell.h"
#import "OMBResidenceLeaseAgreementViewController.h"
#import "OMBResidenceLegalDetailsViewController.h"
#import "OMBResidenceMonthlyPaymentScheduleViewController.h"
#import "OMBRoommate.h"
#import "OMBRoommateCell.h"
#import "OMBViewControllerContainer.h"
#import "TextFieldPadding.h"
#import "UIColor+Extensions.h"
#import "UIImage+Color.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"

@implementation OMBResidenceBookItConfirmDetailsViewController

#pragma mark - Initializer

- (id) initWithResidence: (OMBResidence *) object
{
  if (!(self = [super init])) return nil;

  dateFormatter1 = [NSDateFormatter new];
  dateFormatter1.dateFormat = @"MMM d, yyyy";

  residence = object;

  offer = [[OMBOffer alloc] init];
  offer.amount     = residence.minRent;
  offer.moveInDate = residence.moveInDate;
  if (residence.leaseMonths != 0){
    offer.moveOutDate = [[residence moveOutDateDate] timeIntervalSince1970];
  }else{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:1];
    NSDate *defaultMoveOut =
      [[NSCalendar currentCalendar] dateByAddingComponents: dateComponents
        toDate:[NSDate dateWithTimeIntervalSince1970: residence.moveInDate] options:0];
    offer.moveOutDate = [defaultMoveOut timeIntervalSince1970];
  }
  offer.residence = residence;
  offer.user = [OMBUser currentUser];

  self.screenName = self.title = @"Confirm Offer Details";

  return self;
}

#pragma mark - Override

#pragma mark - Override UIViewController

- (void) loadView
{
  [super loadView];

  doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Done"
    style: UIBarButtonItemStylePlain target: self action: @selector(done)];
  [doneBarButtonItem setTitleTextAttributes: @{
    NSFontAttributeName: [UIFont boldSystemFontOfSize: 17]
  } forState: UIControlStateNormal];

  UIButton *infoButton = [UIButton new];
  infoButton.frame = CGRectMake(0.0f, 0.0f, 26.0f, 26.0f);
  infoButton.layer.borderColor = [UIColor blue].CGColor;
  infoButton.layer.borderWidth = 1.0f;
  infoButton.layer.cornerRadius = 26.0f * 0.5f;
  infoButton.titleLabel.font = [UIFont normalTextFontBold];
  [infoButton addTarget: self action: @selector(showPlaceOfferHowItWorks)
    forControlEvents: UIControlEventTouchUpInside];
  [infoButton setTitle: @"i" forState: UIControlStateNormal];
  [infoButton setTitleColor: [UIColor blue] forState: UIControlStateNormal];
  infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: infoButton];
  // infoBarButtonItem.action = @selector(showPlaceOfferHowItWorks);
  // infoBarButtonItem.style = UIBarButtonItemStylePlain;
  // infoBarButtonItem.target = self;
  // infoBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
  //   [UIImage image: [UIImage imageNamed: @"info_icon.png"]
  //     size: CGSizeMake(26.0f, 26.0f)] style: UIBarButtonItemStylePlain
  //       target: self action: @selector(showPlaceOfferHowItWorks)];
  self.navigationItem.rightBarButtonItem = infoBarButtonItem;

  [self setupForTable];

  CGRect screen = [[UIScreen mainScreen] bounds];
  CGFloat screenHeight = screen.size.height;
  CGFloat screenWidth = screen.size.width;

  CGFloat imageHeight = screenHeight * 0.4f;
  CGFloat height = imageHeight;
  CGFloat padding = 20.0f;

  // reviewBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Review"
  //   style: UIBarButtonItemStylePlain target: self action: @selector(review)];
  // self.navigationItem.rightBarButtonItem = reviewBarButton;

  // Behind the table view so that when u scroll
  // past the bottom, it is not white
  UIView *bottomView = [UIView new];
  bottomView.backgroundColor = [UIColor grayUltraLight];
  bottomView.frame = CGRectMake(0.0f, screenHeight * 0.5f,
                                screenWidth, screenHeight * 0.5f);
  [self.view insertSubview: bottomView belowSubview: self.table];

  self.table.backgroundColor = [UIColor clearColor];
  // Table header view
  UIView *headerView = [[UIView alloc] init];
  headerView.backgroundColor = [UIColor clearColor];
  // 20 = status bar height
  // 44 = navigation bar height
  // 22 = line height for address
  // 22 = line height for bed and bath
  headerView.frame = CGRectMake(0.0f, 0.0f, screenWidth,
    20 + 44 + padding + 22.0f + 22.0f + padding);
  self.table.tableHeaderView = headerView;

  // Title label
  titleLabel = [UILabel new];
  titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15];
  titleLabel.frame = CGRectMake(padding, 20 + 44 + padding,
    screenWidth - (padding * 2), 22.0f);
  titleLabel.textColor = [UIColor whiteColor];
  [headerView addSubview: titleLabel];
  // Bed bath label
  bedBathLabel = [UILabel new];
  bedBathLabel.font = [UIFont normalTextFont];
  bedBathLabel.frame = CGRectMake(titleLabel.frame.origin.x,
    titleLabel.frame.origin.y + titleLabel.frame.size.height,
      titleLabel.frame.size.width, titleLabel.frame.size.height);
  bedBathLabel.textColor = titleLabel.textColor;
  [headerView addSubview: bedBathLabel];
  // Rent label
  rentLabel = [UILabel new];
  rentLabel.frame = CGRectMake(titleLabel.frame.origin.x,
    titleLabel.frame.origin.y, titleLabel.frame.size.width,
      27.0f);
  rentLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium" size: 20];
  rentLabel.textAlignment = NSTextAlignmentRight;
  rentLabel.textColor = titleLabel.textColor;
  [headerView addSubview: rentLabel];

  // Back view
  backView = [UIView new];
  backView.frame = CGRectMake(0.0f, 0.0f, screenWidth, imageHeight);
  [self.view insertSubview: backView belowSubview: self.table];

  // Image of residence
  residenceImageView = [[OMBCenteredImageView alloc] init];
  residenceImageView.backgroundColor = [UIColor redColor];
  residenceImageView.frame = backView.bounds;
  residenceImageView.image = [OMBResidence placeholderImage];
  [backView addSubview: residenceImageView];

  // Gradient
  OMBGradientView *gradient = [[OMBGradientView alloc] init];
  gradient.colors = @[
    [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.0],
    [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.8]
  ];
  gradient.frame = backView.bounds;
  [backView addSubview: gradient];

  CGFloat submitHeight = OMBStandardHeight;
  submitHeight = OMBStandardButtonHeight;
  // Table footer view
  UIView *footerView = [[UIView alloc] init];
  footerView.frame = CGRectMake(0.0f, 0.0f, screenWidth, submitHeight);
  self.table.tableFooterView = footerView;

  // Submit offer view
  AMBlurView *submitView = [[AMBlurView alloc] init];
  submitView.blurTintColor = [UIColor blue];
  submitView.frame = CGRectMake(0.0f, screenHeight - submitHeight,
                                screenWidth, submitHeight);
  [self.view addSubview: submitView];
  // Submit offer button
  submitOfferButton = [UIButton new];
  // submitOfferButton.clipsToBounds = YES;
  // submitOfferButton.frame = CGRectMake(padding, (216.0f - 58.0f) * 0.5,
  //   screenWidth - (padding * 2), padding + 18.0f + padding);
  submitOfferButton.frame = submitView.bounds;
  // submitOfferButton.layer.cornerRadius = 2.0f;
  submitOfferButton.titleLabel.font = [UIFont mediumTextFontBold];
  [submitOfferButton addTarget: self
    action: @selector(submitOfferButtonSelected)
      forControlEvents: UIControlEventTouchUpInside];
  [submitOfferButton setBackgroundImage:
    [UIImage imageWithColor: [UIColor blueHighlightedAlpha: 0.3f]]
      forState: UIControlStateHighlighted];
  [submitOfferButton setTitleColor: [UIColor whiteColor]
    forState: UIControlStateNormal];
  [submitView addSubview: submitOfferButton];
  // [footerView addSubview: submitOfferButton];

  // Effect label
  effectLabel = [[LEffectLabel alloc] init];
  effectLabel.effectColor = [UIColor grayMedium];
  effectLabel.effectDirection = EffectDirectionLeftToRight;
  effectLabel.font = [UIFont mediumTextFontBold];
  effectLabel.frame = submitOfferButton.frame;
  effectLabel.sizeToFit = NO;
  effectLabel.textColor = [UIColor whiteColor];
  effectLabel.textAlignment = NSTextAlignmentCenter;
  [submitView insertSubview: effectLabel
    belowSubview: submitOfferButton];

  // Blur view to go over the image
  DRNRealTimeBlurView *blurView = [[DRNRealTimeBlurView alloc] init];

  blurView.frame = residenceImageView.frame;
  blurView.renderStatic = YES;
  // [headerView addSubview: blurView];

  // Timer
  daysLabel    = [UILabel new];
  hoursLabel   = [UILabel new];
  minutesLabel = [UILabel new];
  secondsLabel = [UILabel new];

  NSArray *array = @[
    daysLabel,
    hoursLabel,
    minutesLabel,
    secondsLabel
  ];
  CGFloat labelSize = 58.0f;
  CGFloat spacing = (screenWidth - (labelSize * [array count])) /
  ([array count] + 1);
  for (UILabel *label in array) {
    int index = [array indexOfObject: label];
    label.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.8f];
    label.clipsToBounds = YES;
    label.font = [UIFont fontWithName: @"DBLCDTempBlack" size: 27.0f];
    label.frame = CGRectMake(spacing + ((labelSize + spacing) * index),
                             (height - labelSize) * 0.5, labelSize, labelSize);
    label.layer.cornerRadius = 5.0f;
    label.textColor = [UIColor whiteColor];
    // [headerView addSubview: label];
  }

  [self setString: @"02" forTimeUnit: @"days"];
  [self setString: @"13" forTimeUnit: @"hours"];
  [self setString: @"49" forTimeUnit: @"minutes"];
  [self setString: @"34" forTimeUnit: @"seconds"];

  leaseMonthsLabel = [UILabel new];
  leaseMonthsLabel.font = [UIFont normalTextFontBold];
  leaseMonthsLabel.frame = CGRectMake(0.0f, 0.0f,
                                      screenWidth, 27.f);
  //label.text = @"0 MONTH LEASE";
  leaseMonthsLabel.textAlignment = NSTextAlignmentCenter;
  leaseMonthsLabel.textColor = [UIColor grayMedium];

  // Current offer
  currentOfferLabel = [[UILabel alloc] init];
  currentOfferLabel.font = [UIFont fontWithName: @"HelveticaNeue-Medium"
    size: 15];
  CGFloat currentOfferLabelSpacing = ((headerView.frame.size.height -
    (daysLabel.frame.origin.y + daysLabel.frame.size.height)) - 44.0f) * 0.5;
  currentOfferLabel.frame = CGRectMake(0.0f,
    headerView.frame.size.height - (currentOfferLabelSpacing + 44.0f),
      screenWidth, 44.0f);
  currentOfferLabel.text = @"Current offer: $4,500";
  currentOfferLabel.textAlignment = NSTextAlignmentCenter;
  currentOfferLabel.textColor = [UIColor whiteColor];
  // [headerView addSubview: currentOfferLabel];

  // Personal note text view
  personalNoteTextView = [UITextView new];
  // personalNoteTextView.contentInset = UIEdgeInsetsMake(0.0f, 10.0f,
  //   0.0f, -20.0f);
  personalNoteTextView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
  personalNoteTextView.delegate = self;
  personalNoteTextView.font = [UIFont normalTextFont];
  personalNoteTextView.frame = CGRectMake(padding, padding,
    screenWidth - (padding * 2), padding * 5); // 5 times the line height

  AMBlurView *inputAccView = [[AMBlurView alloc] init];
  // inputAccView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.f];
  inputAccView.frame = CGRectMake(0.f, 0.0, screenWidth, 40.0);
  UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
  btnDone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
  [btnDone addTarget:self
    action:@selector(done)
      forControlEvents:UIControlEventTouchUpInside];
  btnDone.titleLabel.font = [UIFont normalTextFontBold];
  [btnDone setTitle:@"Done" forState:UIControlStateNormal];
  [btnDone setTitleColor: [UIColor blue] forState:UIControlStateNormal];
  btnDone.frame = CGRectMake(inputAccView.frame.size.width - (80.0f + padding),
    0.0f, 80.0f, inputAccView.frame.size.height);
  [inputAccView addSubview:btnDone];
  personalNoteTextView.inputAccessoryView = inputAccView;
  personalNoteTextView.textColor = [UIColor textColor];

  // Personal note text view place holder
  personalNoteTextViewPlaceholder = [UILabel new];
  personalNoteTextViewPlaceholder.font = personalNoteTextView.font;
  personalNoteTextViewPlaceholder.frame = CGRectMake(5.0f, 8.0f,
    personalNoteTextView.frame.size.width, 20.0f);
  personalNoteTextViewPlaceholder.text = @"Write your personal note here...";
  personalNoteTextViewPlaceholder.textColor = [UIColor grayMedium];
  [personalNoteTextView addSubview: personalNoteTextViewPlaceholder];

  // Alert view
  alert = [[OMBAlertView alloc] init];
  [alert addTarget: self action: @selector(hideAlert)
    forButton: alert.alertCancel];
  [alert addTarget: self action: @selector(submitOffer)
    forButton: alert.alertConfirm];
  [alert.alertCancel setTitle: @"Cancel" forState: UIControlStateNormal];
  [alert.alertConfirm setTitle: @"Submit" forState: UIControlStateNormal];

  // Alert view blur
  alertBlur = [[OMBAlertViewBlur alloc] init];

  // Help pop up
  CGFloat helpHeight = OMBStandardButtonHeight + padding;
  helpPopUpView = [[OMBHelpPopUpView alloc] initWithFrame: CGRectMake(
    0.0f, -helpHeight, screenWidth, helpHeight)];
  [helpPopUpView setLabelText: @"Placing an offer?\n"
    @"Tap here to see how it works."];
  [helpPopUpView.button addTarget: self
    action: @selector(showPlaceOfferHowItWorks)
      forControlEvents: UIControlEventTouchUpInside];
  [self.view addSubview: helpPopUpView];
}

- (void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];

  // if (!hasOfferValue) {
  //   [self scrollToPlaceOffer];
  // }

  if (![[OMBUser currentUser] primaryPaymentPayoutMethod]) {
    [UIView animateWithDuration: OMBStandardDuration * 2 delay: 0.0
      usingSpringWithDamping: 0.65 initialSpringVelocity: 0.5 options: 0
        animations: ^{
          CGRect rect = helpPopUpView.frame;
          rect.origin.y = OMBPadding + OMBStandardHeight;
          // rect.origin.x = 0.0f;
          helpPopUpView.frame = rect;
        }
        completion: nil];
  }
}

- (void) viewDidDisappear: (BOOL) animated
{
  [super viewDidDisappear: animated];
}

- (void) setResidenceImageViewImage
{
  __weak typeof (residenceImageView) weakImageView = residenceImageView;
  [residenceImageView.imageView sd_setImageWithURL: residence.coverPhotoURL
    placeholderImage: nil completed:
      ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
          weakImageView.image = image;
      }
    ];
}

- (void) viewWillAppear: (BOOL) animated
{
  [super viewWillAppear: animated];

  // Bed, bath
  bedBathLabel.text = [NSString stringWithFormat: @"%.0f bd  /  %.0f ba",
    residence.bedrooms, residence.bathrooms];
  // Image
  if (residence.coverPhotoURL) {
    [self setResidenceImageViewImage];
  }
  else {
    [residence downloadCoverPhotoWithCompletion: ^(NSError *error) {
      [self setResidenceImageViewImage];
    }];
  }

  // Move In & Out preferences
  NSDictionary *dates = [OMBUser currentUser].movedInOut;
  if([dates objectForKey:@1]){
    OMBOffer *preference = (OMBOffer *)[dates objectForKey:@1];
    offer.moveInDate = preference.moveInDate;
    offer.moveOutDate = preference.moveOutDate;
  }

  // Landlord Preferred Date
  isLandlordPreferredDate = YES;

  // Rent
  rentLabel.text = [residence rentToCurrencyString];
  // Title, address
  if ([[residence.title stripWhiteSpace] length])
    titleLabel.text = residence.title;
  else
    titleLabel.text = [residence.address capitalizedString];

  // Resize Title and rent
  CGFloat padding = bedBathLabel.frame.origin.x;
  CGRect rentRect = [rentLabel.text boundingRectWithSize:
    CGSizeMake(bedBathLabel.frame.size.width, rentLabel.frame.size.height)
      font: rentLabel.font];
  rentLabel.frame = CGRectMake(
   self.table.frame.size.width - (rentRect.size.width + padding),
    rentLabel.frame.origin.y, rentRect.size.width,
      rentLabel.frame.size.height);
  titleLabel.frame = CGRectMake(titleLabel.frame.origin.x,
    titleLabel.frame.origin.y, self.table.frame.size.width -
    (padding + padding + rentLabel.frame.size.width + padding),
      titleLabel.frame.size.height);

  // Total price notes
  if ([offer isAboveThreshold]) {
    totalPriceNotes = [NSString stringWithFormat:
      @"A down payment of %@ will be charged\n"
      @"upon offer acceptance to secure the place.\n"
      @"If your offer is accepted, you will have %@ "
      @"to sign the lease and pay the remainder total\n"
      @"of %@ for the 1st months rent and\n"
      @"deposit through OnMyBlock.\n",
      [NSString numberToCurrencyString: [offer downPaymentAmount]],
      [offer timelineStringForStudent],
      [NSString numberToCurrencyString: [offer remainingBalanceAmount]]];
  }
  else {
    totalPriceNotes = [NSString stringWithFormat:
      @"You will not be charged upfront when you submit your offer. "
      @"You will authorize a future payment of %@ which will only "
      @"be charged if the landlord or subletter accepts your offer.",
      [NSString numberToCurrencyString: [offer downPaymentAmount]]];
  }



  CGRect rect = [totalPriceNotes boundingRectWithSize:
                 CGSizeMake(self.table.frame.size.width - (20.0f * 2), 9999)
                                                 font: [UIFont smallTextFont]];
  totalPriceNotesSize = rect.size;

  // Submit offer notes
  NSMutableAttributedString *string1 =
  [[NSMutableAttributedString alloc] initWithString:
   @"Tapping on \"Submit Offer\" means that you have read the "
   attributes: @{
                 NSFontAttributeName: [UIFont smallTextFont],
                 NSForegroundColorAttributeName: [UIColor grayMedium]
                 }
   ];
  NSMutableAttributedString *string2 =
  [[NSMutableAttributedString alloc] initWithString: @"legal details"
                                         attributes: @{
                                                       NSFontAttributeName: [UIFont smallTextFont],
                                                       NSForegroundColorAttributeName: [UIColor blue]
                                                       }
   ];
  NSMutableAttributedString *string3 =
  [[NSMutableAttributedString alloc] initWithString:
   @" of this property and understand that you will be required to sign a lease (and co-signer agreement) to secure this rental."
                                         attributes: @{
                                                       NSFontAttributeName: [UIFont smallTextFont],
                                                       NSForegroundColorAttributeName: [UIColor grayMedium]
                                                       }
   ];
  [string1 appendAttributedString: string2];
  [string1 appendAttributedString: string3];

  submitOfferNotes = string1;
  CGRect rect2 = [submitOfferNotes boundingRectWithSize:
                  CGSizeMake(self.table.frame.size.width - (20.0f * 2), 9999)
                                                options: NSStringDrawingUsesLineFragmentOrigin context: nil];
  submitOfferNotesSize = rect2.size;

  // Submit button
  if ([[OMBUser currentUser] primaryPaymentPayoutMethod]) {
    // [submitOfferButton setTitle: @"Submit Offer"
    //                    forState: UIControlStateNormal];
    effectLabel.text = @"Submit booking";
  }
  else {
    // [submitOfferButton setTitle: @"Add payment method"
    //                    forState: UIControlStateNormal];
    effectLabel.text = @"Add a payment method";
  }
  [effectLabel performEffectAnimation];

  // Fetch payout methods
  [[OMBUser currentUser] fetchPayoutMethodsWithCompletion: ^(NSError *error) {
    [self.table reloadData];
  }];
  // Fecth Coapplicants
  [self fetchCoapplicants];

  [self.table reloadData];

  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(keyboardWillShow:)
      name: UIKeyboardWillShowNotification object: nil];
  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(keyboardWillHide:)
      name: UIKeyboardWillHideNotification object: nil];

  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(userAddedFirstPayoutMethod)
      name: OMBPayoutMethodNotificationFirst object: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
  [super viewWillDisappear: animated];

  [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Protocol

#pragma mark - Protocol MNCalendarViewDelegate

- (void) calendarView: (MNCalendarView *) calendarView
  didSelectDate: (NSDate *) date
{
  OMBResidenceBookItCalendarCell *calendarCell = [self calendarCell];
  OMBResidenceConfirmDetailsDatesCell *datesCell = [self datesCell];

  NSString *dateString = [dateFormatter1 stringFromDate: date];
  // Move-in
  if (isShowingMoveInCalendar) {
    offer.moveInDate = [date timeIntervalSince1970];
    datesCell.moveInDateLabel.text = dateString;
    // If move-in date is greater than move-out date
    if (offer.moveOutDate && [date compare:
      [NSDate dateWithTimeIntervalSince1970: offer.moveOutDate]] ==
        NSOrderedDescending) {
      // Move-out date becomes the later date
      offer.moveOutDate = [date timeIntervalSince1970];
      datesCell.moveOutDateLabel.text = dateString;
    }
    // Switch to the move-out calendar
    [self showMoveOutCalendar];
  }
  // Move-out
  else if (isShowingMoveOutCalendar) {
    offer.moveOutDate = [date timeIntervalSince1970];
    datesCell.moveOutDateLabel.text = dateString;
    // If move-out date is less than move-in date
    if (offer.moveInDate && [date compare:
      [NSDate dateWithTimeIntervalSince1970: offer.moveInDate]] ==
        NSOrderedAscending) {
      offer.moveInDate = [date timeIntervalSince1970];
      datesCell.moveInDateLabel.text = dateString;
    }
    // Hide the calendar
    [self hideCalendar];
  }
  // Set the selected date for the calendar cell
  calendarCell.calendarView.moveInDate =
    [NSDate dateWithTimeIntervalSince1970: offer.moveInDate];
  calendarCell.calendarView.moveOutDate =
    [NSDate dateWithTimeIntervalSince1970: offer.moveOutDate];
  // Set the month lease
  int monthsBetween = [offer numberOfMonthsBetweenMovingDates];
  if (monthsBetween > 0) {
    leaseMonthsLabel.text = [NSString stringWithFormat:
      @"%i month lease", monthsBetween];
  }
  else {
    leaseMonthsLabel.text = @"month to month";
  }

  [self verifyLandlordPreference];
}

- (BOOL) calendarView: (MNCalendarView *) calendarView
     shouldSelectDate: (NSDate *) date
{
  // Set days that it cannot be selected
  if ([date timeIntervalSinceDate: [NSDate date]] < 0){
    return NO;
  }
  return YES;
}

#pragma mark - Protocol UIAlertViewDelegate

// - (void) alertView: (UIAlertView *) alertView
// clickedButtonAtIndex: (NSInteger) buttonIndex
// {
//   [self.navigationController popViewControllerAnimated: YES];
// }

- (void) alertView: (UIAlertView *) alertView
clickedButtonAtIndex: (NSInteger) buttonIndex
{
  if (buttonIndex == 0) {
    [[self userDefaults] permissionPushNotificationsSet: NO];
  }
  else if (buttonIndex == 1) {
    [[self userDefaults] permissionPushNotificationsSet: YES];
    [[self appDelegate] registerForPushNotifications];
  }
  [[self appDelegate].container showHomebaseRenter];
  [self hideAlertBlurAndPopController];
}

#pragma mark - Protocol OMBConnectionProtocol

- (void) JSONDictionary:(NSDictionary *)json
{
  [[self renterApplication] readFromDictionary:json
    forModelName:[OMBRoommate modelName]];
  [self.table reloadData];
}

#pragma mark - Protocol PayPalPaymentDelegate

- (void) payPalFuturePaymentDidCancel: 
(PayPalFuturePaymentViewController *)futurePaymentViewController
{
  // The payment was canceled; dismiss
  [futurePaymentViewController dismissViewControllerAnimated: YES
    completion: nil];
}

- (void) payPalFuturePaymentViewController: 
(PayPalFuturePaymentViewController *) futurePaymentViewController
didAuthorizeFuturePayment: (NSDictionary *) futurePaymentAuthorization
{
  // The user has successfully logged into PayPal,
  // and has consented to future payments.

  // Your code must now send the authorization response to your server.
  // [self sendAuthorizationToServer:futurePaymentAuthorization];
  // NSLog(@"Future:\n%@", futurePaymentAuthorization);

  NSDictionary *response = futurePaymentAuthorization[@"response"];
  if (response && response[@"code"])
    offer.authorizationCode = response[@"code"];

  // When your server makes its payment request to PayPal, it must include a
  // Paypal-Application-Correlation-Id HTTP header with this Application
  // Correlation ID value obtained from the SDK.
  // NSString *correlationId =
  //   [PayPalMobile applicationCorrelationIDForEnvironment:
  //     PayPalEnvironmentProduction];
  // NSLog(@"Correlation:\n%@", correlationId);

  // Dismiss
  [futurePaymentViewController dismissViewControllerAnimated: YES
    completion: ^{
      if (offer.authorizationCode) {
        [self createOffer];
        [self trackBookItSubmitted];
      }
      else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
          @"PayPal Authorize Failed" message: @"Please authorize your "
            @"PayPal for a future payment." delegate: nil
              cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [alertView show];
      }
    }];
}

- (void) payPalPaymentDidCancel: (PayPalPaymentViewController *)
paymentViewController
{
  [paymentViewController dismissViewControllerAnimated: YES completion: nil];
}


- (void) payPalPaymentViewController: (PayPalPaymentViewController *)
paymentViewController
didCompletePayment: (PayPalPayment *) completedPayment
{
  NSLog(@"%@", completedPayment);
  [paymentViewController dismissViewControllerAnimated: YES completion: nil];
}
#pragma mark - Protocol UIScrollViewDelegate

- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView
{
  if (hasOfferValue) {
    [self.view endEditing: YES];
  }
}

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
  CGFloat y = scrollView.contentOffset.y;
  CGFloat adjustment = y / 3.0f;

  // Adjust the back view
  // 0.0f = the back view's origin y
  CGRect backViewRect = backView.frame;
  backViewRect.origin.y = 0.0f - adjustment;
  backView.frame = backViewRect;
}

#pragma mark - Protocol UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  // Place offer
  // Dates
  // Co-applicants
  // Price breakdown
  // Payout methods
  // Monthly schedule
  // Renter profile
  // Submit offer notes
  // Spacing
  return 9;
}

- (UITableViewCell *) tableView: (UITableView *) tableView
cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row     = indexPath.row;
  NSUInteger section = indexPath.section;
  BOOL isForSpacing = NO;

  CGFloat padding = OMBPadding;
  UIEdgeInsets maxInsets = UIEdgeInsetsMake(0.0f, tableView.frame.size.width,
    0.0f, 0.0f);

  static NSString *EmptyCellIdentifier = @"EmptyCellIdentifier";
  UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:
                                EmptyCellIdentifier];
  if (!emptyCell)
    emptyCell = [[UITableViewCell alloc] initWithStyle:
                 UITableViewCellStyleValue1 reuseIdentifier: EmptyCellIdentifier];
  emptyCell.detailTextLabel.text = @"";
  emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
  emptyCell.textLabel.font =
  [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
  emptyCell.textLabel.text = @"";
  emptyCell.textLabel.textColor = [UIColor textColor];
  UIView *bottomBorder = [emptyCell.contentView viewWithTag: 9999];
  if (bottomBorder)
    [bottomBorder removeFromSuperview];
  else {
    bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor grayLight];
    bottomBorder.tag = 9999;
  }
  // Spacing as the first row in each section except the first section
  // if (indexPath.section != 0) {
  //   if (indexPath.row == 0) {
  //     emptyCell.accessoryType = UITableViewCellAccessoryNone;
  //     emptyCell.backgroundColor = [UIColor grayUltraLight];
  //     emptyCell.detailTextLabel.text = emptyCell.textLabel.text = @"";
  //     emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
  //     // Bottom border
  //     // bottomBorder.frame = CGRectMake(0.0f, 44.0f - 0.5f,
  //     //   tableView.frame.size.width, 0.5f);
  //     // [emptyCell.contentView addSubview: bottomBorder];
  //   }
  // }
  // Place offer
  if (indexPath.section == OMBResidenceBookItConfirmDetailsSectionPlaceOffer) {
    if (indexPath.row == 0) {
      static NSString *PlaceOfferIdentifier = @"PlaceOfferIdentifier";
      OMBResidenceConfirmDetailsPlaceOfferCell *cell =
      [tableView dequeueReusableCellWithIdentifier: PlaceOfferIdentifier];
      if (!cell)
        cell = [[OMBResidenceConfirmDetailsPlaceOfferCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: PlaceOfferIdentifier];
      [cell.nextStepButton addTarget: self action: @selector(review)
                    forControlEvents: UIControlEventTouchUpInside];
      cell.yourOfferTextField.delegate = self;
      [cell.yourOfferTextField addTarget: self
                                  action: @selector(textFieldDidChange:)
                        forControlEvents: UIControlEventEditingChanged];
        cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Move in and move out dates, View Lease Details
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionDates) {
    // if (indexPath.row == 1) {
    // Move in, move out dates
    if (indexPath.row ==
        OMBResidenceBookItConfirmDetailsSectionDatesRowsMoveInMoveOut) {

      static NSString *DateIdentifier = @"DateIdentifier";
      OMBResidenceConfirmDetailsDatesCell *cell =
      [tableView dequeueReusableCellWithIdentifier: DateIdentifier];
      if (!cell) {
        cell = [[OMBResidenceConfirmDetailsDatesCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: DateIdentifier];

        // [cell loadResidence: residence];
        cell.leaseMonthsLabel.hidden = YES;
        // Labels
        cell.moveInDateLabel.text = [dateFormatter1 stringFromDate:
          [NSDate dateWithTimeIntervalSince1970: offer.moveInDate]];
        cell.moveInDateLabel.textColor = [UIColor blue];
        // cell.moveOutDateLabel.text = @"-";
        cell.moveOutDateLabel.text = [dateFormatter1 stringFromDate:
          [NSDate dateWithTimeIntervalSince1970: offer.moveOutDate]];

        // Buttons
        // Move-in date
        [cell.moveInButton addTarget: self action: @selector(showMoveInCalendar)
          forControlEvents: UIControlEventTouchUpInside];
        // Move-out date
        [cell.moveOutButton addTarget: self
          action: @selector(showMoveOutCalendar)
            forControlEvents: UIControlEventTouchUpInside];
      }
        cell.clipsToBounds = YES;
      return cell;
    }
    // The calendar
    else if (indexPath.row ==
      OMBResidenceBookItConfirmDetailsSectionDatesRowsCalendar) {

      static NSString *CalID = @"CalID";
      OMBResidenceBookItCalendarCell *cell =
      [tableView dequeueReusableCellWithIdentifier: CalID];
      if (!cell)
        cell = [[OMBResidenceBookItCalendarCell alloc] initWithStyle:
          UITableViewCellStyleDefault reuseIdentifier: CalID];
      cell.calendarView.delegate = self;
      cell.separatorInset = UIEdgeInsetsMake(0.0f,
        tableView.frame.size.width, 0.0f, 0.0f);

      int monthsBetween = [offer numberOfMonthsBetweenMovingDates];
      if (monthsBetween > 0)
        leaseMonthsLabel.text = [NSString stringWithFormat:
          @"%i month lease", monthsBetween];
      else
        leaseMonthsLabel.text = @"month to month";

        cell.clipsToBounds = YES;
      return cell;

      // if (selectedIndexPath &&
      //     selectedIndexPath.section == indexPath.section &&
      //     selectedIndexPath.row == indexPath.row - 1) {

      //   static NSString *CalendarCellIdentifier = @"CalendarCellIdentifier";
      //   OMBResidenceBookItCalendarCell *calendarCell =
      //     [tableView dequeueReusableCellWithIdentifier: CalendarCellIdentifier];
      //   if (!calendarCell)
      //     calendarCell = [[OMBResidenceBookItCalendarCell alloc] initWithStyle:
      //                     UITableViewCellStyleDefault reuseIdentifier:
      //                     CalendarCellIdentifier];

      //   calendarCell.calendarView.delegate = self;
      //   return calendarCell;
      // }
    }
    // Lease months
    else if (indexPath.row == 2) {
      static NSString *CellIdentifier = @"CellIdentifier";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                               CellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleValue1 reuseIdentifier: CellIdentifier];
        [leaseMonthsLabel removeFromSuperview];
        [cell.contentView addSubview: leaseMonthsLabel];

      }
      cell.backgroundColor = [UIColor grayUltraLight];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.separatorInset = UIEdgeInsetsMake(0.0f, tableView.frame.size.width,
                                             0.0f, 0.0f);
        cell.clipsToBounds = YES;
      return cell;
    }
    // View lease details
    else if (indexPath.row == 3) {
      static NSString *CellIdentifier = @"CellIdentifier";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                               CellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleValue1 reuseIdentifier: CellIdentifier];
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 13];
        label.frame = CGRectMake(20.0f, 0.0f,
                                 tableView.frame.size.width - (20 * 2), 24.f);
        label.text = @"View Legal Details";
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor blue];
        [cell.contentView addSubview: label];
        // UIView *bor = [UIView new];
        // bor.backgroundColor = [UIColor grayLight];
        // bor.frame = CGRectMake(0.0f, label.frame.size.height - 0.5f,
        //                        cell.bounds.size.width, 0.5f);
        // [cell.contentView addSubview: bor];
      }
      cell.backgroundColor = [UIColor grayUltraLight];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.separatorInset = UIEdgeInsetsMake(0.0f, tableView.frame.size.width,
                                             0.0f, 0.0f);
        cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Coapplicants
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionCoapplicants) {
    // Header
    if(indexPath.row == 0){
      static NSString *RoommateHeaderCellID = @"RoommateHeaderCellID";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
        RoommateHeaderCellID];
      if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:
          UITableViewCellStyleValue1 reuseIdentifier: RoommateHeaderCellID];

      cell.backgroundColor = [UIColor whiteColor];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.detailTextLabel.font =
        [UIFont fontWithName: @"HelveticaNeue-Medium" size: 15];
      cell.detailTextLabel.text = @"";
      cell.detailTextLabel.textColor = [UIColor textColor];
      cell.textLabel.font = [UIFont normalTextFontBold];
      cell.textLabel.textColor = [UIColor textColor];
      cell.textLabel.text = @"Co-applicants";

        cell.clipsToBounds = YES;
      return cell;
    }
    else if (indexPath.row == [[self roommates] count] + 1) {
      isForSpacing = YES;
    }
    else {
      static NSString *RoommateCellID = @"RoommateCellID";
      OMBRoommateCell *cell = [tableView dequeueReusableCellWithIdentifier:
        RoommateCellID];
      if (!cell) {
        cell = [[OMBRoommateCell alloc] initWithStyle:
          UITableViewCellStyleDefault reuseIdentifier:RoommateCellID];
      }
      [cell loadDataFromUser:
        [[self roommates] objectAtIndex: indexPath.row - 1]];
      // If this is the last roommate
      if (row == [[self roommates] count]) {
        cell.separatorInset = maxInsets;
      }
      cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Price breakdown
  else if (section == OMBResidenceBookItConfirmDetailsSectionPriceBreakdown) {
    emptyCell.accessoryType = UITableViewCellAccessoryNone;
    // Price Breakdown, Deposit, 1st Month's Rent
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 ||
        indexPath.row == 3|| indexPath.row == 4) {
      static NSString *PriceCellIdentifier = @"PriceCellIdentifier";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                               PriceCellIdentifier];
      if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:
          UITableViewCellStyleValue1 reuseIdentifier: PriceCellIdentifier];
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
      if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont normalTextFontBold];
      }
      else
        cell.textLabel.font =
        [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
      cell.detailTextLabel.text = @"";
      cell.detailTextLabel.textColor = [UIColor textColor];
      cell.textLabel.textColor = [UIColor textColor];
      if (indexPath.row == 0) {
        cell.textLabel.text = @"Price Breakdown";
      }
      else if (indexPath.row == 1) {
        cell.detailTextLabel.text = [NSString numberToCurrencyString:
          [residence deposit]];
        cell.textLabel.text = @"Security Deposit";
      }
      else if (indexPath.row == 2) {
        cell.detailTextLabel.text = [NSString numberToCurrencyString:
          offer.amount];
        cell.textLabel.text = @"1st Month's Rent";
      }
      else if (indexPath.row == 3) {
        cell.detailTextLabel.text = [NSString numberToCurrencyString:
          [offer downPaymentAmount]];
        cell.textLabel.text = @"Down Payment";
      }
      else if (indexPath.row == 4) {
        cell.detailTextLabel.text = [NSString numberToCurrencyString:
          [offer remainingBalanceAmount]];
        cell.textLabel.text = @"Remaining Payment";
      }
      cell.clipsToBounds = YES;
      return cell;
    }
    // Total
    else if (indexPath.row == 5) {
      static NSString *TotalCellIdentifier = @"TotalCellIdentifier";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
        TotalCellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
          UITableViewCellStyleValue1 reuseIdentifier: TotalCellIdentifier];
        // Bottom border
        UIView *bor = [UIView new];
        bor.backgroundColor = [UIColor grayLight];
        bor.frame = CGRectMake(0.0f, 20 + 36.0f + 20 - 0.5f,
                               tableView.frame.size.width, 0.5f);
        [cell.contentView addSubview: bor];
      }
      cell.backgroundColor = [UIColor whiteColor];
      cell.detailTextLabel.font =
      [UIFont fontWithName: @"HelveticaNeue-Medium" size: 27];
      cell.detailTextLabel.text = [NSString numberToCurrencyString:
        [offer totalAmount]];
      cell.detailTextLabel.textColor = [UIColor green];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.font =
      [UIFont fontWithName: @"HelveticaNeue-Light" size: 27];
      cell.textLabel.text = @"Total";
      cell.textLabel.textColor = [UIColor textColor];
        cell.clipsToBounds = YES;
      return cell;
    }
    // Extra information, notes, etc.
    else if (indexPath.row == 6) {
      static NSString *PriceBreakdownNotesID = @"PriceBreakdownNotesID";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
        PriceBreakdownNotesID];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
          UITableViewCellStyleValue1 reuseIdentifier: PriceBreakdownNotesID];
        UILabel *label = [UILabel new];
        label.font = [UIFont smallTextFont];
        label.frame = CGRectMake(padding, padding,
          tableView.frame.size.width - (padding * 2),
            totalPriceNotesSize.height);
        label.numberOfLines = 0;
        label.text = totalPriceNotes;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayMedium];
        [cell.contentView addSubview: label];
        // UIView *bor = [UIView new];
        // bor.backgroundColor = [UIColor grayLight];
        // bor.frame = CGRectMake(0.0f, label.frame.size.height - 0.5f,
        //   cell.bounds.size.width, 0.5f);
        // [cell.contentView addSubview: bor];
      }
      cell.backgroundColor = [UIColor grayUltraLight];
      cell.selectionStyle  = UITableViewCellSelectionStyleNone;
      cell.separatorInset  = maxInsets;
      cell.clipsToBounds   = YES;
      return cell;
    }
    // Price Breakdown arrow (Not being used)!!!
    else if (indexPath.row == 99) {
      static NSString *PriceBreakdownIdentifier = @"PriceBreakdownIdentifier";
      UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier: PriceBreakdownIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault
                                      reuseIdentifier: PriceBreakdownIdentifier];
        // Border
        UIView *bottomBorder2 = [UIView new];
        bottomBorder2.backgroundColor = tableView.separatorColor;
        bottomBorder2.frame = CGRectMake(0.0f, 44.0f - 0.5f,
                                         tableView.frame.size.width, 0.5f);
        [cell.contentView addSubview: bottomBorder2];
        // Sort arrow
        CGFloat padding = 20.0f;
        CGFloat sortArrowSize = 20.0f;
        UIImageView *sortArrow = [[UIImageView alloc] init];
        sortArrow.alpha = 0.5f;
        sortArrow.frame = CGRectMake(tableView.frame.size.width -
                                     (sortArrowSize + padding), (44.0f - sortArrowSize) * 0.5,
                                     sortArrowSize, sortArrowSize);
        sortArrow.image = [UIImage imageNamed: @"arrow_left.png"];
        sortArrow.transform = CGAffineTransformMakeRotation(
                                                            -90 * M_PI / 180.0f);
        [cell.contentView addSubview: sortArrow];
      }
      cell.textLabel.font =
      [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
      cell.textLabel.text = @"Price Breakdown";
      cell.textLabel.textColor = [UIColor grayMedium];
        cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Payout methods
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionPayoutMethods) {
    if (indexPath.row < [[OMBUser currentUser].payoutMethods count]) {
      static NSString *PayoutID = @"PayoutID";
      OMBPayoutMethodListCell *cell =
      [tableView dequeueReusableCellWithIdentifier: PayoutID];
      if (!cell)
        cell = [[OMBPayoutMethodListCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: PayoutID];
      OMBPayoutMethod *payoutMethod = [[self payoutMethods] objectAtIndex:
                                       indexPath.row];
      [cell loadPayoutMethod: payoutMethod];
      if (indexPath.row == [[self payoutMethods] count] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.0f,
                                               tableView.frame.size.width, 0.0f, 0.0f);
      }
      if ([[self payoutMethods] count] == 1 && indexPath.row == 0)
        cell.userInteractionEnabled = NO;
      else
        cell.userInteractionEnabled = YES;

        cell.clipsToBounds = YES;
      return cell;
    }
    else {
      static NSString *AddPayoutID = @"AddPayoutID";
      UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier: AddPayoutID];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: AddPayoutID];

        UIButton *button = [UIButton new];
        button.backgroundColor = [UIColor blue];
        button.frame = CGRectMake(padding, padding,
          tableView.frame.size.width - (padding * 2),
            OMBStandardHeight);
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont normalTextFontBold];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self
          action:@selector(showPayoutMethods)
            forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:
         [UIImage imageWithColor: [UIColor blueHighlightedAlpha: 0.3f]]
           forState: UIControlStateHighlighted];
        [button setTitle: @"Add new payment method"
          forState:UIControlStateNormal];
        [button setTitleColor: UIColor.whiteColor
          forState:UIControlStateNormal];
        [cell.contentView addSubview: button];
      }
      cell.backgroundColor = [UIColor grayUltraLight];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.separatorInset = UIEdgeInsetsMake(0.0f,
                                             tableView.frame.size.width, 0.0f, 0.0f);
        cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Monthly schedule, View Lease Details (NOT IN USE ANYMORE) !!!
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionMonthlySchedule) {
    if (indexPath.row == 1 || indexPath.row == 2) {
      emptyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      emptyCell.backgroundColor = [UIColor whiteColor];
      emptyCell.detailTextLabel.text = @"";
      emptyCell.selectionStyle = UITableViewCellSelectionStyleDefault;

      // Monthly schedule
      if (indexPath.row == 1) {
        emptyCell.textLabel.text = @"Monthly Payment Schedule";
      }
      // Lease agreement
      else if (indexPath.row == 2) {
        emptyCell.textLabel.text = @"View Lease Details";
      }
    }
  }
  // Buyer, My Renter Profile, Add note to this offer
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionRenterProfile) {
    // Buyer
    if (indexPath.row == 0) {
      static NSString *BuyerCellIdentifier = @"BuyerCellIdentifier";
      OMBResidenceConfirmDetailsBuyerCell *cell =
      [tableView dequeueReusableCellWithIdentifier: BuyerCellIdentifier];
      if (!cell) {
        cell = [[OMBResidenceConfirmDetailsBuyerCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: BuyerCellIdentifier];
        UIView *bor = [UIView new];
        bor.backgroundColor = [UIColor grayLight];
        bor.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
        [cell.contentView addSubview: bor];
      }
      [cell loadUser: [OMBUser currentUser]];
        cell.clipsToBounds = YES;
      return cell;
    }
    // My Renter Profile
    else if (indexPath.row == 1) {
      static NSString *RenterProfileCellIdentifier =
      @"RenterProfileCellIdentifier";
      UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:
       RenterProfileCellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleValue1 reuseIdentifier:
                RenterProfileCellIdentifier];
      }
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.backgroundColor = [UIColor whiteColor];
      cell.detailTextLabel.font = cell.textLabel.font =
      [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
      NSInteger percentage = [[OMBUser currentUser] profilePercentage];
      cell.detailTextLabel.text = [NSString stringWithFormat:
                                   @"%i%% complete", percentage];
      UIColor *color = [UIColor red];
      if (percentage >= 90)
        color = [UIColor green];
      else if (percentage >= 50)
        color = [UIColor yellow];
      cell.detailTextLabel.textColor = color;
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      cell.textLabel.text = @"My Renter Profile";
      cell.textLabel.textColor = [UIColor textColor];
        cell.clipsToBounds = YES;
      return cell;
    }
    // Add note to this offer
    else if (indexPath.row == 2) {
      static NSString *AddNoteIdentifier = @"AddNoteIdentifier";
      UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier: AddNoteIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault
                                      reuseIdentifier: AddNoteIdentifier];
        // Border
        UIView *bottomBorder2 = [UIView new];
        bottomBorder2.backgroundColor = tableView.separatorColor;
        bottomBorder2.frame = CGRectMake(0.0f, 44.0f - 0.5f,
                                         tableView.frame.size.width, 0.5f);
        [cell.contentView addSubview: bottomBorder2];
        // Arrow pointing down
        CGFloat padding = 20.0f;
        CGFloat sortArrowSize = 20.0f;
        UIImageView *sortArrow = [[UIImageView alloc] init];
        sortArrow.alpha = 0.3f;
        sortArrow.frame = CGRectMake(tableView.frame.size.width -
                                     (sortArrowSize + padding), (44.0f - sortArrowSize) * 0.5,
                                     sortArrowSize, sortArrowSize);
        sortArrow.image = [UIImage imageNamed: @"arrow_left.png"];
        sortArrow.transform = CGAffineTransformMakeRotation(
                                                            -90 * M_PI / 180.0f);
        [cell.contentView addSubview: sortArrow];
      }
      cell.textLabel.font =
      [UIFont fontWithName: @"HelveticaNeue-Light" size: 15];
      cell.textLabel.text = @"Add note to this offer";
      cell.textLabel.textColor = [UIColor textColor];
        cell.clipsToBounds = YES;
      return cell;
    }
    // Personal note text view
    else if (indexPath.row == 3) {
      static NSString *NoteCellIdentifier = @"NoteCellIdentifier";
      UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier: NoteCellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier: NoteCellIdentifier];
        [personalNoteTextView removeFromSuperview];
        [cell.contentView addSubview: personalNoteTextView];
        UIView *bor = [UIView new];
        bor.backgroundColor = [UIColor grayLight];
        bor.frame = CGRectMake(0.0f,
                               padding + personalNoteTextView.frame.size.height + padding - 0.5f,
                               tableView.frame.size.width, 0.5f);
        [cell.contentView addSubview: bor];
      }
      personalNoteTextView.text = personalNote;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.clipsToBounds = YES;
      return cell;
    }
  }
  // Submit offer notes
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionSubmitOfferNotes) {
    static NSString *SubmitNotesIdentifier = @"SubmitNotesIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SubmitNotesIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:
              UITableViewCellStyleValue1 reuseIdentifier: SubmitNotesIdentifier];
      UILabel *label = [UILabel new];
      label.attributedText = submitOfferNotes;
      label.font = [UIFont smallTextFont];
      label.frame = CGRectMake(padding, padding,
                               tableView.frame.size.width - (padding * 2),
                               submitOfferNotesSize.height);
      label.numberOfLines = 0;
      label.textAlignment = NSTextAlignmentCenter;
      [cell.contentView addSubview: label];
    }
    cell.backgroundColor = [UIColor grayUltraLight];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0.0f, tableView.frame.size.width,
                                           0.0f, 0.0f);
      cell.clipsToBounds = YES;
    return cell;
  }
  // Spacing
  else if (indexPath.section ==
    OMBResidenceBookItConfirmDetailsSectionSpacing) {
    isForSpacing = YES;
  }
  if (isForSpacing) {
    emptyCell.backgroundColor = [UIColor grayUltraLight];
    emptyCell.separatorInset  = maxInsets;
  }
  emptyCell.clipsToBounds = YES;
  return emptyCell;
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
  // Place offer
  if (section == OMBResidenceBookItConfirmDetailsSectionPlaceOffer) {
    return 1;
  }
  // Dates
  else if (section == OMBResidenceBookItConfirmDetailsSectionDates) {
    // No top spacing
    // Move in, move out, lease months, view lease details
    return 1 + 1 + 1 + 1;
    // Spacing
    // return 1 + 1;
  }
  // Coapplicants
  else if (section == OMBResidenceBookItConfirmDetailsSectionCoapplicants) {
    if([self roommates].count > 0){
      // 1 for header and 1 for spacing at the bottom
      return 1 + [self roommates].count + 1;
    }else
      return 0;
  }
  // Price Breakdown
  else if (section == OMBResidenceBookItConfirmDetailsSectionPriceBreakdown) {
    // Price Breakdown
    // Security Deposit
    // 1st Month's Rent
    // Down Payment
    // Remaining Payment
    // Total
    // Total price notes
    return 7;
    // return 1 + 4;
  }
  // Payout methods
  else if (section == OMBResidenceBookItConfirmDetailsSectionPayoutMethods) {
    // The extra row is for adding a new payout method
    if ([[OMBUser currentUser].payoutMethods count])
      return [[OMBUser currentUser].payoutMethods count] + 1;
  }
  // Monthly schedule, lease agreement
  else if (section == OMBResidenceBookItConfirmDetailsSectionMonthlySchedule) {
    return 1 + 2;
  }
  // Buyer
  else if (section == OMBResidenceBookItConfirmDetailsSectionRenterProfile) {
    // Buyer
    // My Renter Profile
    // Add note to this offer
    // Note text view
    return 4;
    // return 1 + 3;
  }
  // Submit offer notes
  else if (section == OMBResidenceBookItConfirmDetailsSectionSubmitOfferNotes) {
    return 1;
  }
  // Spacing for typing
  else if (section == OMBResidenceBookItConfirmDetailsSectionSpacing) {
    return 1;
  }
  return 0;
}

#pragma mark - Protocol UITableViewDelegate

- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  // Move in, move out, lease months, view lease details

  if (indexPath.section == OMBResidenceBookItConfirmDetailsSectionDates) {
    // View lease details
    if (indexPath.row == 3) {
      [self.navigationController pushViewController:
        [[OMBResidenceLegalDetailsViewController alloc] initWithResidence:
          residence] animated: YES];
    }
  }
  else if(indexPath.section ==
          OMBResidenceBookItConfirmDetailsSectionCoapplicants){
    if(indexPath.row != 0 && indexPath.row != [[self roommates] count] + 1){
      OMBRoommate *aux = [[self roommates] objectAtIndex: indexPath.row - 1];
      // if is a OMB user
      if (aux.roommate)
        [self.navigationController pushViewController:
          [[OMBUserDetailViewController alloc] initWithUser:
            [aux otherUser: [OMBUser currentUser]]] animated: YES];
    }
  }
  // Price breakdown (NOT BEING USED) !!!
  // else if (indexPath.section == 2) {
  //   // Price breakdown
  //   if (indexPath.row == 4) {
  //     isShowingPriceBreakdown = YES;
  //     [tableView reloadSections: [NSIndexSet indexSetWithIndex: 2]
  //       withRowAnimation: UITableViewRowAnimationFade];
  //   }
  // }
  // Monthly schedule, lease agreement (NOT IN USE) !!!
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionMonthlySchedule) {
    if (indexPath.row == 1) {
      [self.navigationController pushViewController:
       [[OMBResidenceMonthlyPaymentScheduleViewController alloc]
        initWithResidence: residence] animated: YES];
    }
    else if (indexPath.row == 2) {
      [self.navigationController pushViewController:
       [[OMBResidenceLeaseAgreementViewController alloc] init] animated: YES];
    }
  }
  // Buyer
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionRenterProfile) {
    // My Renter Profile (No longer Renter application)
    if (indexPath.row == 0 || indexPath.row == 1) {
      OMBMyRenterProfileViewController *vc =
        [[OMBMyRenterProfileViewController alloc] init];
      [vc loadUser: [OMBUser currentUser]];
      [self.navigationController pushViewController: vc animated: YES];
    }
    // Add note to this offer
    else if (indexPath.row == 2) {
      // [self.navigationController pushViewController:
      //   [[OMBResidenceAddPersonalNoteViewController alloc] init]
      //     animated: YES];
      NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:
                                    indexPath.row + 1 inSection: indexPath.section];
      isAddingAPersonalNote = !isAddingAPersonalNote;
      [tableView reloadRowsAtIndexPaths: @[indexPath, nextIndexPath]
                       withRowAnimation: UITableViewRowAnimationFade];
      [tableView scrollToRowAtIndexPath: nextIndexPath
                       atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
  }
  // Payout methods
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionPayoutMethods) {
    // Add a new payout method
    if (indexPath.row == [[OMBUser currentUser].payoutMethods count]) {
      //[[self appDelegate].container showPayoutMethods];
    }
    // The other payout methods
    else {
      OMBPayoutMethod *payoutMethod = [[self payoutMethods] objectAtIndex:
                                       indexPath.row];
      payoutMethod.primary = YES;
      OMBPayoutMethodUpdateConnection *conn =
      [[OMBPayoutMethodUpdateConnection alloc] initWithPayoutMethod:
       payoutMethod attributes: @[@"primary"]];
      conn.completionBlock = ^(NSError *error) {
        if (payoutMethod.primary == YES && !error) {
          // Make all other payout methods that are primary and the
          // same deposit (or payment) not primary
          if (payoutMethod.primary)
            [[OMBUser currentUser] changeOtherSamePrimaryPayoutMethods:
             payoutMethod];
          [self.table reloadData];
        }
        else {
          [self showAlertViewWithError: error];
        }
        [[self appDelegate].container stopSpinning];
      };
      [[self appDelegate].container startSpinning];
      [conn start];
    }
  }
  // Submit offer notes
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionSubmitOfferNotes) {
    if (indexPath.row == 0) {
      [self.navigationController pushViewController:
        [[OMBResidenceLegalDetailsViewController alloc] initWithResidence:
          residence] animated: YES];
    }
  }
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat) tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  CGFloat padding = OMBPadding;
  CGFloat spacing = OMBStandardHeight;
  // Place offer
  if (indexPath.section == OMBResidenceBookItConfirmDetailsSectionPlaceOffer) {
    if (indexPath.row == 0) {
      return 0.0f;
      return [OMBResidenceConfirmDetailsPlaceOfferCell heightForCell];
    }
  }
  // else if (!hasOfferValue) {
  //   return 0.0f;
  // }

  // Dates
  else if (indexPath.section == OMBResidenceBookItConfirmDetailsSectionDates) {
    // if (indexPath.row == 0) {
    //   return spacing;
    // }
    // else if (indexPath.row == 1) {

    // Move in, move out dates
    if (indexPath.row == 0) {
      return [OMBResidenceConfirmDetailsDatesCell
              heightForCellWithNoLeaseMonthLabel];
      // return [OMBResidenceConfirmDetailsDatesCell heightForCell];
    }
    // Calendar
    else if (indexPath.row == 1){
      // if (selectedIndexPath &&
      //     selectedIndexPath.section == indexPath.section &&
      //     selectedIndexPath.row == indexPath.row - 1) {
      //   return [OMBResidenceBookItCalendarCell heightForCell];
      // }
      // else {
      //   return 0.0f;
      // }
      if (isShowingMoveInCalendar || isShowingMoveOutCalendar){
        if(isLandlordPreferredDate)
          return [OMBResidenceBookItCalendarCell heightForCell];
        else
          return [OMBResidenceBookItCalendarCell heightForCellWithAlert];
      }
    }
    // Lease months
    else if (indexPath.row == 2) {
      return 27.f;
    }
    // View lease details
    else if (indexPath.row == 3) {
      return 27.f;
    }
  }
  //
  else if (indexPath.section ==
    OMBResidenceBookItConfirmDetailsSectionCoapplicants){
      if (indexPath.row == 0)
        return spacing;
      else {
        if (indexPath.row == [[self roommates] count] + 1) {
          return spacing;
        }
        else
          return [OMBRoommateCell heightForCell];
      }
  }
  // Price breakdown
  else if (indexPath.section ==
    OMBResidenceBookItConfirmDetailsSectionPriceBreakdown) {
    // Price Breakdown (No longer Spacing)
    if (indexPath.row == 0) {
      return spacing;
    }
    // Deposit, 1st Month's Rent
    else if (indexPath.row == 1 || indexPath.row == 2 ||
             indexPath.row == 3|| indexPath.row == 4) {
      // if (isShowingPriceBreakdown)
      if (indexPath.row > 2) {
        if ([offer isAboveThreshold]) {
          return spacing;
        }
      }
      else {
        return spacing;
      }
    }
    // Total
    else if (indexPath.row == 5) {
      return padding + 36.0f + padding;
    }
    // Total price notes
    else if (indexPath.row == 6) {
      return padding + totalPriceNotesSize.height + padding;
      // return padding + totalPriceNotesSize.height + padding + padding;
    }
    // Price Breakdown
    else if (indexPath.row == 99) {
      return 0.0f;
      if (!isShowingPriceBreakdown)
        return spacing;
    }
  }
  // Payout methods
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionPayoutMethods) {
    if (indexPath.row < [[OMBUser currentUser].payoutMethods count]) {
      return [OMBPayoutMethodListCell heightForCell];
    }
    // Add a payout method
    else {
      return [OMBPayoutMethodListCell heightForCell];
    }
  }
  // Monthly schedule, View Lease Details
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionMonthlySchedule) {
    return 0.0f;
    // Spacing, View Lease Details
    if (indexPath.row == 0 || indexPath.row == 2)
      return spacing;
  }
  // Buyer
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionRenterProfile) {
    // Buyer
    if (indexPath.row == 0) {
      return [OMBResidenceConfirmDetailsBuyerCell heightForCell];
    }
    // My Renter Profile
    else if (indexPath.row == 1) {
      return spacing;
    }
    // Add note to this offer
    else if (indexPath.row == 2) {
      if (!isAddingAPersonalNote)
        return spacing;
    }
    // Personal note text view
    else if (indexPath.row == 3) {
      if (isAddingAPersonalNote)
        return padding + personalNoteTextView.frame.size.height + padding;
    }
    // if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
    //   return spacing;
    // }
    // else if (indexPath.row == 1) {
    //   return [OMBResidenceConfirmDetailsBuyerCell heightForCell];
    // }
  }
  // Submit offer notes
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionSubmitOfferNotes) {
    return padding + submitOfferNotesSize.height + padding;
  }
  // Spacing
  else if (indexPath.section ==
           OMBResidenceBookItConfirmDetailsSectionSpacing)
    if (isEditing)
      return 216.0f;
  return 0.0f;
}

- (BOOL) tableView: (UITableView *) tableView
shouldHighlightRowAtIndexPath: (NSIndexPath *) indexPath
{
  if (indexPath.section ==
    OMBResidenceBookItConfirmDetailsSectionPayoutMethods) {

    if (indexPath.row < [[self payoutMethods] count]) {
      OMBPayoutMethod *payoutMethod = [[self payoutMethods] objectAtIndex:
        indexPath.row];
      if (payoutMethod.primary) {
        return NO;
      }
    }
  }
  return YES;
}

#pragma mark - Protocol UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
  if (textField == [self yourOfferTextField]) {
    [self scrollToPlaceOffer];
    // [self.navigationItem setRightBarButtonItem: reviewBarButton
    //   animated: YES];
  }
}

#pragma mark - Protocol UITextViewDelegate

- (void) textViewDidBeginEditing: (UITextView *) textView
{
  isEditing = YES;
  [self.table beginUpdates];
  [self.table endUpdates];
  //[self.navigationItem setRightBarButtonItem: doneBarButtonItem animated: YES];

  // If it scrolls to the submit offer notes section,
  // it goes too far
  [self.table scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 1 inSection:
    OMBResidenceBookItConfirmDetailsSectionRenterProfile]
      atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

- (void) textViewDidChange: (UITextView *) textView
{
  if ([[textView.text stripWhiteSpace] length]) {
    personalNoteTextViewPlaceholder.hidden = YES;
  }
  else {
    personalNoteTextViewPlaceholder.hidden = NO;
  }
  personalNote = textView.text;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (OMBResidenceBookItCalendarCell *) calendarCell
{
  return (OMBResidenceBookItCalendarCell *) [self.table cellForRowAtIndexPath:
    [NSIndexPath indexPathForRow:
      OMBResidenceBookItConfirmDetailsSectionDatesRowsCalendar inSection:
        OMBResidenceBookItConfirmDetailsSectionDates]];

}

- (void) closeAlertBlur
{
  [alertBlur close];
}

- (void) createOffer
{
  [[OMBUser currentUser] createOffer: offer completion: ^(NSError *error) {
    if (offer.uid && !error) {
      // save move in & move out preferences
      [self saveDatePreferences];

      NSString *userTypeString = @"landlord";
      if ([residence.propertyType isEqualToString: @"sublet"])
        userTypeString = @"subletter";

      [alertBlur setTitle: @"Offer Placed!"];
      NSString *message;
      if ([offer isAboveThreshold]) {
        message = [NSString stringWithFormat:
          @"If the landlord accepts your offer, we will immediately email you "
          @"the lease, and you (and your roommates if applicable) will have %@ "
          @"to secure the place by electronically signing the lease and paying "
          @"the 1st month's rent and deposit through OnMyBlock. "
          @"Some places may also require a signed co-signer agreement. "
          @"If your offer is retracted, declined, or expires, "
          @"any payment authorization is voided.",
          [offer timelineStringForStudent]];
      }
      else {
        message = [NSString stringWithFormat:
          @"If the landlord accepts your offer, we will immediately email you "
          @"the lease, and you (and your roommates if applicable) will have %@ "
          @"to secure the place by electronically signing the lease through "
          @"OnMyBlock. Some places may also require a signed co-signer "
          @"agreement. If your offer is retracted, declined, or expired, "
          @"any payment authorization is voided.",
          [offer timelineStringForStudent]];
      }
      [alertBlur setMessage: message];
      [alertBlur resetQuestionDetails];
      [alertBlur hideQuestionButton];
      // Buttons
      [alertBlur setConfirmButtonTitle: @"Okay"];
      [alertBlur addTargetForConfirmButton: self
        action: @selector(submitOfferConfirmedOkay)];

      if ([alertBlur isClosed]) {
        [alertBlur showInView: self.view withDetails: NO];
      }

      [alertBlur showOnlyConfirmButton];

      [alertBlur animateChangeOfContent];

      // Send push notification to landlord saying they received an offer
      [offer sendPushNotificationSubmitted];
    }
    else {
      [self showAlertViewWithError: error];
      // Try again
      [self submitOfferFinalAnswer];
    }
    [self containerStopSpinningFullScreen];
  }];
  [self containerStartSpinningFullScreen];
}

- (OMBResidenceConfirmDetailsDatesCell *) datesCell
{
  return (OMBResidenceConfirmDetailsDatesCell *)
    [self.table cellForRowAtIndexPath:
      [NSIndexPath indexPathForRow:
        OMBResidenceBookItConfirmDetailsSectionDatesRowsMoveInMoveOut
          inSection: OMBResidenceBookItConfirmDetailsSectionDates]];
}

- (void) done
{
  [self.view endEditing: YES];
}

- (void) fetchCoapplicants
{
  [[self renterApplication] fetchListForResourceName: [OMBRoommate resourceName]
    userUID: offer.user.uid delegate: self completion: ^(NSError *error) {

  }];
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

- (void) hideCalendar
{
  isShowingMoveInCalendar = isShowingMoveOutCalendar = NO;
  [self showCalendar];
}

- (void) keyboardWillHide: (NSNotification *) notification
{
  isEditing = NO;
  [self.table beginUpdates];
  [self.table endUpdates];
  // [self.navigationItem setRightBarButtonItem: nil animated: YES];
}

- (void) keyboardWillShow: (NSNotification *) notification
{

}

- (NSArray *) payoutMethods
{
  return [[OMBUser currentUser] sortedPayoutMethodsWithKey: @"createdAt"
    ascending: NO];
}

- (OMBRenterApplication *) renterApplication
{
  return offer.user.renterApplication;
}

- (void) review
{
  if ([[[self yourOfferTextField].text stripWhiteSpace] length]) {
    hasOfferValue = YES;
    [self.view endEditing: YES];
    [UIView animateWithDuration: 0.15 animations: ^{
      submitOfferButton.alpha = 1.0f;
    }];
    // [self.navigationItem setRightBarButtonItem: nil animated: YES];
  }
  else {
    hasOfferValue = NO;
    [UIView animateWithDuration: 0.15 animations: ^{
      submitOfferButton.alpha = 0.0f;
    }];
  }
  [self.table beginUpdates];
  [self.table endUpdates];
}

- (NSArray *)roommates
{
  return @[];
}

- (void) saveDatePreferences
{
  [[OMBUser currentUser] addMovedInOutDates:offer];
}

- (void) scrollToPlaceOffer
{
  OMBResidenceConfirmDetailsPlaceOfferCell *cell =
  (OMBResidenceConfirmDetailsPlaceOfferCell *)
  [self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 0
                                                        inSection: 0]];
  [cell.yourOfferTextField becomeFirstResponder];
  CGFloat statusNavigationHeight = 20.0f + 44.0f;
  CGFloat contentOffsetY =
    (self.table.tableHeaderView.frame.size.height +
    [OMBResidenceConfirmDetailsPlaceOfferCell heightForCell]) -
      ((self.table.frame.size.height - statusNavigationHeight) -
        self.table.tableFooterView.frame.size.height);
  contentOffsetY -= statusNavigationHeight;
  [self.table setContentOffset: CGPointMake(0.0f, contentOffsetY)
    animated: YES];
}

- (void) setString: (NSString *) string forTimeUnit: (NSString *) unit
{
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.maximumLineHeight = 32.0f;
  style.minimumLineHeight = 32.0f;
  NSMutableAttributedString *text =
  [[NSMutableAttributedString alloc] initWithString: string attributes: @{
    NSParagraphStyleAttributeName: style
  }];
  if ([unit isEqualToString: @"days"]) {
    daysLabel.attributedText = text;
    daysLabel.textAlignment  = NSTextAlignmentCenter;
  }
  else if ([unit isEqualToString: @"hours"]) {
    hoursLabel.attributedText = text;
    hoursLabel.textAlignment  = NSTextAlignmentCenter;
  }
  else if ([unit isEqualToString: @"minutes"]) {
    minutesLabel.attributedText = text;
    minutesLabel.textAlignment  = NSTextAlignmentCenter;
  }
  else if ([unit isEqualToString: @"seconds"]) {
    secondsLabel.attributedText = text;
    secondsLabel.textAlignment  = NSTextAlignmentCenter;
  }
}

- (void) showAlert
{
  NSDateFormatter *dateFormmater = [NSDateFormatter new];
  dateFormmater.dateFormat = @"M/d/yy";

  alert.alertTitle.text = @"Submit Offer";
  alert.alertMessage.text = [NSString stringWithFormat:
    @"Are you sure you want to submit an offer to rent "
    @"this place from %@ - %@ for %@/mo?",
      [dateFormmater stringFromDate:
        [NSDate dateWithTimeIntervalSince1970: residence.moveInDate]],
          [dateFormmater stringFromDate: [residence moveOutDateDate]],
            [residence rentToCurrencyString]];
  [alert showAlert];
}

- (void) showCalendar
{
  OMBResidenceBookItCalendarCell *calendarCell = [self calendarCell];
  OMBResidenceConfirmDetailsDatesCell *datesCell = [self datesCell];

  if (isShowingMoveInCalendar) {
    [datesCell highlightMoveInDate];

    calendarCell.calendarView.moveInDate =
      [NSDate dateWithTimeIntervalSince1970: offer.moveInDate];

    [calendarCell.calendarView.collectionView reloadData];
  }
  else if (isShowingMoveOutCalendar) {
    [datesCell highlightMoveOutDate];

    calendarCell.calendarView.moveOutDate =
      [NSDate dateWithTimeIntervalSince1970: offer.moveOutDate];

    [calendarCell.calendarView.collectionView reloadData];
  }
  else {
    [datesCell highlightNothing];
  }

  [self.table beginUpdates];
  [self.table endUpdates];
}

- (void) showMoveInCalendar
{
  isShowingMoveInCalendar  = !isShowingMoveInCalendar;
  isShowingMoveOutCalendar = NO;

  [self showCalendar];
}

- (void) showMoveOutCalendar
{
  isShowingMoveInCalendar  = NO;
  isShowingMoveOutCalendar = !isShowingMoveOutCalendar;

  [self showCalendar];
}

- (void) showPayoutMethods
{
  [[self appDelegate].container showPayoutMethods];
}

- (void) showPayPalPayment
{
  NSString *shortDescription = [NSString stringWithFormat:
    @"Down Payment for %@", [residence.address capitalizedString]];
  // Down payment; authorize for future payment
  UINavigationController *nav = (UINavigationController *)
    [self payPalPaymentViewControllerWithAmount: [offer downPaymentAmount]
      intent: PayPalPaymentIntentAuthorize shortDescription: shortDescription
        delegate: self];
  if (nav) {
    [self presentViewController: nav animated: YES completion: nil];
  }
}

- (void) showPlaceOfferHowItWorks
{
  NSString *info2;
  NSString *info3;
  if ([offer isAboveThreshold]) {
    info2 = [NSString stringWithFormat: @"Review your offer and add a payment "
      @"method. You will NOT be charged upfront. A down payment of %@ will be "
      @"charged upon offer acceptance to secure the place. "
      @"If your offer is accepted, you will have %@ to sign the lease and pay "
      @"the remainder of the 1st month’s rent and deposit through OnMyBlock.",
      [NSString numberToCurrencyString: [offer downPaymentAmount]],
      [offer timelineStringForStudent]];
    info3 = [NSString stringWithFormat: @"Once you submit your offer, the "
      @"landlord or subletter will have %@ to review your offer, your renter "
      @"profile, and your roommates' renter profiles if applicable.\n\n"
      @"If your offer is accepted, a down payment of %@ will be charged and "
      @"you will have %@ to sign the lease and pay the remainder of the 1st "
      @"month’s rent and deposit through OnMyBlock. Some places may also "
      @"require a signed co-signer agreement. If your offer is retracted, "
      @"declined, or expired, any payment authorization is voided.",
      [offer timelineStringForLandlord],
      [NSString numberToCurrencyString: [offer downPaymentAmount]],
      [offer timelineStringForStudent]];
  }
  else {
    info2 = [NSString stringWithFormat: @"Review your offer and add a payment "
      @"method. You will NOT be charged upfront. Only if your offer is "
      @"accepted, then you will be charged a total amount of %@ for "
      @"the 1st month's rent and deposit. You will then have  %@ "
      @"to sign the lease.",
      [NSString numberToCurrencyString: [offer downPaymentAmount]],
      [offer timelineStringForStudent]];
    info3 = [NSString stringWithFormat: @"Once you submit your offer, "
      @"the landlord or subletter will have %@ to review your offer, "
      @"your renter profile, and your roommates' renter profiles "
      @"if applicable.\n\nIf your offer is accepted, you will be charged "
      @"a total amount of %@. Then you will have %@ to sign the lease.",
      [offer timelineStringForLandlord],
      [NSString numberToCurrencyString: [offer downPaymentAmount]],
      [offer timelineStringForStudent]];
  }
  NSArray *array = @[
    @{
      @"title": @"Renter Profile",
      @"information": @"The more information you complete, the more likely "
        @"landlords or subletters are to accept your booking request. "
        @"If you have roommates, make sure they complete their profiles too!"
    },
    @{
      @"title": @"Authorize Payment",
      @"information": info2
    },
    @{
      @"title": @"Wait For Response",
      @"information": info3
    }
  ];

  OMBInformationHowItWorksViewController *vc =
    [[OMBInformationHowItWorksViewController alloc] initWithInformationArray:
      array];
  vc.title = @"How Placing an Offer Works";
  [(OMBNavigationController *) self.navigationController pushViewController:
    vc animated: YES completion: ^{
        helpPopUpView.hidden = YES;
      }
    ];
}

- (void) submitOfferButtonSelected
{
  if ([[OMBUser currentUser] primaryPaymentPayoutMethod]) {
    [self submitOfferFinalAnswer];
  }
  else {
    [[self appDelegate].container showPayoutMethods];
  }
}

- (void) submitOfferFinalAnswer
{
  offer.amount = residence.minRent;
  offer.note   = personalNote;
  NSString *moveInDateString = [dateFormatter1 stringFromDate:
    [NSDate dateWithTimeIntervalSince1970: offer.moveInDate]];
  NSString *moveOutDateString = [dateFormatter1 stringFromDate:
    [NSDate dateWithTimeIntervalSince1970: offer.moveOutDate]];

  [alertBlur setTitle: @"Submit Offer"];
  [alertBlur setMessage: [NSString stringWithFormat: @"Are you sure you "
    @"want to submit an offer to rent this place (%@/mo + %@ deposit) "
    @"from %@ - %@?", [NSString numberToCurrencyString: offer.amount],
      [NSString numberToCurrencyString: [residence deposit]],
        moveInDateString, moveOutDateString]];
  [alertBlur resetQuestionDetails];
  [alertBlur hideQuestionButton];

  // Buttons
  [alertBlur setCancelButtonTitle: @"Cancel"];
  [alertBlur setConfirmButtonTitle: @"Submit"];

  [alertBlur addTargetForCancelButton: self
    action: @selector(closeAlertBlur)];
  [alertBlur addTargetForConfirmButton: self
    action: @selector(submitOfferConfirmed)];

  [alertBlur showInView: self.view withDetails: NO];
}

- (void) submitOfferConfirmed
{
  // PayPal
  if ([[OMBUser currentUser].primaryPaymentPayoutMethod isPayPal]) {
    [self closeAlertBlur];
    [self showPayPalPayment];
  }
  // Venmo
  else if ([[OMBUser currentUser].primaryPaymentPayoutMethod isVenmo]) {
    [self createOffer];
  }
}

- (void) submitOfferConfirmedOkay
{
  // Ask to register for push notifications
  if ([[self userDefaults] permissionPushNotifications]) {
    [[self appDelegate].container showHomebaseRenter];
    [self hideAlertBlurAndPopController];
  }
  else {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
      @"Offer Notifications" message: @"Would you like to be notified "
      @"as soon as your offer is accepted?"
        delegate: self cancelButtonTitle: @"Not now"
          otherButtonTitles: @"Yes", nil];
    [alertView show];
  }
}

- (void) submitOffer
{
  [alert hideAlert];
  offer.amount = residence.minRent;
  offer.note   = personalNote;
  [[OMBUser currentUser] createOffer: offer completion: ^(NSError *error) {
    if (offer.uid && !error) {
      NSString *userTypeString = @"landlord";
      if ([residence.propertyType isEqualToString: @"sublet"])
        userTypeString = @"subletter";
      NSString *message = [NSString stringWithFormat:
        @"The %@ has been notified of your offer and "
        @"will be getting back to you shortly.\n\n"
        @"If the %@ accepts your offer, you will have 48 hours to confirm "
        @"and pay the 1st month's rent and deposit through your "
        @"selected payment method. If the %@ for some reason rejects your "
        @"offer, you will be notified immediately. You can improve "
        @"your chances of being accepted by completing your renter profile.",
          userTypeString, userTypeString, userTypeString];
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
        @"Offer Placed!" message: message delegate: nil cancelButtonTitle: @"OK"
          otherButtonTitles: nil];
      [alertView show];
      [self.navigationController popViewControllerAnimated: YES];
    }
    else {
      [self showAlertViewWithError: error];
    }
    [[self appDelegate].container stopSpinning];
  }];
  [[self appDelegate].container startSpinning];
}

- (void) textFieldDidChange: (TextFieldPadding *) textField
{
  offer.amount = [textField.text floatValue];
  OMBResidenceConfirmDetailsPlaceOfferCell *cell =
  (OMBResidenceConfirmDetailsPlaceOfferCell *)
  [self.table cellForRowAtIndexPath:
   [NSIndexPath indexPathForRow: 0 inSection: 0]];
  if (offer.amount > 0) {
    [cell enableNextStepButton];
  }
  else {
    [cell disableNextStepButton];
  }
}

- (void) trackBookItSubmitted
{
  OMBMixpanelTrackerTrackSubmission(@"Book It Submitted",
    residence, [OMBUser currentUser]);
}

- (TextFieldPadding *) yourOfferTextField
{
  OMBResidenceConfirmDetailsPlaceOfferCell *cell =
  (OMBResidenceConfirmDetailsPlaceOfferCell *)
  [self.table cellForRowAtIndexPath:
   [NSIndexPath indexPathForRow: 0 inSection: 0]];
  return cell.yourOfferTextField;
}

- (void) userAddedFirstPayoutMethod
{
  UINavigationController *vc = (UINavigationController *)
    [self appDelegate].container.payoutMethodsNavigationController;
  if (vc.presentingViewController)
    [vc dismissViewControllerAnimated: YES completion: nil];
}

- (void) verifyLandlordPreference
{
  // (move-out date = move-in date + lease months)
  isLandlordPreferredDate = YES;

  if([[NSDate dateWithTimeIntervalSince1970: offer.moveInDate]
      compare:[NSDate dateWithTimeIntervalSince1970: residence.moveInDate]] == NSOrderedAscending)
    isLandlordPreferredDate = NO;

  NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
  [dateComponents setMonth:residence.leaseMonths];
  NSDate *preferredMoveOut = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate dateWithTimeIntervalSince1970: residence.moveInDate ] options:0];

  if([[NSDate dateWithTimeIntervalSince1970: offer.moveOutDate]
      compare:preferredMoveOut] == NSOrderedDescending)
    isLandlordPreferredDate = NO;

  [self.table beginUpdates];
  [self.table endUpdates];
}
@end
