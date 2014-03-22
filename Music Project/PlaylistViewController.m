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

//************************ Property Declarations ************************//

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




//************************ Method Declarations ************************//

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
        
        // Register observer to be called when a peer has joined the room
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peerJoinedRoom:)
                                                     name:@"peerJoinedRoom" object:nil];
    
    
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

//called when someone chooses a song in the media picker.
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
        
        
        //if we are the host device, send to all peers
        if ([sharedManager.someProperty isEqualToString:@"YES"])
        {
            [_appDelegate.mpcController.session sendData:data
                                                 toPeers:allPeers
                                                withMode:MCSessionSendDataReliable
                                                   error:&error];
        }
        else
        {
            //find which device is the host device to send the song file too, and send it
            for(int i=0; i<[allPeers count]; i++)
            {
                if([[[allPeers objectAtIndex:i] displayName] isEqualToString:_appDelegate.hostName])
                    [hostDevice addObject:[allPeers objectAtIndex:i]];
            }
            
            [_appDelegate.mpcController.session sendData:data
                                                 toPeers:hostDevice
                                                withMode:MCSessionSendDataReliable
                                                error:&error];
        }
    
        //reload the table data
        [_playlistTable reloadData];
    }];
}

//called when the user hits the pick song button
- (IBAction)chooseSong:(id)sender
{
    NSLog(@"chooseSong");
    
    //sets up and calls the media picker
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    picker.showsCloudItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

//called when user cancels choosing a song in the media picker
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//may be used in the future if i decide to implement the sending bar
/*
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",
                                _song,
                                [(NSProgress *)object fractionCompleted] * 100
                                ];
    
    _songName.text = sendingMessage;
}*/

//called when data is received by the device
-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        NSLog(@"didReceiveDataWithNotification");
        
        //gets the data that was send and stores it as NSData type
        NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    
        //unarchives the data that was received
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
    
    
    
        //device has received a NSArray with the full playlist
        if ([myobject isKindOfClass:[NSArray class]])
        {
            //replace local playlist with received playlist
            NSLog(@"got playlist");
            NSMutableArray *playlist = [myobject copy];
            [_playlistInfo updatePlaylist:playlist];
        
            [_playlistTable reloadData];
        }
    
        /* I don't think this is needed but I don't want to test it yet.
        if ([myobject isKindOfClass:[NSData class]])
        {
            NSLog(@"nsdata received");
            NSData *newSong = [myobject copy];
            [_songQueue addObject:newSong];
        }*/
        
        //checks to see if this device is the host
        MyManager *sharedManager = [MyManager sharedManager];
        if ([sharedManager.someProperty isEqualToString:@"YES"])
        {
            //if the received data is dictionary type
            if ([myobject isKindOfClass:[NSDictionary class]])
            {
                //initialize a dictionary to store the received data in, as well as a string to find out its purpose
                NSDictionary *dic = [myobject copy];
                NSString *type = [dic objectForKey:@"type"];
            
                if (type != nil)
                {
                    //dictionary is about playlist voting
                    if ([type isEqualToString:@"voting"])
                    {
                        //initialize values
                        NSLog(@"received voting dictionary");
                        NSInteger location = [[dic objectForKey:@"where"] integerValue];
                        NSString *voteType = [dic objectForKey:@"voteType"];
                        NSString *songTitle = [dic objectForKey:@"songTitle"];
                    
                        //checks to make sure song hasn't moved spots since the peer sent the vote
                        if ([[_playlistInfo getSongName:location] isEqualToString:songTitle])
                        {
                            NSLog(@"song is in correct location");
                            
                            //copy location value, and initialze upvote/downvote routines based on type
                            _location = location;
                            if ([voteType isEqualToString:@"upvote"])
                            {
                                [self upvoteSong];
                            }
                    
                            if ([voteType isEqualToString:@"downvote"])
                            {
                                [self downvoteSong];
                            }
                    
                            //resend updated playlist info to all peers
                            NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                            NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                NSError *error;
                    
                                NSLog(@"Sending");
                                [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                            }];
                        
                        
                        }
                        else //the song has chanced locations in the array since the vote was sent
                        {
                            //locate where the song has moved too
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
                        
                            //if song was found, do upvote / downvote routine
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
                                //if song wasn't found, do nothing
                                NSLog(@"Song no longer exists in the queue");
                        }
                    }
                
                    //THIS MAY NOT BE NEEDED. NOT GOING TO COMMENT IT OUT RIGHT NOW THOUGH
                    //dictionary is about receiving a new song that was added
                    if ([type isEqualToString:@"newSong"])
                    {
                        //add info to the playlist Info
                        [_playlistInfo addSongFromGuest:dic];
                    
                        //send out updated playlist
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
                
                    //dictionary is about receiving a new song from a peer
                    if ([type isEqualToString:@"songFile"])
                    {
                        NSLog(@"nsdata received");
                    
                        //separete the song data and the playlist data
                        NSData *newSong = [dic objectForKey:@"songData"];
                        NSDictionary *newSongData = [dic objectForKey:@"songInfo"];
                    
                        //add both to each
                        [_songQueue addObject:newSong];
                        [_playlistInfo addSongFromGuest:newSongData];
                    
                        //send out new playlist to peers
                        NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
                        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            NSError *error;
                    
                            NSLog(@"Sending");
                            [_appDelegate.mpcController.session sendData:toBeSent
                                                         toPeers:allPeers
                                                        withMode:MCSessionSendDataReliable
                                                           error:&error];
                        }];
                    }
                }
            }
        }
    }];
    
    //update the table
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_playlistTable reloadData];
    }];
    
}

//clear memory if memory warning received
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//************************ Audio Player Delegate Methods ************************//

#pragma mark - AVAudioPlayerDelegate

//If the audio player finished playing a song, this is called
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"didFinish");
    NSError *error = nil;
    
    //remove the song from the songqueue and the playlist info
    [_songQueue removeObjectAtIndex:0];
    [_playlistInfo removeSong:0];
    
    //if there is another song in the queue, play it
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
        NSError *error = nil;
        
        //reload the table data
        [_playlistTable reloadData];
        
        
        //send out new playlist
        NSData *toBeSent = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    
        NSLog(@"Sending");
        [_appDelegate.mpcController.session sendData:toBeSent
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        
    }];
}


//************************ Table Delegate Methods ************************//

#pragma mark - table stuff

//returns number of sections in the table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//returns the number of rows in the table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_playlistInfo countOfPlaylistInfo];
}

//this method tells the table what data to load. it is called x amount of times based on previous method
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //identify the cells to be updated
    NSLog(@"reload table data");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell"];
    
    //if nil, create a new one
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newCell"];
    }
    
    //get playlist data
    NSMutableArray *play = [_playlistInfo getArray];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    
    info = [play objectAtIndex:indexPath.row];
    
    //load data into the cell
    UILabel *songTitle = (UILabel *)[cell.contentView viewWithTag:111];
    [songTitle setText:[info objectForKey:@"songTitle"]];
    
    UILabel *artist = (UILabel *)[cell.contentView viewWithTag:112];
    [artist setText:[info objectForKey:@"artistName"]];
    
    UILabel *albumName = (UILabel *)[cell.contentView viewWithTag:113];
    [albumName setText:[info objectForKey:@"albumName"]];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:110];
    profileImageView.image = [info objectForKey:@"albumArt"];
    
    //return the cell
    return cell;
}

//this method tells the table what to do when a row is selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //save the location in a method variable. this is due to accessing it later.
    _location = indexPath.row;
    
    //get the playlist info
    NSMutableArray *play = [_playlistInfo getArray];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];

    info = [play objectAtIndex:indexPath.row];
    
    //create a popup (action sheet) asking if you want to upvote or downvote
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

//************************ Table Delegate Methods ************************//

#pragma mark - action sheet

//this method decides what to do when upvote or downvote is clicked
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    //check for 
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        NSLog(@"Host");
        if ([buttonTitle isEqualToString:@"Upvote!"])
        {
            NSLog(@"Upvote!");
            
            [self upvoteSong];
            
 
            
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

//This function was taken and modified from this location
//http://stackoverflow.com/questions/17192716/ios-6-issue-convert-mpmediaitem-to-nsdata
//it transforms the MPMediaItem song into a NSData type

//************************ Turn Song Into Data ************************//

#pragma mark - turn song into data

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
}

//************************ Voting Methods ************************//

#pragma mark - voting methods

//this is called by the host when a song is to be upvoted
-(void)upvoteSong
{
    NSLog(@"Upvote!");
    
    //init variables
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSInteger totalPeers = [allPeers count];
    
    
    //if the song is not first in the queue
    if (_location != 0)
    {
        NSLog(@"Location != 0");
        [_playlistInfo addUpvote:_location];
        
        //check to see if the song is playing
        if (_location == 1 && [_coolPlayer isPlaying] == true)
        {
            NSLog(@"location is 1 and player is playing. upvotes added");
        }
        else
        {
            //add votes to song
            NSLog(@"all other conditions failed, do full upvote routine");
            NSInteger totalUpvotes = [_playlistInfo getUpvoteCount:_location];
            
            //if the total votes > 50% of the people in the room then move it to the top
            if (((totalUpvotes/totalPeers)*100) >= 50 && totalPeers > 2)
            {
                NSLog(@"Move Song to the top");
                [_playlistInfo moveSongToTop:_location];
                NSLog(@"insert code here that moves the songQueue to the top");
            }
            else //otherwise move it up one position
            {
                NSLog(@"Move Song up one position");
                [_songQueue exchangeObjectAtIndex:_location withObjectAtIndex:_location-1];
                [_playlistInfo moveSongUpOnePosition:_location];
            }
        }
    }
    else //this means the song is at the top and cant be upvoted anymore.
        NSLog(@"Location is equal to 0 - do nothing");
}

//this is called by the host when a song is to be downvoted
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
        //check to make sure it doesnt have 50% or more people hating
        if (downVotePercentage >= 50 && totalPeers > 1)
        {
            NSLog(@"Remove first song and play next");
            [_coolPlayer stop];
            
            [_playlistInfo removeSong:_location];
            [_songQueue removeObjectAtIndex:_location];
            
            //play the next song if there is one
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
        
    //if last in queue, just add downvotes, and check for >= 50
    }else if (_location == ([_playlistInfo countOfPlaylistInfo] - 1))
    {
        if (downVotePercentage >= 50 && totalPeers > 1)
        {
            NSLog(@"Remove last song");
            [_playlistInfo removeSong:_location];
            [_songQueue removeObjectAtIndex:_location];
        }
        //other, do general downvote routine
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

-(void)peerJoinedRoom:(NSNotification *)notification
{
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            NSLog(@"Received Notification - User has joined room");
            
            MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
            //NSString *peerDisplayName = peerID.displayName;
            NSError *error;
            NSMutableArray *deviceSendTo = [[NSMutableArray alloc] init];
            [deviceSendTo addObject:peerID];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[_playlistInfo getArray]];
            
            [_appDelegate.mpcController.session sendData:data
                                                 toPeers:deviceSendTo
                                                withMode:MCSessionSendDataReliable
                                                   error:&error];
        }];
    }
}

@end