//
//  OMBLoginViewController.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/30/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import "OMBViewController.h"

@class TextFieldPadding;

@interface OMBLoginViewController : OMBViewController
<UIScrollViewDelegate, UITextFieldDelegate>
{
  UIActivityIndicatorView *activityIndicatorView;
  TextFieldPadding *emailTextField;
  UIButton *facebookButton;
  UIBarButtonItem *loginBarButtonItem;
  UIButton *loginButton;
  TextFieldPadding *nameTextField;
  UIView *orView;
  TextFieldPadding *passwordTextField;
  UIScrollView *scroll;
  UIBarButtonItem *signUpBarButtonItem;
}

#pragma mark - Methods

#pragma mark - Instance Methods

- (void) showLogin;
- (void) showSignUp;

@end
