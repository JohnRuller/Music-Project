//
//  ConnectionsViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

@interface ConnectionsViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
@property (nonatomic, weak) IBOutlet UILabel *testLabel;

//array to store managedObjects for core data
@property (strong) NSMutableArray *profiles;
@property (strong) NSMutableArray *test;


-(void)sendProfileData;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;


@end

@implementation ConnectionsViewController

//managedObject for core data
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    self.profiles = [[NSMutableArray alloc]init];
    //[[self.profiles addObject:[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy]];
    self.profiles = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    self.test = [[NSMutableArray alloc]init];
    NSString *testString = @"test";
    [self.test addObject:testString];


    
    //profile observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        _testLabel.text = @"YAY";
        _hostName = [UIDevice currentDevice].name;
        NSLog(@"%@", _hostName);
    }
    else{
        _testLabel.text = @"NAY";
    }
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //set the name
    if([self.profiles count] != 0)
    {
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [[_appDelegate mpcController] setupPeerAndSessionWithDisplayName:[profile valueForKey:@"name"]];

    }
    else{
        [[_appDelegate mpcController] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];

        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    
    [_tblConnectedDevices setDelegate:self];
    [_tblConnectedDevices setDataSource:self];
    [_appDelegate.mpcController advertiseSelf:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Public method implementation

- (IBAction)browseForDevices:(id)sender {
    [[_appDelegate mpcController] setupMCBrowser];
    [[[_appDelegate mpcController] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mpcController] browser] animated:YES completion:nil];
}


/*- (void)toggleVisibility
{
    [_appDelegate.mpcController advertiseSelf:YES];
}*/



- (IBAction)disconnect:(id)sender {
    [_appDelegate.mpcController.session disconnect];
    
    [_arrConnectedDevices removeAllObjects];
    [_tblConnectedDevices reloadData];
}

- (IBAction)sendDataButton:(id)sender {
    [self sendProfileData];
}


#pragma mark - MCBrowserViewControllerDelegate method implementation

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mpcController.browser dismissViewControllerAnimated:YES completion:nil];
    
    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
        [_appDelegate.mpcController advertiseSelf:YES];

    }
    else{
        [_appDelegate.mpcController advertiseSelf:NO];
    }

    /*
    NSString *message = @"WhoseHost?";
    NSString *returnTo = [UIDevice currentDevice].name;
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;
    
    [_appDelegate.mpcController.session sendData:dataToSend
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];*/
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    
    [_appDelegate.mpcController.browser dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private method implementation

//send profile data over
-(void)sendProfileData{
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:self.test];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;
    
    [_appDelegate.mpcController.session sendData:dataToSend
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    
    NSLog(@"sending profile");

    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    id myObject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    NSLog(@"receiving profile");
    
    if ([myObject isKindOfClass:[NSArray class]]){
        
        //Handle
        //NSManagedObject *profile = [myObject objectAtIndex:0];
        
        //NSString *tagline = [NSString stringWithFormat:@"%@",[profile valueForKey:@"tagline"]];
        
        NSLog(@"if array");

        

    }

}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_arrConnectedDevices addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                int indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
        [_tblConnectedDevices reloadData];
        
        BOOL peersExist = ([[_appDelegate.mpcController.session connectedPeers] count] == 0);
        [_btnDisconnect setEnabled:!peersExist];
    }
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
    
    cell.textLabel.text = [_arrConnectedDevices objectAtIndex:indexPath.row];
    
    NSManagedObject *profile = [self.profiles objectAtIndex:0];
    UIImage *image = [UIImage imageWithData:[profile valueForKey:@"photo"]];
    cell.imageView.image = image;

    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


@end
