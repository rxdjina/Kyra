//
//  MusicSessionViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "MusicSession.h"
#import "SpotifyiOS/SpotifyAppRemote.h"
#import "SpotifyiOS/SpotifyiOS.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicSessionViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *sessionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, strong) MusicSession *session;
@property (strong, nonatomic) IBOutlet UILabel *sessionLogLabel;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *rewindButton;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UILabel *resultsLabel;

// Track
@property (strong, nonatomic) IBOutlet UIImageView *coverArtImage;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;

@property (strong, nonatomic) IBOutlet UILabel *currentlyPlayingNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentlyPlayingArtistLabel;
@property (strong, nonatomic) IBOutlet UIImageView *currentlyPlayingCoverArtImage;
@property (strong, nonatomic) IBOutlet UIButton *currentlyPlayingBGButton;

@property (strong, nonatomic) IBOutlet UIButton *updateNotificationButton;

- (void)updateView;
@end

NS_ASSUME_NONNULL_END
