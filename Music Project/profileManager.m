//
//  profileManager.m
//  Music Project
//
//  Created by John Ruller on 2014-03-03.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "profileManager.h"

@implementation profileManager

@synthesize name;
@synthesize tagline;
@synthesize profilePhoto;
@synthesize artistsArray;
@synthesize profiles;

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

@end
