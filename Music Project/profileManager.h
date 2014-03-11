//
//  profileManager.h
//  Music Project
//
//  Created by John Ruller on 2014-03-03.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMediaItemCollection.h>

@interface profileManager : NSObject

//array to store managedObjects for core data
@property (strong) NSMutableArray *profiles;

//profile data
@property (strong) NSString *name;
@property (strong) NSString *tagline;
@property (strong) NSData *profilePhoto;
@property (strong) NSArray *artistsArray;

//functions
-(bool) hasProfileData;
-(void)fetchArray;

-(NSString*)name;
-(NSString*)tagline;
-(NSData*)profilePhoto;
-(NSArray*)artistsArray;

-(void) setName:(NSString *)newName;
-(void) setTagline:(NSString *)newTagline;
-(void) setProfilePhoto:(UIImage *)newProfilePhoto;
-(void) setArtistsArray:(NSArray *)newArtistsArray;
-(void) setupArtistsArray;

-(void) saveData;

-(int) getCompatabilityInt:(NSArray *)guestArtists;
-(NSString *) getCompatabilityRating:(NSArray *)guestArtists;

-(NSDictionary*)getArtistsDictionary:(NSArray *)guestArtists;




@end
