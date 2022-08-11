//
//  QueueTableViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/7/22.
//

#import "QueueTableViewController.h"
#import "MusicSession.h"
#import "Parse/Parse.h"

@interface QueueTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *queue;

@end

@implementation QueueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.dataSource = self;
    
    [self loadQueue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadQueue {
       PFQuery *query = [[MusicSession query] whereKey:@"sessionCode" equalTo:self.session.sessionCode];

       [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable session, NSError * _Nullable error) {
           if (session) {
              self.queue = [session[0] valueForKey:@"queue"];
           }
           else {
               NSLog(@"Error getting session: %@", error.localizedDescription);
           }
       }];
}

@end

