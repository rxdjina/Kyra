//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"
#import "Parse/Parse.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

@import Parse;
@import ParseLiveQuery;

@interface MusicSessionViewController ()

@end

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionNameLabel.text = self.musicSession.sessionName;
    self.sessionIDLabel.text = self.musicSession.sessionCode;

    
}

- (IBAction)pressedPlay:(id)sender {
    
}


@end
