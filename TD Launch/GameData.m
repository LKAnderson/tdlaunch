
//
//  GameData.m
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import "GameData.h"



@implementation AvailableFieldObject
@end

@implementation ActiveFieldObject


- (void) addAnimation:(Animation *)animation
{
    if (!_animations)
        _animations = [NSMutableArray array];
    [_animations addObject:animation];
}

- (void) setAnimationBody:(ChipmunkBody *)body
{
    for (Animation* anim in _animations)
        anim.body = body;
}

- (void) applySettings:(FieldObjectSettings *)settings
{
    _settings = settings;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:_definition.type forKey:@"definition"];
    [coder encodeCGPoint:_position forKey:@"position"];
    [coder encodeObject:_settings forKey:@"settings"];
}



- (id) initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        _position = [decoder decodeCGPointForKey:@"position"];
        _settings = [decoder decodeObjectForKey:@"settings"];

        FieldObjectType type = [decoder decodeIntForKey:@"definition"];
        _definition = [FieldObjectFactory fieldObjectForType:type];
    }
    return self;
}


@end


@implementation LogEvent
@end



@implementation GameData


- (id) init
{
    if (self = [super init])
    {
        _selectedCharacter = [CharacterDefinition Steve];
        _gameLog = [NSMutableArray arrayWithCapacity:25];
        _activeFieldObjects = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
    
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:_selectedCharacter.type forKey:@"charactertype"];
    [coder encodeObject:_activeFieldObjects forKey:@"activefieldobjects"];
    
    [coder encodeInt:_score forKey:@"score"];
    [coder encodeInt:_gems forKey:@"gems"];
    [coder encodeInt:_distance forKey:@"distance"];
    [coder encodeInt:_overallStars forKey:@"stars"];

    [coder encodeInt:_highScore forKey:@"highscore"];
    [coder encodeInt:_highGems forKey:@"highgems"];
    [coder encodeInt:_highGemStars forKey:@"highgemstars"];
    [coder encodeInt:_highDistance forKey:@"highdistance"];
    [coder encodeInt:_lowDistance forKey:@"lowdistance"];
    [coder encodeInt:_highStars forKey:@"highstars"];
}



- (id) initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        NSArray* afos = (NSArray*)[decoder decodeObjectForKey:@"activefieldobjects"];
        if (afos != nil)
        {
            [_activeFieldObjects removeAllObjects];
            [_activeFieldObjects addObjectsFromArray:afos];
            afos = nil; // paranoid cleanup
        }
        
        _score = [decoder decodeIntForKey:@"score"];
        _gems = [decoder decodeIntForKey:@"gems"];
        
        if ([decoder containsValueForKey:@"stars"])
            _overallStars = [decoder decodeIntForKey:@"stars"];
        else if ([decoder containsValueForKey:@"gemstars"])
            _overallStars = [decoder decodeIntForKey:@"gemstars"];
        else
            _overallStars = 0;
        
        _distance = [decoder decodeIntForKey:@"distance"];
        _highScore = [decoder decodeIntForKey:@"highscore"];
        _highGems = [decoder decodeIntForKey:@"highgems"];
        
        if ([decoder containsValueForKey:@"highstars"])
            _highStars = [decoder decodeIntForKey:@"highstars"];
        else if ([decoder containsValueForKey:@"highgemstars"])
            _highStars = [decoder decodeIntForKey:@"highgemstars"];
        else
            _highStars = 0;

        _highDistance = [decoder decodeIntForKey:@"highdistance"];
        _lowDistance = [decoder decodeIntForKey:@"lowdistance"];
        
        CharacterType type = [decoder decodeIntForKey:@"charactertype"];
        switch (type)
        {
            case Character_Emily:
                _selectedCharacter = [CharacterDefinition Emily];
                break;
            case Character_Bruce:
                _selectedCharacter = [CharacterDefinition Bruce];
                break;
            case Character_Toby:
                _selectedCharacter = [CharacterDefinition Toby];
                break;
            case Character_Angie:
                _selectedCharacter = [CharacterDefinition Angie];
                break;
            default:
                _selectedCharacter = [CharacterDefinition Steve];
                break;
        }
    }

    
    // Do not need to save the event log
    return self;
}

- (void) addEvent:(LogEventType)eventType data:(id)data
{
    LogEvent* event = [[LogEvent alloc] init];
    event.type = eventType;
    event.data = data;
    [_gameLog addObject:event];
}

- (void) clearEventLog
{
    for (LogEvent* event in _gameLog)
    {
        event.data = nil;
    }
    [_gameLog removeAllObjects];
}

@end


