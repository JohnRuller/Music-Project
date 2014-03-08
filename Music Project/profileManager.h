//
//  profileManager.h
//  Music Project
//
//  Created by John Ruller on 2014-03-03.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface profileManager : NSObject

//array to store managedObjects for core data
@property (strong) NSMutableArray *profiles;

//profile data
@property (strong) NSString *name;
@property (strong) NSString *tagline;
@property (strong) UIImage *profilePhoto;
@property (strong) NSArray *artistsArray;

@end
