//
//  FieldObject.m
//  TD Launch
//
//  Created by Kent Anderson on 8/28/12.
//
//

#import "FieldObject.h"
#import "CollisionTypes.h"
#import "Screen.h"
#import "RotationSettingsDialog.h"
#import "LauncherObjectSettingsDialog.h"
#import "PhysicsSprite.h"

static TrampolineFieldObject* TrampolineDef;
static Trampoline2xFieldObject* Trampoline2xDef;

static AirBlowerFieldObject* AirBlowerDef;
static AirBlower2xFieldObject* AirBlower2xDef;

static PlankFieldObject* PlankDef;
static SlideFieldObject* SlideDef;
static LauncherFieldObject* LauncherDef;

static BirdFieldObject* BirdDef;
static Bird2FieldObject* Bird2Def;
static BoulderFieldObject* BoulderDef;

static Accelerator2XFieldObject* Accel2XDef;
static AcceleratorHalfXFieldObject* AccelHalfXDef;
static AntiGravityFieldObject* AntiGravityDef;
static AlignerFieldObject* AlignerDef;



#define chSCALE 0.67


@implementation GemDefinition

+ (GemDefinition*) gem:(int)type at:(CGPoint)position
{
    GemDefinition* g = [[GemDefinition alloc] init];
    g.type = type;
    g.position = position;
    g.shape = nil;
    return g;
}

- (NSString*) spriteName
{
    switch (_type)
    {
        case 0: return @"RedBalloon.png";
        case 1: return @"YellowBalloon.png";
        case 2: return @"BlueBalloon.png";
    }
    return @"RedBalloon.png";
}

@end




@implementation FieldObjectSettings

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:_rotation forKey:@"rotation"];
}



- (id) initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        _rotation = [decoder decodeDoubleForKey:@"rotation"];
    }
    return self;
}

@end

@implementation LauncherObjectSettings


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeDouble:_strength forKey:@"strength"];
}

- (id) initWithCoder:(NSCoder*)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        _strength = [decoder decodeDoubleForKey:@"strength"];
    }
    return self;
}

@end




@implementation SettingsDialog
- (id) init
{
    if (self = [super init])
    {
        _settings = [[FieldObjectSettings alloc] init];
    }
    return self;
}
@end



@implementation FieldObjectDefinition

- (FieldObjectType) type { return FieldObjectType_Unknown; }

- (ChipmunkBody*) createBody:(BOOL)isRogue
{
    if (isRogue)
        return [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
    return [ChipmunkBody staticBody];
}


- (void) addToSpace:(ChipmunkSpace*)space shape:(ChipmunkShape*)shape rogue:(BOOL)isRogue active:(BOOL)isActive
{
    if (isRogue || isActive)
        [space addShape:shape];
    else
        [space addStaticShape:shape];
}



- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space
                       position:(CGPoint)position
                          angle:(float)angle
                          rogue:(BOOL)isRogue
{
    return [self createInSpace:space position:position angle:angle rogue:isRogue active:NO];
}


- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space
                       position:(CGPoint)position
                          angle:(float)angle
                          rogue:(BOOL)isRogue
                         active:(BOOL)isActive
{
    return nil;
}



- (FieldObjectSettings*) getDefaultSettings
{
    FieldObjectSettings* settings = [[FieldObjectSettings alloc] init];
    settings.rotation = 0;
    settings.isChanged = NO;
    return settings;
}

- (SettingsDialog*) getSettingsDialog
{
    return [[RotationSettingsDialog alloc] init];
}


@end



@implementation PlankFieldObject

- (FieldObjectType) type { return FieldObjectType_Plank; }

+ (PlankFieldObject*) definition
{
    if (PlankDef ==  nil)
    {
        PlankDef = [[PlankFieldObject alloc] init];
        PlankDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Plank.png"]).displayFrame;
        PlankDef.anchorPoint = ccp(0, 0.34375);
        PlankDef.activeMass = 0.6;
    }
    return PlankDef;
}

- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    cpBB box;
    box.b = 0;
    box.l = SCRNX(-75);
    box.r = SCRNX(75);
    box.t = SCRNY(15);
    
    ChipmunkBody* body = nil;
    if (isActive)
    {
        body = [ChipmunkBody bodyWithMass:self.activeMass andMoment:cpMomentForBox2(self.activeMass, box)];
    }
    else
    {
        body = [self createBody:isRogue];
    }
    
    body.pos = cpv(position.x,position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    // bouncy part (top)
    ChipmunkPolyShape* shape = [ChipmunkPolyShape boxWithBody:body bb:box];
    shape.elasticity = 1.0;
    shape.friction = 0.65;
    shape.collisionType = CT_Plank;
    
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    return body;
    
}
@end



@implementation SlideFieldObject

- (FieldObjectType) type { return FieldObjectType_Slide; }

+ (SlideFieldObject*) definition
{
    if (SlideDef ==  nil)
    {
        SlideDef = [[SlideFieldObject alloc] init];
        SlideDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Slide.png"]).displayFrame;
        SlideDef.anchorPoint = ccp(0,0.37414);
        SlideDef.activeMass = 1.0;
    }
    return SlideDef;
}

- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    cpBB box;
    box.b = 0;
    box.l = SCRNX(-75);
    box.r = SCRNX(75);
    box.t = SCRNY(13);
    
    ChipmunkBody* body = nil;
    if (isActive)
    {
        body = [ChipmunkBody bodyWithMass:self.activeMass andMoment:cpMomentForBox2(self.activeMass, box)];
    }
    else
    {
        body = [self createBody:isRogue];
    }
    
    body.pos = cpv(position.x,position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    // bouncy part (top)
    ChipmunkPolyShape* shape = [ChipmunkPolyShape boxWithBody:body bb:box];
    shape.elasticity = 0.0;
    shape.friction = 0;
    shape.collisionType = CT_Slide;
    
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    return body;    
}
@end




@implementation LauncherFieldObject
- (FieldObjectType) type { return FieldObjectType_Launcher; }


+ (LauncherFieldObject*) definition
{
    if (LauncherDef == nil)
    {
        LauncherDef = [[LauncherFieldObject alloc] init];
        LauncherDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Launcher.png"]).displayFrame;
        LauncherDef.anchorPoint = ccp(0.5,0.5);
    }
    return LauncherDef;
}


- (ChipmunkBody*) createInSpace:(ChipmunkSpace *)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue
{
    ChipmunkBody* body = [self createBody:isRogue];
    body.pos = cpv(position.x, position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    ChipmunkCircleShape* shape = [ChipmunkCircleShape circleWithBody:body radius:SCRNX(30) offset:cpvzero];
    shape.sensor = YES;
    shape.collisionType = CT_Launcher;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];
    return body;
}

- (SettingsDialog*) getSettingsDialog
{
    return [[LauncherObjectSettingsDialog alloc] init];
}

- (FieldObjectSettings*) getDefaultSettings
{
    LauncherObjectSettings* settings = [[LauncherObjectSettings alloc] init];
    settings.rotation = 0;
    settings.strength = 50;
    settings.isChanged = NO;
    return settings;
}
@end




@implementation TrampolineFieldObject

- (id) init
{
    if (self = [super init])
    {
        _trampolineForce = SCALE_FORCE(750.0) * (isSmallScreen ? 0.664 : 1);
    }
    return self;
}

- (FieldObjectType) type { return FieldObjectType_Trampoline; }

+ (TrampolineFieldObject*) definition
{
    if (TrampolineDef == nil)
    {
        TrampolineDef = [[TrampolineFieldObject alloc] init];
        TrampolineDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Drum.png"]).displayFrame;
        TrampolineDef.anchorPoint = ccp(0,0);
    }
    return TrampolineDef;
}

- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue
{
    cpBB box;
    box.b = 0;
    box.l = SCRNX(-50);
    box.r = SCRNX(50);
    box.t = SCRNX(35);
    
    ChipmunkBody* body = [self createBody:isRogue];
    
    body.pos = cpv(position.x,position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    // bouncy part (top)
    ChipmunkSegmentShape* shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.l+10,box.t) to:cpv(box.r-10,box.t) radius:0];
    shape.elasticity = 1.0;
    shape.friction = 0;
    shape.collisionType = CT_Trampoline;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];

    
    // fill in the gap on the top
    shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.l,box.t) to:cpv(box.l+10,box.t) radius:0];
    shape.elasticity = 0.5;
    shape.friction = 1.0;
    shape.collisionType = CT_Plank;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];
    
    // fill in the gap on the top
    shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.r,box.t) to:cpv(box.r-10,box.t) radius:0];
    shape.elasticity = 0.5;
    shape.friction = 1.0;
    shape.collisionType = CT_Plank;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];
    
    shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.l,box.t) to:cpv(box.l,box.b) radius:0];
    shape.elasticity = 0.5;
    shape.friction = 1.0;
    shape.collisionType = CT_Plank;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];
    
    shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.l,box.b) to:cpv(box.r,box.b) radius:0];
    shape.elasticity = 0.5;
    shape.friction = 1.0;
    shape.collisionType = CT_Plank;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];
    
    shape = [ChipmunkSegmentShape segmentWithBody:body from:cpv(box.r,box.b) to:cpv(box.r,box.t) radius:0];
    shape.elasticity = 0.5;
    shape.friction = 0;
    shape.collisionType = CT_Plank;
    [self addToSpace:space shape:shape rogue:isRogue active:NO];

    return body;
}

@end


@implementation Trampoline2xFieldObject

- (id) init
{
    if (self = [super init])
    {
        self.trampolineForce *= 2;
    }
    return self;
}

- (FieldObjectType) type { return FieldObjectType_Trampoline2x; }

+ (Trampoline2xFieldObject*) definition
{
    if (Trampoline2xDef == nil)
    {
        Trampoline2xDef = [[Trampoline2xFieldObject alloc] init];
        Trampoline2xDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Drum2x.png"]).displayFrame;
        Trampoline2xDef.anchorPoint = ccp(0,0);
    }
    return Trampoline2xDef;
}
@end





@implementation AirBlowerFieldObject

- (FieldObjectType) type { return FieldObjectType_AirBlower; }

- (id) init
{
    if (self = [super init])
    {
        _blowerForce = SCALE_FORCE(250);
    }
    return self;
}


- (float) sensorLength { return SCALE(200); }


- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    cpVect points[5] = {cpv(0,0), cpv(SCRNX(-21),SCRNY(6)), cpv(SCRNX(-14),SCRNY(82)),
        cpv(SCRNX(14),SCRNY(82)), cpv(SCRNX(21),SCRNY(6))};
    
    ChipmunkBody* body = [self createBody:isRogue];
    
    body.pos = cpv(position.x,position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    // bouncy part (top)
    ChipmunkPolyShape* shape = [ChipmunkPolyShape polyWithBody:body count:5 verts:points offset:cpvzero];
    shape.elasticity = 0.5;
    shape.friction = 0;
    shape.collisionType = CT_BlowerBody;
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    
    ChipmunkSegmentShape* sensor1 = [ChipmunkSegmentShape segmentWithBody:body
                                                                     from:cpv(0,points[2].y)
                                                                       to:cpv(0,(points[2].y) + [self sensorLength])
                                                                   radius:15];
    
    sensor1.elasticity = 0;
    sensor1.friction = 0;
    sensor1.sensor = YES;
    sensor1.collisionType = CT_Blower;
    [self addToSpace:space shape:sensor1 rogue:isRogue active:isActive];

    
    return body;

}

+ (AirBlowerFieldObject*) definition
{
    if (AirBlowerDef == nil) {
        AirBlowerDef = [[AirBlowerFieldObject alloc] init];
        AirBlowerDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Blower.png"]).displayFrame;
        AirBlowerDef.anchorPoint = ccp(0,0);
    }
    return AirBlowerDef;
}

@end



@implementation AirBlower2xFieldObject

- (id) init
{
    if (self = [super init])
    {
        self.blowerForce = 2 * self.blowerForce;
    }
    return self;
}

- (float) sensorLength { return SCALE(400); }

- (FieldObjectType) type { return FieldObjectType_AirBlower2x; }

+ (AirBlower2xFieldObject*) definition
{
    if (AirBlower2xDef == nil)
    {
        AirBlower2xDef = [[AirBlower2xFieldObject alloc] init];
        AirBlower2xDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Blower2x.png"]).displayFrame;
        AirBlower2xDef.anchorPoint = ccp(0,0);
    }
    return AirBlower2xDef;
}

@end



@implementation BirdFieldObject

- (FieldObjectType) type { return FieldObjectType_Bird; }

+ (BirdFieldObject*) definition
{
    if (BirdDef ==  nil)
    {
        BirdDef = [[BirdFieldObject alloc] init];
        BirdDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Bird1.png"]).displayFrame;
        BirdDef.anchorPoint = ccp(0, 0.5);
        BirdDef.activeMass = SCALE(0.3);
    }
    return BirdDef;
}




- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    cpBB box;
    box.b = 0;
    box.l = SCRNX(-20);
    box.r = SCRNX(20);
    box.t = SCRNY(25);
    
    ChipmunkBody* body = nil;
    if (isActive)
    {
        body = [ChipmunkBody bodyWithMass:self.activeMass andMoment:cpMomentForBox2(self.activeMass, box)];
    }
    else
    {
        body = [self createBody:isRogue];
    }
    
    body.pos = cpv(position.x,position.y);
    body.angle = -CC_DEGREES_TO_RADIANS(angle);
    
    ChipmunkPolyShape* shape = [ChipmunkPolyShape boxWithBody:body bb:box];
    shape.elasticity = 1.0;
    shape.friction = 0.65;
    shape.collisionType = CT_Projectile_Bird;
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    return body;
    
}
@end


@implementation Bird2FieldObject

- (FieldObjectType) type { return FieldObjectType_Bird2; }

+ (Bird2FieldObject*) definition
{
    if (Bird2Def ==  nil)
    {
        Bird2Def = [[Bird2FieldObject alloc] init];
        Bird2Def.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Bird2.png"]).displayFrame;
        Bird2Def.anchorPoint = ccp(0, 0.5);
        Bird2Def.activeMass = SCALE(0.3);
    }
    return Bird2Def;
}

@end


@implementation Accelerator2XFieldObject
- (FieldObjectType) type { return FieldObjectType_Accelerator2X; }
- (SettingsDialog*) getSettingsDialog { return nil; }
    
+ (Accelerator2XFieldObject*) definition
{
    if (Accel2XDef == nil)
    {
        Accel2XDef = [[Accelerator2XFieldObject alloc] init];
        Accel2XDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Accelerator2X.png"]).displayFrame;
        Accel2XDef.anchorPoint = ccp(0.5, 0.5);
        Accel2XDef.activeMass = SCALE(0.01);
    }
    return Accel2XDef;
}
    
- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    ChipmunkBody* body = nil;
    if (isActive)
    {
        body = [ChipmunkBody bodyWithMass:self.activeMass andMoment:cpMomentForCircle(self.activeMass, 0, SCALE(32), cpvzero)];
    }
    else
    {
        body = [self createBody:isRogue];
    }
    
    body.pos = cpv(position.x,position.y);
    body.angle = 0;
    
    ChipmunkCircleShape* shape = [ChipmunkCircleShape circleWithBody:body radius:SCALE(32) offset:cpvzero];
    shape.elasticity = 0;
    shape.friction = 0;
    shape.sensor = YES;
    shape.collisionType = CT_Accelerator;
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    return body;
}
@end



@implementation AcceleratorHalfXFieldObject
- (FieldObjectType) type { return FieldObjectType_AcceleratorHalfX; }
    
+ (Accelerator2XFieldObject*) definition
{
    if (AccelHalfXDef == nil)
    {
        AccelHalfXDef = [[AcceleratorHalfXFieldObject alloc] init];
        AccelHalfXDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"AcceleratorHalfX.png"]).displayFrame;
        AccelHalfXDef.anchorPoint = ccp(0.5, 0.5);
        AccelHalfXDef.activeMass = SCALE(0.01);
    }
    return AccelHalfXDef;
}
@end


@implementation AntiGravityFieldObject
- (FieldObjectType) type { return FieldObjectType_AntiGravity; }

+ (AntiGravityFieldObject*) definition
{
    if (AntiGravityDef == nil)
    {
        AntiGravityDef = [[AntiGravityFieldObject alloc] init];
        AntiGravityDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"AntiGravity.png"]).displayFrame;
        AntiGravityDef.anchorPoint = ccp(0.5, 0.5);
        AntiGravityDef.activeMass = SCALE(0.01);
    }
    return AntiGravityDef;
}
@end


@implementation AlignerFieldObject
- (FieldObjectType) type { return FieldObjectType_Aligner; }

- (SettingsDialog*) getSettingsDialog
{
    return [[RotationSettingsDialog alloc] init];
}


+ (AlignerFieldObject*) definition
{
    if (AlignerDef == nil)
    {
        AlignerDef = [[AlignerFieldObject alloc] init];
        AlignerDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Aligner.png"]).displayFrame;
        AlignerDef.anchorPoint = ccp(0.5, 0.5);
        AlignerDef.activeMass = SCALE(0.01);
    }
    return AlignerDef;
}
@end




@implementation BoulderFieldObject
- (FieldObjectType) type { return FieldObjectType_Boulder; }
- (SettingsDialog*) getSettingsDialog { return nil; }

+ (BoulderFieldObject*) definition
{
    if (BoulderDef == nil)
    {
        BoulderDef = [[BoulderFieldObject alloc] init];
        BoulderDef.gameSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Boulder.png"]).displayFrame;
        BoulderDef.anchorPoint = ccp(0.5, 0.5);
        BoulderDef.activeMass = SCALE(40.0);
    }
    return BoulderDef;
}

- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle rogue:(BOOL)isRogue active:(BOOL)isActive
{
    ChipmunkBody* body = nil;
    if (isActive)
    {
        body = [ChipmunkBody bodyWithMass:self.activeMass andMoment:cpMomentForCircle(BoulderDef.activeMass, 0, SCALE(84), cpvzero)];
    }
    else
    {
        body = [self createBody:isRogue];
    }
    
    body.pos = cpv(position.x,position.y);
    body.angle = 0;
    
    ChipmunkCircleShape* shape = [ChipmunkCircleShape circleWithBody:body radius:SCALE(42) offset:cpvzero];
    shape.elasticity = 0.5;
    shape.friction = 2.0;
    shape.collisionType = CT_Boulder;
    [self addToSpace:space shape:shape rogue:isRogue active:isActive];
    
    return body;
}
@end




@implementation FieldObjectFactory

+ (FieldObjectDefinition*) fieldObjectForName:(NSString *)name
{
    if ([name isEqual:@"Plank"]) return [PlankFieldObject definition];
    if ([name isEqual:@"Slide"]) return [SlideFieldObject definition];
    if ([name isEqual:@"Trampoline"]) return [TrampolineFieldObject definition];
    if ([name isEqual:@"Trampoline2x"]) return [Trampoline2xFieldObject definition];
    if ([name isEqual:@"AirBlower"]) return [AirBlowerFieldObject definition];
    if ([name isEqual:@"AirBlower2x"]) return [AirBlower2xFieldObject definition];
    if ([name isEqual:@"Launcher"]) return [LauncherFieldObject definition];
    if ([name isEqual:@"Bird"]) return [BirdFieldObject definition];
    if ([name isEqual:@"Bird2"]) return [Bird2FieldObject definition];
    if ([name isEqual:@"Accelerator2X"]) return [Accelerator2XFieldObject definition];
    if ([name isEqual:@"AcceleratorHalfX"]) return [AcceleratorHalfXFieldObject definition];
    if ([name isEqual:@"AntiGravity"]) return [AntiGravityFieldObject definition];
    if ([name isEqual:@"Aligner"]) return [AlignerFieldObject definition];
    if ([name isEqual:@"Boulder"]) return [BoulderFieldObject definition];
    return nil;
}

+ (FieldObjectDefinition*) fieldObjectForType:(FieldObjectType)type
{
    switch (type)
    {
        case FieldObjectType_AirBlower:
            return [AirBlowerFieldObject definition];
            break;
        case FieldObjectType_AirBlower2x:
            return [AirBlower2xFieldObject definition];
            break;
        case FieldObjectType_Bird:
            return [BirdFieldObject definition];
            break;
        case FieldObjectType_Bird2:
            return [Bird2FieldObject definition];
            break;
        case FieldObjectType_Launcher:
            return [LauncherFieldObject definition];
            break;
        case FieldObjectType_Plank:
            return [PlankFieldObject definition];
            break;
        case FieldObjectType_Slide:
            return [SlideFieldObject definition];
            break;
        case FieldObjectType_Trampoline:
            return [TrampolineFieldObject definition];
            break;
        case FieldObjectType_Trampoline2x:
            return [Trampoline2xFieldObject definition];
            break;
        case FieldObjectType_Accelerator2X:
            return [Accelerator2XFieldObject definition];
            break;
        case FieldObjectType_AcceleratorHalfX:
            return [AcceleratorHalfXFieldObject definition];
            break;
        case FieldObjectType_AntiGravity:
            return [AntiGravityFieldObject definition];
            break;
        case FieldObjectType_Aligner:
            return [AlignerFieldObject definition];
            break;
        case FieldObjectType_Boulder:
            return [BoulderFieldObject definition];
            break;
        default:
            return nil;
    }
}

@end



@implementation Sensor
- (id) init
{
    if (self = [super init])
    {
        self.type = 0;
        self.forceX = 0;
        self.forceY = 0;
        
        self.spriteNames = @[];
        self.physicsName = nil;
    }
    return self;
}
@end



@implementation FakeChipmunkSpace

- (id) init
{
    _shapes = [NSMutableArray array];
    return self;
}

- (ChipmunkShape*) addShape:(ChipmunkShape *)shape
{
    [_shapes addObject:shape];
    return shape;
}

- (ChipmunkShape*) addStaticShape:(ChipmunkShape*)shape
{
    [_staticShapes addObject:shape];
    return shape;
}

@end



@implementation Projectile
@end




@implementation ProjectileSource : NSObject

- (id) init:(NSString*)objType
{
    return [self initWithCapacity:1 type:objType];
}

- (id) initWithCapacity:(int)capacity type:(NSString*)objType
{
    if (self = [super init])
    {
        _position = CGPointMake(0,0);
        _rotationAngle = 0;
        _rate  = 0;
        _initialVelocity = cpvzero;
        _initialDelay = 0;
        _impulseCount = 0;
        _impulse = cpvzero;
        _impulseTimer = 0;
        _currentObjects = [NSMutableArray arrayWithCapacity:capacity];
        _waitingObjects = [NSMutableArray arrayWithCapacity:capacity];
        _isRunning = NO;
        
        
        // Pre-allocate all the projectile objects to reduce the potential for memory fragmentation in
        // Chipmunk
        FakeChipmunkSpace* space = [[FakeChipmunkSpace alloc] init];
        for (int i=0; i < capacity; i++)
        {
            FieldObjectDefinition* def = [FieldObjectFactory fieldObjectForName:objType];
            
            Projectile* p = [[Projectile alloc] init];
            p.objType = def.type;
            
            [space.shapes removeAllObjects];
            ChipmunkBody* body = [def createInSpace:space position:cpvzero angle:0 rogue:NO active:YES];
            p.body = body;
            p.shapes = [NSArray arrayWithArray:space.shapes];

            for (ChipmunkShape* shape in p.shapes)
            {
                switch (def.type)
                {
                    case FieldObjectType_Bird:
                    case FieldObjectType_Bird2:
                        shape.collisionType = CT_Projectile_Bird;
                        break;
                    case FieldObjectType_Plank:
                        shape.collisionType = CT_Projectile_Plank;
                        break;
                    case FieldObjectType_Slide:
                        shape.collisionType = CT_Projectile_Slide;
                        break;
                    case FieldObjectType_Boulder:
                        shape.collisionType = CT_Boulder;
                        break;
                    case FieldObjectType_Accelerator2X:
                    case FieldObjectType_AcceleratorHalfX:
                    case FieldObjectType_AntiGravity:
                    case FieldObjectType_Aligner:
                        shape.collisionType = CT_Accelerator;
                        break;
                    default:
                        shape.collisionType = CT_Projectile;
                        break;
                        
                }
            }
            
            
            [_waitingObjects insertObject:p atIndex:0];
        }
    }
    
    return self;
}




- (void) start
{
    _timer = _initialDelay;
    _isRunning = YES;
}

- (void) stop
{
    _isRunning = NO;
}

- (void) reset:(ChipmunkSpace*)space field:(CCNode*)field
{
    _timer = 0;
    for (Projectile* p in _currentObjects)
    {
        [field removeChild:p.sprite cleanup:YES];
        [space remove:p.sprite.body];
        for (ChipmunkShape* sh in p.shapes)
        {
            [space remove:sh];
            p.sprite = nil;
        }
        [_waitingObjects insertObject:p atIndex:0];
    }
    [_currentObjects removeAllObjects];
}



- (void) clockTick:(float)dt space:(ChipmunkSpace*)space playingField:(CCNode *)field
{

    if (_rate <= 0 || _isRunning == NO)
        return;
    
    _timer -= dt;
    if (_timer <= 0 && _waitingObjects.count > 0)
    {
        Projectile* projectile = [_waitingObjects lastObject];
        [_waitingObjects removeLastObject];
        
        ChipmunkBody* body = projectile.body;
        body.vel = _initialVelocity;
        body.angle = _rotationAngle;
        body.angVel = 0;
        [body resetForces];
        body.body->v_bias_private = cpvzero;
        body.body->w_bias_private = 0;

        [space add:body];
        for (ChipmunkShape* shape in projectile.shapes)
            [space add:shape];
        [space reindexShapesForBody:body];
    
        FieldObjectDefinition* def = [FieldObjectFactory fieldObjectForType:projectile.objType];
        projectile.sprite = [PhysicsSprite spriteWithSpriteFrame:def.gameSprite];
        projectile.sprite.anchorPoint = ccp(0.5, def.anchorPoint.y);
        [projectile.sprite setPhysicsBody:body];
        
        projectile.sprite.position = _position;
        [field addChild:projectile.sprite z:10000];
         
        projectile.impulseCount = _impulseCount;
        projectile.impulseTimer = _impulseTimer;

        [_currentObjects addObject:projectile];
        
        _timer = 1 / _rate;
    }
    
    NSMutableArray* deadProjs = [NSMutableArray array];
    
    for (Projectile* p in _currentObjects)
    {
        p.impulseTimer -= dt;
        
        BOOL outOfBounds = (p.sprite.position.x < SCRNX(-200)
                            || p.sprite.position.x > field.contentSize.width + SCRNX(200)
                            || p.sprite.position.y < SCRNY(-200));
        
        if (p.impulseTimer <= 0 || outOfBounds)
        {
            p.impulseCount--;
            if (p.impulseCount <= 0 || outOfBounds)
            {
                [deadProjs addObject:p];
                [space smartRemove:p.sprite.body];
                for (ChipmunkShape* sh in p.shapes)
                {
                    [space smartRemove:sh];
                }
                
                CGPoint position = p.sprite.body.pos;

                [field removeChild:p.sprite cleanup:YES];
                [p.sprite setPhysicsBody:nil];
                
                if (_endAnimation != nil && !outOfBounds)
                {
                    CCAnimation* anim = [[CCAnimationCache sharedAnimationCache] animationByName:_endAnimation];
                    CCAnimate* animAction = [CCAnimate actionWithAnimation:anim];
                    animAction.duration = 0.25;
                    
                    CCAnimationFrame* firstFrame = [anim.frames firstObject];
                    CCSprite* animSprite = [CCSprite spriteWithSpriteFrame:firstFrame.spriteFrame];
                    animSprite.anchorPoint = ccp(0.5,0.5);
                    animSprite.position = position;
                    [field addChild:animSprite];
                    
                    CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
                        [field removeChild:animSprite cleanup:YES];
                    }];
                
                    [animSprite runAction:[CCSequence actions:animAction, cleanup, nil]];
                }
            }
            else
            {
                [p.sprite.body applyImpulse:_impulse offset:cpvzero];
                p.impulseTimer = _impulseTimer;
            }
            
        }
    }
    
    for (Projectile* p in deadProjs)
    {
        [_currentObjects removeObject:p];
        [_waitingObjects insertObject:p atIndex:0];
    }
    
}

- (Projectile*) findProjectileForBody:(ChipmunkBody*)body
{
    for (Projectile* p in _currentObjects)
    {
        if (p.sprite.body == body)
            return p;
    }
    return nil;
}
@end