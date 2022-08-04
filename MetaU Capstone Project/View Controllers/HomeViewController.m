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
#import "SpotifyManager.h"

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

- (IBAction)pressedConnectSpotify:(id)sender {
    // TODO: Disable join buttons OR move spotify connection
    [[SpotifyManager shared] authenticateSpotify];
}

@end
