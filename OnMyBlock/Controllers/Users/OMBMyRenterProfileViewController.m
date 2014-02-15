//
//  OMBMyRenterProfileViewController.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 2/14/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBMyRenterProfileViewController.h"

#import "CustomLoading.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"
#import "OMBCenteredImageView.h"
#import "OMBEmploymentCell.h"
#import "OMBLabelTextFieldCell.h"
#import "OMBOtherUserProfileViewController.h"
#import "OMBPickerViewCell.h"
#import "OMBRenterApplication.h"
#import "OMBRenterProfileUserInfoCell.h"
#import "OMBViewControllerContainer.h"
#import "UIColor+Extensions.h"
#import "UIFont+OnMyBlock.h"
#import "UIImage+Resize.h"

@implementation OMBMyRenterProfileViewController

#pragma mark - Initializer

- (id) init
{
  if (!(self = [super init])) return nil;

  self.title = @"My Renter Profile";

  CGRect rect = [@"First name" boundingRectWithSize:
    CGSizeMake(9999, OMBStandardHeight) font: [UIFont normalTextFontBold]];
  sizeForLabelTextFieldCell = rect.size;

  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(keyboardWillShow:)
      name: UIKeyboardWillShowNotification object: nil];
  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(keyboardWillHide:)
      name: UIKeyboardWillHideNotification object: nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector: @selector(progressConnection:)
      name: @"progressConnection" object:nil];

  // After coming back from Facebook upon verifying
  [[NSNotificationCenter defaultCenter] addObserver: self
    selector: @selector(facebookAuthenticationFinished:)
      name: OMBUserCreateAuthenticationForFacebookNotification object: nil];

  return self;
}

#pragma mark - Override

#pragma mark - Override UIViewController

- (void) loadView
{
  [super loadView];
  [super setupForTable];

  [[CustomLoading getInstance] clearInstance];

  previewBarButtonItem = 
    [[UIBarButtonItem alloc] initWithTitle: @"Preview"
      style: UIBarButtonItemStylePlain target: self action: @selector(preview)];
  self.navigationItem.rightBarButtonItem = previewBarButtonItem;

  CGRect screen       = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screen.size.width;
  CGFloat padding     = OMBPadding;

  // About text view
  aboutTextView = [UITextView new];
  aboutTextView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
  aboutTextView.delegate = self;
  aboutTextView.font = [UIFont normalTextFont];
  aboutTextView.frame = CGRectMake(padding, padding, 
    screenWidth - (padding * 2), padding * 5); // 5 times the line height
  aboutTextView.textColor = [UIColor blueDark];

  // About text view placeholder
  aboutTextViewPlaceholder = [UILabel new];
  aboutTextViewPlaceholder.font = aboutTextView.font;
  aboutTextViewPlaceholder.frame = CGRectMake(5.0f, 8.0f, 
    aboutTextView.frame.size.width, 20.0f);
  aboutTextViewPlaceholder.text = @"Talk about how cool you are...";
  aboutTextViewPlaceholder.textColor = [UIColor grayMedium];
  [aboutTextView addSubview: aboutTextViewPlaceholder];

  // Action sheet
  uploadActionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self 
    cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil 
      otherButtonTitles: @"Take Photo", @"Choose Existing", nil];
  [self.view addSubview: uploadActionSheet];

  // Spacing
  UIBarButtonItem *flexibleSpace = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem: 
      UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
  // Save
  UIBarButtonItem *saveBarButtonItemForTextFieldToolbar =
    [[UIBarButtonItem alloc] initWithTitle: @"Save" 
      style: UIBarButtonItemStylePlain target: self 
        action: @selector(saveFromInputAccessoryView)];
  // Right padding
  UIBarButtonItem *rightPadding = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
      UIBarButtonSystemItemFixedSpace target: nil action: nil];
  // iOS 7 toolbar spacing is 16px; 20px on iPad
  rightPadding.width = 4.0f;

  textFieldToolbar = [UIToolbar new];
  textFieldToolbar.clipsToBounds = YES;
  textFieldToolbar.frame = CGRectMake(0.0f, 0.0f, 
    screenWidth, OMBStandardHeight);
  textFieldToolbar.items = @[flexibleSpace, 
    saveBarButtonItemForTextFieldToolbar, rightPadding];
  textFieldToolbar.tintColor = [UIColor blue];
  aboutTextView.inputAccessoryView = textFieldToolbar;
}

- (void) viewDidDisappear: (BOOL) animated
{
  [super viewDidDisappear: animated];

  [self done];
}

- (void) viewWillAppear: (BOOL) animated
{
  [super viewWillAppear: animated];

  if (!user)
    user = [OMBUser currentUser];

  valueDictionary = [NSMutableDictionary dictionaryWithDictionary: @{
    @"about":     user.about ? user.about : @"",
    @"email":     user.email ? user.email : @"",
    @"firstName": user.firstName ? user.firstName: @"",
    @"lastName":  user.lastName ? user.lastName : @"",
    @"phone":     user.phone ? user.phone : @"",
    @"school":    user.school ? user.school : @"",

    @"coapplicantCount": [NSNumber numberWithInt: 
      user.renterApplication.coapplicantCount],
    @"hasCosigner": [NSNumber numberWithBool: 
      user.renterApplication.hasCosigner]
  }];

  [self.table reloadData];

  // If user is the landlord
  if ([user isLandlord]) {
    // Fetch listings
    [user fetchListingsWithCompletion: ^(NSError *error) {
      [self.table reloadData];
    }];
  }
  else {
    // Fetch the information about the user, specifically the renter application
    [user fetchUserProfileWithCompletion: ^(NSError *error) {
      [valueDictionary setObject: [NSNumber numberWithInt: 
        user.renterApplication.coapplicantCount] forKey: @"coapplicantCount"];
      [valueDictionary setObject: [NSNumber numberWithBool: 
        user.renterApplication.hasCosigner] forKey: @"hasCosigner"];
      [self.table reloadData];
    }];
    // Fetch the employments
    [user fetchEmploymentsWithCompletion: ^(NSError *error) {
      [self.table reloadData];
    }];
  }
}

- (void) viewWillDisappear: (BOOL) animated
{
  [super viewWillDisappear: animated];

  [self save];
}

#pragma mark - Protocol

#pragma mark - Protocol UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet 
clickedButtonAtIndex: (NSInteger) buttonIndex
{
  // Image picker controller
  UIImagePickerController *imagePickerController = 
    [[UIImagePickerController alloc] init];
  imagePickerController.allowsEditing = YES;
  imagePickerController.delegate = self;
  if (buttonIndex == 0) {
    if ([UIImagePickerController isSourceTypeAvailable: 
      UIImagePickerControllerSourceTypeCamera]) {

      imagePickerController.sourceType = 
        UIImagePickerControllerSourceTypeCamera;
      imagePickerController.cameraDevice = 
        UIImagePickerControllerCameraDeviceFront;
    }
    else {
      imagePickerController.sourceType = 
        UIImagePickerControllerSourceTypePhotoLibrary;
    }
  }
  else if (buttonIndex == 1) {
    imagePickerController.sourceType = 
      UIImagePickerControllerSourceTypePhotoLibrary;
  }
  if (buttonIndex == 0 || buttonIndex == 1) {
    [self presentViewController: imagePickerController animated: YES
      completion: nil];
  }
}

#pragma mark - Protocol UIImagePickerControllerDelegate

- (void) imagePickerController: (UIImagePickerController *) picker 
didFinishPickingMediaWithInfo: (NSDictionary *) info
{
  UIImage *image = [info objectForKey: UIImagePickerControllerEditedImage];
  if (!image)
    image = [info objectForKey: UIImagePickerControllerOriginalImage];
  [[CustomLoading getInstance] setNumImages: 1];
  [[OMBUser currentUser] uploadImage: image withCompletion: ^(NSError *error) {
    if ([OMBUser currentUser].image && !error) {
      // [backgroundBlurView refreshWithImage: [OMBUser currentUser].image];
      // [userImageView setImage: [OMBUser currentUser].image];
    }
    else {
      [self showAlertViewWithError: error];
    }
    //[[self appDelegate].container stopSpinning];
  }];
  //[[self appDelegate].container startSpinning];
  [picker dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Protocol UIPickerViewDataSource

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView
{
  return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView
 numberOfRowsInComponent: (NSInteger) component
{
  return 10;
}

#pragma mark - Protocol UIPickerViewDelegate

- (void) pickerView: (UIPickerView *) pickerView 
didSelectRow: (NSInteger) row inComponent: (NSInteger) component
{
  [valueDictionary setObject: [NSNumber numberWithInt: row + 1]
    forKey: @"coapplicantCount"];
  [self.table reloadData];
  [self updateRenterApplication];
}

- (CGFloat) pickerView: (UIPickerView *) pickerView
rowHeightForComponent: (NSInteger) component
{
  return OMBStandardHeight;
}

- (NSString *) pickerView: (UIPickerView *) pickerView 
titleForRow: (NSInteger) row forComponent: (NSInteger) component
{
  return [NSString stringWithFormat: @"%i", row + 1];
}

#pragma mark - Protocol UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  // User info
  // Rental info
  // Employments
  // Spacing
  return 4;
}

- (UITableViewCell *) tableView: (UITableView *) tableView
cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSInteger row     = indexPath.row;
  NSInteger section = indexPath.section;

  CGFloat padding = OMBPadding;
  CGRect tableRect = tableView.frame;

  // Subclasses implement this
  static NSString *EmptyCellID = @"EmptyCellID";
  UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:
    EmptyCellID];
  if (!emptyCell)
    emptyCell = [[UITableViewCell alloc] initWithStyle: 
      UITableViewCellStyleDefault reuseIdentifier: EmptyCellID];

  if (section == OMBMyRenterProfileSectionUserInfo) {
    // Image
    if (row == OMBMyRenterProfileSectionUserInfoRowImage) {
      static NSString *ImageID = @"ImageID";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
        ImageID];
      NSInteger imageViewTag = 9999;
      NSInteger labelTag     = 9998;
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: 
          UITableViewCellStyleDefault reuseIdentifier: ImageID];
        // Image
        OMBCenteredImageView *imageView = [[OMBCenteredImageView alloc] init];
        imageView.frame = CGRectMake(padding, padding, OMBStandardButtonHeight,
          OMBStandardButtonHeight);
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5f;
        imageView.tag = imageViewTag;
        [cell.contentView addSubview: imageView];
        // Name
        CGFloat originX = 
          imageView.frame.origin.x + imageView.frame.size.width + padding;
        UILabel *label = [UILabel new];
        label.font = [UIFont mediumLargeTextFontBold];
        label.frame = CGRectMake(originX, imageView.frame.origin.y,
          tableRect.size.width - (originX + padding), 
            imageView.frame.size.height);
        label.tag = labelTag;
        label.textColor = [UIColor textColor];
        [cell.contentView addSubview: label];
      }
      // Image view
      if ([cell viewWithTag: imageViewTag]) {
        OMBCenteredImageView *imageView = 
          (OMBCenteredImageView *) [cell viewWithTag: imageViewTag];
        imageView.image = user.image;
      }
      // Name label
      if ([cell viewWithTag: labelTag]) {
        UILabel *label = (UILabel *) [cell viewWithTag: labelTag];
        label.text = [user shortName];
      }
      return cell;
    }
    // About
    else if (row == OMBMyRenterProfileSectionUserInfoRowAbout) {
      static NSString *AboutCellID = @"AboutCellID";
      UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier: AboutCellID];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:
          UITableViewCellStyleDefault reuseIdentifier: AboutCellID];
        [aboutTextView removeFromSuperview];
        [cell.contentView addSubview: aboutTextView];
      }
      aboutTextView.text = [valueDictionary objectForKey: @"about"];
      if ([[aboutTextView.text stripWhiteSpace] length]) {
        aboutTextViewPlaceholder.hidden = YES;
      }
      else {
        aboutTextViewPlaceholder.hidden = NO;
      }
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      // cell.separatorInset = UIEdgeInsetsMake(0.0f,
      //   tableView.frame.size.width, 0.0f, 0.0f);
      return cell;
    }
    // Everything else
    else {
      static NSString *LabelTextCellID = @"LabelTextCellID";
      OMBLabelTextFieldCell *cell = 
        [tableView dequeueReusableCellWithIdentifier: LabelTextCellID];
      if (!cell) {
        cell = [[OMBLabelTextFieldCell alloc] initWithStyle:
          UITableViewCellStyleDefault reuseIdentifier: LabelTextCellID];
        [cell setFrameUsingSize: sizeForLabelTextFieldCell];
      }
      // cell.backgroundColor = transparentWhite;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textField.font = [UIFont normalTextFontBold];
      cell.textField.textColor = [UIColor blueDark];
      cell.textFieldLabel.font = [UIFont normalTextFont];
      NSString *key;
      NSString *labelString;
      // First name
      if (row == OMBMyRenterProfileSectionUserInfoRowFirstName) {
        key         = @"firstName";
        labelString = @"First name";
      }
      // Last name
      else if (row == OMBMyRenterProfileSectionUserInfoRowLastName) {
        key         = @"lastName";
        labelString = @"Last name";
      }
      // School
      else if (row == OMBMyRenterProfileSectionUserInfoRowSchool) {
        key         = @"school";
        labelString = @"School";
      }
      // Email
      else if (row == OMBMyRenterProfileSectionUserInfoRowEmail) {
        key         = @"email";
        labelString = @"Email";
      }
      // Phone
      else if (row == OMBMyRenterProfileSectionUserInfoRowPhone) {
        key         = @"phone";
        labelString = @"Phone";
      }
      cell.textField.delegate  = self;
      cell.textField.indexPath = indexPath;
      cell.textField.placeholder = [labelString lowercaseString];
      cell.textField.text = [valueDictionary objectForKey: key];
      cell.textFieldLabel.text = labelString;
      [cell.textField addTarget: self action: @selector(textFieldDidChange:)
        forControlEvents: UIControlEventEditingChanged];
      return cell;
    }
  }
  else if (section == OMBMyRenterProfileSectionRentalInfo) {
    // Co-applicants picker view
    if (row == OMBMyRenterProfileSectionRentalInfoRowCoapplicantsPickerView) {
      static NSString *PickerID = @"PickerID";
      OMBPickerViewCell *pickerCell =
      [tableView dequeueReusableCellWithIdentifier: PickerID];
      if (!pickerCell)
        pickerCell = [[OMBPickerViewCell alloc] initWithStyle:
          UITableViewCellStyleDefault reuseIdentifier: PickerID];
      pickerCell.pickerView.dataSource = self;
      pickerCell.pickerView.delegate   = self;
      return pickerCell;
    }

    static NSString *RentalInfoID = @"RentalInfoID";
    OMBRenterProfileUserInfoCell *cell = 
      [tableView dequeueReusableCellWithIdentifier: RentalInfoID];
    if (!cell)
      cell = [[OMBRenterProfileUserInfoCell alloc] initWithStyle: 
        UITableViewCellStyleDefault reuseIdentifier: RentalInfoID];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [cell reset];
    CGSize imageSize = cell.iconImageView.bounds.size;
    UIImage *image;
    NSString *string;
    NSString *valueString;
    // Co-applicants
    if (row == OMBMyRenterProfileSectionRentalInfoRowCoapplicants) {
      image = [UIImage imageNamed: @"group_icon.png"];
      string = @"Co-applicants";
      valueString = [NSString stringWithFormat: @"%i",
        [[valueDictionary objectForKey: @"coapplicantCount"] intValue]];
    }
    // Co-signer
    else if (row == OMBMyRenterProfileSectionRentalInfoRowCosigners) {
      image = [UIImage imageNamed: @"landlord_icon.png"];
      string = @"Co-signer";
      if ([[valueDictionary objectForKey: @"hasCosigner"] intValue])
        valueString = @"Yes";
      else
        valueString = @"No";
    }
    // Facebook
    else if (row == OMBMyRenterProfileSectionRentalInfoRowFacebook) {
      [cell resetWithCheckmark];
      image  = [UIImage imageNamed: @"facebook_icon_blue.png"];
      string = @"Facebook";
      if (user.renterApplication.facebookAuthenticated) {
        cell.iconImageView.alpha = 1.0f;
        valueString = @"Verified";
        [cell fillCheckmark];
      }
      else
        valueString = @"Unverified";
    }
    // LinkedIn
    else if (row == OMBMyRenterProfileSectionRentalInfoRowLinkedIn) {
      [cell resetWithCheckmark];
      image  = [UIImage imageNamed: @"linkedin_icon.png"];
      string = @"LinkedIn";
      if (user.renterApplication.linkedinAuthenticated) {
        cell.iconImageView.alpha = 1.0f;
        valueString = @"Verified";
        [cell fillCheckmark];
      }
      else
        valueString = @"Unverified";
      // cell.separatorInset = UIEdgeInsetsMake(0.0f, 
      //   tableView.frame.size.width, 0.0f, 0.0f);
    }
    cell.iconImageView.image = [UIImage image: image size: imageSize];
    cell.label.text = string;
    cell.valueLabel.text = valueString;
    return cell;
  }
  else if (section == OMBMyRenterProfileSectionEmployments) {
    static NSString *EmploymentCellID = @"EmploymentCellID";
    OMBEmploymentCell *cell = [tableView dequeueReusableCellWithIdentifier:
      EmploymentCellID];
    if (!cell)
      cell = [[OMBEmploymentCell alloc] initWithStyle: 
        UITableViewCellStyleDefault reuseIdentifier: EmploymentCellID];
    [cell loadData: 
      [[user.renterApplication employmentsSortedByStartDate] 
        objectAtIndex: indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  }

  return emptyCell;
}

- (NSInteger) tableView: (UITableView *) tableView
numberOfRowsInSection: (NSInteger) section
{
  if (section == OMBMyRenterProfileSectionUserInfo) {
    return 7;
  }
  else if (section == OMBMyRenterProfileSectionRentalInfo) {
    return 5;
  }
  // Employments
  else if (section == OMBMyRenterProfileSectionEmployments) {
    return [[user.renterApplication employmentsSortedByStartDate] count];
  }
  else if (section == OMBMyRenterProfileSectionSpacing) {
    return 1;
  }
  return 0;
}

#pragma mark - Protocol UITableViewDelegate

- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSInteger row     = indexPath.row;
  NSInteger section = indexPath.section;

  // User info
  if (section == OMBMyRenterProfileSectionUserInfo) {
    // Image
    if (row == OMBMyRenterProfileSectionUserInfoRowImage) {
      [uploadActionSheet showInView: self.view];
    }
  }
  // Rental info
  else if (section == OMBMyRenterProfileSectionRentalInfo) {
    // Co-applicants
    if (row == OMBMyRenterProfileSectionRentalInfoRowCoapplicants) {
      [self reloadPickerViewRowAtIndexPath: indexPath];
    }
    // Co-signer
    else if (row == OMBMyRenterProfileSectionRentalInfoRowCosigners) {
      BOOL coSigners = [[valueDictionary objectForKey: 
        @"hasCosigner"] boolValue];
      [valueDictionary setObject: [NSNumber numberWithBool: !coSigners]
        forKey: @"hasCosigner"];
      [self.table reloadData];
      [self updateRenterApplication];
    }
    // Facebook
    else if (row == OMBMyRenterProfileSectionRentalInfoRowFacebook) {
      [self facebookButtonSelected];
    }
    // LinkedIn
    else if (row == OMBMyRenterProfileSectionRentalInfoRowLinkedIn) {
      [self linkedInButtonSelected];
    }
  }

  [self.table deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat) tableView: (UITableView *) tableView 
heightForHeaderInSection: (NSInteger) section
{
  if (section == OMBMyRenterProfileSectionEmployments) {
    if (![user isLandlord]) {
      if ([[user.renterApplication employmentsSortedByStartDate] count])
        return OMBStandardHeight;
    }
  }
  return 0.0f;
}

- (CGFloat) tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSInteger row     = indexPath.row;
  NSInteger section = indexPath.section;

  // User info
  if (section == OMBMyRenterProfileSectionUserInfo) {
    // Image
    if (row == OMBMyRenterProfileSectionUserInfoRowImage) {
      return OMBPadding + OMBStandardButtonHeight + OMBPadding;
    }
    // School
    else if (row == OMBMyRenterProfileSectionUserInfoRowSchool) {
      if ([user isLandlord]) {
        return 0.0f;
      }
    }
    // About
    else if (row == OMBMyRenterProfileSectionUserInfoRowAbout) {
      return OMBPadding + (22.0f * 5) + OMBPadding;
    }
    return [OMBLabelTextFieldCell heightForCell];
  }
  // Rental info
  else if (section == OMBMyRenterProfileSectionRentalInfo) {
    // Co-applicants
    if (row == OMBMyRenterProfileSectionRentalInfoRowCoapplicants) {
      if ([user isLandlord]) {
        return 0.0f;
      }
    }
    // Co-applicants picker view
    else if (row == 
      OMBMyRenterProfileSectionRentalInfoRowCoapplicantsPickerView) {
      if (section == selectedIndexPath.section && 
        row == selectedIndexPath.row + 1) {

        return OMBKeyboardHeight;
      }
      else {
        return 0.0f;
      }
    }
    // Co-signers
    else if (row == OMBMyRenterProfileSectionRentalInfoRowCosigners) {
      if ([user isLandlord]) {
        return 0.0f;
      }
    }
    return [OMBRenterProfileUserInfoCell heightForCell];
  }
  // Employments
  else if (section == OMBMyRenterProfileSectionEmployments) {
    if (![user isLandlord]) {
      return [OMBEmploymentCell heightForCell];
    }
  }
  // Spacing
  else if (section == OMBMyRenterProfileSectionSpacing) {
    if (isEditing) {
      return 216.0f;
    }
  }
  return 0.0f;
}

- (UIView *) tableView: (UITableView *) tableView 
viewForHeaderInSection: (NSInteger) section
{
  NSString *string;
  if (section == OMBMyRenterProfileSectionEmployments)
    string = @"Work History";
  UIView *v = [UIView new];
  v.backgroundColor = [UIColor grayUltraLightAlpha: 0.95f];
  v.frame = CGRectMake(0.0f, 0.0f, 
    tableView.frame.size.width, OMBStandardHeight);
  UILabel *label = [UILabel new];
  label.font = [UIFont normalTextFont];
  label.frame = CGRectMake(OMBPadding, 0.0f, 
    v.frame.size.width - (OMBPadding * 2), v.frame.size.height);
  label.text = string;
  label.textColor = [UIColor grayMedium];
  label.textAlignment = NSTextAlignmentCenter;
  [v addSubview: label];
  return v;
}

#pragma mark - Protocol UITextFieldDelegate

- (void) textFieldDidBeginEditing: (TextFieldPadding *) textField
{
  textField.inputAccessoryView = textFieldToolbar;

  isEditing = YES;
  [self.table beginUpdates];
  [self.table endUpdates];
  [self.table scrollToRowAtIndexPath: textField.indexPath
    atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
  [self done];
  return YES;
}

#pragma mark - Protocol UITextViewDelegate

- (void) textViewDidBeginEditing: (UITextView *) textView
{
  textView.inputAccessoryView = textFieldToolbar;

  isEditing = YES;
  [self.table beginUpdates];
  [self.table endUpdates];
  [self.table scrollToRowAtIndexPath: 
    [NSIndexPath indexPathForRow: OMBMyRenterProfileSectionUserInfoRowAbout
      inSection: OMBMyRenterProfileSectionUserInfo]
        atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

- (void) textViewDidChange: (UITextView *) textView
{
  if ([[textView.text stripWhiteSpace] length]) {
    aboutTextViewPlaceholder.hidden = YES;
  }
  else {
    aboutTextViewPlaceholder.hidden = NO;
  }
  [valueDictionary setObject: textView.text forKey: @"about"];
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) done
{
  [self.view endEditing: YES];
  isEditing = NO;
  [self.table beginUpdates];
  [self.table endUpdates];
}

- (void) facebookAuthenticationFinished: (NSNotification *) notification
{
  NSError *error = [notification.userInfo objectForKey: @"error"];
  if (!error) {
    user.renterApplication.facebookAuthenticated = YES;
    [user downloadImageFromImageURLWithCompletion: nil];
    [self.table reloadData];
  }
  else {
    [self showAlertViewWithError: error];
  }
  [[self appDelegate].container stopSpinning];
}

- (void) facebookButtonSelected
{
  [[self appDelegate].container startSpinning];
  [[self appDelegate] openSession];
}

- (void) keyboardWillHide: (NSNotification *) notification
{
  // [self.navigationItem setRightBarButtonItem: saveBarButtonItem 
  //   animated: YES];
}

- (void) keyboardWillShow: (NSNotification *) notification
{
  // [self.navigationItem setRightBarButtonItem: doneBarButtonItem 
  //   animated: YES];
}

- (void) linkedInButtonSelected
{
  LIALinkedInApplication *app = 
    [LIALinkedInApplication applicationWithRedirectURL: @"https://onmyblock.com"
      clientId: @"75zr1yumwx0wld" clientSecret: @"XNY3VsMzvdhyR1ej"
        state: @"DCEEFWF45453sdffef424" grantedAccess: @[@"r_fullprofile"]];
  linkedInClient = [LIALinkedInHttpClient clientForApplication: app 
    presentingViewController: self];
  [linkedInClient getAuthorizationCode: ^(NSString *code) {
    [linkedInClient getAccessToken: code success: 
      ^(NSDictionary *accessTokenData) {
        NSString *accessToken = [accessTokenData objectForKey: @"access_token"];
        [user createAuthenticationForLinkedInWithAccessToken:
          accessToken completion: ^(NSError *error) {
            if (!error) {
              user.renterApplication.linkedinAuthenticated = YES;
              [self.table reloadData];
            }
            else {
              [self showAlertViewWithError: error];
            }
            [[self appDelegate].container stopSpinning];
          }
        ];
        [[self appDelegate].container startSpinning];
      }
    failure: ^(NSError *error) {
      [self showAlertViewWithError: error];
    }];
  } cancel: ^{
    NSLog(@"LINKEDIN CANCELED");
  } failure: ^(NSError *error) {
    [self showAlertViewWithError: error];
  }];
}

- (void) loadUser: (OMBUser *) object
{
  user = object;

  if ([user isLandlord])
    self.title = @"My Landlord Profile";
  else
    self.title = @"My Renter Profile";
}

- (void) preview
{
  [self.navigationController pushViewController:
    [[OMBOtherUserProfileViewController alloc] initWithUser: user]
      animated: YES];
}

- (void) progressConnection: (NSNotification *) notification
{
  float value = ([[notification object] floatValue]);
  
  CustomLoading *custom = [CustomLoading getInstance];
  //editBarButtonItem.enabled = NO;

  if (value == 1.0) {
    custom.numImages--;
    [custom stopAnimatingWithView: self.view];
      //editBarButtonItem.enabled = YES;
  }
  else {
    [custom startAnimatingWithProgress: (int)(value * 25) withView: self.view];
  }
}

- (void) reloadPickerViewRowAtIndexPath: (NSIndexPath *) indexPath
{
  isEditing = NO;
  [self.view endEditing: YES];

  if (selectedIndexPath) {
    if (selectedIndexPath.section == indexPath.section &&
      selectedIndexPath.row == indexPath.row) {

      selectedIndexPath = nil;
    }
    else {
      selectedIndexPath = indexPath;
    }
  }
  else {
    selectedIndexPath = indexPath;
  }
  [self.table reloadRowsAtIndexPaths: @[
    [NSIndexPath indexPathForRow: indexPath.row + 1 
      inSection: indexPath.section]
  ] withRowAnimation: UITableViewRowAnimationFade];

  if (selectedIndexPath)
    [self scrollToRowAtIndexPath: selectedIndexPath];
}

- (void) save
{
  [[OMBUser currentUser] updateWithDictionary: valueDictionary
    completion: ^(NSError *error) {
      if (!error) {
        // Clear this because they updated their about
        // so the sizes need to change
        [[OMBUser currentUser].heightForAboutTextDictionary removeAllObjects];
        [self.table reloadData];
        // [self.navigationController popViewControllerAnimated: YES];
      }
      else {
        [self showAlertViewWithError: error];
      }
      // [[self appDelegate].container stopSpinning];
    }
  ];
  // [[self appDelegate].container startSpinning];
}

- (void) saveFromInputAccessoryView
{
  [self save];
  [self done];
}

- (void) scrollToRowAtIndexPath: (NSIndexPath *) indexPath
{
  [self.table scrollToRowAtIndexPath: indexPath
    atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

- (void) textFieldDidChange: (TextFieldPadding *) textField
{
  NSInteger row = textField.indexPath.row;
  if (row == OMBMyRenterProfileSectionUserInfoRowFirstName) {
    if ([textField.text length])
      [valueDictionary setObject: textField.text forKey: @"firstName"];
  }
  else if (row == OMBMyRenterProfileSectionUserInfoRowLastName) {
    if ([textField.text length])
      [valueDictionary setObject: textField.text forKey: @"lastName"]; 
  }
  else if (row == OMBMyRenterProfileSectionUserInfoRowSchool) {
    [valueDictionary setObject: textField.text forKey: @"school"]; 
  }
  else if (row == OMBMyRenterProfileSectionUserInfoRowEmail) {
    [valueDictionary setObject: textField.text forKey: @"email"]; 
  }
  else if (row == OMBMyRenterProfileSectionUserInfoRowPhone) {
    [valueDictionary setObject: textField.text forKey: @"phone"];
  }
}

- (void) updateRenterApplication
{
  [user.renterApplication updateWithDictionary: valueDictionary
    completion: ^(NSError *error) {
      if (error)
        [self showAlertViewWithError: error];
      // [[self appDelegate].container stopSpinning];
    }
  ];
  // [[self appDelegate].container startSpinning];
}

@end
