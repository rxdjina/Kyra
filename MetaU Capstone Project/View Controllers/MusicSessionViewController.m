//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"
#import "AppDelegate.h"
#import "MusicSessionHandler.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import <SpotifyiOS/SpotifyAppRemote.h>

@import ParseLiveQuery;

@interface MusicSessionViewController ()

@property BOOL isPlaying;

@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) id<SPTAppRemotePlayerState> playerState;

@property (nonatomic, strong) PFLiveQueryClient *client;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) MusicSessionHandler *handler;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;

@end

static const NSInteger MAX_SECONDS = 5;
static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;

NSString * const APPLICATION_ID = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
NSString * const CLIENT_KEY = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
NSString * const SERVER_URL = @"wss://musicsessionlog.b4a.io";

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sessionNameLabel.text = self.musicSession.sessionName;
    self.sessionIDLabel.text = self.musicSession.sessionCode;
    self.isPlaying = NO;
    
    [self querySetup];
}

- (void)querySetup {
    self.client = [[PFLiveQueryClient alloc] initWithServer:SERVER_URL applicationId:APPLICATION_ID clientKey:CLIENT_KEY];
    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
    self.subscription = [self.client subscribeToQuery:query];

    __unsafe_unretained typeof(self) weakSelf = self;
    
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

- (IBAction)pressedThePlayButton:(id)sender {
    UIImage *playImage = [UIImage systemImageNamed:@"play.circle.fill"];
    UIImage *stopImage = [UIImage systemImageNamed:@"stop.circle.fill"];
    
    [self.appRemote isConnected] ? NSLog(@"Conneted") : NSLog(@"Not Connected");
    if (!self.isPlaying) {
        [sender setImage:stopImage forState:UIControlStateNormal];
        self.isPlaying = YES;
        [self playMusic];
        
    } else {
        [sender setImage:playImage forState:UIControlStateNormal];
        self.isPlaying = NO;
        [self stopMusic];
    }
}

- (IBAction)pressedSkipButton:(id)sender {
    [self skipMusic];
}

- (IBAction)pressedRewindButton:(id)sender {
    [self rewindMusic];
}

- (void)playMusic {
    NSLog(@"Play music called");
    [[self.appRemote playerAPI] resume:^(id result, NSError * error){
        NSLog(@"Playing current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Played music");
        }
    }];
}

- (void)stopMusic {
    NSLog(@"Pause music called");
    [[self.appRemote playerAPI] pause:^(id result, NSError * error){
        NSLog(@"Pausing current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Stopped music.");
        }
    }];
}

- (void)skipMusic {
    NSLog(@"Skip music called");
    [[self.appRemote playerAPI] skipToNext:^(id result, NSError * error){
        NSLog(@"Skipping current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Skipped to next track");
        }
    }];
}

- (void)rewindMusic {
    NSLog(@"Rewinding music called");
    
    if (self.timestamp < MAX_MILISECONDS) { // if current timestamp < x seconds, restart current song
        NSLog(@"Restarting current track...");
        [[self.appRemote playerAPI] seekToPosition:0 callback:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Restarted track");
            }
        }];
        
    } else if (self.timestamp > MAX_MILISECONDS) { // if current timestamp > x seconds, rewind to previous song
        NSLog(@"Rewinding to previous track...");
        [[self.appRemote playerAPI] skipToPrevious:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Skipped to previous track");
            }
        }];
    }
}

@end
