//
//  AnarchyViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 2/22/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnarchyViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *play;
@property (nonatomic, strong) IBOutlet UIButton *stop;
@property (nonatomic, strong) IBOutlet UIButton *skip;
@property (nonatomic, strong) IBOutlet UIButton *anarchy;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)skip:(id)sender;
- (IBAction)anarchy:(id)sender;





@end
