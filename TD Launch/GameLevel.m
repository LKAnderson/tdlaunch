//
//  GameLevel.m
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import "GameLevel.h"
#import "Character.h"
#import "FieldObject.h"
#import "CollisionTypes.h"
#import "Screen.h"
#import "Animation.h"
#import "Achievements.h"

@implementation GameLevel

- (id) init
{
    if ( (self = [super init]))
    {
        _plist = nil;
        _ID = 0;
        _gameData = nil;
        _gameConfig = nil;
        _availableFieldObjects = [NSMutableArray array];
        _availableCharacters = [NSMutableArray array];
        _staticFieldObjects = [NSMutableArray array];
        _sensors = [NSMutableArray array];
        _gems = [NSMutableArray array];
        _gameSize = CGSizeMake(0,0);
        _namedSprites = [NSMutableDictionary dictionary];
        _projectileSources = [NSMutableArray array];
        
#define AFO(afoName, achVar) if ([Achievements sharedAchievements].achVar > 0){\
                             afo = [[AvailableFieldObject alloc] init];\
                             afo.definition = [FieldObjectFactory fieldObjectForName:afoName];\
                             afo.count = [Achievements sharedAchievements].achVar;\
                             [_availableFieldObjects addObject:afo];}
        
        AvailableFieldObject *afo;
        AFO(@"Plank", plank);
        AFO(@"Slide", slide);
        AFO(@"Trampoline", trampoline);
        AFO(@"Trampoline2x", trampoline2x);
        AFO(@"AirBlower", blower);
        AFO(@"AirBlower2x", blower2x);
        AFO(@"Launcher", launcher);
        AFO(@"Aligner", aligner);
        AFO(@"Accelerator2X", accel2X);
        AFO(@"AcceleratorHalfX", accelHalfX);
        AFO(@"AntiGravity", antiGravity);
    
#undef AFO
        
        [_availableCharacters addObject:[CharacterDefinition characterForName:@"Steve"]];
        [_availableCharacters addObject:[CharacterDefinition characterForName:@"Emily"]];
        
        if ([Achievements sharedAchievements].hasBruce)
            [_availableCharacters addObject:[CharacterDefinition characterForName:@"Bruce"]];
        if ([Achievements sharedAchievements].hasToby)
            [_availableCharacters addObject:[CharacterDefinition characterForName:@"Toby"]];
        if ([Achievements sharedAchievements].hasAngie)
            [_availableCharacters addObject:[CharacterDefinition characterForName:@"Angie"]];
        
    }
    return self;
}

- (id) initWithPlist:(NSDictionary *)plist
{
    if ( (self = [super init]))
    {
        _plist = plist;
        
        _ID = ((NSNumber*)[_plist objectForKey:@"ID"]).integerValue;
        
        _gameData = nil;
        _gameConfig = nil;
        _availableFieldObjects = [NSMutableArray array];
        _availableCharacters = [NSMutableArray array];
        _staticFieldObjects = [NSMutableArray array];
        _sensors = [NSMutableArray array];
        _gems = [NSMutableArray array];
        
        NSNumber* width = [_plist objectForKey:@"Width"];
        NSNumber* height = [_plist objectForKey:@"Height"];
        _gameSize = CGSizeMake(width.floatValue, height.floatValue);
        
        _namedSprites = [NSMutableDictionary dictionary];
        
    }
    return self;
}


- (NSString*) getSaveFilePath
{
    return [self getSaveFilePath:@""];
}

- (NSString*) getSaveFilePath:(NSString*)suffix
{
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                stringByAppendingPathComponent:[NSString stringWithFormat:@"L%d%@.dat", _ID, suffix]];
    return path;
}


- (NSString*) getTempFilePath
{
    return [NSString stringWithFormat:@"%@.tmp", [self getSaveFilePath]];
}

- (BOOL) hasTempFile
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getTempFilePath]];
}


- (void) saveConfig
{
    [self saveConfigToFile:[self getSaveFilePath]];
    _isChanged = NO;
}

- (void) saveData
{
    [self saveDataToFile:[self getSaveFilePath:@"data"]];
}


- (void) saveTempFile
{
    [self saveConfigToFile:[self getTempFilePath]];
}


- (void) saveConfigToFile:(NSString *)filePath
{
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_gameConfig forKey:@"gamedata"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}

- (void) saveDataToFile:(NSString *)filePath
{
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_gameData forKey:@"gamedata"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}


- (id) load
{
    if ([self loadConfigFromFile:[self getSaveFilePath]] == nil)
        _gameConfig = [[GameData alloc] init];
    
    if ([self loadDataFromFile:[self getSaveFilePath:@"data"]] == nil)
    {
        // Must be upgrading from v1.0 to v1.1
        _gameData = [[GameData alloc] init];
        if (_gameConfig != nil)
        {
            _gameData.score = _gameConfig.score;
            _gameData.gems = _gameConfig.gems;
            _gameData.distance = _gameConfig.distance;
            _gameData.scoreStars = _gameConfig.scoreStars;
            _gameData.gemStars = _gameConfig.gemStars;
            _gameData.distanceStars = _gameConfig.distanceStars;
            _gameData.overallStars = _gameConfig.overallStars;
            _gameData.highScore = _gameConfig.highScore;
            _gameData.highScoreStars = _gameConfig.highScoreStars;
            _gameData.highGems = _gameConfig.highGems;
            _gameData.highGemStars = _gameConfig.highGemStars;
            _gameData.highDistance = _gameConfig.highDistance;
            _gameData.highDistanceStars = _gameConfig.highDistanceStars;
            _gameData.lowDistance = _gameConfig.lowDistance;
            _gameData.highStars = _gameConfig.highStars;
        }
    }
    
    _isChanged = NO;
    return self;
}

- (id) loadTempFile:(BOOL)deleteFile
{
    [self loadConfigFromFile:[self getTempFilePath]];
    _isChanged = YES;
    
    if (deleteFile)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self getTempFilePath] error:nil];
    }
    
    return self;
}

- (id) loadConfigFromFile:(NSString *)filePath
{
    NSData* codedData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (codedData != nil)
    {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
        _gameConfig = [unarchiver decodeObjectForKey:@"gamedata"];
        if (_gameConfig.selectedCharacter == nil)
            _gameConfig.selectedCharacter = Character_Steve;
        return _gameConfig;
    }
    
    return nil;
}

- (id) loadDataFromFile:(NSString *)filePath
{
    NSData* codedData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (codedData != nil)
    {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
        _gameData = [unarchiver decodeObjectForKey:@"gamedata"];
        return _gameData;
    }
    
    return nil;
}





- (float) parseCoordinateValue:(NSString*)strValue pctSource:(float)pctSource defaultValue:(float)defaultValue isX:(bool)isX
{
    if (strValue == nil)
        return isX ? defaultValue : defaultValue;
    
    // if absolute number (no '%' character), just convert it to a float
    NSRange index = [strValue rangeOfString:@"%"];
    if (index.location == NSNotFound)
        return isX ? strValue.floatValue : strValue.floatValue;
    
    // It's a percentage (assume the pctSource is already translated to screen values
    float pct = [strValue substringToIndex:index.location].floatValue;
    return pctSource * (pct/100);
}

- (float) parseXCoordinateValue:(NSString*)strValue pctSource:(float)pctSource defaultValue:(float)defaultValue
{
    return [self parseCoordinateValue:strValue pctSource:pctSource defaultValue:defaultValue isX:YES];
}

- (float) parseYCoordinateValue:(NSString*)strValue pctSource:(float)pctSource defaultValue:(float) defaultValue
{
    return [self parseCoordinateValue:strValue pctSource:pctSource defaultValue:defaultValue isX:NO];
}







- (ChipmunkSpace*) createSpace
{
    // We'll use these for general place setting below
    float x1, y1, x2, y2;
    
    // Clean out sensors
    [_sensors removeAllObjects];  // paranoid code
    
    ChipmunkSpace* space = [[ChipmunkSpace alloc] init];
    space.gravity = cpv(((NSNumber*)[_plist objectForKey:@"GravityX"]).floatValue,
                        ((NSNumber*)[_plist objectForKey:@"GravityY"]).floatValue);
    
    NSNumber* damping = [_plist objectForKey:@"Damping"];
    if (damping != nil)
        space.damping = damping.floatValue;
    
    
    //  Process the walls
    for (NSDictionary* wallDef in [[_plist objectForKey:@"Walls"] allValues])
    {
        x1 = [self parseXCoordinateValue:[wallDef objectForKey:@"X1"] pctSource:_gameSize.width defaultValue:0];
        y1 = [self parseYCoordinateValue:[wallDef objectForKey:@"Y1"] pctSource:_gameSize.height defaultValue:0];
        x2 = [self parseXCoordinateValue:[wallDef objectForKey:@"X2"] pctSource:_gameSize.width defaultValue:_gameSize.width];
        y2 = [self parseYCoordinateValue:[wallDef objectForKey:@"Y2"] pctSource:_gameSize.height defaultValue:_gameSize.height];
        
        ChipmunkSegmentShape* wall = [ChipmunkSegmentShape segmentWithBody:[space staticBody] from:cpv(x1,y1) to:cpv(x2,y2) radius:0];
        wall.elasticity = ((NSNumber*) [wallDef objectForKey:@"Elasticity"]).floatValue;
        wall.friction = ((NSNumber*) [wallDef objectForKey:@"Friction"]).floatValue;
        [space addStaticShape:wall];

    }
    
    
    NSDictionary* launchPadDef = [_plist objectForKey:@"LaunchPad"];
    x1 = [self parseXCoordinateValue:[launchPadDef objectForKey:@"Left"] pctSource:_gameSize.width defaultValue:0];
    x2 = [self parseXCoordinateValue:[launchPadDef objectForKey:@"Right"] pctSource:_gameSize.width defaultValue:_gameSize.width];
    y1 = [self parseYCoordinateValue:[launchPadDef objectForKey:@"Height"] pctSource:_gameSize.height defaultValue:0];
    _launchPad = [[ChipmunkSegmentShape alloc] initWithBody:[space staticBody] from:cpv(x1,y1) to:cpv(x2,y1) radius:0.0f];
    _launchPad.elasticity = 0.0f;
    _launchPad.friction = 0.0;
    [space add:_launchPad];
    
    float forceX = 15;
    float forceY = 0;
    if ([launchPadDef objectForKey:@"ForceX"]) forceX = ((NSNumber*)[launchPadDef objectForKey:@"ForceX"]).floatValue;
    if ([launchPadDef objectForKey:@"ForceY"]) forceY = ((NSNumber*)[launchPadDef objectForKey:@"ForceY"]).floatValue;
    _launchForce = cpv(forceX, forceY);
    
    _launchSensor = [[ChipmunkSegmentShape alloc] initWithBody:[space staticBody] from:cpv(x1,y1) to:cpv(x2,y1) radius:0];
    _launchSensor.sensor = YES;
    _launchSensor.collisionType = CT_LaunchPad;
    [space add:_launchSensor];
    
    for(NSDictionary* targetDef in [_plist objectForKey:@"Targets"])
    {
        x1 = [self parseXCoordinateValue:[targetDef objectForKey:@"X1"] pctSource:_gameSize.width defaultValue:0];
        y1 = [self parseYCoordinateValue:[targetDef objectForKey:@"Y1"] pctSource:_gameSize.height defaultValue:0];
        x2 = [self parseXCoordinateValue:[targetDef objectForKey:@"X2"] pctSource:_gameSize.width defaultValue:0];
        y2 = [self parseYCoordinateValue:[targetDef objectForKey:@"Y2"] pctSource:_gameSize.height defaultValue:0];
        
        _target = [[ChipmunkSegmentShape alloc] initWithBody:[space staticBody] from:cpv(x1,y1) to:cpv(x2,y2) radius:2];
        _target.elasticity = 0;
        _target.friction = 2.5;
        _target.collisionType = CT_Target;
        [space add:_target];
    }
    
    
    
    for (NSDictionary* obstacleDef in [_plist objectForKey:@"Obstacles"])
    {
        NSString* type = [obstacleDef objectForKey:@"Type"];
        if ([type isEqual:@"Wall"] || [type isEqual:@"ApplyForce"] || [type isEqual:@"ToggleSprite"]
            || [type isEqual:@"TogglePhysics"])
        {
            [self loadWallObstacle:obstacleDef space:space];
        }
        else if ([type isEqual:@"FieldObject"])
        {
            [self loadFieldObjectObstacle:obstacleDef space:space];
        }
    }
    
    
    
    for (GemDefinition* gem in self.gems)
    {
        ChipmunkBody* body = [ChipmunkBody staticBody];
        body.pos = gem.position;
        
        ChipmunkShape* shape;
        int size = 40 - (5 * gem.type);
        shape = [ChipmunkPolyShape boxWithBody:body width:size height:size];        
        shape.sensor = YES;
        shape.collisionType = CT_Gem;
        gem.shape = shape;
    }
    
    for (ActiveFieldObject* obj in _gameConfig.activeFieldObjects)
    {
        obj.body = [obj.definition createInSpace:space position:obj.position angle:obj.settings.rotation rogue:NO];
    }
    
    return space;
}


- (void) loadWallObstacle:(NSDictionary*)obstacleDef space:(ChipmunkSpace*)space
{
    float x1, y1, x2, y2, elasticity, friction, radius;
    
    x1 = [self parseXCoordinateValue:[obstacleDef objectForKey:@"X1"] pctSource:_gameSize.width defaultValue:0];
    y1 = [self parseYCoordinateValue:[obstacleDef objectForKey:@"Y1"] pctSource:_gameSize.height defaultValue:0];
    x2 = [self parseXCoordinateValue:[obstacleDef objectForKey:@"X2"] pctSource:_gameSize.width defaultValue:0];
    y2 = [self parseYCoordinateValue:[obstacleDef objectForKey:@"Y2"] pctSource:_gameSize.height defaultValue:0];
    elasticity = ((NSNumber*) [obstacleDef objectForKey:@"Elasticity"]).floatValue;
    friction = ((NSNumber*) [obstacleDef objectForKey:@"Friction"]).floatValue;
    radius = ((NSNumber*) [obstacleDef objectForKey:@"Radius"]).floatValue;
    
    ChipmunkShape* wall = [[ChipmunkSegmentShape alloc] initWithBody:[space staticBody]
                                                                from:cpv(x1,y1) to:cpv(x2,y2)
                                                              radius:radius];
    wall.elasticity = elasticity;
    wall.friction = friction;
    
    if ([obstacleDef objectForKey:@"Name"] != nil)
    {
        wall.collisionType = CT_NamedWall;
        wall.data = [obstacleDef objectForKey:@"Name"];
    }
    
    if ([[obstacleDef objectForKey:@"IsSensor"] isEqual:@YES])
    {
        wall.sensor = YES; //[[obstacleDef objectForKey:@"IsSensor"] isEqual:@YES];
        wall.collisionType = CT_Sensor;
        
        Sensor* sensor = [[Sensor alloc] init];
        if ([[obstacleDef objectForKey:@"Type"] isEqual:@"ApplyForce"])
        {
            sensor.type = ApplyForce_Sensor;
            sensor.forceX = ((NSString*) [obstacleDef objectForKey:@"ForceX"]).floatValue;
            sensor.forceY = ((NSString*) [obstacleDef objectForKey:@"ForceY"]).floatValue;
        }
        else if ([[obstacleDef objectForKey:@"Type"] isEqual:@"TogglePhysics"])
        {
            sensor.type = TogglePhysics_Sensor;
            sensor.physicsName = [obstacleDef objectForKey:@"Name"];
        }
        
        wall.data = sensor;
        [_sensors addObject:sensor]; // Have to keep a strong reference or else it gets dealloc'd. blech.
    }
    
    [space add:wall];
}

- (void) loadFieldObjectObstacle:(NSDictionary*)obstacleDef space:(ChipmunkSpace*)space
{
    float x, y, angle;

    NSString* foType = [obstacleDef objectForKey:@"Object"];
    x = [self parseXCoordinateValue:[obstacleDef objectForKey:@"X"] pctSource:_gameSize.width defaultValue:0];
    y = [self parseYCoordinateValue:[obstacleDef objectForKey:@"Y"] pctSource:_gameSize.height defaultValue:0];
    angle = ((NSNumber*)[obstacleDef objectForKey:@"Angle"]).floatValue;
    
    
    ActiveFieldObject* afo = [[ActiveFieldObject alloc] init];
    afo.definition = [FieldObjectFactory fieldObjectForName:foType];
    afo.position = ccp(x,y);
    afo.settings.rotation = angle;
    
    for( NSDictionary* animDef in [obstacleDef objectForKey:@"Animations"] )
    {
        NSString* animType = [animDef objectForKey:@"Type"];
        if ([animType isEqual:@"Rotation"])
        {
            NSNumber* frequency = [animDef objectForKey:@"Frequency"];
            if (!frequency)
                frequency = [NSNumber numberWithFloat:1.0];
            NSString* direction = [animDef objectForKey:@"Direction"];
            if (!direction)
                direction = @"Clockwise";
            
            RotationAnimation* anim = [[RotationAnimation alloc] init];
            anim.frequency = frequency.floatValue;
            anim.isClockwise = ([direction isEqual:@"Clockwise"]);
            [afo addAnimation:anim];
        }
        else if ([animType isEqual:@"Oscillation"])
        {
            NSNumber* frequency = [animDef objectForKey:@"Frequency"];
            NSNumber* rangeBegin = [animDef objectForKey:@"RangeBegin"];
            NSNumber* rangeEnd = [animDef objectForKey:@"RangeEnd"];
            
            OscillationAnimation* anim = [[OscillationAnimation alloc] init];
            anim.homePosition = afo.position;
            anim.frequency = frequency.floatValue;
            anim.rangeBegin = rangeBegin.floatValue;
            anim.rangeEnd = rangeEnd.floatValue;
            anim.isHorizontal = [[animDef objectForKey:@"Direction"] isEqual:@"Horizontal"];
            [afo addAnimation:anim];
        }

    }
    
    [_staticFieldObjects addObject:afo];
}


- (CCNode*) loadImage:(NSString*)imageName
{
    CCNode* image = [CCSprite spriteWithFile:imageName];
    if (image == nil)
        image = [CCSprite spriteWithSpriteFrameName:imageName];
    return image;
}


- (void) loadResources:(CCNode *)node
{
    return;
}

- (void) unloadResources:(CCNode *)node
{
    return;
}


- (void) addSceneryToNode:(CCNode*)node staticNode:(CCNode *)staticNode
{
    
    for (NSDictionary* imageDef in [[_plist objectForKey:@"Scenery"] objectForKey:@"Background"])
    {
        NSString* spriteName = [imageDef objectForKey:@"Image"];
        float X = [self parseXCoordinateValue:[imageDef objectForKey:@"X"] pctSource:_gameSize.width defaultValue:0];
        float Y = [self parseYCoordinateValue:[imageDef objectForKey:@"Y"] pctSource:_gameSize.height defaultValue:0];
        
        CCNode* background = [self loadImage:spriteName];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(X,Y);
        [node addChild:background z:-999999];
    }
    
    for (NSDictionary* imageDef in [[_plist objectForKey:@"Scenery"] objectForKey:@"Foreground"])
    {
        NSString* spriteName = [imageDef objectForKey:@"Image"];
        float X = [self parseXCoordinateValue:[imageDef objectForKey:@"X"] pctSource:_gameSize.width defaultValue:0];
        float Y = [self parseYCoordinateValue:[imageDef objectForKey:@"Y"] pctSource:_gameSize.height defaultValue:0];
        
        CCNode* foreground = [self loadImage:spriteName];
        foreground.anchorPoint = ccp(0,0);
        foreground.position = ccp(X,Y);
        [node addChild:foreground z:999];
        [_namedSprites setObject:foreground forKey:spriteName];
    }

}


- (CCSprite*) getNamedSprite:(NSString *)name
{
    return [_namedSprites objectForKey:name];
}


- (void) setDebug:(bool)debug
{
    _debug = debug;
}

- (bool) debug
{
    return [[_plist objectForKey:@"Debug"] isEqual:@YES];
}


- (void) gameFrame:(ccTime) dt space:(ChipmunkSpace*) space gameLayer:(CCNode*) gameLayer
{
    //empty for now
}


- (void) resetLevel:(ChipmunkSpace *)space gameLayer:(CCNode *)gameLayer
{
    for (ChipmunkShape* shape in [space shapes])
    {
        shape.body.angVel = 0;
        shape.body.vel = cpvzero;
        shape.surfaceVel = cpvzero;
        [shape.body resetForces];
        /* this is the ugly part */
        shape.body.body->v_bias_private = cpvzero;
        shape.body.body->w_bias_private = 0;
    }
    
}

- (void) syncAchievements
{
    // Sync up the available objects array with whatever is in Settings
    Achievements* ach = [Achievements sharedAchievements];
    for (AvailableFieldObject* afo in _availableFieldObjects)
    {
        switch (afo.definition.type)
        {
            case FieldObjectType_Plank: afo.count = ach.plank; break;
            case FieldObjectType_Slide: afo.count = ach.slide; break;
            case FieldObjectType_Launcher: afo.count = ach.launcher; break;
            case FieldObjectType_AirBlower: afo.count = ach.blower; break;
            case FieldObjectType_AirBlower2x: afo.count = ach.blower2x; break;
            case FieldObjectType_Trampoline: afo.count = ach.trampoline; break;
            case FieldObjectType_Trampoline2x: afo.count = ach.trampoline2x; break;
            default: break;
        }
    }
}


- (Projectile*) findProjectileForBody:(ChipmunkBody*)body
{
    for (ProjectileSource* source in _projectileSources)
    {
        Projectile* p = [source findProjectileForBody:body];
        if (p != nil)
            return p;
    }
    return nil;
}


@end
