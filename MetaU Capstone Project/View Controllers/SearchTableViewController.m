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

@end
