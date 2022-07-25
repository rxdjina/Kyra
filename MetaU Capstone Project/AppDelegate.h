//
//  AppDelegate.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "SpotifyiOS/SpotifyiOS.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic) id<SPTAppRemoteDelegate> playerState;

@end
