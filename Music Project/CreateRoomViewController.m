//
//  CreateRoomViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

//things to note:

#import "CreateRoomViewController.h"
#import "TDSession.h"
#import "TDAudioStreamer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface CreateRoomViewController () <TDSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@property (weak, nonatomic) IBOutlet UIImageView *nextAlbumImage;
@property (weak, nonatomic) IBOutlet UILabel *nextSongTitle;
@property (weak, nonatomic) IBOutlet UILabel *nextSongArtist;

@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;

@property (strong,nonatomic) NSMutableArray *songQueue;
@property int locationInSongQueue; //-1 the current position is the current song.

@property (nonatomic, strong)IBOutlet UITextField *chatBox;
@property (nonatomic, strong)IBOutlet UITextView *textBox;

@end

@implementation CreateRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.thisRoomName;
    self.session = [[TDSession alloc] initWithPeerDisplayName:self.thisRoomName];
    [self.session startAdvertisingForServiceType:@"dance-party" discoveryInfo:nil];
    self.session.delegate = self;
    
    self.songQueue = [[NSMutableArray alloc] init];
    self.locationInSongQueue = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.session stopAdvertising];
}

//changes the info for the current song;
- (void)changeSongInfo:(NSDictionary *)info
{
    //update the next
    NSLog(@"we are running changeSongINfo");
    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;
    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];
    
    self.nextAlbumImage.image = nil;
    self.nextSongArtist.text = @"";
    self.nextSongTitle.text = @"";
    
    
}

//controls the play button
//sends data to start the player
- (IBAction)playButton:(id)sender
{
    NSString *data = @"PLAY";
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[data copy]]];
    [self updateWhatsPlaying];
}

//updates the  list
- (void)addToList:(NSDictionary *)info
{
    [self.songQueue addObject:info];
    [self updateWhatsNext];
}

- (void)updateWhatsNext
{
    //currently playing song -1
    //next queued song is where the location is pointing
    //if there is nothing else in the queue do this
    if (self.locationInSongQueue == [self.songQueue count])
    {
        self.nextSongTitle.text = nil;
        self.nextSongArtist.text = nil;
        self.nextAlbumImage.image = nil;
    }else //otherwise, update with the next information
    {
        NSDictionary *nextSong = [self.songQueue objectAtIndex:self.locationInSongQueue];
        //NSString *username = nextSong[@"username"];
        //NSString *recordType = nextSong[@"type"];
        NSString *songTitle = nextSong[@"title"];
        NSString *artist = nextSong[@"artist"];
        //UIImage *bigArt = nextSong[@"bigArt"];
        UIImage *smallArt = nextSong[@"smallArt"];
        
        self.nextSongTitle.text = songTitle;
        self.nextSongArtist.text = artist;
        if (smallArt)
            self.nextAlbumImage.image = smallArt;
        else
            self.nextAlbumImage.image = nil;
    }
    
    
    /*NSDictionary *nextSong = [self.songQueue objectAtIndex:self.locationInSongQueue];
    NSString *username = nextSong[@"username"];
    NSString *recordType = nextSong[@"type"];
    NSString *songTitle = nextSong[@"title"];
    NSString *artist = nextSong[@"artist"];
    UIImage *bigArt = nextSong[@"bigArt"];
    UIImage *smallArt = nextSong[@"smallArt"];
    
    NSLog(@"%@",songTitle);
    NSLog(@"%@",artist);*/

    /*self.nextSongTitle.text = info[@"title"];
     self.nextSongArtist.text = info[@"artist"];
     if (info[@"nextArtwork"])
     self.nextAlbumImage.image = info[@"artwork"];
     else
     self.nextAlbumImage.image= nil;*/
}

-(void)updateWhatsPlaying
{
    NSDictionary *currentSong = [self.songQueue objectAtIndex:self.locationInSongQueue];
    //NSString *username = currentSong[@"username"];
    //NSString *recordType = currentSong[@"type"];
    NSString *songTitle = currentSong[@"title"];
    NSString *artist = currentSong[@"artist"];
    UIImage *bigArt = currentSong[@"bigArt"];
    //UIImage *smallArt = currentSong[@"smallArt"];
    
    self.songTitle.text = songTitle;
    self.songArtist.text = artist;
    if (bigArt)
        self.albumImage.image = bigArt;
    else
        self.albumImage.image = nil;
    
    self.locationInSongQueue++;
    
    NSLog(@"Ok were about to go");
    [self updateWhatsNext];
    //[self updatePeersWhatsPlaying];
    //[self updatePeersWhatsNext];
}

- (void)updatePeersWhatsPlaying
{
    NSLog(@"Ok we got here");
    
    NSMutableDictionary *currentSong = [self.songQueue objectAtIndex:self.locationInSongQueue-1];
    NSLog(@"Ok we got here 2");
    [currentSong setObject:@"current" forKey:@"type"];
    NSLog(@"current song dictionary created");
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[currentSong copy]]];
}

- (void) updatePeersWhatsNext
{
    if (self.locationInSongQueue <= [self.songQueue count])
    {
        NSMutableDictionary *nextSong = [self.songQueue objectAtIndex:self.locationInSongQueue];
        [nextSong setObject:@"next" forKey:@"type"];
        NSLog(@"next song dictionary created");
        [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[nextSong copy]]];
    }
}

#pragma mark - TDSessionDelegate

- (void)session:(TDSession *)session didReceiveData:(NSData *)data
{
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"got object ID");

    
    if ([myobject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([[info objectForKey:@"type"] isEqualToString:@"next"])
        {
            [self performSelectorOnMainThread:@selector(addToList:) withObject:info waitUntilDone:NO];
        }
        else if ([[info objectForKey:@"type"] isEqualToString:@"current"])
        {
            [self performSelectorOnMainThread:@selector(changeSongInfo:) withObject:info waitUntilDone:NO];
        }
    }
}

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    if (!self.inputStream) {
        self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
        [self.inputStream start];
    }
}


@end

