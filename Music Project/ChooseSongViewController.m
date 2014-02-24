//
//  ChooseSongViewController.m
//  Music Project
//
//  Created by Ryan Fraser on 2/23/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ChooseSongViewController.h"
#import "myManager.h"

@interface ChooseSongViewController ()

@property (strong, nonatomic) NSMutableArray *songs;


@end

@implementation ChooseSongViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    MyManager *sharedManager = [MyManager sharedManager];
    if ([sharedManager.someProperty isEqualToString:@"YES"])
    {
//        MPMediaQuery *everything = [[MPMediaQuery alloc] init];
//        
//        NSArray *songs = [everything items];
//        MPMediaItemCollection *mediaCollection = [MPMediaItemCollection collectionWithItems:songs];
//        
//        MPMediaQuery *allLibrary = [[MPMediaQuery alloc]init];
//        [allLibrary setGroupingType:MPMediaGroupingTitle];
//        [_musicPlayer setQueueWithQuery:allLibrary];
        
        NSMutableString *outText = [[NSMutableString alloc] initWithString:@"Albums:"];
        [outText appendFormat:@"\r\n count:%i",[[[MPMediaQuery albumsQuery] collections] count]];
        for (MPMediaItemCollection *collection in [[MPMediaQuery albumsQuery] collections]) {
            [outText appendFormat:@"\r\n -%@",[[collection representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle]];
        }
        
        [outText appendString:@"\r\n\r\n Artist:"];
        
        
    }
    else{
        //_chooseSong.enabled = NO;
        //_chooseSong.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
