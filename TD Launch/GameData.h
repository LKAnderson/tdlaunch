//
//  GameData.h
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import <cocos2d.h>
#import <Foundation/Foundation.h>
#import <ObjectiveChipmunk.h>
#import "FieldObject.h"
#import "Character.h"
#import "PhysicsSprite.h"
#import "Animation.h"





@interface AvailableFieldObject : NSObject

@property FieldObjectDefinition* definition;
@property int count;
@property CCSprite* menuItem;
@property CCLabelAtlas* countLabel;

@end




@interface ActiveFieldObject : NSObject <NSCoding>
{
    NSMutableArray* _animations;
}

@property FieldObjectDefinition* definition;
@property CGPoint position;
@property FieldObjectSettings* settings;
@property PhysicsSprite* sprite;
@property ChipmunkBody* body;
@property NSArray* animations;

- (void) addAnimation:(Animation*) animation;
- (void) setAnimationBody:(ChipmunkBody*) body;
- (void) applySettings:(FieldObjectSettings*)settings;
@end


typedef enum
{
    TargetTouched,
    TargetLeft
}
LogEventType;

@interface LogEvent : NSObject
@property LogEventType type;
@property id data;
@end




@interface GameData : NSObject <NSCoding>

@property CharacterDefinition* selectedCharacter;
@property NSMutableArray* activeFieldObjects;   // holds ActiveFieldObject


@property unsigned int score;
@property unsigned int gems;
@property unsigned int distance;

@property unsigned int scoreStars;
@property unsigned int gemStars;
@property unsigned int distanceStars;
@property unsigned int overallStars;

@property BOOL isNewHighScore;
@property unsigned int highScore;
@property unsigned int highScoreStars;
@property unsigned int highGems;
@property unsigned int highGemStars;
@property unsigned int highDistance;
@property unsigned int highDistanceStars;
@property unsigned int lowDistance;
@property unsigned int highStars;

@property NSMutableArray* gameLog;

- (void) addEvent:(LogEventType)eventType data:(id)data;
- (void) clearEventLog;

@end




