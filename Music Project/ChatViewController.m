//
//  ChatViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"


@interface ChatViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end

@implementation ChatViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tabBarItem setBadgeValue:nil];
    }];
}

- (void)loadView {
    [super loadView];
    NSLog(@"Loading chat view controller.");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tabBarItem setBadgeValue:nil];
    }];

    [self viewDidLoad];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _txtMessage.delegate = self;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMyMessage];
    return YES;
}

/*
 functions for pushing the screen up when the keyboard is brought up: http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 160; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


#pragma mark - IBAction method implementation

- (IBAction)sendMessage:(id)sender {
    [self sendMyMessage];
}

- (IBAction)cancelMessage:(id)sender {
    [_txtMessage resignFirstResponder];
}


#pragma mark - Private method implementation

-(void)sendMyMessage{
    NSString *textString = _txtMessage.text;
    //NSData *dataToSend = [_txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:[textString copy]];
    NSArray *allPeers = _appDelegate.mpcController.session.connectedPeers;
    NSError *error;
    
    [_appDelegate.mpcController.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_tvChat setText:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _txtMessage.text]]];
    [_txtMessage setText:@""];
    [_txtMessage resignFirstResponder];
}


-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    
    if ([myobject isKindOfClass:[NSString class]])
    {
        NSLog(@"out");
        NSString *receivedText = [[NSString alloc] initWithString:myobject];
        [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tabBarItem setBadgeValue:@"New"];
        }];
    }
    
   
    
    
         
    //NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
}

@end
