//
//  Session.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "Parse/Parse.h"
#import "SpotifyiOS/SpotifyiOS.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicSession : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *sessionCode;
@property (nonatomic, strong) PFUser *creator;
@property (nonatomic, strong) PFUser *host;
@property (nonatomic, strong) NSMutableArray *log;
@property (nonatomic, strong) NSMutableArray *activeUsers;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) NSMutableArray *queue;

// Settings?
@property (nonatomic) BOOL *allowExplicit;
@property (nonatomic, strong) NSString *sessionName;

+ (MusicSession *) createSession: ( NSString * )sessionName withCompletion: (PFBooleanResultBlock _Nullable)completion;
+ (void) joinSession: ( NSString * )sessionID withCompletion: (PFBooleanResultBlock _Nullable)completion;
+ (void) addUserToSession: ( NSString * )sessionCode withCompletion: (PFBooleanResultBlock _Nullable)completion;
+ (void)removeUserFromSession:(NSString *)sessionCode user: ( PFUser * )user withCompletion: (PFBooleanResultBlock _Nullable) completion;
+ (void)updateSessionLog: ( NSString * )sessionCode decription:( NSString * )message withCompletion: (PFBooleanResultBlock _Nullable) completion;
+ (void)addToQueue: ( NSString * )sessionCode track:( NSDictionary * )trackInfo withCompletion: ( PFBooleanResultBlock _Nullable ) completion;
@end

NS_ASSUME_NONNULL_END
