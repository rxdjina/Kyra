//
//  Session.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import <Foundation/Foundation.h>
#import "MusicSession.h"
#import "Parse/Parse.h"
#import "SpotifyManager.h"
#import "SpotifyiOS/SpotifyiOS.h"

@implementation MusicSession

@dynamic sessionID;
@dynamic userID;
@dynamic sessionCode;
@dynamic creator;
@dynamic allowExplicit;
@dynamic sessionName;
@dynamic host;
@dynamic activeUsers;
@dynamic log;
@dynamic isActive;
@dynamic isPlaying;
@dynamic timestamp;
@dynamic queue;
@dynamic playedTracks;
@dynamic currentlyPlaying;

static const NSUInteger LENGTH_ID = 6;

+ (nonnull NSString *)parseClassName {
    return @"MusicSession";
}

+ (MusicSession *) createSession: ( NSString * )sessionName withCompletion: (PFBooleanResultBlock  _Nullable)completion; {
    MusicSession *newSession = [MusicSession new];
    newSession.sessionCode = [self createSessionId];
    newSession.creator = [PFUser currentUser];
    newSession.sessionName = sessionName;
    newSession.isActive = YES;
    newSession.host = [PFUser currentUser];
    newSession.isPlaying = NO;
    newSession.timestamp = @(0);
    
    // Active Users
    NSMutableArray *users = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser], nil];
    newSession.activeUsers = users;

    // Log
    NSString *logMessage = [NSString stringWithFormat:@"Created a session named %@", newSession.sessionName];
    NSString *date = [MusicSession getDateString];

    NSDictionary *task = @{
        @"date" : date,
        @"user" : PFUser.currentUser.username,
        @"description" : logMessage
    };

    newSession.log = (NSMutableArray *)@[task];

    // Queue
//    [[[SpotifyManager shared] appRemote] pla]
//    task = @{
//        @"trackName" : track.name,
//        @"trackArtist" : track.artist,
//        @"trackURI" : track.URI,
//        @"addedBy" : user
//    };
    
    newSession.queue = [NSMutableArray new];
    
    [newSession saveInBackgroundWithBlock: completion];
    
    return newSession;
}

+ (NSString *)createSessionId {
    NSString *characters = @"123456789ABCDEFGHIJKLMNOPQRSTUVWYZ";
    NSMutableString *randomCode = [NSMutableString stringWithCapacity:LENGTH_ID];
        
    for (int i = 0; i < LENGTH_ID; i++) {
        [randomCode appendFormat:@"%C", [characters characterAtIndex:(arc4random() % characters.length)]];
    }
        
    return randomCode;
}

+ (void)addUserToSession:(NSString *)sessionCode withCompletion: (PFBooleanResultBlock _Nullable) completion {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session.count > 0) {
            NSMutableArray *users = [session[0] valueForKey:@"activeUsers"];
            
            [users addObject:[PFUser currentUser]];
            [session setValue:users forKey:@"activeUsers"];
            
            [MusicSession updateSessionLog:sessionCode decription:@"Joined session" withCompletion:^(BOOL succeeded, NSError * error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    NSLog(@"%@ added to session successfully", PFUser.currentUser.username);
                }
            }];
            
            [PFObject saveAllInBackground:session];
        }
        else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (void)removeUserFromSession:(NSString *)sessionCode user: ( PFUser * )user withCompletion: (PFBooleanResultBlock _Nullable) completion {
    
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session.count > 0) {
            NSMutableArray *users = [session[0] valueForKey:@"activeUsers"];
            
            
            if (users.count > 1) {
                // TODO: If user was host, assign new host
                NSLog(@"[%lu] %@", (unsigned long)users.count, users);
                
                NSInteger *count = @(0);

                [users removeObjectIdenticalTo:user.objectId];
                NSLog(@"[%lu] %@", (unsigned long)users.count, users);
                [session setValue:users forKey:@"activeUsers"];
                
                [MusicSession updateSessionLog:sessionCode decription:@"Left session" withCompletion:^(BOOL succeeded, NSError * error) {
                    if (error != nil) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    } else {
                        NSLog(@"%@ left session successfully", PFUser.currentUser.username);
                    }
                }];
                
            } else if (users.count == 1) {
                NSLog(@"One user left");
                // TODO: Close session
            }
            
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (void)updateSessionLog: ( NSString * )sessionCode decription:( NSString * )message withCompletion: (PFBooleanResultBlock _Nullable) completion {
    
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];
    NSString *date = [MusicSession getDateString];
    
    NSDictionary *task = @{
        @"date" : date,
        @"user" : PFUser.currentUser.username,
        @"description" : message
    };
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            NSMutableArray *log = [session[0] valueForKey:@"log"];

            [log addObject:task];
            [session setValue:log forKey:@"log"];
            
            [PFObject saveAllInBackground:session];
        }
        else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (NSString *)getDateString {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss a"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

+ (void)addToQueue: ( NSString * )sessionCode track:( NSDictionary * )trackInfo withCompletion: ( PFBooleanResultBlock _Nullable ) completion {
 
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];
    PFUser *user = [PFUser currentUser];

    NSDictionary *task = @{
        @"track" : trackInfo,
        @"addedBy" : user
    };

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            NSMutableArray *queue = [session[0] valueForKey:@"queue"];

            [queue addObject:task];
            [session setValue:queue forKey:@"queue"];
            
            NSString *logDescription = [NSString stringWithFormat:@"Added %@ by %@ to queue", trackInfo[@"name"], trackInfo[@"artist"]];
            
            [MusicSession updateSessionLog:sessionCode decription:logDescription withCompletion:^(BOOL succeeded, NSError * error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
            
            [PFObject saveAllInBackground:session];
        }
        else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (void)removeFromQueue: ( NSString * )sessionCode index:( NSInteger )trackIndex withCompletion: ( PFBooleanResultBlock _Nullable ) completion {
 
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session.count > 0) {
            NSMutableArray *queue = [session[0] valueForKey:@"queue"];;
            
            if (queue.count > 1) {
                [queue removeObjectAtIndex:trackIndex];
                [session[0] setValue:queue forKey:@"queue"];
                
                [PFObject saveAllInBackground:session];
                
            } else if (queue.count == 1) {
                NSLog(@"One song left");
                // TODO: Add Recommendations
            }
            
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (void)addToPlayedTracks: ( NSString * )sessionCode track:(NSDictionary *)trackInfo withCompletion: ( PFBooleanResultBlock _Nullable ) completion {
    
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];

    NSDictionary *task = @{
        @"track" : trackInfo,
        @"addedBy" : PFUser.currentUser
    };
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            NSMutableArray *track = [session[0] valueForKey:@"queue"][0];
            NSMutableArray *playedTracks = [session[0] valueForKey:@"playedTracks"];

            [playedTracks addObject:task];
            [session setValue:playedTracks forKey:@"playedTracks"];
            
            if ([[track valueForKey:@"URI"] isEqual:[trackInfo valueForKey:@"URI"]]) {
                [MusicSession removeFromQueue:sessionCode index:0 withCompletion:nil];
            }
            
            [PFObject saveAllInBackground:session];
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

+ (void)updateCurrentlyPlaying: ( NSString * )sessionCode track:( NSDictionary * )trackInfo withCompletion: ( PFBooleanResultBlock _Nullable ) completion {
 
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:sessionCode];
    PFUser *user = [PFUser currentUser];

    NSDictionary *task = @{
        @"track" : trackInfo,
        @"addedBy" : user
    };

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            NSMutableArray *queue = [session[0] valueForKey:@"queue"];
            NSString *nextInQueueURI = [[queue valueForKey:@"track"] valueForKey:@"URI"][0];
            
            NSMutableArray *currentlyPlaying = [session[0] valueForKey:@"currentlyPlaying"];
            NSString *currentlyPlayingURI = [[currentlyPlaying valueForKey:@"track"] valueForKey:@"URI"];
            
            NSMutableArray *newTrack = [[NSMutableArray alloc] init];

            if ([nextInQueueURI isEqualToString:currentlyPlayingURI]) {
                [MusicSession removeFromQueue:sessionCode index:0 withCompletion:nil];
                [newTrack addObject:queue[0]];
            } else {
                [newTrack addObject:task];
            }
            
            [session setValue:newTrack forKey:@"currentlyPlaying"];
            
            NSString *logDescription = [NSString stringWithFormat:@"New track \n Now playing %@ by %@", trackInfo[@"name"], trackInfo[@"artist"]];
            
            [MusicSession updateSessionLog:sessionCode decription:logDescription withCompletion:^(BOOL succeeded, NSError * error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
            
            [PFObject saveAllInBackground:session];
        }
        else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

@end
