//
//  SearchTableViewController.h
//  Pods
//
//  Created by Rodjina Pierre Louis on 8/11/22.
//

#import <UIKit/UIKit.h>
#import "MusicSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchTableViewController : UITableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) MusicSession *session;
@property (nonatomic) BOOL isHost;
@end

NS_ASSUME_NONNULL_END
