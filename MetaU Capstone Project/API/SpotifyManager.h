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

@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSDictionary *currentTrack;
@property (nonatomic, weak) id<SPTAppRemoteTrack> currentTrackContentItem;
@property (nonatomic, strong) NSDictionary *previousTrack;
@property (nonatomic) NSInteger currentTrackTimestamp;
@property (nonatomic) BOOL isTrackPlaying;


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

- (NSDictionary *)getCurrentTrack;
- (NSDictionary *)getPreviousTrack;
- (void)updateTimestamp;
- (NSInteger)getCurrentTrackTimestamp;
- (BOOL)getPlayerStatus;
- (id<SPTAppRemoteTrack>)getCurrentTrackAsContentItem;

- (void)retriveDataFrom:(NSString *)targetUrl result:(void (^)(NSDictionary *))parsingFinished;
- (void)searchTrack:(NSString *)query type:(NSString *)type result:(void (^)(NSDictionary *))parsingFinished;
- (void)addQueueToSpotify: (NSString *)trackURI;
- (void)playTrackAtTimestamp:(NSString *)trackURI timestamp:(NSInteger)timestamp result:(void (^)(NSDictionary *))parsingFinished;

@end

NS_ASSUME_NONNULL_END
