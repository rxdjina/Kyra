//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"
#import "AppDelegate.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import <SpotifyiOS/SpotifyAppRemote.h>

@interface MusicSessionViewController ()

@property BOOL isPlaying;
@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) id<SPTAppRemotePlayerState> playerState;

@end

static const NSInteger MAX_SECONDS = 5;
static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sessionNameLabel.text = self.musicSession.sessionName;
    self.sessionIDLabel.text = self.musicSession.sessionCode;
    self.isPlaying = NO;
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
