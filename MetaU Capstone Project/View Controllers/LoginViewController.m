//
//  LoginViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)registerUser {
    PFUser *newUser = [PFUser user];
//    NSLog(@"%@", self.nameField.text);

    NSString *fullName = self.nameField.text;
    NSString *firstName = [[fullName componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *lastName = [fullName substringFromIndex:[fullName rangeOfString:firstName].length + 1];
    
    // Set Properties
    newUser.username = [self.usernameField.text lowercaseString];
    newUser.password = self.passwordField.text;
    newUser.email = [self.emailField.text lowercaseString];

    
    newUser[@"firstName"] = [firstName capitalizedString];
    newUser[@"lastName"] =  [lastName capitalizedString];

    // Call Sign Up Function
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            [self performSegueWithIdentifier:@"signUpSegue" sender:self];
        }
    }];
}

- (void)loginUser {
    NSString *username = [self.usernameField.text lowercaseString];
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in sucessfully");

            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}

- (IBAction)loginButton:(id)sender {
    [self loginUser];
}

- (IBAction)signUpButton:(id)sender {
    [self registerUser];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
