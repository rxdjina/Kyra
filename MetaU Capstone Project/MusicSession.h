//
//  Session.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicSession : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *sessionCode;
@property (nonatomic, strong) PFUser *creator;

// Settings?
@property (nonatomic) BOOL *allowExplicit;
@property (nonatomic, strong) NSString *sessionName;

+ (MusicSession *) createSession: ( NSString * )sessionName withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) joinSession: ( NSString * )sessionID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
