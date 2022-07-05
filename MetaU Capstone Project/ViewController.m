//
//  ViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "ViewController.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

@end
