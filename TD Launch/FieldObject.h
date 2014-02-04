//
//  FieldObject.h
//  TD Launch
//
//  Created by Kent Anderson on 8/28/12.
//
//

#import <cocos2d.h>
#import <ObjectiveChipmunk.h>
#import <Foundation/Foundation.h>
#import "Dialog.h"
#import "PhysicsSprite.h"


//NOTE: Deleting enum entries really messes up decoding the activefieldobject list in
// the saved gamedata structure.  It's better just to rename.
typedef enum
{
    FieldObjectType_Unknown,
    FieldObjectType_Trampoline,
    FieldObjectType_Trampoline2x,
    FieldObjectType_AirBlower,
    FieldObjectType_AirBlower2x,
    FieldObjectType_Plank,
    FieldObjectType_Slide,
    FieldObjectType_Launcher,
    FieldObjectType_Bird,
    FieldObjectType_Balloon,
    FieldObjectType_Accelerator2X,
    FieldObjectType_AcceleratorHalfX,
    FieldObjectType_AntiGravity,
    FieldObjectType_Aligner,
    FieldObjectType_Boulder,
    FieldObjectType_Bird2,
}
FieldObjectType;


@interface GemDefinition : NSObject

@property CGPoint position;
@property int type;

@property bool isActive;
@property ChipmunkShape* shape;
@property CCSprite* sprite;

+ (GemDefinition*) gem:(int)type at:(CGPoint)position;
- (NSString*) spriteName;
@end


@interface FieldObjectSettings : NSObject <NSCoding>
@property bool isChanged;
@property double rotation;
@end


@interface LauncherObjectSettings : FieldObjectSettings <NSCoding>
@property uint strength;
@end


@interface SettingsDialog : Dialog
@property FieldObjectSettings* settings;
@property CCSprite* activeSprite;
@end



@interface FieldObjectDefinition : NSObject

@property (readonly) FieldObjectType type;
@property CCSpriteFrame* gameSprite;
@property CGPoint anchorPoint;
@property float activeMass;

- (ChipmunkBody*) createBody:(BOOL)isRogue;
- (void) addToSpace:(ChipmunkSpace*)space shape:(ChipmunkShape*)shape rogue:(BOOL)isRogue active:(BOOL)isActive;
- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue;
- (ChipmunkBody*) createInSpace:(ChipmunkSpace *)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive;
- (FieldObjectSettings*) getDefaultSettings;
- (SettingsDialog*) getSettingsDialog;
@end


@interface TrampolineFieldObject : FieldObjectDefinition
+ (TrampolineFieldObject*) definition;
@property float trampolineForce;
@end

@interface Trampoline2xFieldObject : TrampolineFieldObject
+ (Trampoline2xFieldObject*) definition;
@end



@interface AirBlowerFieldObject : FieldObjectDefinition

+ (AirBlowerFieldObject*) definition;
@property float blowerForce;
@property (readonly) float sensorLength;

@end

@interface AirBlower2xFieldObject : AirBlowerFieldObject
+ (AirBlower2xFieldObject*) definition;
@end



@interface PlankFieldObject : FieldObjectDefinition
+ (PlankFieldObject*) definition;
@end

@interface SlideFieldObject : PlankFieldObject
+ (PlankFieldObject*) definition;
@end


@interface LauncherFieldObject : FieldObjectDefinition
+ (LauncherFieldObject*) definition;
@property float launcherForce;
@end


@interface BirdFieldObject : FieldObjectDefinition
+ (BirdFieldObject*) definition;
@end

@interface Bird2FieldObject : BirdFieldObject
+ (Bird2FieldObject*) definition;
@end

@interface Accelerator2XFieldObject : FieldObjectDefinition
+ (Accelerator2XFieldObject*) definition;
@end

@interface AcceleratorHalfXFieldObject : Accelerator2XFieldObject
+ (AcceleratorHalfXFieldObject*) definition;
@end

@interface AntiGravityFieldObject : Accelerator2XFieldObject
+ (AntiGravityFieldObject*) definition;
@end

@interface AlignerFieldObject : Accelerator2XFieldObject
+ (AlignerFieldObject*) definition;
@end

@interface BoulderFieldObject : FieldObjectDefinition
+ (BoulderFieldObject*) definition;
@end

@interface FieldObjectFactory : NSObject

+ (FieldObjectDefinition*) fieldObjectForName:(NSString*)name;
+ (FieldObjectDefinition*) fieldObjectForType:(FieldObjectType)type;

@end


typedef enum
{
    ApplyForce_Sensor,
    ToggleSprite_Sensor,
    TogglePhysics_Sensor,
    Area_Sensor
}
SensorType;

typedef enum
{
    Toggle_Undefined = -1,
    Toggle_Off,
    Toggle_On,
    Toggle_Toggle
}
ToggleType;

@interface Sensor : NSObject

@property SensorType type;

@property float forceX;
@property float forceY;

@property NSArray* spriteNames;
@property NSString* physicsName;
@property NSString* indicatorName;
@property ToggleType inArea;

@end



@interface Projectile : NSObject
@property int impulseCount;
@property float impulseTimer;
@property PhysicsSprite* sprite;
@property ChipmunkBody* body;
@property NSArray* shapes;
@property FieldObjectType objType;
@end


@interface FakeChipmunkSpace : ChipmunkSpace
@property NSMutableArray* shapes;
@property NSMutableArray* staticShapes;
@end


@interface ProjectileSource : NSObject
{
    NSMutableArray* _waitingObjects;  // Will be used as a queue
    NSMutableArray* _currentObjects;
    float _timer;
}

@property CGPoint position;
@property float   rotationAngle;
@property float   rate;
@property float   initialDelay;
@property cpVect  initialVelocity;
@property float   impulseTimer;
@property float   impulseCount;
@property cpVect  impulse;
@property NSString* endAnimation;

@property BOOL    isRunning;

- (id) init:(NSString*)objType;
- (id) initWithCapacity:(int)capacity type:(NSString*)objType;

- (void) start;
- (void) stop;
- (void) reset:(ChipmunkSpace*)space field:(CCNode*)field;
- (void) clockTick:(float)dt space:(ChipmunkSpace*)space playingField:(CCNode*)field;
- (Projectile*) findProjectileForBody:(ChipmunkBody*)body;
@end