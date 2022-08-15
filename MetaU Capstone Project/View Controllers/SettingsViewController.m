//
//  SettingsViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/28/22.
//

#import "SettingsViewController.h"
#import "Parse/Parse.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.errorMessageLabel.hidden = YES;
    
    self.emailTextField.delegate = self;
    self.oldPasswordTextField.delegate = self;
    self.updatedPasswordTextField.delegate = self;
    self.confirmUpdatedPasswordTextField.delegate = self;
    
    self.updateEmailButton.layer.cornerRadius = 5;
    self.updateEmailButton.clipsToBounds = YES;
    self.updatePasswordButton.layer.cornerRadius = 5;
    self.updateEmailButton.clipsToBounds = YES;
}

- (void)setDefaultTextField:(NSArray *)arrayOfTextFields {
    for (UITextField *textField in arrayOfTextFields) {
        [self setBorderProperties:textField color:[UIColor grayColor]];
    }
}

- (void)setBorderProperties:(UITextField *)textField color:(UIColor *)color {
    textField.layer.borderColor = [color CGColor];
    textField.layer.borderWidth = 1;
}

- (void)clearTextFields: (NSArray *)arrayOfTextFields{
    for (UITextField *textField in arrayOfTextFields) {
        textField.text = @"";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self validateTextFields:textField];
    return YES;
}

// Verify All Text Fields Filled
- (void)validateTextFields: (UITextField *)textField {
    BOOL allFieldsFilled = ((self.oldPasswordTextField.text.length > 0) &&
                            (self.updatedPasswordTextField.text.length > 0) &&
                            (self.confirmUpdatedPasswordTextField.text.length > 0));
    
    if (allFieldsFilled) {
    self.updatePasswordButton.enabled = YES;
    self.updatePasswordButton.backgroundColor = [UIColor colorWithRed:0.47 green:0.61 blue:0.90 alpha:1.0];
        
  } else {
    self.updatePasswordButton.backgroundColor = [UIColor lightGrayColor];
    self.updatePasswordButton.enabled = NO;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)changeEmail {
    NSArray *changeEmailTextFields = @[self.emailTextField];
    PFUser *currentUser = [PFUser currentUser];
    NSString *email = self.emailTextField.text;
    
    NSLog(@"%@", email);
    if (currentUser) {
      currentUser[@"email"] = email;

      [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Sucessfully updated email to %@", email);
            [self clearTextFields:changeEmailTextFields];
            [self dismissViewControllerAnimated:YES completion:nil];
            // TODO: Add success alert
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            self.errorMessageLabel.hidden = NO;
            self.errorMessageLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
        }
      }];
    }
}

- (void)changePassword {
    NSArray *changePasswordTextFields = @[self.oldPasswordTextField, self.updatedPasswordTextField, self.confirmUpdatedPasswordTextField];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *newPassword;

    if ([self.updatedPasswordTextField.text isEqual:self.confirmUpdatedPasswordTextField.text]) {
        // TODO: Verify that oldPasswordTextField matched old password
        
        newPassword = self.updatedPasswordTextField.text;
        
        if (currentUser) {
            [currentUser setPassword:newPassword];

          [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Sucessfully updated password");
                [self clearTextFields:changePasswordTextFields];
                [self dismissViewControllerAnimated:YES completion:nil];
                // TODO: Add success alert
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                self.errorMessageLabel.hidden = NO;
                self.errorMessageLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            }
          }];
        }
    } else {
        self.updatePasswordButton.enabled = NO;
        NSLog(@"Passwords do not match");
        self.errorMessageLabel.hidden = NO;
        self.errorMessageLabel.text = @"* Passwords do not match";
    }
}

- (IBAction)pressedUpdateEmail:(id)sender {
    [self changeEmail];
    [self notificationBanner:@"Verification email sent"];
}

- (IBAction)pressedUpdatePassword:(id)sender {
    [self changePassword];
    [self notificationBanner:@"Password successfully reset"];
}

- (void)notificationBanner:(NSString *)bannerText{
    [self.updateNotificationButton setTitle:bannerText forState:UIControlStateNormal];

    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self selector:@selector(bannerAnimationUp) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                 target:self selector:@selector(bannerAnimationDown) userInfo:nil repeats:NO];
}

- (void)bannerAnimationUp {
    self.updateNotificationButton.hidden = NO;
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger  x = width / 2;
    
    NSInteger buttonWidth = self.updateNotificationButton.intrinsicContentSize.width;

    self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 60, buttonWidth, 31);
    [UIView animateWithDuration:0.25 animations:^{
        self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 80, buttonWidth, 31);
    }];
}

- (void)bannerAnimationDown {
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger  x = width / 2;
    NSInteger buttonWidth = self.updateNotificationButton.intrinsicContentSize.width;

    self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 80, buttonWidth, 31);

    [UIView animateWithDuration:0.15 animations:^{
        self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 60, buttonWidth, 31);
    } completion:^(BOOL finished) {
        if (finished) {
            self.updateNotificationButton.hidden = YES;
        }
    }];
}

@end
