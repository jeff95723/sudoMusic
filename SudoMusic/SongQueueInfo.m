//
//  SongQueueInfo.m
//  SudoMusic
//
//  Created by Fan Xia on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import "SongQueueInfo.h"

@implementation SongQueueInfo

- (id) initWithName:(NSString*) name Artist:(NSString*) artist Album:(NSString*) album Artwork:(UIImage*) artwork Status:(int) status Progress:(NSProgress*) progress
{
    if (self = [super init]) {
        self.name = name;
        self.artist = artist;
        self.album = album;
        self.artwork = artwork;
        self.status = status;
        self.progress = progress;
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.album forKey:@"album"];
    [aCoder encodeObject:self.artwork forKey:@"artwork"];
    [aCoder encodeInt:self.status forKey:@"status"];
    [aCoder encodeObject:self.progress forKey:@"progress"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    NSString* name = [aDecoder decodeObjectForKey:@"name"];
    NSString* artist = [aDecoder decodeObjectForKey:@"artwork"];
    NSString* album = [aDecoder decodeObjectForKey:@"album"];
    UIImage* artwork = [aDecoder decodeObjectForKey:@"artwork"];
    int status = [aDecoder decodeIntForKey:@"status"];
    NSProgress* progress = [aDecoder decodeObjectForKey:@"progress"];
    return [self initWithName:name Artist:artist Album:album Artwork:artwork Status:status Progress:progress];
}

@end
