//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"
#import "HomeViewController.h"
#import "QueueTableViewController.h"
#import "MusicSession.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import <SpotifyiOS/SpotifyAppRemote.h>
#import "SpotifyManager.h"
#import "Track.h"
#import "SearchTableViewController.h"
#import "MessageCell.h"
#import "UIImageView+AFNetworking.h"
#import "TrackViewController.h"

@import ParseLiveQuery;

@interface MusicSessionViewController ()

@property BOOL isPlaying;
@property (nonatomic) BOOL isHost;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) PFLiveQueryClient *client;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;
@property (nonatomic) NSInteger testCounter;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *currentlyPlaying;
@property (nonatomic, strong) NSDictionary *previouslyPlaying;

@end

static const NSInteger MAX_SECONDS = 5;
static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;

NSString * const APPLICATION_ID = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
NSString * const CLIENT_KEY = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
NSString * const SERVER_URL = @"wss://musicsessionlog.b4a.io";

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.session.sessionName;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationController.toolbarHidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"playerStateChangeNotification"
            object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"playPauseNotification"
            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"rewindNotification"
            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"skipNotification"
            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"newTrackNotification"
            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"playRequestNotification"
            object:nil];

    self.accessToken = [[SpotifyManager shared] accessToken];
    
    [self querySetup];

    [MusicSession addUserToSession:self.session.sessionCode withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Add Alert
        } else {
            NSLog(@"Sucessfully added user to session");
        }
    }];
    
    if ([[self.session.host valueForKey:@"objectId"] isEqualToString:PFUser.currentUser.objectId]) {
        self.isHost = YES;
    } else {
        self.isHost = NO;
    }
    
    self.currentlyPlaying = [[SpotifyManager shared] getCurrentTrack];
    NSLog(@"CURRENT IN MS: %@", self.currentlyPlaying);
    
    if (self.isHost) {
        self.isPlaying = [[SpotifyManager shared] getPlayerStatus];
        [MusicSession updateIsPlaying:self.session.sessionCode status:self.isPlaying withCompletion:nil];

        self.timestamp = [[SpotifyManager shared] getCurrentTrackTimestamp];
        [MusicSession updateTimestamp:self.session.sessionCode timestamp:self.timestamp withCompletion:nil];
        
        [self testTimer];
    } else {
        self.isPlaying = self.session.isPlaying;
        self.currentlyPlaying = (NSDictionary *)self.session.currentlyPlaying;

        if (self.isPlaying) {
            self.timestamp = self.session.timestamp;
            NSLog(@"Playing %@ @ timestamp: %ld", [self.currentlyPlaying valueForKey:@"name"], (long)self.timestamp);
            
            NSString *contextURI = [[self.currentlyPlaying valueForKey:@"track"] valueForKey:@"contextURI"][0];

            if (contextURI == nil) {
                contextURI = [self.currentlyPlaying valueForKey:@"contextURI"];
            }

            [[SpotifyManager shared] playTrackAtTimestamp:contextURI timestamp:self.timestamp result:^(NSDictionary * _Nonnull results) {
                NSLog(@"RESULTS: %@", results);
            }];
        }
    }
    
    [self querySetup];

    [MusicSession addUserToSession:self.session.sessionCode withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Add Alert
        } else {
            NSLog(@"Sucessfully added user to session");
        }
    }];
    
    self.updateNotificationButton.hidden = YES;
    [self notificationBanner:@"This is a test"];
}
- (void)notificationBanner:(NSString *)bannerText{
    [self.updateNotificationButton setTitle:bannerText forState:UIControlStateNormal];

    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self selector:@selector(bannerAnimationUp) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                 target:self selector:@selector(bannerAnimationDown) userInfo:nil repeats:NO];
}

- (void)bannerAnimationUp {
    self.updateNotificationButton.hidden = NO;
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger  x = width / 2;
    
    NSInteger buttonWidth = self.updateNotificationButton.intrinsicContentSize.width;

    self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 60, buttonWidth, 31);
    [UIView animateWithDuration:0.25 animations:^{
        self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 80, buttonWidth, 31);
    }];
}

- (void)bannerAnimationDown {
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger  x = width / 2;
    NSInteger buttonWidth = self.updateNotificationButton.intrinsicContentSize.width;

    self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 80, buttonWidth, 31);

    [UIView animateWithDuration:0.15 animations:^{
        self.updateNotificationButton.frame = CGRectMake(x - (buttonWidth / 2), 60, buttonWidth, 31);
    } completion:^(BOOL finished) {
        if (finished) {
            self.updateNotificationButton.hidden = YES;
        }
    }];
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"playerStateChangeNotification"]) {
        NSLog(@"Player State Change Notification Recived");

        if (self.isHost) {
            self.currentlyPlaying = [[SpotifyManager shared] getCurrentTrack];

            [MusicSession updateCurrentlyPlaying:self.session.sessionCode track:self.currentlyPlaying withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error Updating Currently Playing: %@", error.localizedDescription);
                }
            }];
        }
        
        [self updateView];
    } else if ([[notification name] isEqualToString:@"playPauseNotification"]) {
        NSLog(@"Play Pause Notification Recived");
        // TODO: Display yes/no alert
        
    } else if ([[notification name] isEqualToString:@"rewindNotification"]) {
        NSLog(@"Rewind Notification Recived");
        // TODO: Display yes/no alert
        
    } else if ([[notification name] isEqualToString:@"skipNotification"]) {
        NSLog(@"Skip Change Notification Recived");
        // TODO: Display yes/no alert
    } else if ([[notification name] isEqualToString:@"newTrackNotification"]) {
        NSLog(@"New Track Notification Recived");
        
        if (self.isHost) {
            self.previouslyPlaying = [[SpotifyManager shared] getPreviousTrack];
        
            if (self.previouslyPlaying != nil) {
                [MusicSession addToPlayedTracks:self.session.sessionCode track:self.previouslyPlaying withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil){
                        NSLog(@"Error adding to played tracks: %@", error.localizedDescription);
                    }
                }];
            }
        }
    }
}

- (void)testTimer {
    [NSTimer scheduledTimerWithTimeInterval:5.0f
                                 target:self selector:@selector(updateServerTimestamp) userInfo:nil repeats:YES];
}

-  (void)updateServerTimestamp {
    self.timestamp = [[SpotifyManager shared] getCurrentTrackTimestamp];

    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];
    if (self.isHost) {
    [query getObjectInBackgroundWithId:self.session.objectId
                                 block:^(PFObject *session, NSError *error) {

        session[@"timestamp"] = @(self.timestamp);
        [session saveInBackground];
    }];
    }
}

- (void)querySetup {
    self.client = [[PFLiveQueryClient alloc] initWithServer:SERVER_URL applicationId:APPLICATION_ID clientKey:CLIENT_KEY];

    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
    self.subscription = [self.client subscribeToQuery:query];

    __weak typeof(self) weakSelf = self;

    // Called when subscribed
    (void)[self.subscription addSubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"Subscription Handler");
    }];

    // Called when unsubscribed
    (void)[self.subscription addUnsubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"Unsubscription Handler");
    }];

    // Called when query changes, object existed BEFORE
    (void)[self.subscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        __strong typeof (self) strongSelf = weakSelf;
        NSLog(@"Update Handler");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!strongSelf.isHost) {
                [strongSelf updateCurrentlyPlaying];
            }
            
            [strongSelf updateView];
            [strongSelf loadPlayedTracks];
            [strongSelf updatePlayerStatus];
            [strongSelf.tableView reloadData];
        });
    }];

    // Called when object created, object DID NOT exist
    (void)[self.subscription addEnterHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Enter Handler");
    }];

    (void)[self.subscription addCreateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Create Handler");
    }];

    // Called when object deleted, object DID exist but now does NOT
    (void)[self.subscription addLeaveHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"Leave Handler");
    }];

    // Called if error occurs
    (void)[self.subscription addErrorHandler:^(PFQuery<PFObject *> * _Nonnull query, NSError * _Nonnull error) {
        NSLog(@"Error Handler: %@", error.localizedDescription);
    }];
}

- (void)updateView {
    NSString *trackName = @"";
    NSString *stringOfArtists = @"";
    NSString *trackURI = @"";
    
    trackName = [[self.currentlyPlaying valueForKey:@"track"] valueForKey:@"name"][0];
    
    if (trackName == nil) {
        trackName = [self.currentlyPlaying valueForKey:@"name"];
    }
    
    NSMutableArray *trackArtists = [[self.currentlyPlaying valueForKey:@"track"] valueForKey:@"artist"];
    
    if (trackArtists.count == 0) {
        stringOfArtists = [self.currentlyPlaying valueForKey:@"artist"];
        // Array of Artists -> Formatted String
        for (NSString *name in trackArtists) {
            if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
                stringOfArtists = [stringOfArtists stringByAppendingString:name];
            } else {
                stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
            }
        }
    } else {
        // Array of Artists -> Formatted String
        for (NSString *name in trackArtists) {
            if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
                stringOfArtists = [stringOfArtists stringByAppendingString:name];
            } else {
                stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
            }
        }
    }
    
    trackURI = [[self.currentlyPlaying valueForKey:@"track"] valueForKey:@"URI"][0];
    
    if (trackURI == nil) {
        trackURI = [self.currentlyPlaying valueForKey:@"URI"];
    }
    
    NSString *trackID = [trackURI substringFromIndex:14];
    
    NSString *targetURL = [NSString stringWithFormat:@"https://api.spotify.com/v1/tracks/%@", trackID];
    __block NSString *imageURL;
    
    [[SpotifyManager shared] retriveDataFrom:targetURL result:^(NSDictionary * _Nonnull dataRevieved) {
        imageURL = [[[dataRevieved valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"][2];
        NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentlyPlayingNameLabel.text = trackName;
            self.currentlyPlayingArtistLabel.text = stringOfArtists;
            self.currentlyPlayingCoverArtImage.image = nil;
            [self.currentlyPlayingCoverArtImage setImageWithURL:albumURL];
        });
    }];
}

- (NSString *)getInfo: (NSString *)objectId {
    NSString *username;

    PFQuery *query = [[PFUser query] whereKey:@"objectId" equalTo:objectId];
    NSMutableArray *users = (NSMutableArray *)[query findObjects];
    username = [users valueForKey:@"username"];

    return username;
}

- (void)loadPlayedTracks {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            self.session.playedTracks = [session[0] valueForKey:@"playedTracks"];

        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

- (void)updatePlayerStatus {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            self.session.isPlaying = [session[0] valueForKey:@"isPlaying"];
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

- (void)updateTimestamp {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            self.timestamp = (NSInteger)[session[0] valueForKey:@"timestamp"];
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

- (void)updateCurrentlyPlaying {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
        if (session) {
            self.currentlyPlaying = [session[0] valueForKey:@"currentlyPlaying"];
        } else {
            NSLog(@"Error getting session: %@", error.localizedDescription);
        }
    }];
}

// CELL
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.session.playedTracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isSender = false;
    
    NSString *senderID = [[self.session.playedTracks valueForKey:@"addedBy"] valueForKey:@"objectId"][indexPath.row];
    
    if ([PFUser.currentUser.objectId isEqual:senderID]) {
        isSender = true;
    }
    
    NSString *CellIdentifier = isSender ? @"SenderTrackCell" : @"RecieverTrackCell";
    
    // Displays Cells
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSArray *track = [self.session.playedTracks valueForKey:@"track"][indexPath.row];
    
    NSMutableArray *trackArtists = [track valueForKey:@"artist"];
    NSString *stringOfArtists = @"";
    
    // Array of Artists -> Formatted String
    for (NSString *name in trackArtists) {
        if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
            stringOfArtists = [stringOfArtists stringByAppendingString:name];
        } else {
            stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
        }
    }
    
    cell.trackNameLabel.text = [track valueForKey:@"name"];
    cell.trackArtistLabel.text = stringOfArtists;
    
    // Track Cover Art
    NSString *imageURL = [track valueForKey:@"images"][0];
    
    NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
    cell.coverArtImage.image = nil;
    [cell.coverArtImage setImageWithURL:albumURL];
    
    
    cell.coverArtImage.layer.cornerRadius = 10;
    cell.coverArtImage.clipsToBounds = YES;
    
    cell.messageBGImage.layer.cornerRadius = 15;
    cell.messageBGImage.clipsToBounds = YES;
    
    return cell;
}

- (IBAction)pressedLeaveSession:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];

    [MusicSession removeUserFromSession:self.session.sessionCode user:[PFUser currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    [self.client unsubscribeFromQuery:query];
    [[[[SpotifyManager shared] appRemote] playerAPI] pause:nil];
    [[[SpotifyManager shared] appRemote] disconnect];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"queueSegue"]) {
        MusicSession *dataToPass = self.session;
        QueueTableViewController *queueVC = [segue destinationViewController];
        queueVC.session = dataToPass;
        queueVC.isHost = self.isHost;
    } else if ([segue.identifier  isEqual: @"searchSegue"]) {
        MusicSession *dataToPass = self.session;
        SearchTableViewController *searchVC = [segue destinationViewController];
        searchVC.session = dataToPass;
        searchVC.isHost = self.isHost;
    }  else if ([segue.identifier  isEqual: @"currentlyPlayingSegue"]) {
        MusicSession *sessionToPass = self.session;
        NSDictionary *trackToPass = self.currentlyPlaying;
        TrackViewController *trackVC = [segue destinationViewController];
        trackVC.session = sessionToPass;
        trackVC.track = trackToPass;
    }
}

@end
