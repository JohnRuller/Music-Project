//
//  JoinRoomViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

@import MediaPlayer;
@import MultipeerConnectivity;
@import AVFoundation;

#import "JoinRoomViewController.h"
#import "TDAudioStreamer.h"
#import "TDSession.h"

@interface JoinRoomViewController () <MPMediaPickerControllerDelegate, TDSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
@property (strong, nonatomic) IBOutlet UILabel *playLabel;

@property (weak, nonatomic) IBOutlet UIImageView *nextAlbumImage;
@property (weak, nonatomic) IBOutlet UILabel *nextSongTitle;
@property (weak, nonatomic) IBOutlet UILabel *nextSongArtist;

@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;    // dont need for now
@property (strong, nonatomic) TDSession *session;                       // dont need for now
@property (strong, nonatomic) AVPlayer *player;

@property (nonatomic, strong)IBOutlet UITextField *chatBox;
@property (nonatomic, strong)IBOutlet UITextView *textBox;

@end

@implementation JoinRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.session = [[TDSession alloc] initWithPeerDisplayName:[UIDevice currentDevice].name];
    [self presentViewController:[self.session browserViewControllerForSeriviceType:@"dance-party"] animated:YES completion:nil];
    self.session.delegate = self;
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //get the song
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.outputStreamer) return;
    self.song = mediaItemCollection.items[0];
    
    //get variables from the song
    NSString *username = [UIDevice currentDevice].name;
    NSString *title = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    NSString *artist = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    //BOOL personAlreadyExists = FALSE;
    
    //create the dictionary entry
    NSMutableDictionary *nextSongInfo = [NSMutableDictionary dictionary];
    nextSongInfo[@"type"] = @"next";
    nextSongInfo[@"userName"] = username;
    nextSongInfo[@"title"] = title;
    nextSongInfo[@"artist"] = artist;
    UIImage *bigArt = [artwork imageWithSize:self.albumImage.frame.size];
    if (bigArt)
        nextSongInfo[@"bigArt"] = bigArt;
    UIImage *smallArt = [artwork imageWithSize:self.nextAlbumImage.frame.size];
    if (smallArt)
        nextSongInfo[@"smallArt"] = smallArt;
    
    
    //add the song and send the new dictionary entry
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[nextSongInfo copy]]];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Actions

- (IBAction)invite:(id)sender
{
    [self presentViewController:[self.session browserViewControllerForSeriviceType:@"dance-party"] animated:YES completion:nil];
}

- (IBAction)addSongs:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    picker.showsCloudItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)startPlaying:(NSString *) message
{
    /*NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"current";
    info[@"username"] = @"";
    info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
    
    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
    if (image)
        info[@"artwork"] = image;
    
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;
    
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];*/
    
    NSArray *peers = [self.session connectedPeers];
    
    if (peers.count) {
        self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peers[0]]];
        [self.outputStreamer streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
        [self.outputStreamer start];
    }
}

- (void) updateCurrentandNext:(NSDictionary *) dic
{
    NSLog(@"updateCUrrentandNext");

    //for current songs
    if ([dic[@"type"] isEqualToString:@"current"])
    {
        NSLog(@"updating current");
        //NSString *username = dic[@"username"];
        //NSString *recordType = dic[@"type"];
        NSString *songTitle = dic[@"title"];
        NSString *artist = dic[@"artist"];
        UIImage *bigArt = dic[@"bigArt"];
        //UIImage *smallArt = dic[@"smallArt"];
        
        self.songTitle.text = songTitle;
        self.songArtist.text = artist;
        if (bigArt)
            self.albumImage.image = bigArt;
        else
            self.albumImage.image = nil;
    }
    
    //for next songs
    if ([dic[@"type"] isEqualToString:@"current"])
    {
        NSLog(@"updating next");
        //NSString *username = dic[@"username"];
        //NSString *recordType = dic[@"type"];
        NSString *songTitle = dic[@"title"];
        NSString *artist = dic[@"artist"];
        //UIImage *bigArt = dic[@"bigArt"];
        UIImage *smallArt = dic[@"smallArt"];
        
        self.nextSongTitle.text = songTitle;
        self.nextSongArtist.text = artist;
        if (smallArt)
            self.nextAlbumImage.image = smallArt;
        else
            self.nextAlbumImage.image = nil;
    }
    
    
}

#pragma mark - Delegate
- (void)session:(TDSession *)session didReceiveData:(NSData *)data
{
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if ([myobject isKindOfClass:[NSString class]])
     {
         NSString *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         if ([message isEqualToString:@"PLAY"])
         {
             [self performSelectorOnMainThread:@selector(startPlaying:) withObject:message waitUntilDone:NO];
         }
     }
    
    if ([myobject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"unencrypting dictionary");
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self performSelectorOnMainThread:@selector(updateCurrentandNext:) withObject:dic waitUntilDone:NO];
    }
}

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream
{

}




@end
