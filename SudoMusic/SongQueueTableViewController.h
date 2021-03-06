//
//  SongQueueTableViewController.h
//  SudoMusic
//
//  Created by Hongyu Li on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "TSLibraryImport.h"

@interface SongQueueTableViewController : UITableViewController

@property NSArray *songs;
@property NSArray *artists;
@property NSArray *upvotes;
@property NSArray *downvotes;
@property NSArray *songIDs;
@property NSString *server;
@property NSInteger nowPlayingIndex;

@end
