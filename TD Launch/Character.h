//
//  Character.h
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import <cocos2d.h>
#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"


typedef enum
{
    Character_Steve,
    Character_Emily,
    Character_Bruce,
    Character_Toby,
    Character_Angie
}
CharacterType;


@interface CharacterDefinition : NSObject

@property CCSpriteFrame* normalSprite;
@property CCSpriteFrame* sadSprite;
@property CCSpriteFrame* happySprite;
@property CCSpriteFrame* whoaSprite;
@property CCSpriteFrame* downwardSprite;
@property CCSpriteFrame* upwardSprite;
@property CCSpriteFrame* cringeSprite;

@property CCSpriteFrame* normalBigSprite;
@property CCSpriteFrame* sadBigSprite;
@property CCSpriteFrame* happyBigSprite;
@property CCSpriteFrame* whoaBigSprite;

@property CharacterType type;
@property float mass;
@property float maxRotationVelocity;

@property float cringeVelocity;
@property float cringeDistance;

@property CGSize bodySize;

// TODO: lots more situational sprite frames will be added here (animations, etc).

+ (CharacterDefinition*) characterForName:(NSString*)name;
+ (CharacterDefinition*) Steve;
+ (CharacterDefinition*) Emily;
+ (CharacterDefinition*) Bruce;
+ (CharacterDefinition*) Toby;
+ (CharacterDefinition*) Angie;

- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle;
@end
