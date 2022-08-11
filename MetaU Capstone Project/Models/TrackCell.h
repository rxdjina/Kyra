//
//  TrackCell.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *coverArtImage;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;


@end

NS_ASSUME_NONNULL_END
