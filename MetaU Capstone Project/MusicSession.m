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

static const NSUInteger LENGTH_ID = 6;

+ (nonnull NSString *)parseClassName {
    return @"MusicSession";
}

+ (MusicSession *) createSession: ( NSString * )sessionName withCompletion: (PFBooleanResultBlock  _Nullable)completion; {
    
    MusicSession *newSession = [MusicSession new];
    newSession.sessionCode = [self createSessionId];
    newSession.creator = [PFUser currentUser];
    newSession.sessionName = sessionName;

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

@end
