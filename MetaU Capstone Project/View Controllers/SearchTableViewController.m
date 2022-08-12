//
//  SearchTableViewController.m
//  Pods
//
//  Created by Rodjina Pierre Louis on 8/11/22.
//

#import "SearchTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SpotifyiOS/SpotifyiOS.h"
#import "SpotifyManager.h"
#import "TrackCell.h"

@interface SearchTableViewController ()

@property (strong, nonatomic) NSDictionary *searchResults;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    [self loadSearchResults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadSearchResults {
    [[SpotifyManager shared] searchTrack:self.searchBar.text type:@"track" result:^(NSDictionary * _Nonnull dataRecieved) {
        self.searchResults = [dataRecieved valueForKey:@"tracks"];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self performSelector:@selector(loadSearchResults) withObject:searchText afterDelay:0.5];
    [self.tableView reloadData];
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

// Cells and Cell customization
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TrackCell"];
    }
    
    // tracks -> items -> [0, k]
    NSArray *track = [self.searchResults valueForKey:@"items"][indexPath.row];
    
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

    cell.trackNameLabel.text = [track valueForKey:@"name"];
    cell.artistLabel.text = stringOfArtists;

    // Track Cover Art
    NSString *imageURL = [[[track valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"][1];
    
    NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
    cell.coverArtImage.image = nil;
    [cell.coverArtImage setImageWithURL:albumURL];

    return cell;
}

// Swipe Gesture
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Track Details
    NSArray *track = [self.searchResults valueForKey:@"items"][indexPath.row];
    
    NSString *trackName = [track valueForKey:@"name"];
    NSString *trackURI = [track valueForKey:@"uri"];
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
    NSString *trackAlbum = [[track valueForKey:@"album"] valueForKey:@"name"];
    NSString *imageURL = [[[track valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"];

    // Swipe Gestures
    UIContextualAction *addToQueueAction = [UIContextualAction contextualActionWithStyle:normal title:@"add" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        NSDictionary *trackDetails = @{
            @"name" : trackName,
            @"URI" : trackURI,
            @"artist" : trackArtists,
            @"album" : trackAlbum,
            @"images" : imageURL
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MusicSession addToQueue:self.session.sessionCode track:trackDetails withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    NSLog(@"%@ added to queue", trackName);
                }
            }];
        });
        
        completionHandler(YES);
    }];
    
    addToQueueAction.backgroundColor = [UIColor colorWithRed: 0.71 green: 0.87 blue: 0.64 alpha: 1.00];
    addToQueueAction.image = [UIImage systemImageNamed:@"plus"];
    
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[addToQueueAction]];
    
    swipeActions.performsFirstActionWithFullSwipe = false;
    
    return swipeActions;
}

@end
