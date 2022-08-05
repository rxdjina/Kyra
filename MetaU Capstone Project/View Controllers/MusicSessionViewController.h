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

@interface MusicSessionViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *sessionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, strong) MusicSession *musicSession;
@property (strong, nonatomic) IBOutlet UILabel *sessionLogLabel;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *rewindButton;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UILabel *resultsLabel;

@end

NS_ASSUME_NONNULL_END
