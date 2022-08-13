//
//  SpotifyManager.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyManager : NSObject <SPTAppRemoteDelegate, SPTSessionManagerDelegate, SPTAppRemotePlayerStateDelegate>

+ (id)shared;

@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
@property (nonatomic, strong) SPTAppRemote *appRemote;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, weak) id<SPTAppRemotePlayerStateDelegate> delegate;

@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, weak) id<SPTAppRemoteTrack> currentTrack;


// Authorization & Spotify Setup
- (void)authenticateSpotify;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (void)connectSpotify;

// Audio Playback Control
- (void)startTrack;
- (void)stopTrack;
- (void)skipTrack;
- (void)rewindTrack;

- (id<SPTAppRemoteTrack>)getCurrentTrackInfo;
- (void)retriveDataFrom:(NSString *)targetUrl result:(void (^)(NSDictionary *))parsingFinished;
- (void)searchTrack:(NSString *)query type:(NSString *)type result:(void (^)(NSDictionary *))parsingFinished;
- (void)addQueueToSpotify: (NSString *)trackURI;

@end

NS_ASSUME_NONNULL_END
