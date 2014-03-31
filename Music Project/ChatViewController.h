//
//  ChatViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITextFieldDelegate, UITabBarDelegate>

//text
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITextView *tvChat;

//buttons
- (IBAction)sendMessage:(id)sender;
- (IBAction)cancelMessage:(id)sender;

@end