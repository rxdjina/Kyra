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

@interface CreateSessionViewController ()

@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (nonatomic, strong) MusicSession *arrayMusicSession;

@end
 
@implementation CreateSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        } else {
            NSLog(@"Sucessfully created session!");
            [self performSegueWithIdentifier:@"createSessionSegue" sender:sender];
        }
    }];
//    NSLog(@"%@", self.arrayMusicSession.sessionCode);
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
