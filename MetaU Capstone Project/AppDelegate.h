//
//  AppDelegate.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "SpotifyiOS/SpotifyiOS.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
@property (nonatomic, strong) SPTAppRemote *appRemote;

@end

