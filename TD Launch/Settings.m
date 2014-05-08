//
//  Settings.m
//  TD Launch
//
//  Created by Kent Anderson on 9/16/13.
//
//

#import "Settings.h"


Settings* _globalSettings = nil;



@implementation Settings

- (id) init
{
    if (self = [super init])
    {
        _sound = YES;
        _gameCenter = YES;
        _showCharacterTutorial = YES;
        _showObjectTutorial = YES;
        _showDrawerTutorial = YES;
        _showRotateTutorial = YES;
    }
    return self;
}


- (BOOL) showTutorial
{
    return _showCharacterTutorial || _showObjectTutorial || _showDrawerTutorial || _showRotateTutorial;
}

+ (Settings*) globalSettings
{
    if (_globalSettings == nil)
    {
        NSString* path = [self settingsFilePath];
        NSData* codedData = [[NSData alloc] initWithContentsOfFile:path];
        
        if (codedData != nil)
        {
            NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
            _globalSettings = [unarchiver decodeObjectForKey:@"settings"];
        }
        else
        {
            _globalSettings = [[Settings alloc] init];
            [_globalSettings save];
        }

    }
    return _globalSettings;
}

+ (NSString*) settingsFilePath
{
    return[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                       objectAtIndex:0] stringByAppendingPathComponent:@"settings.dat"];
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:_sound forKey:@"sound"];
    [coder encodeBool:_gameCenter forKey:@"gamecenter"];
    [coder encodeBool:_showCharacterTutorial forKey:@"chtutorial"];
    [coder encodeBool:_showObjectTutorial forKey:@"objtutorial"];
    [coder encodeBool:_showDrawerTutorial forKey:@"drwtutorial"];
    [coder encodeBool:_showRotateTutorial forKey:@"rottutorial"];
}



- (id) initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        _sound = [decoder decodeBoolForKey:@"sound"];
        if ([decoder containsValueForKey:@"gamecenter"])
            _gameCenter = [decoder decodeBoolForKey:@"gamecenter"];
        _showCharacterTutorial = [decoder decodeBoolForKey:@"chtutorial"];
        _showObjectTutorial = [decoder decodeBoolForKey:@"objtutorial"];
        _showDrawerTutorial = [decoder decodeBoolForKey:@"drwtutorial"];
        _showRotateTutorial = [decoder decodeBoolForKey:@"rottutorial"];
    }
    return self;
}


- (void) save
{
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_globalSettings forKey:@"settings"];
    [archiver finishEncoding];
    [data writeToFile:[self.class settingsFilePath] atomically:YES];
}

@end

