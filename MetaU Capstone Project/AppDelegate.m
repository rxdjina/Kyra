//
//  AppDelegate.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
            configuration.clientKey = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
            configuration.server = @"https://parseapi.back4app.com";
        }];

    [Parse initializeWithConfiguration:config];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
