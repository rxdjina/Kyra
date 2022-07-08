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

static const NSInteger lengthID = 6;

+ (nonnull NSString *)parseClassName {
    return @"MusicSession";
}

+ (MusicSession *) createSession: ( NSString * )sessionName withCompletion: (PFBooleanResultBlock  _Nullable)completion; {
    
    MusicSession *newSession = [MusicSession new];
    newSession.sessionCode = [self createSessionId];
    newSession.creator = [PFUser currentUser];
    newSession.sessionName = sessionName;

    [newSession saveInBackgroundWithBlock: completion];
    
    NSLog(@"%@", newSession.sessionCode);
    
    // Return
//    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
//
//    [query getObjectInBackgroundWithId:newSession.sessionID block:^(PFObject *parseObject, NSError *error) {
//        NSLog(@"%@", parseObject);
//    }];
    
    return newSession;
}

+ (NSString *)createSessionId {
    NSString *characters = @"123456789ABCDEFGHIJKLMNOPQRSTUVWYZ";
    NSMutableString *randomCode = [NSMutableString stringWithCapacity:lengthID];
        
    for (int i = 0; i < lengthID; i++) {
        [randomCode appendFormat:@"%C", [characters characterAtIndex:(arc4random() % characters.length)]];
    }
        
    return randomCode;
}



@end
