//
//  peerPlaylist.m
//  Music Project
//
//  Created by Ryan Fraser on 3/2/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "peerPlaylist.h"

@implementation peerPlaylist

- (id)init
{
    self = [super init];
    
    NSLog(@"Init Playlist");
    
    _playlistInfo = [[NSMutableArray alloc] init];
    return  self;
    
}

- (void) addSongFromHost:(MPMediaItem *)song
{
    NSDictionary *newSong = [self makeDictionaryItem:song];
    [_playlistInfo addObject:newSong];
}

- (void)addSongFromGuest:(NSDictionary *)song
{
    [_playlistInfo addObject:song];
}

- (NSDictionary *)makeDictionaryItem:(MPMediaItem *)song
{
    NSString *songNameString = [song valueForProperty:MPMediaItemPropertyTitle] ? [song valueForProperty:MPMediaItemPropertyTitle] : @"";
    NSString *artistNameString = [song valueForProperty:MPMediaItemPropertyArtist] ? [song valueForProperty:MPMediaItemPropertyArtist] : @"";
    NSString *albumNameString = [song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [song valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
    
    MPMediaItemArtwork *artz = [song valueForProperty:MPMediaItemPropertyArtwork];
    if (artz)
    {
        //UIImage *art = [artz imageWithSize:_albumArt.frame.size];
        
    }
    //UIImage *smallArt = [artz imageWithSize:self.albumImage.frame.size];
    
    
    NSNumber *nada = [[NSNumber alloc] initWithInt:0];
    NSMutableDictionary *newSong = [[NSMutableDictionary alloc] init];
    
    [newSong removeAllObjects];
    [newSong setObject:songNameString forKey:@"songTitle"];
    [newSong setObject:artistNameString forKey:@"artistName"];
    [newSong setObject:albumNameString forKey:@"albumName"];
    //another one that gets the device name
    //[newSong setObject:art forKey:@"albumArt"];
    [newSong setObject:nada forKey:@"votes"];
    [newSong setObject:@"newSong" forKey:@"type"];
    
    return newSong;
}

-(void)removeSong:(NSInteger)location
{
    [_playlistInfo removeObjectAtIndex:location];
}

-(NSMutableArray *)getArray
{
    return _playlistInfo;
}

-(void)updatePlaylist:(NSMutableArray *)receivedPlaylist
{
    _playlistInfo = [receivedPlaylist copy];
}

-(void)playlistUpvote:(NSInteger)loc
{

        [_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc-1];
}

-(void)playlistDownvote:(NSInteger)loc
{
    [_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc+1];
}

- (NSInteger)countOfPlaylistInfo
{
    return [_playlistInfo count];
}


@end

