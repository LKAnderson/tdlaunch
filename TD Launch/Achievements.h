//
//  Achievements.h
//  TD Launch
//
//  Created by Kent Anderson on 9/30/13.
//
//

#import <Foundation/Foundation.h>
#import "FieldObject.h"
#import "GameLevel.h"


struct AchievementResult
{
    int trampoline;
    int trampoline2x;
    int blower;
    int blower2x;
    int plank;
    int slide;
    int launcher;
    int accel2X;
    int accelHalfX;
    int antiGravity;
    int aligner;
    BOOL steve;
    BOOL emily;
    BOOL bruce;
    BOOL toby;
    BOOL angie;
};


@interface Achievements : NSObject <NSCoding>

@property int level;
@property int trampoline;
@property int trampoline2x;
@property int blower;
@property int blower2x;
@property int plank;
@property int slide;
@property int launcher;
@property int accel2X;
@property int accelHalfX;
@property int antiGravity;
@property int aligner;
@property BOOL hasSteve;
@property BOOL hasEmily;
@property BOOL hasBruce;
@property BOOL hasToby;
@property BOOL hasAngie;
@property (readonly) BOOL isTampered;


+ (Achievements*) sharedAchievements;
- (struct AchievementResult) applyLevelData:(GameLevel*)gameLevel;

@end
