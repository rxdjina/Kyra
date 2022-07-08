//
//  HomeViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "HomeViewController.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(PFUser.currentUser) {
        NSLog(@"Loaded Current User :)");
        NSLog(@"User: %@", PFUser.currentUser.username);
        NSLog(@"User: %@", [PFUser currentUser][@"firstName"]);
        
        self.greetingLabel.text = [NSString stringWithFormat:@"Welcome Back, %@", [PFUser currentUser][@"firstName"]];
    }
    
}


- (IBAction)pressedLogOut:(id)sender {
    SceneDelegate *appDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

    appDelegate.window.rootViewController = loginViewController;

    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
    NSLog(@"User logged out sucessfully");
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
