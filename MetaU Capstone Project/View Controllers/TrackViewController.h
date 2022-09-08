//
//  TrackViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/12/22.
//

#import <UIKit/UIKit.h>
#import "MusicSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackViewController : UIViewController

@property (nonatomic, strong) MusicSession *session;
@property (nonatomic, strong) NSDictionary *track;
@property (nonatomic) BOOL isHost;

@property (strong, nonatomic) IBOutlet UIImageView *viewBGImage;
@property (strong, nonatomic) IBOutlet UIImageView *coverArtImage;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UISlider *trackPlayer;
@property (strong, nonatomic) IBOutlet UIButton *rewindButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;


@end

NS_ASSUME_NONNULL_END
