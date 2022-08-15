//
//  SpotifyManager.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/19/22.
//

#import "SpotifyManager.h"
#import "SpotifyiOS/SpotifyAppRemote.h"

@implementation SpotifyManager

+ (SpotifyManager *)shared {
    static SpotifyManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

static const NSInteger MAX_SECONDS = 3;

static const NSInteger MIN_MILISECONDS = 0;
static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;

- (void)connectSpotify {
    NSString *spotifyClientID = @"d45f5e4964984bc49dfb5b2280b8d28c";
    NSURL *spotifyRedirectURL = [NSURL URLWithString:@"metau-summer-2022-capstone-project://callback"];
    
    self.configuration = [[SPTConfiguration alloc] initWithClientID:spotifyClientID redirectURL:spotifyRedirectURL];
    
    // Empty Value [@""] -> Resume Playback User Last Track
    // @"spotify:track:20I6sIOMTCkB6w7ryavxtO" -> Resume Example Track
    self.configuration.playURI = @"";
    
    self.sessionManager = [[SPTSessionManager alloc] initWithConfiguration:self.configuration delegate:self];
    self.appRemote = [[SPTAppRemote alloc] initWithConfiguration:self.configuration logLevel:SPTAppRemoteLogLevelNone];
    
    self.appRemote.delegate = self;
}

- (void)authenticateSpotify {
    SPTScope requestedScope = SPTAppRemoteControlScope | SPTUserFollowReadScope | SPTPlaylistModifyPrivateScope | SPTPlaylistReadPrivateScope  | SPTUserLibraryReadScope | SPTUserTopReadScope | SPTUserReadPrivateScope | SPTUserLibraryModifyScope | SPTPlaylistReadCollaborativeScope | SPTUserReadEmailScope | SPTUserReadRecentlyPlayedScope | SPTUserReadCurrentlyPlayingScope | SPTUserModifyPlaybackStateScope;
    
    [self.sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
}

- (void)applicationDidBecomeActive {
    if (self.appRemote.connectionParameters.accessToken) {
      [self.appRemote connect];
        NSLog(@"Connecting app remote...");
    } else {
        NSLog(@"Failed to connect app remote....");
    }
}

- (void)applicationWillResignActive {
    if (self.appRemote.isConnected) {
      [self.appRemote disconnect];
        NSLog(@"Disconnecting app remote...");
    }
}

#pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    NSLog(@"success: %@", session);
    
    self.appRemote.connectionParameters.accessToken = session.accessToken;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.appRemote connect];
    });

    self.accessToken = session.accessToken;
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didFailWithError:(nonnull NSError *)error {
    NSLog(@"fail: %@", error);
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session
{
  NSLog(@"renewed: %@", session);
}

#pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(nonnull SPTAppRemote *)appRemote {
    NSLog(@"connected");
    
    self.appRemote.playerAPI.delegate = (id<SPTAppRemotePlayerStateDelegate>)self;
    
    [self.appRemote.playerAPI subscribeToPlayerState:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
          NSLog(@"error: %@", error.localizedDescription);
        } else {
            NSLog(@"Success!");
        }
    }];
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    NSLog(@"disconnected");
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    NSLog(@"failed");
}

- (void)playerStateDidChange:(nonnull id<SPTAppRemotePlayerState>)playerState {
    NSLog(@"Track name: %@", playerState.track.name);
    NSLog(@"player state changed");

    @try {
        self.currentTrack = [self currentTrackInfo:playerState.track];
        self.currentTrackContentItem = playerState.track;
    } @catch (NSException *exception) {
        NSLog(@"Error getting current track...");
    }
    
    [self recentlyPlayedTrack];

    NSLog(@"PREVIOUS TRACK: %@", self.previousTrack);
    NSLog(@"CURRENT TRACK : %@", self.currentTrack);

    [self sendNotification];
}

- (void)sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playerStateChangeNotification" object:self];
}

- (void)sendNewTrackNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newTrackNotification" object:self];
}

- (void)startTrack {
    [[self.appRemote playerAPI] resume:^(id result, NSError * error){
        NSLog(@"Playing current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Played music");
        }
    }];
}

- (void)stopTrack {
    NSLog(@"%@", @([self.appRemote isConnected]));
    [[self.appRemote playerAPI] pause:^(id result, NSError * error){
        NSLog(@"Pausing current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Stopped music.");
        }
    }];
}

- (void)skipTrack {
    [[self.appRemote playerAPI] skipToNext:^(id result, NSError * error){
        NSLog(@"Skipping current track...");
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Skipped to next track");
        }
    }];
    
    [self.appRemote.playerAPI skipToNext:(nil)];
}

- (void)rewindTrack {
    NSLog(@"Rewinding music called");
    
    self.currentTrackTimestamp = 3; // Placeholder timestamp
    
    if (MIN_MILISECONDS <= self.timestamp <= MAX_MILISECONDS) { // if current timestamp < x seconds, restart current song
        [[self.appRemote playerAPI] seekToPosition:0 callback:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Restarted track");
            }
        }];
        
    } else if (MIN_MILISECONDS >= self.timestamp >= MAX_MILISECONDS) { // if current timestamp > x seconds, rewind to previous song
        [[self.appRemote playerAPI] skipToPrevious:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Skipped to previous track");
            }
        }];
    }
}

- (void)retriveDataFrom:(NSString *)targetUrl result:(void (^)(NSDictionary *))parsingFinished {
    NSString *tokenType = @"Bearer";
    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, self.accessToken];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    __block NSDictionary *dataRecieved = [[NSDictionary alloc] init];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

        NSString *strISOLatin = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        NSData *dataUTF8 = [strISOLatin dataUsingEncoding:NSUTF8StringEncoding];
        dataRecieved = [NSJSONSerialization JSONObjectWithData:dataUTF8 options:0 error:&error];
        
        if (dataRecieved != nil) {
            parsingFinished([dataRecieved copy]);
        } else {
            NSLog(@"Error: %@", error);
            parsingFinished([[NSDictionary alloc] init]);
        }
    }] resume];
}

- (void)searchTrack:(NSString *)query type:(NSString *)type result:(void (^)(NSDictionary *))parsingFinished {
    
    if (![type.lowercaseString isEqual: @"track"] || ![type.lowercaseString isEqual: @"artist"]) {
        type = @"track";
    }
    
    // "this is an example query" -> "this%20is%20an%20example%20query"
    NSString *formattedQuery = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *limit = @"10";
    NSString *baseURL = @"https://api.spotify.com/v1/search";
    NSString *targetURL = [NSString stringWithFormat: @"%@?q=%@&type=%@&market=ES&limit=%@&offset=0", baseURL, formattedQuery, type, limit];
    
    NSString *tokenType = @"Bearer";
    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, self.accessToken];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetURL]];

    __block NSDictionary *dataRecieved = [[NSDictionary alloc] init];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

        NSString *strISOLatin = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        NSData *dataUTF8 = [strISOLatin dataUsingEncoding:NSUTF8StringEncoding];
        dataRecieved = [NSJSONSerialization JSONObjectWithData:dataUTF8 options:0 error:&error];
        
        if (dataRecieved != nil) {
            parsingFinished([dataRecieved copy]);
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            parsingFinished([[NSDictionary alloc] init]);
        }
    }] resume];
}

- (void)addQueueToSpotify: (NSString *)trackURI {
    [[self.appRemote playerAPI] enqueueTrackUri:trackURI callback:^(id  _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"%@ added to Spotify queue", trackURI);
            }
    }];
}

- (NSDictionary *)currentTrackInfo: (id<SPTAppRemoteTrack>)track {
    NSDictionary *trackDetails = @{
            @"name" : track.name,
            @"URI" : track.URI,
            @"contextURI" : track.album.URI,
            @"artist" : track.artist.name,
            @"album" : track.album.name,
            @"images" : @[]
    };

    return (NSDictionary *)trackDetails;
}

- (NSDictionary *)getCurrentTrack {
    return self.currentTrack;
}

- (id<SPTAppRemoteTrack>)getCurrentTrackAsContentItem {
    return self.currentTrackContentItem;
}

- (void)recentlyPlayedTrack {
    NSString *targetURL = @"https://api.spotify.com/v1/me/player/recently-played?limit=1";
    
    [self retriveDataFrom:targetURL result:^(NSDictionary * _Nonnull dataRecieved) {
        NSString *track = [[dataRecieved valueForKey:@"items"] valueForKey:@"track"][0];
        
        NSString *trackName = [track valueForKey:@"name"];
        NSString *trackURI = [track valueForKey:@"uri"];

        NSMutableArray *trackArtists = [[track valueForKey:@"artists"] valueForKey:@"name"];

        NSString *trackAlbum = [[track valueForKey:@"album"] valueForKey:@"name"];
        NSString *contextURI =  [[track valueForKey:@"album"] valueForKey:@"uri"];
        NSArray *trackImages = [[[track valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"];
        
        NSDictionary *trackDetails = @{
                @"name" : trackName,
                @"URI" : trackURI,
                @"contextURI" : contextURI,
                @"artist" : trackArtists,
                @"album" : trackAlbum,
                @"images" : trackImages
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previousTrack = trackDetails;
        });
    }];
    
    [self sendNewTrackNotification];
}

- (NSDictionary *)getPreviousTrack {
    return self.previousTrack;
}

- (void)currentlyPlayingTrack {
    NSString *targetURL = @"https://api.spotify.com/v1/me/player/currently-playing";
    
    [self retriveDataFrom:targetURL result:^(NSDictionary * _Nonnull dataRecieved) {
        NSString *isPlaying = [dataRecieved valueForKey:@"is_playing"];
        NSNumber *timestamp = [dataRecieved valueForKey:@"progress_ms"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isTrackPlaying = isPlaying;
            self.currentTrackTimestamp = [timestamp integerValue];
        });
    }];
}

- (void)updateTimestamp {
    [self currentlyPlayingTrack];
}

- (NSInteger)getCurrentTrackTimestamp {
    [self updateTimestamp];
    return self.currentTrackTimestamp;
}

- (BOOL)getPlayerStatus {
    [self currentlyPlayingTrack];
    return self.isTrackPlaying;
}

- (void)playTrackAtTimestamp:(NSString *)trackURI timestamp:(NSInteger)timestamp result:(void (^)(NSDictionary *))parsingFinished {
    NSString *targetURL = @"https://api.spotify.com/v1/me/player/play";
    
    NSDictionary *requestBody = @{
      @"context_uri": trackURI,
      @"offset": @{
        @"position": @5
      },
      @"position_ms": @(timestamp)
    };
    
    NSError * err;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:NSUTF8StringEncoding error:&err];

    NSString *tokenType = @"Bearer";
    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, self.accessToken];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"PUT"];
    [request setURL:[NSURL URLWithString:targetURL]];
    [request setHTTPBody:requestData];

    __block NSDictionary *dataRecieved = [[NSDictionary alloc] init];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        
        NSString *strISOLatin = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        NSData *dataUTF8 = [strISOLatin dataUsingEncoding:NSUTF8StringEncoding];
        dataRecieved = [NSJSONSerialization JSONObjectWithData:dataUTF8 options:0 error:&error];

        if (dataRecieved != nil) {
            parsingFinished([dataRecieved copy]);
        } else {
            NSLog(@"Error: %@", error);
            parsingFinished([[NSDictionary alloc] init]);
        }
    }] resume];
}

@end
