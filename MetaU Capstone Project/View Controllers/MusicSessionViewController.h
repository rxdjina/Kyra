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

@interface MusicSessionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *sessionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, strong) MusicSession *musicSession;
@property (strong, nonatomic) IBOutlet UILabel *sessionLogLabel;

@end

NS_ASSUME_NONNULL_END
