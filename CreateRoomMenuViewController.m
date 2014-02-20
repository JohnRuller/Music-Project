  //
//  CreateRoomMenuViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 1/24/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

@import MediaPlayer;

#import "CreateRoomMenuViewController.h"

@interface CreateRoomMenuViewController ()
@property (weak,nonatomic) IBOutlet UITextField *myTextField;

- (IBAction)createRoom:(id)sender;

@end

@implementation CreateRoomMenuViewController
//@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.roomName = self.myTextField.text;
    if([segue.identifier isEqualToString:@"showDetailSegue"]){
        CreateRoomViewController *controller = (CreateRoomViewController *)segue.destinationViewController;
        controller.thisRoomName = self.roomName;
    }
}


- (IBAction)finishedEditing:(id)sender
{
    
}



@end
