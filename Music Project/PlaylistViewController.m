//
//  PlaylistViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "PlaylistViewController.h"
#import "AppDelegate.h"
#import "myManager.h"


@interface PlaylistViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (strong, nonatomic) IBOutlet UIImageView *albumArt;
@property (strong, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *albumName;
@property (strong, nonatomic) IBOutlet UIButton *chooseSong;

@property (strong, nonatomic) NSString *songNameString;
@property (strong, nonatomic) NSString *artistNameString;
@property (strong, nonatomic) NSString *albumNameString;
@property (strong, nonatomic) UIImage *albumArtImage;
@property (strong, nonatomic) MPMediaItem *song;

@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) NSMutableArray *songQueue;
@property (strong, nonatomic) NSMutableArray *playlistInfo;
@property (strong, nonatomic) NSString *hostName;

@property (nonatomic) NSInteger location;

//@property NSInteger *locationInSongQueue;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;
-(void)nowPlayingChanged:(NSNotification *)notification;

@end

@implementation PlaylistViewController

@synthesize player; // the player object

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _songQueue = [[NSMutableArray alloc] init];
    _playlistInfo = [[NSMutableArray alloc] init];
    _hostName = [[NSString alloc] init];

    
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        _chooseSong.enabled = YES;
        _chooseSong.hidden = NO;
        
    }
    else{
        _chooseSong.enabled = NO;
        _chooseSong.hidden = YES;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (nowPlayingChanged:)
                                                 name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object: self.player];

    [_playlistTable setDelegate:self];
    [_playlistTable setDataSource:self];
    
    [_playlistTable reloadData];}

- (IBAction)play:(id)sender
{
    NSLog(@"play");
   // MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    MPMediaItemCollection *songs = [[MPMediaItemCollection alloc] initWithItems:_songQueue];
    MPMusicPlayerController *newPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [newPlayer setQueueWithItemCollection:songs];
    [newPlayer beginGeneratingPlaybackNotifications];
    [newPlayer play];

    
//    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _assetURL
//                                                                      error: nil];
//    
//    //[_assetURL release];
//    
//    self.player = newPlayer;
//    //[newPlayer release];
//    [player prepareToPlay];
//    [player setDelegate: self];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSLog(@"mediaPicker");

    //get the song
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    
    //self.song = [mediaItemCollection.items objectAtIndex: 0];
    
//    _songQueue = [mediaItemCollection copy];
    
    NSInteger MPcount = [mediaItemCollection count];
    NSInteger SQcount = [_songQueue count];
    
    NSLog(@"MediaPicker MPCount: %zd", MPcount);
    NSLog(@"MediaPicker SQCount 1: %zd", SQcount);

    for (NSInteger i = 0; i < MPcount; i++)
    {
        _song = [mediaItemCollection.items objectAtIndex:i];
        [_songQueue addObject:_song];
        
        _songNameString = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
        _artistNameString = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
        _albumNameString = [self.song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [self.song valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
        MPMediaItemArtwork *art = [self.song valueForProperty:MPMediaItemPropertyArtwork];
        
        NSNumber *nada = [[NSNumber alloc] initWithInt:0];
        [item removeAllObjects];
        [item setObject:_songNameString forKey:@"songTitle"];
        [item setObject:_artistNameString forKey:@"artistName"];
        [item setObject:_albumNameString forKey:@"albumName"];
        [item setObject:art forKey:@"albumArt"];
        [item setObject:nada forKey:@"votes"];
        
        [_playlistInfo addObject:item];
    }
    
    [_playlistTable reloadData];
    
    SQcount = [_songQueue count];
    NSLog(@"MediaPicker SQCount 2: %tu", SQcount);
    
    NSInteger PLcount = [_playlistInfo count];
    NSLog(@"MediaPicker PLCount: %tu", PLcount);

    
    

//    _assetURL = [_song valueForProperty: MPMediaItemPropertyAssetURL];
//    
//    NSAssert(_assetURL, @"URL is valid.");
//    NSLog(@"%@", [_assetURL absoluteString]);
    
    
//    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
//    
//    // Play the item using AVPlayer
//    self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    [self.avAudioPlayer play];

    
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_assetURL];
//    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//    [player play];
    
//    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: _assetURL options:nil];
//    
//    NSError *error;
//	player.numberOfLoops = -1;
//	
//	if (player == nil)
//		NSLog([error description]);
//	else
//		[player play];
//    
//
    
    
//    _songNameString = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
//    _artistNameString = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
//    _albumNameString = [self.song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [self.song valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
//    _albumArtImage = [self.song valueForProperty:MPMediaItemPropertyArtwork];
//    
//    _songName.text = _songNameString;
//    _artist.text = _artistNameString;
//    _albumName.text = _albumNameString;
//    //_albumArt
}

- (IBAction)chooseSong:(id)sender
{
    NSLog(@"chooseSong");

    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    picker.showsCloudItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender
{
    
    // Get raw PCM data from the track
    NSMutableData *data = [[NSMutableData alloc] init];
    
    const uint32_t sampleRate = 16000; // 16k sample/sec
    const uint16_t bitDepth = 16; // 16 bit/sample/channel
//    const uint16_t channels = 2; // 2 channel/sample (stereo)
    
    NSDictionary *opts = [NSDictionary dictionary];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_assetURL options:opts];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
                              [NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];
    
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:        [[asset tracks] objectAtIndex:0] outputSettings:settings];
    [reader addOutput:output];
    [reader startReading];
    
    // read the samples from the asset and append them subsequently
    while ([reader status] != AVAssetReaderStatusCompleted) {
        CMSampleBufferRef buffer = [output copyNextSampleBuffer];
        if (buffer == NULL) continue;
        
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
        size_t size = CMBlockBufferGetDataLength(blockBuffer);
        uint8_t *outBytes = malloc(size);
        CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
        CMSampleBufferInvalidate(buffer);
        CFRelease(buffer);
        [data appendBytes:outBytes length:size];
        free(outBytes);
    }
    
    NSArray *allpeers = _appDelegate.mpcController.session.connectedPeers;
    //NSError *error;

    dispatch_async(dispatch_get_main_queue(), ^{
        [_appDelegate.mpcController.session sendData:data
                                             toPeers:allpeers
                                            withMode:MCSessionSendDataReliable
                                               error:nil];
    });
    NSLog(@"sending?");
    
    
    
//    NSArray *allpeers = _appDelegate.mpcController.session.connectedPeers;
//
//    NSLog(@"We are about to be sending the file");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSProgress *progress =
//        [_appDelegate.mpcController.session sendResourceAtURL:_assetURL
//                            withName:_songNameString
//                                toPeer:allpeers
//                                withCompletionHandler:^(NSError *error)
//        {
//        if (error)
//            NSLog(@"[Error] %@", error);
//        }];
//        
//        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
//        
//        NSLog(@"We should be sending the file");
//    });
    
    /*NSData *dataToSend = [_song];
    NSArray *allpeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;

    dispatch_async(dispatch_get_main_queue(), ^{
        [_appDelegate.mpcController.session sendData:_song toPeers:allpeers withMode:MCSessionSendDataReliable error:&error];
    });*/
        

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",
                                _song,
                                [(NSProgress *)object fractionCompleted] * 100
                                ];
    
    _songName.text = sendingMessage;
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    NSLog(@"didReceiveDataWithNotification");

    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSLog(@"ugh");
    
    NSDictionary *info = [[NSMutableDictionary alloc] init];
    
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    NSLog(@"got object ID");
    
    if ([myobject isKindOfClass:[NSArray class]])
    {
        NSLog(@"got array");
        _playlistInfo = [myobject copy];
        
        info = [_playlistInfo objectAtIndex:0];
        
        /*_songName.text = [info objectForKey:@"songTitle"];
        _artist.text = [info objectForKey:@"artistName"];
        _albumName.text = [info objectForKey:@"albumName"];
        
        MPMediaItemArtwork *theImage = [info objectForKey:@"albumArt"];
        UIImage *art = [theImage imageWithSize:_albumArt.frame.size];
        _albumArt.image = art;*/
        
        _hostName = peerDisplayName;
        
        [_playlistTable reloadData];
    }
    
    /*if ([myobject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Received dictionary");
        NSNumber *replace;
        
        NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
        NSString *whatKind = [info objectForKey:@"type"];
        
        int loc = [[info objectForKey:@"integer"] intValue];
        NSMutableDictionary *songInfo = [_playlistInfo objectAtIndex:loc];
        
        if ([whatKind isEqualToString:@"Upvotes!"])
        {
            NSLog(@"Upvote!");
            replace = [NSNumber numberWithInt:[[info objectForKey:@"where"] intValue] + 1];
            [songInfo setObject:replace forKey:@"votes"];
            
            NSLog(@"Remove!");
            [_playlistInfo replaceObjectAtIndex:_location withObject:info];
            [_playlistInfo exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
        }
        
        if ([whatKind isEqualToString:@"Downboat!"])
        {
            NSLog(@"Downvote!");
            replace = [NSNumber numberWithInt:[[info objectForKey:@"where"] intValue] - 1];
            [songInfo setObject:replace forKey:@"votes"];
            
            NSLog(@"Remove!");
            [_playlistInfo replaceObjectAtIndex:_location withObject:info];
            [_playlistInfo exchangeObjectAtIndex:_location withObjectAtIndex:_location + 1];
        }
    }*/


    
    
    /*NSString *filelocation = NSTemporaryDirectory();
    NSURL *url = [[NSURL alloc] initWithString:filelocation];
    [filelocation writeToURL:url atomically:YES];
    
    NSLog(@"ass1");
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSLog(@"ass2");
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    NSLog(@"ass3");

    player = [AVPlayer playerWithPlayerItem:anItem];
    NSLog(@"ass4");
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    NSLog(@"ass5");
    [player play];
    NSLog(@"ass6");

    
    //NSString *tempFile = [tempPath stringByAppendingPathComponent:@”tempFile.txt”];

    
    //NSMutableDictionary *songCacheDictionary = [[NSMutableDictionary alloc] initWithContentsOfURL:;
    //[receivedData writeToURL:<#(NSURL *)#> atomically:YES]
    //AVPlayerItem *player = [AVPlayerItem playerItemWithURL:<#(NSURL *)#>]
    
    //NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:receivedData];

    
    //AVPlayerItem *player = [[AVPlayerItem alloc] initwithdata:_assetURL];
    //*player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    //[player play];
    
//    NSString *urlString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    self.player = [[AVPlayer alloc] initWithURL:url];
//    [self.player play];
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *ful
    
    //NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:receivedData];
    //NSURL *furl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:receivedData];
    
//    NSString *urlString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//    NSURL *url = [[NSURL alloc] initWithString:urlString];
//    
//    NSData *wavDATA = [NSData dataWithContentsOfURL:url];
//    NSError *error;
//    
//    self.player=[[AVAudioPlayer alloc] initWithData:wavDATA error:&error];
//    [self.player play];*/
    
}

-(void)nowPlayingChanged:(NSNotification *)notification
{
    NSLog(@"nowPlayingChanged");
    NSInteger SQcount = [_songQueue count];
    NSLog(@"nowPlayingChanged SQCount 1: %tu", SQcount);
    
    NSDictionary *info = [[NSDictionary alloc] init];
    info = [_playlistInfo objectAtIndex:0];
    
    
    _songName.text = [info objectForKey:@"songTitle"];
    _artist.text = [info objectForKey:@"artistName"];
    _albumName.text = [info objectForKey:@"albumName"];
    //_albumArt.image = [info objectForKey:@"albumArt"];
    
    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:_playlistInfo];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;
    
    NSLog(@"Sending");
    [_appDelegate.mpcController.session sendData:toBeSent
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    
    //[_playlistInfo removeObjectAtIndex:0];
    //[_songQueue removeObjectAtIndex:0];
    
    SQcount = [_songQueue count];
    NSLog(@"nowPlayingChanged SQCount 2: %tu", SQcount);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table stuff

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_playlistInfo count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"reload table data");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    NSDictionary *info = [[NSDictionary alloc] init];
    info = [_playlistInfo objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [info objectForKey:@"songTitle"];
    cell.detailTextLabel.text = [info objectForKey:@"artistName"];
    
    MPMediaItemArtwork *theImage = [info objectForKey:@"albumArt"];
    UIImage *art = [theImage imageWithSize:cell.imageView.frame.size];
    cell.imageView.image = art;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _location = indexPath.row;
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info = [_playlistInfo objectAtIndex:indexPath.row];
    
    UIActionSheet *chooseUpOrDown = [[UIActionSheet alloc] initWithTitle:[info objectForKey:@"songTitle"]
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
    
    [chooseUpOrDown addButtonWithTitle:@"Upvote!"];
    [chooseUpOrDown addButtonWithTitle:@"Downboat!"];
    [chooseUpOrDown setCancelButtonIndex:[chooseUpOrDown addButtonWithTitle:@"Cancel"]];
    [chooseUpOrDown showInView:self.view];
}


#pragma mark - action sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    NSLog(@"Host");
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info = [_playlistInfo objectAtIndex:_location];
    NSNumber *cool = [info objectForKey:@"votes"];
    NSNumber *replace;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *type;
    NSNumber *loc = [[NSNumber alloc] initWithLong:_location];
    
    if ([buttonTitle isEqualToString:@"Upvote!"])
    {
        NSLog(@"Upvote!");
        replace = [NSNumber numberWithInt:[cool intValue] + 1];
        [info setObject:replace forKey:@"votes"];
    
        NSLog(@"Remove!");
        [_playlistInfo replaceObjectAtIndex:_location withObject:info];
        [_playlistInfo exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
        
        //prepare dictionary to be sent to peers
        type = @"Upvote";
        [dic setObject:type forKey:@"type"];
        [dic setObject:loc forKey:@"where"];
        
    } else if ([buttonTitle isEqualToString:@"Downboat!"])
    {
        NSLog(@"Downvote!");
        replace = [NSNumber numberWithInt:[cool intValue] - 1];
        [info setObject:replace forKey:@"votes"];

        [_playlistInfo replaceObjectAtIndex:_location withObject:info];
        [_playlistInfo exchangeObjectAtIndex:_location withObjectAtIndex:_location+1];
        
        //prepare dictionary to be sent to peers
        type = @"Downvote";
        [dic setObject:type forKey:@"type"];
        [dic setObject:loc forKey:@"where"];
        
    } else
    {
        NSLog(@"Cancel!");
        return;
    }
        
    [_playlistTable reloadData];
    
    NSLog(@"send to Guests");
        
//    if ([buttonTitle isEqualToString:@"Upvote!"])
//    {
//        NSLog(@"Upvote!");
//        type = @"Upvote";
//            
//        [dic setObject:type forKey:@"type"];
//        [dic setObject:loc forKey:@"where"];
//    }
//        
//    if (buttonIndex == 1)
//    {
//            type = @"Downvote";
//            
//            [dic setObject:type forKey:@"type"];
//            [dic setObject:loc forKey:@"where"];
//        }
    
    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;
    
    NSLog(@"Sending");
    [_appDelegate.mpcController.session sendData:toBeSent
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];

}


@end
