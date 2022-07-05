//
//  LoginViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;

@end

NS_ASSUME_NONNULL_END
