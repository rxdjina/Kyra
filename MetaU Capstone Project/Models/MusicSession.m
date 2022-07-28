//
//  Session.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import <Foundation/Foundation.h>
#import "MusicSession.h"
#import "Parse/Parse.h"

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

@end
