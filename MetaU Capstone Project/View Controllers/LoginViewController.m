//
//  LoginViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.errorMessageLabel.hidden = YES;
    
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordRentryField.delegate = self;
    
    [self validateTextFields];
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
    [self validateTextFields];
    return YES;
}

// Verify All Text Fields Filled
- (void)validateTextFields {
    BOOL allFieldsFilled =
        ([self.nameField.text componentsSeparatedByString:@" "].count > 1) &&
        (self.emailField.text.length > 0) &&
        (self.usernameField.text.length > 0) &&
        (self.passwordField.text.length > 0) &&
        (self.passwordRentryField.text.length > 0);
    
    if (allFieldsFilled) {
    self.signUpButton.enabled = YES;
    self.signUpButton.backgroundColor = [UIColor colorWithRed:0.47 green:0.61 blue:0.90 alpha:1.0];
        
  } else {
    self.signUpButton.backgroundColor = [UIColor lightGrayColor];
    self.signUpButton.enabled = NO;
  }
}

- (void)registerUser {
    NSArray *signUpTextFields = @[self.nameField, self.emailField, self.usernameField, self.passwordField, self.passwordRentryField];
    
    PFUser *newUser = [PFUser user];
    
    NSString *fullName = self.nameField.text;
    NSString *firstName = [[fullName componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *lastName = [fullName substringFromIndex:[fullName rangeOfString:firstName].length + 1];

    // Set Properties
    newUser.username = [self.usernameField.text lowercaseString];
    newUser.email = [self.emailField.text lowercaseString];
    
    // Verify Password Match and Length
    if ([self.passwordField.text isEqualToString:self.passwordRentryField.text]) {
        newUser.password = self.passwordField.text;
    } else {
        newUser.password = NULL;
    }

    newUser[@"firstName"] = [firstName capitalizedString];
    newUser[@"lastName"] =  [lastName capitalizedString];

    // Call Sign Up Function
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            self.errorMessageLabel.hidden = NO;
            [self errorMessageHandling:error.localizedDescription];
            
        } else {
            NSLog(@"User registered successfully");
            
            [self setDefaultTextField:signUpTextFields];
            [self clearTextFields:signUpTextFields];
            self.errorMessageLabel.hidden = YES;
            
            [self performSegueWithIdentifier:@"signUpSegue" sender:self];
        }
    }];
}

- (void)loginUser {
    NSArray *loginTextFields = @[self.usernameField, self.passwordField];
    
    NSString *username = [self.usernameField.text lowercaseString];
    NSString *password = self.passwordField.text;
    
    // Call Login Function
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            
            self.errorMessageLabel.hidden = NO;
            [self errorMessageHandling:error.localizedDescription];
            
        } else {
            NSLog(@"User logged in sucessfully");

            [self setDefaultTextField:loginTextFields];
            [self clearTextFields:loginTextFields];
            self.errorMessageLabel.hidden = YES;
            
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}

- (void)errorMessageHandling:(NSString *)errorMessage{
    NSArray *loginTextFields = @[self.usernameField, self.passwordField];
    
    @try {
        NSArray *signUpTextFields = @[self.nameField, self.emailField, self.usernameField, self.passwordField, self.passwordRentryField];
        
        [self setDefaultTextField: signUpTextFields];
     }
     @catch (NSException *exception) {
         NSLog(@"%@", exception.reason);
         [self setDefaultTextField:loginTextFields];
     }
     @finally {

     }
    
    // Error Handling Registration
    if ([errorMessage isEqualToString:@"Cannot sign up without a password."]) {
        self.errorMessageLabel.text = @"* Passwords do not match.";
        [self setBorderProperties:self.passwordField color:[UIColor redColor]];
        [self setBorderProperties:self.passwordRentryField color:[UIColor redColor]];
        
    } else if ([errorMessage isEqualToString:@"Account already exists for this email address."]) {
        self.errorMessageLabel.text = [NSString stringWithFormat:@"* %@", errorMessage];
        [self setBorderProperties:self.emailField color:[UIColor redColor]];
        
    } else if ([errorMessage isEqualToString:@"Account already exists for this username."]) {
        self.errorMessageLabel.text = [NSString stringWithFormat:@"* %@", errorMessage];
        [self setBorderProperties:self.usernameField color:[UIColor redColor]];
        
    } else if ([errorMessage isEqualToString:@"Please enter full name."]) {
        self.errorMessageLabel.text = [NSString stringWithFormat:@"* %@", errorMessage];
        [self setBorderProperties:self.nameField color:[UIColor redColor]];
        
    } // Error Handling Login
    else if ([errorMessage isEqualToString:@"Invalid username/password."]) {
        self.errorMessageLabel.text = @"* Invalid username or password.";
        
    } else if ([errorMessage isEqualToString:@"password is required."]) {
        self.errorMessageLabel.text = @"* Password is required.";
        [self setBorderProperties:self.passwordField color:[UIColor redColor]];
        
    } else if ([errorMessage isEqualToString:@"username/email is required."]) {
        self.errorMessageLabel.text = @"* Username or email is required.";
        [self setBorderProperties:self.usernameField color:[UIColor redColor]];
    } else {
        self.errorMessageLabel.text = @"* Error occured. Please try again later.";
    }
}

- (IBAction)loginButton:(id)sender {
    [self loginUser];
}

- (IBAction)signUpButton:(id)sender {
    [self registerUser];
}

@end
