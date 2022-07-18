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

@end
