//
//  TrackViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/12/22.
//

#import "TrackViewController.h"

@interface TrackViewController ()

@end

@implementation TrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//
////
////  MusicSessionViewController.m
////  MetaU Capstone Project
////
////  Created by Rodjina Pierre Louis on 7/8/22.
////
//
//#import "MusicSessionViewController.h"
//#import "HomeViewController.h"
//#import "QueueTableViewController.h"
//#import "MusicSession.h"
//#import <SpotifyiOS/SpotifyiOS.h>
//#import <SpotifyiOS/SpotifyAppRemote.h>
//#import "SpotifyManager.h"
//#import "Track.h"
//#import "SearchTableViewController.h"
//#import "SessionTableViewController.h"
//#import "MessageCell.h"
//#import "UIImageView+AFNetworking.h"
//
//@import ParseLiveQuery;
//
//@interface MusicSessionViewController ()
//
//@property BOOL isPlaying;
//@property (nonatomic) NSInteger timestamp;
//@property (nonatomic, strong) NSString *accessToken;
//
//@property (nonatomic, strong) PFLiveQueryClient *client;
//@property (nonatomic, strong) PFQuery *query;
//@property (nonatomic, strong) PFLiveQuerySubscription *subscription;
//@property (nonatomic) NSInteger testCounter;
//@property (nonatomic, strong) IBOutlet UITableView *tableView;
//
//@end
//
//static const NSInteger MAX_SECONDS = 5;
//static const NSInteger MAX_MILISECONDS = MAX_SECONDS * 1000;
//
//NSString * const APPLICATION_ID = @"h0XnNsrye2OKPXScQlU43EYqgbjzpKHmSfstQXH3";
//NSString * const CLIENT_KEY = @"c2ervpUl9gZIkgVbx0ABEbrUkL4POF2hYA2CWH2k";
//NSString * const SERVER_URL = @"wss://musicsessionlog.b4a.io";
//
//@implementation MusicSessionViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.navigationItem.title = self.session.sessionName;
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    
//    self.navigationController.toolbarHidden = NO;
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//            selector:@selector(receiveNotification:)
//            name:@"playerStateChangeNotification"
//            object:nil];
//
//    self.accessToken = [[SpotifyManager shared] accessToken];
////    self.sessionNameLabel.text = self.session.sessionName;
////    self.sessionIDLabel.text = self.session.sessionCode;
//    self.isPlaying = YES;
//
//    [self querySetup];
////    [self updateView];
//
//    [MusicSession addUserToSession:self.session.sessionCode withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Error: %@", error.localizedDescription);
//            // TODO: Add Alert
//        } else {
//            NSLog(@"Sucessfully added user to session");
//        }
//    }];
//}
//
//- (void)receiveNotification:(NSNotification *)notification {
//    if ([[notification name] isEqualToString:@"playerStateChangeNotification"]) {
//        NSLog(@"Player State Change Notification Recived");
////        [self updateView];
//    }
//}
//
//- (void)testTimer { // Increments counter every second
//    [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                 target:self selector:@selector(testTimestamp:) userInfo:nil repeats:YES];
//}
//
//-  (void)testTimestamp:(NSTimer *)timer {
//
//    self.testCounter++;
//
//    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];
//
//    [query getObjectInBackgroundWithId:self.session.objectId
//                                 block:^(PFObject *session, NSError *error) {
//        PFUser *host = session[@"host"];
//
//        if ([PFUser.currentUser.objectId isEqual:host.objectId]) {
//            session[@"timestamp"] = @(self.testCounter);
//            [session saveInBackground];
//        }
//    }];
//}
//
//- (void)querySetup {
//    self.client = [[PFLiveQueryClient alloc] initWithServer:SERVER_URL applicationId:APPLICATION_ID clientKey:CLIENT_KEY];
//
//    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
//    self.subscription = [self.client subscribeToQuery:query];
//
//    __weak typeof(self) weakSelf = self;
//
//    // Called when subscribed
//    (void)[self.subscription addSubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
//        NSLog(@"Subscription Handler");
//    }];
//
//    // Called when unsubscribed
//    (void)[self.subscription addUnsubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
//        NSLog(@"Unsubscription Handler");
//    }];
//
//    // Called when query changes, object existed BEFORE
//    (void)[self.subscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
//        __strong typeof (self) strongSelf = weakSelf;
//
////        MusicSession *session = (MusicSession *)object;
//
//        NSLog(@"Update Handler");
//
////        dispatch_async(dispatch_get_main_queue(), ^{
////
////            strongSelf.sessionLogLabel.text = [NSString stringWithFormat:@"%@", session.activeUsers];
////            strongSelf.testLabel.text = [NSString stringWithFormat:@"%ld", (long)session.timestamp];
////
////            UIImage *playImage = [UIImage systemImageNamed:@"play.circle.fill"];
////            UIImage *stopImage = [UIImage systemImageNamed:@"stop.circle.fill"];
////
////            if (strongSelf.isPlaying) {
////                [strongSelf.playPauseButton setImage:stopImage forState:UIControlStateNormal];
////            } else {
////                [strongSelf.playPauseButton setImage:playImage forState:UIControlStateNormal];
////            }
////        });
//    }];
//
//    // Called when object created, object DID NOT exist
//    (void)[self.subscription addEnterHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
//        NSLog(@"Enter Handler");
//    }];
//
//    (void)[self.subscription addCreateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
//        NSLog(@"Create Handler");
//    }];
//
//    // Called when object deleted, object DID exist but now does NOT
//    (void)[self.subscription addLeaveHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
//        NSLog(@"Leave Handler");
//    }];
//
//    // Called if error occurs
//    (void)[self.subscription addErrorHandler:^(PFQuery<PFObject *> * _Nonnull query, NSError * _Nonnull error) {
//        NSLog(@"Error Handler: %@", error.localizedDescription);
//    }];
//}
//
//- (void)updateView {
//    NSLog(@"Update Called");
//
//    __weak typeof(self) weakSelf = self;
//    [[[[SpotifyManager shared] appRemote] playerAPI] getPlayerState:^(id<SPTAppRemotePlayerState> _Nullable result, NSError * _Nullable error) {
//
//        __strong typeof (self) strongSelf = weakSelf;
//
//        if (strongSelf == nil) {
//            NSLog(@"strongSelf NIL");
//            return;
//        }
//
//        if (error == nil) {
////            dispatch_async(dispatch_get_main_queue(), ^{
////                strongSelf.trackNameLabel.text = result.track.name;
////                strongSelf.artistLabel.text = [result.track.artist name];
////            });
//
//            [[[[SpotifyManager shared] appRemote] imageAPI] fetchImageForItem:result.track withSize:CGSizeZero callback:^(id  _Nullable result, NSError * _Nullable error) {
//
//                if (error != nil) {
//                    NSLog(@"Error: %@", error.localizedDescription);
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        strongSelf.coverArtImage.image = result;
//                    });
//                }
//            }];
//
//        } else {
//            NSLog(@"Error: %@", error.localizedDescription);
//        }
//    }];
//}
//
//- (IBAction)pressedThePlayButton:(id)sender {
//    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];
//
//    // if user presses play -> song plays -> update status on server -> update image based on server
//    // if the user presses stop -> song stops -> update status on seerver -> update image based on server
//
//    if (!self.isPlaying) {
//        self.isPlaying = YES;
//        [self playMusic];
//
//    } else {
//        self.isPlaying = NO;
//        [self stopMusic];
//    }
//
//    [query getObjectInBackgroundWithId:self.session.objectId
//                                 block:^(PFObject *session, NSError *error) {
//
//        PFUser *host = session[@"host"];
//
//        if ([PFUser.currentUser.objectId isEqual:host.objectId]) {
//            session[@"isPlaying"] = @(self.isPlaying);
//            [session saveInBackground];
//        }
//    }];
//}
//
//- (IBAction)pressedSkipButton:(id)sender {
//    [self skipMusic];
//}
//
//- (IBAction)pressedRewindButton:(id)sender {
//    [self rewindMusic];
//}
//
//- (void)playMusic {
//    [[SpotifyManager shared] startTrack];
//}
//
//- (void)stopMusic {
//    [[SpotifyManager shared] stopTrack];
//}
//
//- (void)skipMusic {
//    [[SpotifyManager shared] skipTrack];
//}
//
//- (void)rewindMusic {
//    [[SpotifyManager shared] rewindTrack];
//}
//
//- (NSString *)getInfo: (NSString *)objectId {
//    NSString *username;
//
//    PFQuery *query = [[PFUser query] whereKey:@"objectId" equalTo:objectId];
//    NSMutableArray *users = (NSMutableArray *)[query findObjects];
//    username = [users valueForKey:@"username"];
//
//    return username;
//}
//
//- (NSDictionary *)getDataFrom: (NSString *)targetUrl {
//    NSString *token = [[SpotifyManager shared] accessToken];
//    NSString *tokenType = @"Bearer";
//    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, token];
//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//
//    [request setValue:header forHTTPHeaderField:@"Authorization"];
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:targetUrl]];
//
//    __block NSDictionary *dataRecieved = [[NSDictionary alloc] init];
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
//      ^(NSData * _Nullable data,
//        NSURLResponse * _Nullable response,
//        NSError * _Nullable error) {
//
//        NSString *strISOLatin = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
//        NSData *dataUTF8 = [strISOLatin dataUsingEncoding:NSUTF8StringEncoding];
//        dataRecieved = [NSJSONSerialization JSONObjectWithData:dataUTF8 options:0 error:&error];
//
//        if (dataRecieved != nil) {
//            NSLog(@"Data: %@", dataRecieved);
//        } else {
//            NSLog(@"Error: %@", error);
//        }
//    }] resume];
//
//    return dataRecieved;
//}
//
//// CELL
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.session.playedTracks.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // if user added track -> sender, else reciever
//    
//    BOOL isSender = false;
//    
//    NSString *senderID = [[self.session.playedTracks valueForKey:@"addedBy"] valueForKey:@"objectId"][indexPath.row];
//    
//    if ([PFUser.currentUser.objectId isEqual:senderID]) {
//        isSender = true;
//    }
//    
//    NSString *CellIdentifier = isSender ? @"SenderTrackCell" : @"RecieverTrackCell";
//    
//    NSLog(@"%@", CellIdentifier);
//    // Displays Cells
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
//    NSArray *track = [self.session.playedTracks valueForKey:@"track"][indexPath.row];
//    
//    NSMutableArray *trackArtists = [track valueForKey:@"artist"];
//    NSString *stringOfArtists = @"";
//    
//    // Array of Artists -> Formatted String
//    for (NSString *name in trackArtists) {
//        if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
//            stringOfArtists = [stringOfArtists stringByAppendingString:name];
//        } else {
//            stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
//        }
//    }
//    
//    cell.trackNameLabel.text = [track valueForKey:@"name"];
//    cell.trackArtistLabel.text = stringOfArtists;
//    
//    // Track Cover Art
//    NSString *imageURL = [track valueForKey:@"images"][0];
//    
//    NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
//    cell.coverArtImage.image = nil;
//    [cell.coverArtImage setImageWithURL:albumURL];
//    
//    
//    cell.coverArtImage.layer.cornerRadius = 10;
//    cell.coverArtImage.clipsToBounds = YES;
//    
//    cell.messageBGImage.layer.cornerRadius = 15;
//    cell.messageBGImage.clipsToBounds = YES;
//    
//    return cell;
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier  isEqual: @"queueSegue"]) {
//        MusicSession *dataToPass = self.session;
//        QueueTableViewController *queueVC = [segue destinationViewController];
//        queueVC.session = dataToPass;
//    } else if ([segue.identifier  isEqual: @"searchSegue"]) {
//        MusicSession *dataToPass = self.session;
//        SearchTableViewController *searchVC = [segue destinationViewController];
//        searchVC.session = dataToPass;
////    }  else if ([segue.identifier  isEqual: @"testSegue"]) {
////        MusicSession *dataToPass = self.session;
////        SessionTableViewController *sessionVC = [segue destinationViewController];
////        sessionVC.session = dataToPass;
//    }
//}
//
//- (IBAction)pressedLeaveSession:(id)sender {
//    PFQuery *query = [PFQuery queryWithClassName:@"MusicSession"];
//
//    [MusicSession removeUserFromSession:self.session.sessionCode user:[PFUser currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            [self.client unsubscribeFromQuery:query];
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            NSLog(@"Error: %@", error.localizedDescription);
//        }
//    }];
//}
//
//@end
//
@end