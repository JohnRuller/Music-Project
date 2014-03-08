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

-(NSMutableArray*)fetchArray
{
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    return [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

- (id)init {
    if (self = [super init]) {
        
        //inits
        name = [[NSString alloc] init];
        tagline = [[NSString alloc] init];
        profilePhoto = [[UIImage alloc] init];
        artistsArray = [[NSArray alloc] init];
        profiles = [[NSMutableArray alloc] init];
        
        //set default profile data is none already exists
        if (![self hasProfileData]) {
            
            //
            
            // Create a new managed object
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *newProfile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
            [newProfile setValue:[UIDevice currentDevice].name forKey:@"name"];
            [newProfile setValue:@"I like music!" forKey:@"tagline"];
            [newProfile setValue:[UIImage imageNamed:@"defaultProfile.png"] forKey:@"photo"];
            
            }
        
        
    }
    return self;
}

-(bool) hasProfileData {
    
    //fecth data
    profiles = [self fetchArray];
    
    if([self.profiles count] != 0)
    {
        return YES;
        
    }
    else {
        return NO;
    }
}

@end
