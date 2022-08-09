//
//  SpotifyManager.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/19/22.
//

#import "SpotifyManager.h"
#import "SpotifyiOS/SpotifyAppRemote.h"
#import "MusicSessionViewController.h"

@implementation SpotifyManager

+ (SpotifyManager *)shared {
    static SpotifyManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


static const NSInteger MAX_SECONDS = 5;
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
    SPTScope requestedScope = SPTAppRemoteControlScope | SPTUserFollowReadScope | SPTPlaylistModifyPrivateScope | SPTPlaylistReadPrivateScope  | SPTUserLibraryReadScope | SPTUserTopReadScope | SPTUserReadPrivateScope | SPTUserLibraryModifyScope | SPTPlaylistReadCollaborativeScope | SPTUserReadEmailScope | SPTUserReadRecentlyPlayedScope | SPTUserReadCurrentlyPlayingScope;
    
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
    
    [self sendNotification];
}

- (void)sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playerStateChangeNotification" object:self];
}

- (id<SPTAppRemoteTrack>) getCurrentTrackInfo {
    return self.currentTrack;
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
    
    self.timestamp = 3; // Placeholder timestamp
    
    if (self.timestamp < MAX_MILISECONDS) { // if current timestamp < x seconds, restart current song
        [[self.appRemote playerAPI] seekToPosition:0 callback:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Restarted track");
            }
        }];
        
    } else if (self.timestamp > MAX_MILISECONDS) { // if current timestamp > x seconds, rewind to previous song
        [[self.appRemote playerAPI] skipToPrevious:^(id result, NSError * error){
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Skipped to previous track");
            }
        }];
    }
}


@end
