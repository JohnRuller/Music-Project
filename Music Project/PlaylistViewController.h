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

//@property (strong, nonatomic) MPMediaItem *song;
//@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) MPMusicPlayerController *player;
@property (nonatomic, strong) MPMediaItemCollection *allSongs;
@property (nonatomic, weak) IBOutlet UITableView *playlistTable;



- (IBAction)chooseSong:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)play:(id)sender;






@end
