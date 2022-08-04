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
    
    self.emailTextField.delegate = self;
    self.oldPasswordTextField.delegate = self;
    self.updatedPasswordTextField.delegate = self;
    self.confirmUpdatedPasswordTextField.delegate = self;
}

- (void)changeEmail {
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *email = self.emailTextField.text;
    
    if (currentUser) {
      currentUser[@"email"] = email;

      [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Sucessfully updated email");
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
      }];
    }
}

- (void)changePassword {
     
}

- (IBAction)pressedUpdateEmail:(id)sender {
    [self changeEmail];
}

- (IBAction)pressedUpdatePassword:(id)sender {
    [self changePassword];
}

@end
