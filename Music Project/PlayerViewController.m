//
//  PlayerViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/21/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()
//@synthesize player; // the player object

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

/*-(void)play
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: @"sound"
                                    ofType: @"wav"];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    AVAudioPlayer *newPlayer =
    [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                           error: nil];
    [fileURL release];
    
    [newPlayer play];
    
    [newPlayer release];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
