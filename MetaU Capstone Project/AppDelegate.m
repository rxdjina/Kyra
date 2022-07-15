//
//  AppDelegate.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "MusicSessionHandler.h"

@import Parse;
@import ParseLiveQuery;

@interface AppDelegate ()

@property (nonatomic, strong) PFLiveQueryClient *client;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) MusicSessionHandler *handler;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
            configuration.clientKey = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
            configuration.server = @"https://parseapi.back4app.com";
            NSLog(@"Connecting to: %@", configuration.server);
        }];
    
    [Parse initializeWithConfiguration:config];

    // Live Query
    self.client = [[PFLiveQueryClient alloc] initWithServer:@"https://parseapi.back4app.com" applicationId:@"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3" clientKey:@"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k"];
    
    NSString *objectID = @"C48b7Dzzlp";
    PFQuery* query = [[PFQuery queryWithClassName:@"MusicSession"] whereKey:@"objectId" equalTo:objectID];
  
    self.handler = [[MusicSessionHandler alloc] init];
    self.subscription = [self.client subscribeToQuery:query withHandler:self.handler];

    
    [self.subscription addCreateHandler:^(PFQuery * query, PFObject * message) {
        NSLog(@"LQ!!");
    }];
    
//    [self.subscription addCreateHandler:^(PFQuery * _Nonnull query, PFObject * message) {
////        NSLog(@"LQ!!");
//    }];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
