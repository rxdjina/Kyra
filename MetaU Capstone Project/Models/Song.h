//
//  Song.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/29/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic) NSInteger *timestamp;
@property (nonatomic, strong) PFObject *coverArt;

@end

NS_ASSUME_NONNULL_END
