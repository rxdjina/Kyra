//
//  SceneDelegate.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/5/22.
//

#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "SpotifyManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = [[URLContexts allObjects] firstObject].URL;
    
        if (url != nil) {
            [[[SpotifyManager shared] sessionManager] application:[UIApplication sharedApplication] openURL:url options:[NSMutableDictionary dictionary]];
        }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (PFUser.currentUser) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticatedViewController"];
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
}


- (void)sceneWillResignActive:(UIScene *)scene {
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    [[[UIApplication sharedApplication] delegate] applicationWillEnterForeground: [UIApplication sharedApplication]];
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    [[[UIApplication sharedApplication] delegate] applicationDidEnterBackground: [UIApplication sharedApplication]];
}


@end
