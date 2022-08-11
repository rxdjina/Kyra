//
//  QueueTableViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/7/22.
//

#import <UIKit/UIKit.h>
#import "MusicSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MusicSession *session;

@end

NS_ASSUME_NONNULL_END
