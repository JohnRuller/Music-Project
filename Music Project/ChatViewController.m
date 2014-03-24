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
-(void)peerJoinedRoom:(NSNotification *)notification;
-(void)updateNewBadge;


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
    _txtMessage.returnKeyType = UIReturnKeyDone;

    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    // Register observer to be called when a peer has joined the room
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerJoinedRoom:)
                                                 name:@"peerJoinedRoom" object:nil];
        
    // Register observer to be called when a peer has joined the room
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerLeftRoom:)
                                                 name:@"peerLeftRoom" object:nil];

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//function to resign keyboard when background is touched
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(![_txtMessage.text isEqualToString:@""])
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            //Your code goes in here
        [self sendMyMessage];
        }];
    else
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            //Your code goes in here
        [_txtMessage resignFirstResponder];
        }];

    return YES;
}

/*
 functions for pushing the screen up when the keyboard is brought up: http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    [self animateTextField: textField up: YES];
    }];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    [self animateTextField: textField up: NO];
    }];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    const int movementDistance = 160; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    }];
}


#pragma mark - IBAction method implementation

- (IBAction)sendMessage:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    if(![_txtMessage.text isEqualToString:@""])
        [self sendMyMessage];
    }];
}

- (IBAction)cancelMessage:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    _txtMessage.text = @"";
    [_txtMessage resignFirstResponder];
    }];
}


#pragma mark - Private method implementation

-(void)peerJoinedRoom:(NSNotification *)notification {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSLog(@"Received Notification - User has joined room.");
    
        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        NSString *peerDisplayName = peerID.displayName;
        
        if ([peerDisplayName isEqualToString:[_appDelegate hostName]]) {
            [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"You joined %@'s room.\n\n", peerDisplayName]] waitUntilDone:NO];
        }
        else {
            [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ joined the room.\n\n", peerDisplayName]] waitUntilDone:NO];
        }
    
        [self scrollTextViewToBottom:_tvChat];
    
        [self updateNewBadge];
    }];
}

-(void)peerLeftRoom:(NSNotification *)notification {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        NSLog(@"Received Notification - User has left room");
        
        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        NSString *peerDisplayName = peerID.displayName;
        
        [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ left the room.\n\n", peerDisplayName]] waitUntilDone:NO];
        
        [self scrollTextViewToBottom:_tvChat];
        
        [self updateNewBadge];
    }];
}

-(void)updateNewBadge {
    
    if(!self.view.window) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tabBarItem setBadgeValue:@"New"];
        }];
    }
  
}

//Function to scroll text to bottom: http://stackoverflow.com/questions/16698638/textview-scroll-textview-to-bottom?answertab=oldest
-(void)scrollTextViewToBottom:(UITextView *)textView {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    }];
    
}


-(void)sendMyMessage{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
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
    
    [self scrollTextViewToBottom:_tvChat];
    }];
}


-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    id myobject = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    
    if ([myobject isKindOfClass:[NSString class]])
    {
        NSLog(@"Received chat message.");
        NSString *receivedText = [[NSString alloc] initWithString:myobject];
        [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
        
        [self scrollTextViewToBottom:_tvChat];

        [self updateNewBadge];
    }
        
    }];
    
   
    
    
         
    //NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
}

@end
