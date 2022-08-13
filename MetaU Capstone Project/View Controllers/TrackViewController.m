//
//  TrackViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 8/12/22.
//

#import "TrackViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CoreImage/CoreImage.h"
#import "SpotifyManager.h"

@interface TrackViewController ()

@property BOOL isPlaying;

@end

@implementation TrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = self.session.sessionName;

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(receiveNotification:)
            name:@"playerStateChangeNotification"
            object:nil];
    
    self.isPlaying = YES;
    [self updateView];
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"playerStateChangeNotification"]) {
        NSLog(@"Player State Change Notification Recived");
        
        self.track = [[SpotifyManager shared] getCurrentTrack];
        [self updateView];
    }
}

- (void)updateView {
    NSString *trackID = [[self.track valueForKey:@"URI"] substringFromIndex:14];
    
    
    NSString *targetURL = [NSString stringWithFormat:@"https://api.spotify.com/v1/tracks/%@", trackID];
    
    [[SpotifyManager shared] retriveDataFrom:targetURL result:^(NSDictionary * _Nonnull dataRecieved) {
        
        NSString *trackName = [dataRecieved valueForKey:@"name"];
        
        // Artists
        NSMutableArray *trackArtists = [[dataRecieved valueForKey:@"artists"] valueForKey:@"name"];
        NSString *stringOfArtists = @"";
        
        // Array of Artists -> Formatted String
        for (NSString *name in trackArtists) {
            if (trackArtists.count == 1 || (trackArtists.count - 1) == [trackArtists indexOfObject:name]) {
                stringOfArtists = [stringOfArtists stringByAppendingString:name];
            } else {
                stringOfArtists = [stringOfArtists stringByAppendingString:[NSString stringWithFormat:@"%@, ", name]];
            }
        }
        
        // Cover Art
        NSString *imageURL = [[[dataRecieved valueForKey:@"album"] valueForKey:@"images"] valueForKey:@"url"][0];
        
        NSURL *albumURL = [[NSURL alloc] initWithString:imageURL];
        NSData *albumData = [[NSData alloc] initWithContentsOfURL: albumURL];
        UIImage *albumImage = [UIImage imageWithData:albumData];
        UIImage *blurredAlbumImage = [self blurredImageEffect:albumImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.trackNameLabel.text = trackName;
            self.artistNameLabel.text = stringOfArtists;
            
            [self.coverArtImage setImage:albumImage];
            self.coverArtImage.layer.cornerRadius = 5;
            self.coverArtImage.clipsToBounds = YES;
            
            [self.viewBGImage setImage:blurredAlbumImage];
        });
    }];
}

- (UIImage *)blurredImageEffect:(UIImage *)sourceImage{

    //  Create blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];

    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:25.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    // Resize Image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];

    UIImage *finalImage= [UIImage imageWithCGImage:cgImage];

    if (cgImage) {
        CGImageRelease(cgImage);
    }

    return finalImage;
}

@end
