//
//  AnarchyViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/22/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "AnarchyViewController.h"
#import "AppDelegate.h"

@interface AnarchyViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

- (void)send:(NSString *)pass;
- (void)didReceiveDataWithNotification:(NSNotification *)notification;

@end

@implementation AnarchyViewController

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
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
	// Do any additional setup after loading the view.
    
}

- (IBAction)play:(id)sender
{
    NSString *note = @"play";
    [self send:note];
}

- (IBAction)stop:(id)sender
{
    NSString *note = @"stop";
    [self send:note];
}

- (IBAction)skip:(id)sender
{
    NSString *note = @"skip";
    [self send:note];
}

- (IBAction)anarchy:(id)sender
{
    NSString *note = @"anarchy";
    [self send:note];
}

- (void)send:(NSString *) type
{
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"anarchy" forKey:@"type"];
    [dic setValue:type forKey:@"kind"];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    [_appDelegate.mpcController.session sendData:data
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    //});
}

- (void)didReceiveDataWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    if ([myobject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:myobject];
        if ([dic objectForKey:@"type"] != nil)
        {
            NSString *kind = [dic objectForKey:@"kind"];
            if ([kind isEqualToString:@"play"])
            {
                
            }
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
