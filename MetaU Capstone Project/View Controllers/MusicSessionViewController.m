//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"
#import "HomeViewController.h"
#import "MusicSession.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import <SpotifyiOS/SpotifyAppRemote.h>
#import "SpotifyManager.h"

@import ParseLiveQuery;

@interface MusicSessionViewController ()

@property BOOL isPlaying;

@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) id<SPTAppRemotePlayerState> playerState;
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) PFLiveQueryClient *client;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;
@property (nonatomic) NSInteger testCounter;

@end

static const NSInteger MAX_SECONDS = 5;
static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;

NSString * const APPLICATION_ID = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
NSString * const CLIENT_KEY = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
NSString * const SERVER_URL = @"wss://musicsessionlog.b4a.io";

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accessToken = [[SpotifyManager shared] accessToken];
    self.sessionNameLabel.text = self.musicSession.sessionName;
    self.sessionIDLabel.text = self.musicSession.sessionCode;
    self.isPlaying = NO;
    
    [self querySetup];
    
    [MusicSession addUserToSession:self.musicSession.sessionCode withCompletion:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User added to session successfully");
        }
    }];
}

- (void)testTimer // Increments counter every second
{
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                 target:self selector:@selector(testTimestamp:) userInfo:nil repeats:YES];
}

-  (void)testTimestamp:(NSTimer *)timer {

    self.testCounter++;
    
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.musicSession.sessionCode];
    
    [query getObjectInBackgroundWithId:self.musicSession.objectId
                                 block:^(PFObject *session, NSError *error) {
        PFUser *host = session[@"host"];
        
        if ([PFUser.currentUser.objectId isEqual:host.objectId]) {
            session[@"timestamp"] = @(self.testCounter);
            [session saveInBackground];
        }
    }];
}

- (void)querySetup {
    self.client = [[PFLiveQueryClient alloc] initWithServer:SERVER_URL applicationId:APPLICATION_ID clientKey:CLIENT_KEY];

    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
    self.subscription = [self.client subscribeToQuery:query];
    
    __weak typeof(self) weakSelf = self;
    
    // Called when subscribed
    (void)[self.subscription addSubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"Subscription Handler");
    }];
    
    // Called when unsubscribed
    (void)[self.subscription addUnsubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"Unsubscription Handler");
    }];
    
    // Called when query changes, object existed BEFORE
    (void)[self.subscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        __strong typeof (self) strongSelf = weakSelf;
        
        MusicSession *session = (MusicSession *)object;
        
        NSLog(@"Update Handler");

        dispatch_async(dispatch_get_main_queue(), ^{
    
            strongSelf.sessionLogLabel.text = [NSString stringWithFormat:@"%@", session.activeUsers];
            strongSelf.testLabel.text = [NSString stringWithFormat:@"%ld", (long)session.timestamp];
            strongSelf.trackLabel.text = [[SpotifyManager shared] getCurrentTrackInfo].name;
            
            UIImage *playImage = [UIImage systemImageNamed:@"play.circle.fill"];
            UIImage *stopImage = [UIImage systemImageNamed:@"stop.circle.fill"];
            
            if (strongSelf.isPlaying) {
                [strongSelf.playPauseButton setImage:stopImage forState:UIControlStateNormal];
            } else {
                [strongSelf.playPauseButton setImage:playImage forState:UIControlStateNormal];
            }
        });
    }];
    
    // Called when object created, object DID NOT exist
    (void)[self.subscription addEnterHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Enter Handler");
    }];
    
    (void)[self.subscription addCreateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Create Handler");
    }];
    
    // Called when object deleted, object DID exist but now does NOT
    (void)[self.subscription addLeaveHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Leave Handler");
    }];
    
    // Called if error occurs
    (void)[self.subscription addErrorHandler:^(PFQuery<PFObject *> * _Nonnull query, NSError * _Nonnull error) {
        NSLog(@"Error Handler: %@", error.localizedDescription);
    }];
}

- (void)updateMusicSession {
    // TODO: Update session view controller
}

- (IBAction)pressedThePlayButton:(id)sender {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.musicSession.sessionCode];
    
    // if user presses play -> song plays -> update status on server -> update image based on server
    // if the user presses stop -> song stops -> update status on seerver -> update image based on server
    
    if (!self.isPlaying) {
        self.isPlaying = YES;
        [self playMusic];

    } else {
        self.isPlaying = NO;
        [self stopMusic];
    }
    
    [query getObjectInBackgroundWithId:self.musicSession.objectId
                                 block:^(PFObject *session, NSError *error) {

        PFUser *host = session[@"host"];
        
        if ([PFUser.currentUser.objectId isEqual:host.objectId]) {
            session[@"isPlaying"] = @(self.isPlaying);
            [session saveInBackground];
        }
    }];
}

- (IBAction)pressedSkipButton:(id)sender {
    [self skipMusic];
}

- (IBAction)pressedRewindButton:(id)sender {
    [self rewindMusic];
}

- (void)playMusic {
    [[SpotifyManager shared] startTrack];
}

- (void)stopMusic {
    [[SpotifyManager shared] stopTrack];
}

- (void)skipMusic {
    [[SpotifyManager shared] skipTrack];
}

- (void)rewindMusic {
    [[SpotifyManager shared] rewindTrack];
}

- (IBAction)pressedLeaveSession:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];

    [MusicSession removeUserFromSession:self.musicSession.sessionCode user:[PFUser currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.client unsubscribeFromQuery:query];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (NSString *)getInfo: (NSString *)objectId {
    NSString *username;

    PFQuery *query = [[PFUser query] whereKey:@"objectId" equalTo:objectId];
    NSMutableArray *users = (NSMutableArray *)[query findObjects];
    username = [users valueForKey:@"username"];

    return username;
}


- (void)getDataFrom: (NSString *)targetUrl {
    NSString *token = [[SpotifyManager shared] accessToken];
    NSString *tokenType = @"Bearer";
    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

          NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"Data received: %@", myString);
    }] resume];
}

@end
