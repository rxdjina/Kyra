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

    self.accessToken = [[SpotifyManager shared] accessToken];
    self.isPlaying = YES;
    self.currentlyPlaying = (NSDictionary *)self.session.currentlyPlaying;

    [self querySetup];

    [MusicSession addUserToSession:self.session.sessionCode withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Add Alert
        } else {
            NSLog(@"Sucessfully added user to session");
        }
    }];
    
    NSMutableArray *arrayOftrackURI = [[NSMutableArray alloc] init];
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"playerStateChangeNotification"]) {
        NSLog(@"Player State Change Notification Recived");
        self.currentlyPlaying = [[SpotifyManager shared] getCurrentTrack];
        
        [MusicSession updateCurrentlyPlaying:self.session.sessionCode track:self.currentlyPlaying withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error Updating Currently Playing: %@", error.localizedDescription);
            }
        }];
        
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

- (void)testTimer { // Increments counter every second
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                 target:self selector:@selector(testTimestamp:) userInfo:nil repeats:YES];
}

-  (void)testTimestamp:(NSTimer *)timer {

    self.testCounter++;

    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query getObjectInBackgroundWithId:self.session.objectId
                                 block:^(PFObject *session, NSError *error) {
        PFUser *host = session[@"host"];

        if ([PFUser.currentUser.objectId isEqual:host.objectId]) {
            session[@"timestamp"] = @(self.testCounter);
            [session saveInBackground];
        }
    }];
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
            [strongSelf updateView];
            [strongSelf loadPlayedTracks];
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
    NSLog(@"Update Called");
    
    self.currentlyPlayingNameLabel.text = [self.currentlyPlaying valueForKey:@"name"];
    
    NSString *trackArtists = [self.currentlyPlaying valueForKey:@"artist"];
    self.currentlyPlayingArtistLabel.text = trackArtists;
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
        if (succeeded) {
            [self.client unsubscribeFromQuery:query];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"queueSegue"]) {
        MusicSession *dataToPass = self.session;
        QueueTableViewController *queueVC = [segue destinationViewController];
        queueVC.session = dataToPass;
    } else if ([segue.identifier  isEqual: @"searchSegue"]) {
        MusicSession *dataToPass = self.session;
        SearchTableViewController *searchVC = [segue destinationViewController];
        searchVC.session = dataToPass;
    }  else if ([segue.identifier  isEqual: @"trackViewSegue"]) {
        MusicSession *sessionToPass = self.session;
        NSDictionary *trackToPass = self.currentlyPlaying;
        TrackViewController *trackVC = [segue destinationViewController];
        trackVC.session = sessionToPass;
        trackVC.track = trackToPass;
    }
}

@end
