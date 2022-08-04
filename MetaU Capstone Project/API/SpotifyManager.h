//
//  SpotifyManager.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyManager : NSObject <SPTAppRemoteDelegate, SPTSessionManagerDelegate>

+ (id)shared;

@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, weak) id<SPTAppRemotePlayerStateDelegate> delegate;

- (void)authenticateSpotify;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (void)connectSpotify;

@end

NS_ASSUME_NONNULL_END
