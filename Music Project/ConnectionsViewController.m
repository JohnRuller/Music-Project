//
//  ConnectionsViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"
#import "profileManager.h"
#import "ViewGuestProfileViewController.h"
#import "MainTabBarViewController.h"

@interface ConnectionsViewController ()

//multipeer stuff
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
@property (nonatomic, weak) IBOutlet UILabel *testLabel;
@property (nonatomic, weak) IBOutlet UIButton *browseButton;
@property (strong) NSString *isHost;

//profile data stuff
-(void)sendProfileData:(MCPeerID *)peerID;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;
-(bool)hasProfileData:(NSString *)name;
-(int)profileIndex:(NSString *)name;
@property (strong) NSDictionary *profileData;
@property (strong) NSMutableArray *guestProfiles;

//refresh property
@property (nonatomic,retain) UIRefreshControl *refreshControl;
-(void)refreshTable;

@end

@implementation ConnectionsViewController

//local vars
profileManager *userProfile;
UITabBarController *tbc;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //initializers
    userProfile = [[profileManager alloc] init];
    _isHost = [[NSString alloc] init];
    tbc = self.tabBarController;
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    self.guestProfiles = [[NSMutableArray alloc] init];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //setup peer and session
    if([userProfile hasProfileData]) {
        [[_appDelegate mpcController] setupPeerAndSessionWithDisplayName:userProfile.name];
    }
    else {
        [[_appDelegate mpcController] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    }
    
    //setup mymanager
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        NSLog(@"Setting user as non-advertising host.");
        //host does not want to advertise
        [[_appDelegate mpcController] advertiseSelf:NO];
    
        //set host values
        _isHost = @"YES";
        //_testLabel.text = @"HOST";
        //_appDelegate.hostName = userProfile.name;
    
        //show browse button
        _browseButton.enabled = YES;
        _browseButton.hidden = NO;
    }
    else {
    
        NSLog(@"Setting user as advertising guest.");
        //guest wants to advertise
        [_appDelegate.mpcController advertiseSelf:YES];
    
        //set guest values
        _isHost = @"NO";
        //_testLabel.text = @"GUEST";
    
        //hide browse button
        _browseButton.enabled = NO;
        _browseButton.hidden = YES;
    }
    
    //store values from profile managed object
    NSString *name = [NSString stringWithFormat:@"%@",userProfile.name];
    NSString *tagline = [NSString stringWithFormat:@"%@",userProfile.tagline];
    UIImage *image = [UIImage imageWithData:userProfile.profilePhoto];
    NSArray *artistsArray = [[NSArray alloc] init];
    NSArray *guestArtistsArray = [[NSArray alloc] init];
    NSString *rating = [[NSString alloc] init];
    UIImage *compBarImage = [[UIImage alloc] init];
    artistsArray = userProfile.artistsArray;
    //NSLog(@"Artists array count in connections: %lu", (unsigned long)[artistsArray count]);
    
    //compress image for better sending time
    UIGraphicsBeginImageContext(CGSizeMake(90,90));
    [image drawInRect:CGRectMake(0,0,90,90)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = newImage;

    //pass profile data into dictionary
    self.profileData = [[NSDictionary alloc] init];
    self.profileData = [NSDictionary dictionaryWithObjectsAndKeys: _isHost, @"isHost", name, @"name", tagline, @"tagline", image, @"image", artistsArray, @"artists", guestArtistsArray, @"guestArtists", rating, @"rating", compBarImage, @"compBarImage", nil];
    
    //profile observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    //did change state observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    //setup table
    [_tblConnectedDevices setDelegate:self];
    [_tblConnectedDevices setDataSource:self];
    
    //refresh stuff
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tblConnectedDevices;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory warning on connections view controller.");

}

- (void)refreshTable
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //refresh table
        [_tblConnectedDevices reloadData];
    
        [self.refreshControl performSelector:@selector(endRefreshing)];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewProfile"]) {

        //get table index of guest profile
        NSString *peerID = [_arrConnectedDevices objectAtIndex:[[_tblConnectedDevices indexPathForSelectedRow] row]];
        
        //make sure profile data exists
        if([self hasProfileData:peerID]) {
            
            //find index of guest profile
            int profileIndex = [self profileIndex:peerID];
            NSDictionary *guestDictionary = [[NSDictionary alloc] init];
            guestDictionary = [self.guestProfiles objectAtIndex:profileIndex];
            
            //send guest profile data over to next view controller
            ViewGuestProfileViewController *destViewController = segue.destinationViewController;
            destViewController.guestDictionary = guestDictionary;
        }
      
    }
}


#pragma mark - Public method implementation

- (IBAction)browseForDevices:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[_appDelegate mpcController] setupMCBrowser];
        [[[_appDelegate mpcController] browser] setDelegate:self];
        [self presentViewController:[[_appDelegate mpcController] browser] animated:YES completion:nil];
    }];
}

- (IBAction)disconnect:(id)sender {
    
        //send disconnect data
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self sendDisconnectData];
        }];
    
        //run disconnect method after delay
        [self performSelector:@selector(disconnectFunc) withObject:self afterDelay:3.0 ];
    
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)disconnectFunc {
    [_appDelegate.mpcController.session disconnect];
    [_arrConnectedDevices removeAllObjects];
    [self.guestProfiles removeAllObjects];
    [[_appDelegate mpcController] advertiseSelf:NO];
    
}

#pragma mark - MCBrowserViewControllerDelegate method implementation

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
       
        [_appDelegate.mpcController.browser dismissViewControllerAnimated:YES completion:nil];
    
        //reload table data
        [_tblConnectedDevices reloadData];
         NSLog(@"Refreshing table data after dismissing browser view controller.");
    }];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
     [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
         [_appDelegate.mpcController.browser dismissViewControllerAnimated:YES completion:nil];
     }];
}


#pragma mark - Private method implementation

//send profile data over
-(void)sendProfileData:(MCPeerID *)peerID{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSLog(@"Sending profile data to %@.", peerID.displayName);
        
        NSError *error;
        NSMutableArray *deviceSendTo = [[NSMutableArray alloc] init];
        [deviceSendTo addObject:peerID];
        
        NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:self.profileData];
        
        [_appDelegate.mpcController.session sendData:dataToSend
                                         toPeers:deviceSendTo
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)sendDisconnectData {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSLog(@"Sending disconnect data to all peers.");
        
        NSDictionary *disconnectData = [[NSDictionary alloc] init];
        disconnectData = [NSDictionary dictionaryWithObjectsAndKeys:@"Disconnect", @"type", nil];
        NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:[disconnectData copy]];
        NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
        NSError *error;
        
        [_appDelegate.mpcController.session sendData:dataToSend
                                             toPeers:allPeers
                                            withMode:MCSessionSendDataReliable
                                               error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        
    }];
}


-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        //get notifier user info
        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        NSString *peerDisplayName = peerID.displayName;
        
        NSLog(@"Receiving data from %@ in the connections view.", peerDisplayName);
        
        //receive data
        NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
        NSLog(@"The length of the data being received is %lu bytes.", (unsigned long)[receivedData length]);
        
        id myObject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
        //ensure it is a dictionary
        if ([myObject isKindOfClass:[NSDictionary class]]){
            
            //set dictionary values
            NSMutableDictionary *dic = [myObject mutableCopy];
            NSString *type = [dic objectForKey:@"type"];
            
            //if it doesn't have a type, then it's profile data
            if (type == nil && ![self hasProfileData:peerDisplayName])
            {
                //get compatability rating
                NSDictionary *compatabilityDictionary = [[NSDictionary alloc] init];
                NSArray *guestArtists = [[NSArray alloc] init];
                guestArtists = [dic objectForKey:@"artists"];
                compatabilityDictionary = [userProfile getArtistsDictionary:guestArtists];
                
                //set compatability in dictionary
                [dic setObject:[compatabilityDictionary objectForKey:@"rating"] forKey:@"rating"];
                [dic setObject:[compatabilityDictionary objectForKey:@"compBar"] forKey:@"compBarImage"];
                [dic setObject:[compatabilityDictionary objectForKey:@"artists"] forKey:@"guestArtists"];
                
                //add profile data to profile array
                NSLog(@"Adding %@'s profile data in array.", peerDisplayName);
                [self.guestProfiles addObject:dic];
                NSLog(@"Current number of entries in profile data array: %lu", (unsigned long)[self.guestProfiles count]);
                
                //set host name in app delegate
                if([[dic objectForKey:@"isHost"] isEqualToString:@"YES"]) {
                    
                    NSString *hostName = [dic objectForKey:@"name"];
                    NSLog(@"Setting host name to %@ in app delegate.", hostName);
                    _appDelegate.hostName = hostName;
                }
            
                //refresh table
                NSLog(@"Refreshing table data after receiving profile and setting it.");
                [_tblConnectedDevices reloadData];
                    
                // Post a notification that a peer has joined the room
                [[NSNotificationCenter defaultCenter]
                postNotificationName:@"peerJoinedRoom" object:nil userInfo:[notification userInfo]];
            }
            else if ([type isEqualToString:@"Disconnect"]) {
                NSLog(@"%@ has disconnected from the room.", peerDisplayName);
                
                NSInteger indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
                int indexOfProfile = [self profileIndex:peerDisplayName];
                [self.guestProfiles removeObjectAtIndex:indexOfProfile];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [_tblConnectedDevices reloadData];
                }];
                
                // Post a notification that a peer has left the room
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"peerLeftRoom" object:nil userInfo:[notification userInfo]];
                
                if([peerDisplayName isEqualToString:_appDelegate.hostName]) {
                    [self disconnectFunc];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
    }];
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    
    //get notifier user info
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    //if not connecting
    if (state != MCSessionStateConnecting)
    {
        //if connected
        if (state == MCSessionStateConnected) {
            
            //add peer to connected devices
            [_arrConnectedDevices addObject:peerDisplayName];
            
            //send profile data
            NSLog(@"Calling send profile data from didChangeState for %@.", peerDisplayName);
            [self sendProfileData:peerID];
        }
        //if not connected
        else if (state == MCSessionStateNotConnected){
            NSLog(@"%@ didChangeState to disconnected.", peerDisplayName);
            /*
            if ([_arrConnectedDevices count] > 0) {
                
                //disconnect device
                int indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                if(indexOfPeer > 0 && indexOfPeer < 8) {
                    NSLog(@"Disconnecting %@ in didChangeState.", peerDisplayName);

                    [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
                    
                    if([self hasProfileData:peerDisplayName]) {
                        int indexOfProfile = [self profileIndex:peerDisplayName];
                        [self.guestProfiles removeObjectAtIndex:indexOfProfile];
                    }
                    
                    
                    // Post a notification that a peer has left the room
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"peerLeftRoom" object:nil userInfo:[notification userInfo]];
                    
                    if([peerDisplayName isEqualToString:_appDelegate.hostName]) {
                        [self disconnectFunc];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    
                }
                
            }
             */
        }
        
        //reload table data
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tblConnectedDevices reloadData];
        }];
        
        //determine if peers exist in room
        BOOL peersExist = ([[_appDelegate.mpcController.session connectedPeers] count] == 0);
        //[_btnDisconnect setEnabled:!peersExist];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            
            //set tabs if not host
            if([_isHost isEqualToString:@"NO"]) {
                //set hidden tabs
                if(!peersExist) {
                    
                    NSLog(@"Peers exist in room.");
                    [[[[tbc tabBar]items]objectAtIndex:1]setEnabled:TRUE];
                    [[[[tbc tabBar]items]objectAtIndex:2]setEnabled:TRUE];
                }
                else {
                    
                    NSLog(@"Peers do not exist in room.");
                    [[[[tbc tabBar]items]objectAtIndex:1]setEnabled:FALSE];
                    [[[[tbc tabBar]items]objectAtIndex:2]setEnabled:FALSE];
                }
            }
          
        }];
    }
}

-(bool)hasProfileData:(NSString *)name{
    //determine if received profile data exists in connected devices list
    for(int i=0; i<[self.guestProfiles count]; i++)
    {
        if([[[self.guestProfiles objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]) {
            return true;
        }
    }
    return false;
}

-(int)profileIndex:(NSString *)name{
    //determine index of connected device
    for(int i=0; i<[self.guestProfiles count]; i++)
    {
        if([[[self.guestProfiles objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]) {
            return i;
        }
    }
    return -1;
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    //set peer name
    NSString *peerID = [_arrConnectedDevices objectAtIndex:indexPath.row];
    UILabel *profileNameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    [profileNameLabel setText:peerID];
    NSLog(@"Set %@'s name in connections table.", peerID);
    
    //set profile data if it has been received and matches a connected device
    if([self hasProfileData:[_arrConnectedDevices objectAtIndex:indexPath.row]])
    {
        NSLog(@"%@'s profile data macthes a connected device - setting in table now.", peerID);
        
        //get index of profile
        int profileIndex = [self profileIndex:peerID];
        
        //set the profile image
        UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:100];
        profileImageView.image = [[self.guestProfiles objectAtIndex:profileIndex] objectForKey:@"image"];
        
        // set image layer circular
        CALayer * l = [profileImageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:45.0];
        [l setBorderWidth:0.25];
        [l setBorderColor:[[UIColor blackColor] CGColor]];
        
        //set tagline
        UILabel *profileTaglineLabel = (UILabel *)[cell viewWithTag:102];
        [profileTaglineLabel setText:[[self.guestProfiles objectAtIndex:profileIndex] objectForKey:@"tagline"]];
    
        //set compatability
        UILabel *profileCompatabilityRating = (UILabel *)[cell viewWithTag:103];
        //set compatability
        [profileCompatabilityRating setText:[NSString stringWithFormat:@"Your artists compatability is %@", [[self.guestProfiles objectAtIndex:profileIndex] objectForKey:@"rating"]]];
        UIImageView *compBarImageView = (UIImageView *)[cell viewWithTag:105];
        compBarImageView.image = [[self.guestProfiles objectAtIndex:profileIndex] objectForKey:@"compBarImage"];
        
        //set room identifier
        UIImageView *identifierImageView = (UIImageView *)[cell viewWithTag:107];
        if([_appDelegate.hostName isEqualToString:peerID]) {
            identifierImageView.image = [UIImage imageNamed:@"Host.png"];
        }
        else {
            identifierImageView.image = [UIImage imageNamed:@"Guest.png"];
        }
        
        
    }
    
    return cell;
}

//commented this out due to custom storyboard height setting
/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 60.0;
 }*/


@end