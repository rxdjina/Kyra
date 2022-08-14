//
//  MessageCell.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UIImageView *messageBGImage;
@property (strong, nonatomic) IBOutlet UIImageView *coverArtImage;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackArtistLabel;


@end

NS_ASSUME_NONNULL_END
