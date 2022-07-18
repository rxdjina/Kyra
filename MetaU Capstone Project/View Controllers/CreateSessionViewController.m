//
//  CreateSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "CreateSessionViewController.h"
#import "MusicSessionViewController.h"
#import "Parse/Parse.h"
#import "MusicSession.h"

@import Parse;
@import ParseLiveQuery;

@interface CreateSessionViewController ()

@property (nonatomic, strong) MusicSession *arrayMusicSession;

@end
 
@implementation CreateSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionNameTextField.delegate = self;
    self.codeTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)getSession{
    PFQuery *query = [MusicSession query];
    [query whereKey:@"sessionCode" equalTo:self.codeTextField.text];
    query.limit = 1;

    [query findObjectsInBackgroundWithBlock:^(NSArray<MusicSession *> * _Nullable sessions, NSError * _Nullable error) {
        if (sessions.count > 0) {
            self.arrayMusicSession = sessions[0];
            [self performSegueWithIdentifier:@"joinSessionSegue" sender:self];
        } else if (sessions.count < 1){
            NSLog(@"Unable to find session");
        }
        else {
            NSLog(@"Error getting music session: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)pressedCreateSession:(id)sender {
    self.arrayMusicSession = [MusicSession createSession:self.sessionNameTextField.text withCompletion:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                       message:@"An error occured while creating your session."
                                       preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            NSLog(@"Sucessfully created session!");
            [self performSegueWithIdentifier:@"createSessionSegue" sender:sender];
        }
    }];
}

- (IBAction)pressedJoinSession:(id)sender {
    [self getSession];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"joinSessionSegue"]) {
        MusicSession *dataToPass = self.arrayMusicSession;
        
        UINavigationController *navControl = [segue destinationViewController];
        MusicSessionViewController *destinationVC = [navControl topViewController];
        destinationVC.musicSession = dataToPass;
    } else if ([segue.identifier  isEqual: @"createSessionSegue"]) {
        MusicSession *dataToPass = self.arrayMusicSession;
        
        UINavigationController *navControl = [segue destinationViewController];
        MusicSessionViewController *destinationVC = [navControl topViewController];
        destinationVC.musicSession = dataToPass;
    }
}

@end
