//
//  peerPlaylist.h
//  Music Project
//
//  Created by Ryan Fraser on 3/2/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@import MediaPlayer;


@interface peerPlaylist : NSObject <MPMediaPickerControllerDelegate>

@property (strong, nonatomic) NSMutableArray *playlistInfo;

- (void)addSongFromHost:(MPMediaItem *) song;
- (void)addSongFromGuest:(NSDictionary *) song;
- (NSDictionary *)makeDictionaryItem: (MPMediaItem *)song;
- (void)updatePlaylist:(NSMutableArray *)receivedPlaylist;
- (void)removeSong:(NSInteger) location;
- (NSMutableArray *)getArray;
- (void)playlistUpvote:(NSInteger)loc; 
- (void)playlistDownvote:(NSInteger)loc;
- (NSInteger)countOfPlaylistInfo;
- (BOOL)upvoteSongAtLocation:(NSInteger)loc :(NSInteger)peerCount;
- (BOOL)downvoteSongAtLocation:(NSInteger)loc :(NSInteger)peerCount;
- (void)moveSongToTop:(NSInteger)loc;



@end
