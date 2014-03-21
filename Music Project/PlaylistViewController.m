//
// PlaylistViewController.m
// Music Project
//
// Created by Ryan Fraser on 2/20/2014.
// Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "PlaylistViewController.h"
#import "AppDelegate.h"
#import "myManager.h"


@interface PlaylistViewController ()

//************************ Properties ************************//

//Initializes the app delegate which has our multipeer connectivity stuff in it
@property (nonatomic, strong) AppDelegate *appDelegate;

//these properties are all visual buttons and labels that exist on the storyboard
@property (strong, nonatomic) IBOutlet UIImageView *albumArt;
@property (strong, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) IBOutlet UILabel *artist;
@property (strong, nonatomic) IBOutlet UILabel *albumName;
@property (strong, nonatomic) IBOutlet UIButton *chooseSong;

//This is the MP media item chosen by the user
@property (strong, nonatomic) MPMediaItem *song;

//This is the queue of song files chosen and received.
@property (strong, nonatomic) NSMutableArray *songQueue;

//This is the name of the host device.
@property (strong, nonatomic) NSString *hostName;

//This is the location chosen by the actionsheet. Used for playlist voting.
@property (nonatomic) NSUInteger location;

//This is the player that plays the songs.
@property (nonatomic, strong) AVAudioPlayer *coolPlayer;

//This is an instance of the peerPlaylist class, which controls the playlist.
@property (nonatomic, strong) peerPlaylist *playlistInfo;

//This is the exported data created by the turnSongIntoData class
@property (nonatomic, strong) NSData *exportedData;




//************************ Methods ************************//

//This is called when data is received by the app.
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

//A method that determines how to upvote the song.
-(void)upvoteSong;

//A method that determines how to downvote the song
-(void)downvoteSong;

@end


//************************ Implementation ************************//

@implementation PlaylistViewController


//used to load the playlist view controller
- (void)loadView {
    [super loadView];
    NSLog(@"Loading playlist view controller.");
    
    [self viewDidLoad];
}

//called when the playlistViewController loads. Initializes variables and sets it up.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initializes varaibles
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _songQueue = [[NSMutableArray alloc] init];
    _playlistInfo = [[peerPlaylist alloc] init];
    _hostName = [[NSString alloc] init];
    
    //Checks to see if it is the host device or not.
    //If so, enable play button, if not, disable it.
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        _buttonPlay.enabled = YES;
        _buttonPlay.hidden = NO;
        
    }
    else{
        _buttonPlay.enabled = NO;
        _buttonPlay.hidden = YES;
    }
    
    //setup the system notification for when the app receives data
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    
        //sets up the playlist table
        [_playlistTable setDelegate:self];
        [_playlistTable setDataSource:self];
        
        //sets up the audio player
        [_coolPlayer setDelegate:self];
    
        //loads the table data (should be empty)
        [_playlistTable reloadData];
    }];
}

//called when the play button is pressed.
- (IBAction)play:(id)sender
{
    //write to log, set up error checking.
    NSLog(@"play");
    NSError *error;
    
    //makes sure that there is a song in the queue
    if ([_songQueue count] != 0)
    {
        //update the now playing portion at the top of the app from the top song in the playlist info
        NSMutableArray *playlist = [_playlistInfo getArray];
        NSDictionary *firstSong = [playlist objectAtIndex:0];
        _songName.text = [firstSong objectForKey:@"songTitle"];
        _artist.text = [firstSong objectForKey:@"artistName"];
        _albumName.text = [firstSong objectForKey:@"albumName"];
        _albumArt.image = [firstSong objectForKey:@"albumArt"];
        
        //begin playing the audio player
        AVAudioPlayer *neatPlayer = [[AVAudioPlayer alloc]initWithData:[_songQueue objectAtIndex:0] error:&error];
        _coolPlayer = neatPlayer;
        [_coolPlayer prepareToPlay];
        [_coolPlayer setDelegate:self];
        [_coolPlayer play];
    }
    else
    {
        //alert the user that there is no song in the queue
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Songs in Queue"
                                                        message:@"Please add a Song!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//Called when someone chooses a song in the media picker.
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //write to log and close the mediapicker view controller
    NSLog(@"mediaPicker");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //iniitalze variables. song is the media item chosen by the user, data is
    NSData *data;
    MPMediaItem *song = [mediaItemCollection.items objectAtIndex: 0];
    
    //if host
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        //we have to send out the playlist to peers. this prepares that
        //also adds song to the songqueue
        
        //add song information to playlistInfo array
        [_playlistInfo addSongFromHost:song];
        
        //get the array and store it in a NSData type file.
        data = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
        
        //turn the song file into a NSData type.
        [self turnSongIntoData:song];
        
        //wait while turnSongIntoData finishes
        while (_exportedData == nil) {
        }
        
        //once complete, add to array and clear memory of exportedData
        [_songQueue addObject:_exportedData];
        _exportedData = nil;
    }
    else
    {
        //is guest
        //makes a NSDictionary containing the song file and the playlist information
        
        //initialze dictionary to be sent
        NSMutableDictionary *newSong = [[NSMutableDictionary alloc] init];
        
        //create a dictionary item that will contain the info for playlistInfo
        NSDictionary *info = [_playlistInfo makeDictionaryItem:song];
        
        //turn song file into NSData type
        [self turnSongIntoData:song];
        
        //wait for turnSongIntoData
        while (_exportedData == nil) {
        }
        
        //setup the newSong Dictionary with required info
        [newSong setObject:@"songFile" forKey:@"type"];
        [newSong setObject:info forKey:@"songInfo"];
        [newSong setObject:_exportedData forKey:@"songData"];
        
        //archive it
        data = [NSKeyedArchiver archivedDataWithRootObject:[newSong copy]];
        
        //release memory
        _exportedData = nil;
        
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        //initialize error and array that will contain only the host device, as well of array of all peers.
        NSError *error;
        NSMutableArray *hostDevice = [[NSMutableArray alloc] init];
        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;

        NSLog(@"Sending Song");
        
        
        //find which device is the host device to send the song file too
        for(int i=0; i<[allPeers count]; i++)
        {
            if([[[allPeers objectAtIndex:i] displayName] isEqualToString:_appDelegate.hostName])
                [hostDevice addObject:[allPeers objectAtIndex:i]];
        }
        
        if ([sharedManager.someProperty isEqualToString:@"YES"])
        {
            [_appDelegate.mpcController.session sendData:data
                                                 toPeers:allPeers
                                                withMode:MCSessionSendDataReliable
                                                   error:&error];
        }
        else
        {
            [_appDelegate.mpcController.session sendData:data
                                                 toPeers:hostDevice
                                                withMode:MCSessionSendDataReliable
                                                error:&error];
        }

    
        [_playlistTable reloadData];
    }];
}

- (IBAction)chooseSong:(id)sender
{
    NSLog(@"chooseSong");
    
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



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",
                                _song,
                                [(NSProgress *)object fractionCompleted] * 100
                                ];
    
    _songName.text = sendingMessage;
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    NSLog(@"didReceiveDataWithNotification");
    
    //MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    //NSString *peerDisplayName = peerID.displayName;
    
    NSLog(@"ugh");
    
    //NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    //NSLog(@"ugh");
    
    // NSDictionary *info = [[NSMutableDictionary alloc] init];
    
    NSKeyedUnarchiver* unarchiver;
    
    @try {
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:receivedData];
    }
    
    @catch (NSException *exception) {
        NSLog(@"unarchive exception");
        return;

        
    }
    NSLog(@"past exception");

    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    NSLog(@"got object ID");
    
    
    
    //means that this is a guest, and has received a new
    //NSArray with the full playlist
    if ([myobject isKindOfClass:[NSArray class]])
    {
        NSLog(@"got array");
        NSMutableArray *playlist = [myobject copy];
        //_playlistInfo = [myobject copy];
        
        [_playlistInfo updatePlaylist:playlist];
        
        // info = [_playlistInfo objectAtIndex:0];
        //
        // _songName.text = [info objectForKey:@"songTitle"];
        // _artist.text = [info objectForKey:@"artistName"];
        // _albumName.text = [info objectForKey:@"albumName"];
        //
        // //MPMediaItemArtwork *theImage = [info objectForKey:@"albumArt"];
        // //UIImage *art = [theImage imageWithSize:_albumArt.frame.size];
        // _albumArt.image = [info objectForKey:@"art"];
        // //_albumArt.image = art;*/
        //
        // _hostName = peerDisplayName;
        
        [_playlistTable reloadData];
    }
    
    if ([myobject isKindOfClass:[NSData class]])
    {
        NSLog(@"nsdata received");
        NSData *newSong = [myobject copy];
        [_songQueue addObject:newSong];
    }
    
    
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        if ([myobject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = [myobject copy];
            NSString *type = [dic objectForKey:@"type"];
            //NSNumber *replace;
            
            if (type != nil)
            {
                /*if ([type isEqualToString:@"upvote"])
                {
                    NSNumber *where = [dic objectForKey:@"where"];
                    NSInteger loc = [where integerValue];
                    //replace = [NSNumber numberWithInt:[cool intValue] + 1]
                    
                    //[_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc-1];
                    [_playlistInfo playlistUpvote:loc];
                    //[_songQueue exchangeObjectAtIndex:loc withObjectAtIndex:loc-1];
                    
                    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                    NSError *error;
                    
                    NSLog(@"Sending");
                    [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                }
                
                if ([type isEqualToString:@"downvote"])
                {
                    NSNumber *where = [dic objectForKey:@"where"];
                    NSInteger loc = [where integerValue];
                    //replace = [NSNumber numberWithInt:[cool intValue] + 1]
                    
                    //[_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc+1];
                    
                    [_playlistInfo playlistDownvote:loc];
                    //[_songQueue exchangeObjectAtIndex:loc withObjectAtIndex:loc+1];
                    
                    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                    NSError *error;
                    
                    NSLog(@"Sending");
                    [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                }
                */
                
                
                //if it is the voting dictionary type
                //get the variables from the type
                //check to make sure song hasn't moved.
                //if it hasn't upvote or downvote accordingly
                //if it has, check through all songs to try and find it
                //if you cant find it, then do nothing
                //otherwise upvote/downvote
                
                if ([type isEqualToString:@"voting"])
                {
                    NSLog(@"received voting dictionary");
                    NSInteger location = [[dic objectForKey:@"where"] integerValue];
                    NSString *voteType = [dic objectForKey:@"voteType"];
                    NSString *songTitle = [dic objectForKey:@"songTitle"];
                    
                    if ([[_playlistInfo getSongName:location] isEqualToString:songTitle])
                    {
                        NSLog(@"song is in correct location");
                        _location = location;
                        if ([voteType isEqualToString:@"upvote"])
                        {
                            [self upvoteSong];
                        }
                        
                        if ([voteType isEqualToString:@"downvote"])
                        {
                            [self downvoteSong];
                        }
                        
                        NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            //Your code goes in here
                        NSError *error;
                        
                        NSLog(@"Sending");
                        [_appDelegate.mpcController.session sendData:toBeSent
                                                             toPeers:allPeers
                                                            withMode:MCSessionSendDataReliable
                                                               error:&error];
                        }];
                        
                        
                    }
                    else
                    {
                        NSLog(@"song is not in correct location. locating song");
                        NSInteger i = 0;
                        BOOL found = false;
                        while (i < [_playlistInfo countOfPlaylistInfo] && found != true)
                        {
                            if ([songTitle isEqualToString:[_playlistInfo getSongName:i]])
                            {
                                NSLog(@"song found");
                                found = true;
                                _location = i;
                            }
                            else
                                i++;
                        }
                        
                        if (found == true)
                        {
                            NSLog(@"voting on found song");
                            if ([voteType isEqualToString:@"upvote"])
                            {
                                [self upvoteSong];
                            }
                            
                            if ([voteType isEqualToString:@"downvote"])
                            {
                                [self downvoteSong];
                            }
                            
                            NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                            NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                //Your code goes in here
                            NSError *error;
                            
                            NSLog(@"Sending");
                            [_appDelegate.mpcController.session sendData:toBeSent
                                                                 toPeers:allPeers
                                                                withMode:MCSessionSendDataReliable
                                                                   error:&error];
                            
                            }];
                        }else
                            NSLog(@"Song no longer exists in the queue");
                    }
                }
                
                if ([type isEqualToString:@"newSong"])
                {
                    //add file locally
                    [_playlistInfo addSongFromGuest:dic];
                    
                    //send it out
                    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        //Your code goes in here
                    NSError *error;
                    
                    NSLog(@"Sending");
                    [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                    }];
                }
                
                if ([type isEqualToString:@"songFile"])
                {
                    NSLog(@"nsdata received");
                    
                    NSData *newSong = [dic objectForKey:@"songData"];
                    NSDictionary *newSongData = [dic objectForKey:@"songInfo"];
                    
                    [_songQueue addObject:newSong];
                    [_playlistInfo addSongFromGuest:newSongData];
                    
                    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        //Your code goes in here
                    NSError *error;
                    
                    NSLog(@"Sending");
                    [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                    }];
                }
                
                /*
                 if ([type isEqualToString:@"anarchy"])
                 {
                 NSString *kind = [dic objectForKey:@"kind"];
                 if ([kind isEqualToString:@"play"])
                 {
                 //[_newPlayer play];
                 //[_newPlayer pause];
                 }
                 if ([kind isEqualToString:@"stop"])
                 {
                 //[_newPlayer pause];
                 }
                 if ([kind isEqualToString:@"anarchy"])
                 {
                 }
                 if ([kind isEqualToString:@"skip"])
                 {
                 //[_newPlayer skipToNextItem];
                 }
                 if ([kind isEqualToString:@"playbackSlow"])
                 {
                 //[_newPlayer currentPlaybackRate];
                 }
                 if ([kind isEqualToString:@"playbackFaster"])
                 {
                 }
                 if([kind isEqualToString:@"playbackNormal"])
                 {
                 }
                 }
                 */
            }
        }
    }
    }];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_playlistTable reloadData];
    }];
    
}

/*
 //-(void)nowPlayingChanged:(NSNotification *)notification
 //{
 // NSLog(@"nowPlayingChanged");
 //
 // //_startTime = [NSDate date];
 // //[NSThread sleepForTimeInterval:1.0];
 //
 // NSTimeInterval elapsedTime = [_startTime timeIntervalSinceNow];
 // NSLog([NSString stringWithFormat:@"Elapsed time interval: %f", -elapsedTime]);
 // int time = round(elapsedTime);
 // NSLog(@"Elapsed time: %tu", -time);
 //
 //
 // _startTime = [NSDate date];
 // NSLog(@"nowPlayingChanged in loop");
 // NSInteger SQcount = [_songQueue count];
 // NSLog(@"nowPlayingChanged SQCount 1: %tu", SQcount);
 //
 // NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
 // info = [_playlistInfo objectAtIndex:0];
 //
 //
 // _songName.text = [info objectForKey:@"songTitle"];
 // _artist.text = [info objectForKey:@"artistName"];
 // _albumName.text = [info objectForKey:@"albumName"];
 // //_albumArt.image = [info objectForKey:@"albumArt"];
 //
 // NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:_playlistInfo];
 // NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
 // NSError *error;
 //
 // NSLog(@"Sending");
 // [_appDelegate.mpcController.session sendData:toBeSent
 // toPeers:allPeers
 // withMode:MCSessionSendDataReliable
 // error:&error];
 //
 // //[_playlistInfo removeObjectAtIndex:0];
 // //[_songQueue removeObjectAtIndex:0];
 // [_playlistTable reloadData];
 //
 // SQcount = [_songQueue count];
 // NSLog(@"nowPlayingChanged SQCount 2: %tu", SQcount);
 //
 // _startTime = [NSDate date];
 //
 //// NSTimeInterval elapsedTime = [_startTime timeIntervalSinceNow];
 //// NSLog([NSString stringWithFormat:@"Elapsed time interval: %f", -elapsedTime]);
 //// int time = round(elapsedTime);
 //// NSLog(@"Elapsed time: %tu", -time);
 //}
 */


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"didFinish");
    NSError *error = nil;
    
    [_songQueue removeObjectAtIndex:0];
    [_playlistInfo removeSong:0];
    
    if ([_songQueue count] != 0)
    {
        NSMutableArray *playlist = [_playlistInfo getArray];
        NSDictionary *firstSong = [playlist objectAtIndex:0];
        _songName.text = [firstSong objectForKey:@"songTitle"];
        _artist.text = [firstSong objectForKey:@"artistName"];
        _albumName.text = [firstSong objectForKey:@"albumName"];
        _albumArt.image = [firstSong objectForKey:@"albumArt"];
        
        NSLog(@"Play next");
        AVAudioPlayer *neatPlayer = [[AVAudioPlayer alloc]initWithData:[_songQueue objectAtIndex:0] error:&error];
        _coolPlayer = neatPlayer;
        [_coolPlayer prepareToPlay];
        [_coolPlayer setDelegate:self];
        [_coolPlayer play];
    }
    else
    {
        NSLog(@"Stop");
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        NSError *error = nil;
    
    [_playlistTable reloadData];
    
    NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    
    
    
    NSLog(@"Sending");
    [_appDelegate.mpcController.session sendData:toBeSent
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        
    }];
    
    
}

#pragma mark - table stuff
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_playlistInfo countOfPlaylistInfo];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"reload table data");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newCell"];
    }
    
    NSMutableArray *play = [_playlistInfo getArray];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    
    /*NSString *writer = [info objectForKey:@"artistName"];
     NSString *album = [info objectForKey:@"albumName"];
     NSString *middle = @" - ";
     NSString *final = @"";
     NSLog(@"%@", final);
     final = [final stringByAppendingString:writer];
     NSLog(@"%@", final);
     final = [final stringByAppendingString:middle];
     NSLog(@"%@", final);
     final = [final stringByAppendingString:album];
     NSLog(@"%@", final);*/
    
    info = [play objectAtIndex:indexPath.row];
    
    UILabel *songTitle = (UILabel *)[cell.contentView viewWithTag:111];
    [songTitle setText:[info objectForKey:@"songTitle"]];
    
    UILabel *artist = (UILabel *)[cell.contentView viewWithTag:112];
    [artist setText:[info objectForKey:@"artistName"]];
    
    UILabel *albumName = (UILabel *)[cell.contentView viewWithTag:113];
    [albumName setText:[info objectForKey:@"albumName"]];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:110];
    profileImageView.image = [info objectForKey:@"albumArt"];
    
    
    
    
    // cell.textLabel.text = [info objectForKey:@"songTitle"];
    // cell.detailTextLabel.text = [info objectForKey:@"artistName"];
    // cell.imageView.image = [info objectForKey:@"art"];
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _location = indexPath.row;
    NSMutableArray *play = [_playlistInfo getArray];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    
    info = [play objectAtIndex:indexPath.row];
    
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
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        NSLog(@"Host");
        if ([buttonTitle isEqualToString:@"Upvote!"])
        {
            NSLog(@"Upvote!");
            
            [self upvoteSong];
            
            /*if (_location != 0)
            {
                NSLog(@"Location != 0");
                [_playlistInfo addUpvote:_location];
                
                if (_location == 1 && [_coolPlayer isPlaying] == true)
                {
                    NSLog(@"location is 1 and player is playing. upvotes added");
                }
                else
                {
                    NSLog(@"all other conditions failed, do full upvote routine");
                    NSInteger totalUpvotes = [_playlistInfo getUpvoteCount:_location];
                    if (((totalUpvotes/totalPeers)*100) >= 50 && totalPeers > 2)
                    {
                        NSLog(@"Move Song to the top");
                        [_playlistInfo moveSongToTop:_location];
                        //insert code here that moves the songQueue to the top
                    }
                    else
                    {
                        NSLog(@"Move Song up one position");
                        [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
                        [_playlistInfo moveSongUpOnePosition:_location];
                    }
                }
            }
            else
                NSLog(@"Location is equal to 0 - do nothing");
            
            
            //replace = [NSNumber numberWithInt:[cool intValue] + 1];
            //[info setObject:replace forKey:@"votes"];
            
            NSLog(@"replace! Location: %ld", (long)_location);
            
            //[_playlistInfo replaceObjectAtIndex:_location withObject:info];
            //NSLog(@"exchange!");
            
            if (_location != 0 && _location != 1)
            {
                [_playlistInfo playlistUpvote:_location];
                [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
                NSLog(@"Location = whatever");
            }
            
            if (_location == 1)
            {
                NSLog(@"Location = 1");
                if (![_coolPlayer isPlaying])
                {
                    [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
                    NSLog(@"player not playing");
                }
                [_playlistInfo playlistUpvote:_location];
            }
            
            if (_location == 0)
            {
                NSLog(@"location = 0");
            }
            
            //prepare dictionary to be sent to peers
            //type = @"Upvote";
            //[dic setObject:type forKey:@"type"];
            //[dic setObject:loc forKey:@"where"];
             */
            
        } else if ([buttonTitle isEqualToString:@"Downboat!"])
        {
            NSLog(@"Downvote!");
            
            [self downvoteSong];
            
 
        } else
        {
            NSLog(@"Cancel!");
            return;
        }
        
        NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            //Your code goes in here
        NSError *error;
        
        NSLog(@"Sending");
        [_appDelegate.mpcController.session sendData:toBeSent
                                             toPeers:allPeers
                                            withMode:MCSessionSendDataReliable
                                               error:&error];
        }];
        
        
        //THIS IS NOW WHAT HAPPENS IF THE USER IS A GUEST
    }else{
        
        NSLog(@"Guest");
        NSNumber *loc = [[NSNumber alloc] initWithLong:_location];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        NSString *songName = [_playlistInfo getSongName:_location];
        [dic setObject:songName forKey:@"songTitle"];
        [dic setObject:@"voting" forKey:@"type"];
        [dic setObject:loc forKey:@"where"];
        [dic setObject:@"" forKey:@"voteType"];

        
        //upvote first
        if ([buttonTitle isEqualToString:@"Upvote!"])
        {
            [dic setObject:@"upvote" forKey:@"voteType"];
            
            //downvote second
        } else if ([buttonTitle isEqualToString:@"Downboat!"]) {
            [dic setObject:@"downvote" forKey:@"voteType"];
            
            //cancel
        } else
        {
            NSLog(@"Cancel!");
            return;
        }
        
        //check to be sure to send data only if user voted
        if ([[dic objectForKey:@"voteType"] isEqualToString:@""] == false)
        {
            
            NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:dic];
            NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                //Your code goes in here
            NSError *error;
            
            NSLog(@"Vote Sending");
            [_appDelegate.mpcController.session sendData:toBeSent
                                                 toPeers:allPeers
                                                withMode:MCSessionSendDataReliable
                                                   error:&error];
            }];
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_playlistTable reloadData];
    }];
}

- (void)turnSongIntoData:(MPMediaItem *) item
{
    
    NSURL *url = [item valueForProperty: MPMediaItemPropertyAssetURL];
    
    if (url == nil)
    {
        NSLog(@"url = nil");
    }
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName:AVAssetExportPresetAppleM4A];
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * myDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    [[NSDate date] timeIntervalSince1970];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    NSString *intervalSeconds = [NSString stringWithFormat:@"%0.0f",seconds];
    NSString * fileName = [NSString stringWithFormat:@"%@.m4a",intervalSeconds];
    NSString *exportFile = [myDocumentsDirectory stringByAppendingPathComponent:fileName];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    
    // do the export
    // (completion handler block omitted)
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         long int exportStatus = exporter.status;
         
         switch (exportStatus)
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *exportError = exporter.error;
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 
                 
                 _exportedData = [NSData dataWithContentsOfFile: [myDocumentsDirectory
                                                                  stringByAppendingPathComponent:fileName]];
                 if (_exportedData == nil)
                 {
                     NSLog(@"exported data in thing = nil");
                 }
                 /*
                  //return data;
                  // NSError *error = nil;
                  //
                  // NSLog(@"Please play");
                  // //_coolPlayer =[[AVAudioPlayer alloc] initWithData:data error:&error];
                  // //[_coolPlayer play];
                  //
                  // NSLog(@"%@", [error localizedDescription]);
                  //
                  //
                  //
                  // NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:data];
                  // //
                  // //
                  // NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                  // //
                  // NSLog(@"Sending");
                  // [_appDelegate.mpcController.session sendData:toBeSent
                  // toPeers:allPeers
                  // withMode:MCSessionSendDataReliable
                  // error:&error];
                  //
                  // //DLog(@"Data %@",data);
                  // data = nil;
                  */
                 break;
             }
             case AVAssetExportSessionStatusUnknown:
             {
                 NSLog (@"AVAssetExportSessionStatusUnknown"); break;
             }
             case AVAssetExportSessionStatusExporting:
             {
                 NSLog (@"AVAssetExportSessionStatusExporting"); break;
             }
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog (@"AVAssetExportSessionStatusCancelled"); break;
             }
             case AVAssetExportSessionStatusWaiting:
             {
                 NSLog (@"AVAssetExportSessionStatusWaiting"); break;
             }
             default:
             {
                 NSLog (@"didn't get export status"); break;
             }
         }
     }];
    [_playlistTable reloadData];
    
    //NSData *data = [NSData dataWithContentsOfFile: [myDocumentsDirectory
    // stringByAppendingPathComponent:fileName]];
    //return data;
}

-(void)upvoteSong
{
    NSLog(@"Upvote!");
    
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSInteger totalPeers = [allPeers count];
    
    if (_location != 0)
    {
        NSLog(@"Location != 0");
        [_playlistInfo addUpvote:_location];
        
        if (_location == 1 && [_coolPlayer isPlaying] == true)
        {
            NSLog(@"location is 1 and player is playing. upvotes added");
        }
        else
        {
            NSLog(@"all other conditions failed, do full upvote routine");
            NSInteger totalUpvotes = [_playlistInfo getUpvoteCount:_location];
            if (((totalUpvotes/totalPeers)*100) >= 50 && totalPeers > 2)
            {
                NSLog(@"Move Song to the top");
                [_playlistInfo moveSongToTop:_location];
                NSLog(@"insert code here that moves the songQueue to the top");
            }
            else
            {
                NSLog(@"Move Song up one position");
                [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
                [_playlistInfo moveSongUpOnePosition:_location];
            }
        }
    }
    else
        NSLog(@"Location is equal to 0 - do nothing");
}

-(void)downvoteSong
{
    //initialize variables
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSInteger totalPeers = [allPeers count];
    [_playlistInfo addDownvote:_location];
    NSInteger totalDownvotes = [_playlistInfo getDownvoteCount:_location];
    NSInteger downVotePercentage = (totalDownvotes/totalPeers)*100;
    
    
    //if it is the first song and its playing
    if (_location == 0 && [_coolPlayer isPlaying] == true)
    {
        if (downVotePercentage >= 50 && totalPeers > 1)
        {
            NSLog(@"Remove first song and play next");
            [_coolPlayer stop];
            
            [_playlistInfo removeSong:_location];
            [_songQueue removeObjectAtIndex:_location];
            
            if ([_songQueue count] != 0)
            {
                NSError *error;
                NSMutableArray *playlist = [_playlistInfo getArray];
                NSDictionary *firstSong = [playlist objectAtIndex:0];
                _songName.text = [firstSong objectForKey:@"songTitle"];
                _artist.text = [firstSong objectForKey:@"artistName"];
                _albumName.text = [firstSong objectForKey:@"albumName"];
                _albumArt.image = [firstSong objectForKey:@"albumArt"];
                
                NSLog(@"Play next");
                AVAudioPlayer *neatPlayer = [[AVAudioPlayer alloc]initWithData:[_songQueue objectAtIndex:0] error:&error];
                _coolPlayer = neatPlayer;
                [_coolPlayer prepareToPlay];
                [_coolPlayer setDelegate:self];
                [_coolPlayer play];
            }
        }
        //if last in queue
    }else if (_location == ([_playlistInfo countOfPlaylistInfo] - 1))
    {
        if (downVotePercentage >= 50 && totalPeers > 1)
        {
            NSLog(@"Remove last song");
            [_playlistInfo removeSong:_location];
            [_songQueue removeObjectAtIndex:_location];
        }
        //other
    } else {
        if (downVotePercentage >= 50 && totalPeers > 1)
        {
            NSLog(@"Remove song");
            [_playlistInfo removeSong:_location];
            [_songQueue removeObjectAtIndex:_location];
        } else {
            NSLog(@"Move song down one position");
            [_playlistInfo moveSongDownOnePosition:_location];
            [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location+1];
        }
    }
}

@end