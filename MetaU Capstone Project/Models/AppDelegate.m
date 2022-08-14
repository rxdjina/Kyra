//  AppDelegate.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "MusicSessionHandler.h"
#import "SpotifyManager.h"
#import "SpotifyiOS/SpotifyiOS.h"
#import "SpotifyiOS/SpotifyAppRemote.h"

@import Parse;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Parse Setup
    ParseClientConfiguration *config = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
            configuration.clientKey = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
            configuration.server = @"https://parseapi.back4app.com";
            NSLog(@"Connecting to: %@", configuration.server);
    }];

    [Parse initializeWithConfiguration:config];
    
    [[SpotifyManager shared] connectSpotify];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    NSLog(@"Scence Discarded");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Application Resigned");
    [[SpotifyManager shared] applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Application Became Active");
    [[SpotifyManager shared] applicationDidBecomeActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application Entered Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application Entered Foreground");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application Terminated");
}

@end
