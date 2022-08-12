//
//  QueueTableViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/7/22.
//

#import "QueueTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SpotifyManager.h"
#import "MusicSession.h"
#import "Parse/Parse.h"
#import "TrackCell.h"
#import "Track.h"

@interface QueueTableViewController ()

@property (strong, nonatomic) NSArray *queue;

@end

NSString * const GET_TRACK_URL = @"https://api.spotify.com/v1/tracks/";

@implementation QueueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadQueue) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self loadQueue];
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadQueue {
    PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
       if (session) {
           self.queue = [session[0] valueForKey:@"queue"];
           [self.tableView reloadData];
       }
       else {
           NSLog(@"Error getting session: %@", error.localizedDescription);
       }
        [self.refreshControl endRefreshing];
    }];
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

// Cells and Cell customization
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    NSArray *track = [self.queue valueForKey:@"track"][indexPath.row];
    
    NSString *trackURI = [track valueForKey:@"URI"];
    NSString *trackID = [trackURI substringFromIndex:14];
    
    NSMutableArray *trackArtists = [[track valueForKey:@"artists"] valueForKey:@"name"];
    NSString *stringOfArtists = @"";
    
    // Array of Artists -> Formatted String
    for (NSString *name in trackArtists) {
        if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
            stringOfArtists = [stringOfArtists stringByAppendingString:name];
        } else {
            stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
        }
    }
    
    NSDictionary *user = [self.queue valueForKey:@"addedBy"];

    cell.trackNameLabel.text = [track valueForKey:@"name"];
    cell.artistLabel.text = stringOfArtists;
    
    NSString *targetURL = [NSString stringWithFormat:@"%@%@", GET_TRACK_URL, trackID];
    __block NSString *imageURL;
    
    [[SpotifyManager shared] retriveDataFrom:targetURL result:^(NSDictionary * _Nonnull dataRevieved) {
        
        // [0] -> 640x640
        // [1] -> 300x300
        // [2] -> 30x30

        imageURL = [[[dataRevieved valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"][1];
        NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.coverArtImage.image = nil;
            [cell.coverArtImage setImageWithURL:albumURL];
        });
    }];
    
    return cell;
}

@end

