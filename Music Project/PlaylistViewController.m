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





@end

@implementation PlaylistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //get the song
    [self dismissViewControllerAnimated:YES completion:nil];
    self.song = mediaItemCollection.items[0];
    
    _assetURL = [_song valueForProperty: MPMediaItemPropertyAssetURL];
    
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
    NSLog(@"We are about to be sending the file");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSProgress *progress =
        [_appDelegate.mpcController.session sendResourceAtURL:_assetURL
                            withName:_songNameString
                                toPeer:[[_appDelegate.mpcController.session connectedPeers] objectAtIndex:1]
                                withCompletionHandler:^(NSError *error)
        {
        if (error)
            NSLog(@"[Error] %@", error);
        }];
        
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        
        NSLog(@"We should be sending the file");
    });
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",
                                _song,
                                [(NSProgress *)object fractionCompleted] * 100
                                ];
    
    _songName.text = sendingMessage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
