//
//  SongQueueInfo.h
//  SudoMusic
//
//  Created by Fan Xia on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SongQueueInfo : NSObject <NSCoding>

@property NSString* name;
@property NSString* artist;
@property NSString* album;
@property UIImage* artwork;

@property int status;
@property NSProgress* progress;

- (id) initWithName:(NSString*) name Artist:(NSString*) artist Album:(NSString*) album Artwork:(UIImage*) artwork Status:(int) status Progress:(NSProgress*) progress;

@end
