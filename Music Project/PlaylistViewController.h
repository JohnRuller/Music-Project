//
//  PlaylistViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "peerPlaylist.h"
@import MediaPlayer;

@interface PlaylistViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

//visual elements. The table and play button declarations.
@property (nonatomic, weak) IBOutlet UITableView *playlistTable;

@property (nonatomic, strong) IBOutlet UIButton *buttonPlay;
@property (nonatomic, strong) IBOutlet UIButton *buttonStop;
@property (nonatomic, strong) IBOutlet UIButton *buttonSkip;




- (IBAction)chooseSong:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)skip:(id)sender;







@end
