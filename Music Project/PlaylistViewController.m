//
//  PlaylistViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "PlaylistViewController.h"
#import "AppDelegate.h"


@interface PlaylistViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (strong, nonatomic) IBOutlet UIImage *albumArt;
@property (strong, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *albumName;

@property (strong, nonatomic) NSString *songNameString;
@property (strong, nonatomic) NSString *artistNameString;
@property (strong, nonatomic) NSString *albumNameString;
@property (strong, nonatomic) UIImage *albumArtImage;

@property (strong, nonatomic) NSURL *assetURL;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;


@end

@implementation PlaylistViewController

@synthesize player; // the player object

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
	// Do any additional setup after loading the view.
}

- (IBAction)play:(id)sender
{

    
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
    //get the song
    [self dismissViewControllerAnimated:YES completion:nil];
    self.song = [mediaItemCollection.items objectAtIndex: 0];
    
    _assetURL = [_song valueForProperty: MPMediaItemPropertyAssetURL];
    
    NSAssert(_assetURL, @"URL is valid.");
    NSLog(@"%@", [_assetURL absoluteString]);

    
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
    _songNameString = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    _artistNameString = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";
    _albumNameString = [self.song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [self.song valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
    _albumArtImage = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    
    _songName.text = _songNameString;
    _artist.text = _artistNameString;
    _albumName.text = _albumNameString;
    //_albumArt
}

- (IBAction)chooseSong:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
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
    const uint16_t channels = 2; // 2 channel/sample (stereo)
    
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
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSLog(@"ugh");
    
    NSString *filelocation = NSTemporaryDirectory();
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
//    [self.player play];
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player

                        successfully: (BOOL) completed {
    
    if (completed == YES) {
        
        //[self.button setTitle: @"Play" forState: UIControlStateNormal];
        
    }
    
}

@end
