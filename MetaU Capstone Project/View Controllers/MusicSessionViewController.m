//
//  MusicSessionViewController.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import "MusicSessionViewController.h"

@interface MusicSessionViewController ()

@end

@implementation MusicSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionNameLabel.text = self.musicSession.sessionName;
    self.sessionIDLabel.text = self.musicSession.sessionCode;
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
