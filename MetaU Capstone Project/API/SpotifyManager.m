//
//  SpotifyManager.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/19/22.
//

#import "SpotifyManager.h"
#import "SpotifyiOS/SpotifyAppRemote.h"

@implementation SpotifyManager

+ (id)shared {
    static SpotifyManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

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
    SPTScope requestedScope = SPTAppRemoteControlScope | SPTUserFollowReadScope | SPTPlaylistModifyPrivateScope | SPTPlaylistReadPrivateScope  | SPTUserLibraryReadScope | SPTUserTopReadScope | SPTUserReadPrivateScope | SPTUserLibraryModifyScope | SPTPlaylistReadCollaborativeScope | SPTUserReadEmailScope;
    
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
    [self.appRemote connect];
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
}

// TODO: Add Play/Pause
// TODO: Add Skip/Rewind

@end
