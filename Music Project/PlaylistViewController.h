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
@import MediaPlayer;

@interface PlaylistViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (strong, nonatomic) MPMediaItem *song;

- (IBAction)chooseSong:(id)sender;
- (IBAction)send:(id)sender;




@end
