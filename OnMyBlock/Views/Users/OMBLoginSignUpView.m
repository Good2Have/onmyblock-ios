//
//  OMBLoginSignUpView.m
//  OnMyBlock
//
//  Created by Tommy DANGerous on 1/30/14.
//  Copyright (c) 2014 OnMyBlock. All rights reserved.
//

#import "OMBLoginSignUpView.h"

#import "AMBlurView.h"
#import "OMBBlurView.h"
#import "OMBCloseButtonView.h"
#import "OMBFullListView.h"
#import "OMBFacebookButton.h"
#import "OMBFullListCell.h"
#import "OMBOrView.h"
#import "OMBSchool.h"
#import "OMBViewController.h"
#import "TextFieldPadding.h"
#import "UIColor+Extensions.h"
#import "UIImage+Color.h"

// Swift
#import "OnMyBlock-Swift.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface OMBLoginSignUpView ()
<
 SearchManagerDelegate
>
{
 OMBSchool *otherSchool;
}
@end

@implementation OMBLoginSignUpView

#pragma mark - Initializer

- (id) init
{
 if (!(self = [super init])) return nil;

 CGRect screen = [[UIScreen mainScreen] bounds];
 CGFloat screenHeight = screen.size.height;
 CGFloat screenWidth  = screen.size.width;
 CGFloat padding      = OMBPadding;
 CGFloat buttonHeight = OMBStandardButtonHeight;
 CGFloat standardHeight = OMBStandardHeight;
 CGFloat width = screenWidth - (padding * 2);

 self.frame = screen;
 // Blur view
 _blurView = [[OMBBlurView alloc] initWithFrame: screen];
 _blurView.blurRadius = 20.0f;
 _blurView.tintColor  = [UIColor colorWithWhite: 0.0f alpha: 0.3f];
 // [_blurView refreshWithImage: [UIImage imageNamed:
 //   @"intro_still_image_slide_5_background.jpg"]];
 [self addSubview: _blurView];

 // Scroll
 scroll = [[UIScrollView alloc] init];
 scroll.alwaysBounceVertical = YES;
 scroll.backgroundColor = [UIColor clearColor];
 scroll.frame = CGRectMake(0.0f, padding, screenWidth, screenHeight - padding);
 scroll.showsVerticalScrollIndicator = NO;
 [self addSubview: scroll];

 // Close button view
 CGFloat closeButtonSize = 30.0f;
 CGRect closeButtonRect = CGRectMake(screenWidth - (closeButtonSize + padding),
   padding * 1.5f, closeButtonSize, closeButtonSize);
 _closeButtonView = [[OMBCloseButtonView alloc] initWithFrame: closeButtonRect
   color: [UIColor colorWithWhite: 1.0f alpha: 0.8f]];
 [self addSubview: _closeButtonView];

 // Header label
 headerLabel = [UILabel new];
 headerLabel.font = [UIFont mediumTextFontBold];
 headerLabel.frame = CGRectMake(0.0f, padding, screenWidth, padding);
 headerLabel.text = @"Students";
 headerLabel.textColor = [UIColor whiteColor];
 headerLabel.textAlignment = NSTextAlignmentCenter;
 [scroll addSubview: headerLabel];

 // Facebook button
 _facebookButton = [[OMBFacebookButton alloc] initWithFrame: CGRectMake(
   padding, padding + padding + padding, width, buttonHeight)];
 _facebookButton.backgroundColor = [UIColor facebookBlueAlpha: 0.8f];
 _facebookButton.layer.cornerRadius = OMBCornerRadius;
 _facebookButton.titleLabel.font = [UIFont mediumTextFont];
 [_facebookButton setTitle: @"Sign up using Facebook"
   forState: UIControlStateNormal];
 [scroll addSubview: _facebookButton];

 // Or view
 orView = [[OMBOrView alloc] initWithFrame: CGRectMake(0.0f,
   _facebookButton.frame.origin.y + _facebookButton.frame.size.height +
     padding, screenWidth, padding) color: [UIColor whiteColor]];
 [orView setCapitalizedLabel: NO];
 [orView setLabelBold: NO];
 [scroll addSubview: orView];

 // Hold all the text fields
 textFieldView = [[UIView alloc] init];
 textFieldView.backgroundColor = [UIColor colorWithWhite: 1.0f alpha: 0.8f];
 textFieldView.frame = CGRectMake(padding,
   orView.frame.origin.y + orView.frame.size.height + padding,
     width, buttonHeight * 4);
 textFieldView.layer.cornerRadius = OMBCornerRadius;
 [scroll addSubview: textFieldView];
 // First name
 _firstNameTextField = [[TextFieldPadding alloc] init];
 _firstNameTextField.autocapitalizationType =
   UITextAutocapitalizationTypeWords;
 _firstNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
 _firstNameTextField.placeholder = @"First name";
 // Last name
 _lastNameTextField = [[TextFieldPadding alloc] init];
 _lastNameTextField.autocapitalizationType =
   UITextAutocapitalizationTypeWords;
 _lastNameTextField.clearButtonMode = _firstNameTextField.clearButtonMode;
 _lastNameTextField.placeholder = @"Last name";
 // School
 _schoolTextField = [[TextFieldPadding alloc] init];
 //_schoolTextField.clearButtonMode = _firstNameTextField.clearButtonMode;
 _schoolTextField.userInteractionEnabled = NO;
 _schoolTextField.placeholder = @"School";
 // Email
 _emailTextField = [[TextFieldPadding alloc] init];
 _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
 _emailTextField.clearButtonMode = _firstNameTextField.clearButtonMode;
 _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
 _emailTextField.placeholder = @"School email";
 // Password
 _passwordTextField = [[TextFieldPadding alloc] init];
 _passwordTextField.placeholder = @"Password";
 _passwordTextField.secureTextEntry = YES;
 // Images for text field
 NSArray *textFieldImageArray = @[
   @"user_icon.png",
   @"user_icon.png",
   @"school_icon.png",
   @"messages_icon_dark.png",
   @"password_icon.png"
 ];
 // Set attributes for all text fields
 NSArray *textFieldArray = @[
   _firstNameTextField,
   _lastNameTextField,
   _schoolTextField,
   _emailTextField,
   _passwordTextField
 ];
 // Frames for text fields
 textFieldBorderArray = [NSMutableArray array];
 textFieldFrameArray  = [NSMutableArray array];
 for (TextFieldPadding *textField in textFieldArray) {
  
   NSInteger index = [textFieldArray indexOfObject: textField];
   textField.autocorrectionType = UITextAutocorrectionTypeNo;
   // textField.clearButtonMode = UITextFieldViewModeWhileEditing;
   textField.delegate = self;
   textField.font = [UIFont normalTextFont];
   float widthObject = width;
  
   int auxIndex = (index > 0 ? index - 1 : index);
   // Half of width
   if(textField == _firstNameTextField || textField == _lastNameTextField){
     float origin = 0.0f;
     // Next to first name
     if(textField == _lastNameTextField)
       origin = widthObject * .5f;
    
     textField.frame = CGRectMake(origin, auxIndex * buttonHeight,
       widthObject * .5f, buttonHeight);
     if (textField == _firstNameTextField) {
       // Right border
       UIView *bor = [UIView new];
       bor.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.3f];
       bor.frame = CGRectMake(textField.frame.size.width - 1.0f, 0.0f,
         1.0f, textField.frame.size.height);
       [textField addSubview: bor];
       }
     }
   else {
     textField.frame = CGRectMake(0.0f, auxIndex * buttonHeight,
       widthObject, buttonHeight);
   }
   [textFieldFrameArray addObject: [NSValue valueWithCGRect: textField.frame]];
   textField.leftPaddingX = buttonHeight;
   textField.paddingY = 0.0f;
   textField.placeholderColor = [UIColor grayMedium];
   textField.placeholder = textField.placeholder;
   textField.returnKeyType = UIReturnKeyDone;
   textField.rightPaddingX = padding;
   textField.textColor = [UIColor textColor];
   if (textField == _lastNameTextField) {
     textField.leftPaddingX = buttonHeight * .5f;
   }
   else {
     if(textField == _firstNameTextField) {
       textField.rightPaddingX = padding * .5f;
     }
     // Image view
     UIImageView *iv = [UIImageView new];
     iv.alpha = 0.3f;
     iv.frame = CGRectMake(15.0f, 15.0f,
       textField.frame.size.height - (15.0f * 2),
         textField.frame.size.height - (15.0f * 2));
     iv.image = [UIImage imageNamed: [textFieldImageArray objectAtIndex: index]];
     [textField addSubview: iv];
   }
   // Top border
   if (index > 1) {
     UIView *bor = [UIView new];
     bor.backgroundColor = [UIColor colorWithWhite: 0.0f alpha: 0.3f];
     bor.frame = CGRectMake(0.0f, 0.0f, textField.frame.size.width, 1.0f);
     [textField addSubview: bor];
     [textFieldBorderArray addObject: bor];
   }
   // Add arrow and tap recognizer
   if (textField == _schoolTextField) {
     // Arrow image
     // float widthIcon  = textField.frame.size.height * .3f;
     // float heightIcon = textField.frame.size.height * .34f;
     // UIImageView *arrow = [UIImageView new];
     // arrow.frame = CGRectMake(textField.frame.size.width - widthIcon - padding,
     //   (textField.frame.size.height - heightIcon) * .5f,
     //     widthIcon, heightIcon);
     // arrow.image = [UIImage imageNamed:@"arrow_left"];
     // arrow.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
     // [textField addSubview:arrow];
    
     // Textfield container for gesture recognizer
     schoolView = [UIView new];
     schoolView.frame = textField.frame;
     schoolView.backgroundColor = UIColor.clearColor;
    
     textField.frame = CGRectMake(0.0f, 0.0f,
       textField.frame.size.width, textField.frame.size.height);
     [schoolView addSubview:textField];
    
     // Gesture to show schools
     UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]
       initWithTarget:self action:@selector(showSchools)];
     [schoolView addGestureRecognizer:recognizer];
    
     [textFieldView addSubview: schoolView];
   }
   else {
     [textFieldView addSubview: textField];
   }
 }

 bottomView = [UIView new];
 bottomView.frame = CGRectMake(padding,
   textFieldView.frame.origin.y + textFieldView.frame.size.height + padding,
     width, buttonHeight + standardHeight);
 [scroll addSubview: bottomView];

 // Action button
 _actionButton = [UIButton new];
 _actionButton.backgroundColor = [UIColor blueAlpha: 0.8f];
 _actionButton.clipsToBounds = YES;
 _actionButton.frame = CGRectMake(0.0f, 0.0f, width, buttonHeight);
 _actionButton.layer.cornerRadius = OMBCornerRadius;
 _actionButton.titleLabel.font = [UIFont mediumTextFont];
 [_actionButton setBackgroundImage: [UIImage imageWithColor:
   [UIColor blueHighlightedAlpha: 0.8f]] forState: UIControlStateHighlighted];
 [_actionButton setTitle: @"Student Sign Up" forState: UIControlStateNormal];
 [_actionButton setTitleColor: [UIColor whiteColor]
   forState: UIControlStateNormal];
 [bottomView addSubview: _actionButton];

 // User switch button
 userSwitchButton = [UIButton new];
 userSwitchButton.contentHorizontalAlignment =
   UIControlContentHorizontalAlignmentLeft;
 userSwitchButton.frame = CGRectMake(0.0f,
   _actionButton.frame.origin.y + _actionButton.frame.size.height,
     bottomView.frame.size.width * 0.5f, standardHeight);
 userSwitchButton.titleLabel.font = [UIFont normalTextFont];
 [userSwitchButton addTarget: self action: @selector(switchUserViews)
   forControlEvents: UIControlEventTouchUpInside];
 [userSwitchButton setTitle: @"Landlord?" forState: UIControlStateNormal];
 [userSwitchButton setTitleColor: [UIColor whiteColor]
   forState: UIControlStateNormal];
 [bottomView addSubview: userSwitchButton];

 // Action switch button
 actionSwitchButton = [UIButton new];
 actionSwitchButton.contentHorizontalAlignment =
   UIControlContentHorizontalAlignmentRight;
 actionSwitchButton.frame = CGRectMake(
   userSwitchButton.frame.origin.x + userSwitchButton.frame.size.width,
     userSwitchButton.frame.origin.y,
       userSwitchButton.frame.size.width, userSwitchButton.frame.size.height);
 actionSwitchButton.titleLabel.font = userSwitchButton.titleLabel.font;
 [actionSwitchButton addTarget: self action: @selector(switchViews)
   forControlEvents: UIControlEventTouchUpInside];
 [actionSwitchButton setTitle: @"Login" forState: UIControlStateNormal];
 [actionSwitchButton setTitleColor: [UIColor whiteColor]
   forState: UIControlStateNormal];
 [bottomView addSubview: actionSwitchButton];

 otherSchool = [OMBSchool new];
 otherSchool.displayName = @"Other";

//  schools = [[OMBSchoolStore sharedStore] schools];
 // School List
 schools = [NSMutableArray array];

 schoolListView = [OMBFullListView new];
 schoolListView.table.dataSource = self;
 schoolListView.table.delegate   = self;
 schoolNameSelected = @"";

 UISearchBar *searchBar           = [[UISearchBar alloc] init];
 searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
 searchBar.autocorrectionType     = UITextAutocorrectionTypeNo;
 searchBar.barTintColor = UIColor.clearColor;
 searchBar.delegate               = self;
 searchBar.frame = CGRectMake(padding * 0.6f, padding,
   CGRectGetWidth(schoolListView.frame) - 2 * (padding * 0.6f), OMBStandardHeight);
 searchBar.placeholder = @"Search school";
 [searchBar setBackgroundImage:[UIImage imageWithColor:UIColor.clearColor]];
 [schoolListView addSubview:searchBar];

 [[NSNotificationCenter defaultCenter] addObserver: self
   selector: @selector(keyboardWillShow:)
     name: UIKeyboardWillShowNotification object: nil];
 [[NSNotificationCenter defaultCenter] addObserver: self
   selector: @selector(keyboardWillHide:)
     name: UIKeyboardWillHideNotification object: nil];

 [self refreshContentSize];

 return self;
}

#pragma mark - Protocol

#pragma mark - Protocol SearchManagerDelegate

- (void)searchFailedWithError:(NSError *)error
{
 // When user is typing quickly, current searching have to be canceled.
}

- (void)searchSucceededWithResponseObject:(id)responseObject
{
 if ([responseObject isKindOfClass:[NSArray class]]) {
  
   schools = [NSMutableArray array];
   for (NSDictionary *dic in responseObject) {
     OMBSchool *school = [OMBSchool new];
     [school readFromQBox:dic];
     [schools addObject:school];
   }
   [schools addObject:otherSchool];
 }

 [schoolListView.table reloadData];
}

#pragma mark - Protocol UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
 [schoolListView endEditing:YES];
}

#pragma mark - Protocol UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar
 textDidChange:(NSString *)searchText
{
 SchoolSearchManager *schoolSearch = [SchoolSearchManager sharedInstance];
 [schoolSearch cancel];
 [schoolSearch search:@{ @"query" : searchText }
   accessToken:nil delegate:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
 [schoolListView endEditing:YES];
}

#pragma mark - Protocol UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 static NSString *cellID = @"cellID";
 OMBFullListCell *cell = [tableView
   dequeueReusableCellWithIdentifier:cellID];

 if (!cell) {
   cell = [[OMBFullListCell alloc] initWithStyle:
     UITableViewCellStyleDefault reuseIdentifier:cellID];
 }

 NSString *schoolName = ((OMBSchool *)schools[indexPath.row]).displayName;

 if ([schoolNameSelected isEqualToString:schoolName]) {
   cell.textLabel.font = [UIFont normalTextFontBold];
 }
 else {
   cell.textLabel.font = [UIFont normalTextFont];
 }

 cell.textLabel.text = schoolName;

 return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
 return schools.count;
}

#pragma mark - Protocol UITableViewDelegate

- (void)tableView:(UITableView *)tableView
 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 schoolNameSelected = ((OMBSchool *)[schools
   objectAtIndex:indexPath.row]).displayName;

 _schoolTextField.text = schoolNameSelected;
 [schoolListView closeView];
}

- (CGFloat)tableView:(UITableView *)tableView
 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 return [OMBFullListCell heightForCell];
}

#pragma mark - Protocol UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
 if (!isEditing) {
   isEditing = YES;
   [self refreshContentSize];
 }

 NSInteger index = 0;
 if (textField == _emailTextField) {
   index = OMBLoginSignUpViewTextFieldEmail;
 }
 else if (textField == _firstNameTextField || textField == _lastNameTextField) {
   index = OMBLoginSignUpViewTextFieldFirstName;
 }
 /*else if (textField == _lastNameTextField)
   index = OMBLoginSignUpViewTextFieldLastName;*/
 else if (textField == _passwordTextField) {
   index = OMBLoginSignUpViewTextFieldPassword;
 }

 CGFloat contentHeight = scroll.contentSize.height;
 CGFloat height        = scroll.frame.size.height;
 CGFloat bottomY       = contentHeight - height;

 CGFloat originY = textFieldView.frame.origin.y;
 if (isLogin) {
   index -= 2;
 }
 if (index < 0) {
   index = 0;
 }

 originY += index * _firstNameTextField.frame.size.height;
 if (originY > bottomY) {
   originY = bottomY;
 }

 CGPoint point = CGPointMake(0.0f, originY);
 [UIView animateWithDuration: OMBStandardDuration animations: ^{
   scroll.contentOffset = point;
 }];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
 [textField resignFirstResponder];
 return YES;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) clearTextFields
{
 schoolNameSelected = @"";
 _emailTextField.text = _firstNameTextField.text =
   _lastNameTextField.text = _passwordTextField.text = _schoolTextField.text = @"";
}

- (CGFloat) heightForScrollContentSize
{
 CGFloat height  = 0.0f;
 CGFloat padding = OMBPadding;
 height = actionSwitchButton.frame.origin.y +
   actionSwitchButton.frame.size.height + padding;
 return height;
}

- (BOOL) isLandlord
{
 return isLandlord;
}

- (BOOL) isLogin
{
 return isLogin;
}

- (void) keyboardWillHide: (NSNotification *) notification
{
 isEditing = NO;
 [self refreshContentSize];
}

- (void) keyboardWillShow: (NSNotification *) notification
{
}

- (void) refreshContentSize
{
 CGFloat height = bottomView.frame.origin.y +
   bottomView.frame.size.height + OMBPadding;

 if (isEditing) {
   height += OMBKeyboardHeight;
 }
 [UIView animateWithDuration: OMBStandardDuration animations: ^{
   scroll.contentSize = CGSizeMake(scroll.contentSize.width, height);
 }];
}

- (NSString *) schoolSelected
{
 if(!isLandlord){
   return schoolNameSelected;
 }

 return @"";
}

- (void) scrollToTop
{
 [scroll setContentOffset: CGPointZero animated: YES];
}

- (void) showSchools
{
 [self endEditing:YES];

 [schoolListView setupWithTitle:@"Schools" inView:self];
 [schoolListView showView];
}

- (void) switchToLandlord
{
 isLandlord = YES;
 [self updateUserViews];
}

- (void) switchToLogin
{
 isLogin = YES;
 [self updateViews];
}

- (void) switchToSignUp
{
 isLogin = NO;
 [self updateViews];
}

- (void) switchToStudent
{
 isLandlord = NO;
 [self updateUserViews];
}

- (void) switchUserViews
{
 isLandlord = !isLandlord;
 [self updateUserViews];
}

- (void) switchViews
{
 isLogin = !isLogin;
 [self updateViews];
}

- (void) updateUserViews
{
 NSString *actionButtonString = isLogin ? @"Login" : @"Sign Up";

 headerLabel.text = [NSString stringWithFormat: @"%@ %@",
   isLandlord ? @"Landlord" : @"Student", actionButtonString];
 _emailTextField.placeholder = [NSString stringWithFormat: @"%@ email",
   isLandlord ? @"Landlord" : @"School"];
 [_actionButton setTitle: actionButtonString
   forState: UIControlStateNormal];
 [userSwitchButton setTitle: [NSString stringWithFormat: @"Are you a %@?",
   isLandlord ? @"student" : @"landlord"] forState: UIControlStateNormal];
 schoolView.hidden = isLandlord;

 [UIView animateWithDuration:OMBStandardDuration animations:^{
   textFieldView.frame = CGRectMake(textFieldView.frame.origin.x,
     textFieldView.frame.origin.y, textFieldView.frame.size.width,
       _emailTextField.frame.size.height * (isLandlord ? 3 : 4));
  
   CGRect rectEmail, rectPassword;
   if (isLandlord) {
     rectEmail = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldSchool] CGRectValue];
     rectPassword = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldEmail] CGRectValue];
   }
   else {
     rectEmail = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldEmail] CGRectValue];
     rectPassword = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldPassword] CGRectValue];
   }
  
   schoolView.alpha = isLandlord ? 0.0f : 1.0f;
   _emailTextField.frame = rectEmail;
   _passwordTextField.frame = rectPassword;
  
   // Bottom view
   bottomView.frame = CGRectMake(bottomView.frame.origin.x,
     textFieldView.frame.origin.y + textFieldView.frame.size.height +
       OMBPadding, bottomView.frame.size.width,
         bottomView.frame.size.height);
 }];

 [self refreshContentSize];
}

- (void) updateViews
{
 // Login
 if (isLogin) {
   [UIView animateWithDuration: OMBStandardDuration animations: ^{
     _firstNameTextField.alpha = 0.0f;
     _lastNameTextField.alpha  = 0.0f;
     schoolView.alpha    = 0.0f;
     userSwitchButton.hidden = YES;
     // Email
     CGRect rect1 = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldFirstName] CGRectValue];
     rect1.size.width = _schoolTextField.frame.size.width;
     _emailTextField.frame = rect1;
     _emailTextField.placeholder = @"Email";
     // Password
     CGRect rect2 = [[textFieldFrameArray objectAtIndex:
       OMBLoginSignUpViewTextFieldSchool] CGRectValue];
     rect2.size.width = _schoolTextField.frame.size.width;
     _passwordTextField.frame = rect2;
     // Resize the text field view
     textFieldView.frame = CGRectMake(textFieldView.frame.origin.x,
       textFieldView.frame.origin.y, textFieldView.bounds.size.width,
         _emailTextField.frame.size.height * 2);
     // Hide the top borders
     for (NSInteger i = OMBLoginSignUpViewTextFieldSchool;
       i < OMBLoginSignUpViewTextFieldEmail; i++) {
       UIView *v = [textFieldBorderArray objectAtIndex: i - 1];
       v.hidden = YES;
     }
     // Bottom view
     bottomView.frame = CGRectMake(bottomView.frame.origin.x,
       textFieldView.frame.origin.y + textFieldView.frame.size.height +
       OMBPadding, bottomView.frame.size.width,
         bottomView.frame.size.height);
   } completion: ^(BOOL finished) {
     if (finished) {
       _firstNameTextField.hidden = YES;
       _lastNameTextField.hidden  = YES;
       schoolView.hidden    = YES;
     }
   }];
   // Facebook
   [_facebookButton setTitle: @"Login using Facebook"
     forState: UIControlStateNormal];
   // Action button
   [_actionButton setTitle: @"Login" forState: UIControlStateNormal];
   // Action switch button
   [actionSwitchButton setTitle: @"Sign Up"
     forState: UIControlStateNormal];
   // Change the header label text
   NSString *actionButtonString = isLogin ? @"Login" : @"Sign Up";
   headerLabel.text = actionButtonString;
 }
 // Sign up
 else {
   _firstNameTextField.hidden = NO;
   _lastNameTextField.hidden  = NO;
   schoolView.hidden    = isLandlord;
   userSwitchButton.hidden = NO;
   [UIView animateWithDuration: OMBStandardDuration animations: ^{
     _firstNameTextField.alpha = 1.0f;
     _lastNameTextField.alpha  = 1.0f;
     schoolView.alpha    = isLandlord ? 0.0f : 1.0f;
    
     CGRect rectEmail, rectPassword;
    
     if (isLandlord) {
       rectEmail = [[textFieldFrameArray objectAtIndex:
         OMBLoginSignUpViewTextFieldSchool] CGRectValue];
       rectPassword = [[textFieldFrameArray objectAtIndex:
         OMBLoginSignUpViewTextFieldEmail] CGRectValue];
     }
     else {
       rectEmail = [[textFieldFrameArray objectAtIndex:
         OMBLoginSignUpViewTextFieldEmail] CGRectValue];
       rectPassword = [[textFieldFrameArray objectAtIndex:
         OMBLoginSignUpViewTextFieldPassword] CGRectValue];
     }
    
     // Email
     _emailTextField.frame = rectEmail;
     _emailTextField.placeholder = [NSString stringWithFormat: @"%@ email",
       isLandlord ? @"Landlord" : @"School"];
     // Password
     _passwordTextField.frame = rectPassword;
     // Resize the text field view
     textFieldView.frame = CGRectMake(textFieldView.frame.origin.x,
       textFieldView.frame.origin.y, textFieldView.bounds.size.width,
         _emailTextField.frame.size.height * (isLandlord ? 3 : 4));
     // Hide the top borders
     for (NSInteger i = OMBLoginSignUpViewTextFieldSchool;
       i < OMBLoginSignUpViewTextFieldEmail; i++) {
       UIView *v = [textFieldBorderArray objectAtIndex: i - 1];
       v.hidden = NO;
     }
     // Bottom view
     bottomView.frame = CGRectMake(bottomView.frame.origin.x,
       textFieldView.frame.origin.y + textFieldView.frame.size.height +
       OMBPadding, bottomView.frame.size.width,
         bottomView.frame.size.height);
   }];
   // Facebook
   [_facebookButton setTitle: @"Sign up using Facebook"
     forState: UIControlStateNormal];
   // Action button
   [_actionButton setTitle: @"Sign Up" forState: UIControlStateNormal];
   // Action switch button
   [actionSwitchButton setTitle: @"Login"
     forState: UIControlStateNormal];

   NSString *actionButtonString = isLogin ? @"Login" : @"Sign Up";
   headerLabel.text = [NSString stringWithFormat: @"%@ %@",
     isLandlord ? @"Landlord" : @"Student", actionButtonString];
 }

 [self refreshContentSize];
}

@end
