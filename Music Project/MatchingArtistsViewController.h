//
//  MatchingArtistsViewController.h
//  Music Project
//
//  Created by John Ruller on 2014-03-30.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchingArtistsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)back:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *artistsTable;
@property (strong, nonatomic) IBOutlet UILabel *tableLabel;

@property (strong) NSArray *matchingArtists;


@end
