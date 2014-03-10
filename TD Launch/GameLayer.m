//
//  ConfigurationLayer.m
//  TD Launch
//
//  Created by Kent Anderson on 8/25/12.
//
//

#import <iAd/iAd.h>
#import "AppDelegate.h"

#import "GameLayer.h"
#import "PhysicsSprite.h"
#import "CPDebugLayer.h"
#import "CCLayerPanZoom.h"
#import "CCGestureRecognizer.h"
#import "MainMenu.h"
#import "LevelMenu.h"
#import "RulerNode.h"
#import "ColoredNode.h"
#import "GestureRecognizerWithBlock.h"
#import "SaneMenu.h"
#import "Character.h"
#import "CollisionTypes.h"
#import "Screen.h"
#import "YesNoDialog.h"
#import "Settings.h"
#import "TutorialDialog.h"
#import "EventManager.h"
#import "Achievements.h"
#import "GameCenter.h"
#import "AppStore.h"

#import <sys/time.h>
#import <stdlib.h>

#import <SimpleAudioEngine.h>

// exported from LevelMenu
GameLevel* getLevelForID(int ID);


#define NUMBERS_ATLAS ([CCLabelAtlas labelWithString:@"9876543210" charMapFile:@"Numbers.png" \
                        itemWidth:SCRNX(26) itemHeight:SCRNY(38) startCharMap:'-'])


#define AFO_CONFIG_Z 9999999
#define AFO_SIM_Z    9999

#define ALMOST_ZERO  0.001

static const int DrawerOffset = 20;
static bool isTrackingPlayer = YES;

static float accel2xTimer;
static float accelHalfXTimer;
static float antiGravityTimer;

#define ACCELERATOR(a) float a = 1.0;\
if (accel2xTimer > 0) a *= 2;\
if (accelHalfXTimer > 0) a *= 0.5


//void dumpShape(cpShape* shape)
//{
//    NSLog(@"\n  Shape\n"
//          "klass type:    %d\n"
//          "bb:            %f,%f  %f,%f\n"
//          "sensor:        %d\n"
//          "e:             %f\n"
//          "u:             %f\n"
//          "surface_v:     %f,%f\n"
//          "data:          0x%p\n"
//          "collisionType: 0x%p\n"
//          "group:         0x%p\n"
//          "layers:        0x%d\n"
//          "hashid:        0x%lu\n",
//          shape->klass_private->type, shape->bb.l, shape->bb.b, shape->bb.r, shape->bb.t,
//          shape->sensor, shape->e, shape->u, shape->surface_v.x, shape->surface_v.y, shape->data,
//          shape->collision_type, shape->group, shape->layers, shape->hashid_private);
//}
//
//void dumpShapeFromIndex(void* obj, void* data)
//{
//    dumpShape((cpShape*)obj);
//}
//
//void dumpBody(void* pbody)
//{
//    cpBody* body = (cpBody*)pbody;
//    
//    NSLog(@"\nBody\n"
//          "m:            %f\n"
//          "m_inv:        %f\n"
//          "i:            %f\n"
//          "i_inv:        %f\n"
//          "p:            %f,%f\n"
//          "v:            %f,%f\n"
//          "f:            %f,%f\n"
//          "a:            %f\n"
//          "w:            %f\n"
//          "t:            %f\n"
//          "rot:          %f,%f\n"
//          "data:         0x%p\n"
//          "v_limit:      %f\n"
//          "w_limit:      %f\n"
//          "v_bias:       %f,%f\n"
//          "w_bias:       %f\n",
//          body->m, body->m_inv, body->i, body->i_inv, body->p.x, body->p.y, body->v.x, body->v.y,
//          body->f.x, body->f.y, body->a, body->w, body->t, body->rot.x, body->rot.y, body->data,
//          body->v_limit, body->w_limit, body->v_bias_private.x, body->v_bias_private.y, body->w_bias_private);
//    
//    cpShape* shape = body->shapeList_private;
//    while (shape)
//    {
//        dumpShape(shape);
//        shape = shape->prev_private;
//    }
//}
//
//
//void dumpSpace(cpSpace* space)
//{
//    static int PRINT_ID = 1;
//    NSLog(@"\nSpace:\n"
//          "  iterations:         %d\n"
//          "  gravity:            %f,%f\n"
//          "  damping:            %f\n"
//          "  idleSpeedThreshold: %f\n"
//          "  sleepTimeThreshold: %f\n"
//          "  collisionSlop:      %f\n"
//          "  collisionBias:      %f\n"
//          "  collisionPersistence: %d\n"
//          "  enableContactGraph: %d\n"
//          "  data:               0x%p\n"
//          "  staticBody:         0x%p\n"
//          "  pr - stamp:         %d\n"
//          "  pr - curr_dt:       %f\n",
//          space->iterations, space->gravity.x, space->gravity.y, space->damping, space->idleSpeedThreshold,
//          space->sleepTimeThreshold, space->collisionSlop, space->collisionBias, space->collisionPersistence,
//          space->enableContactGraph, space->data, space->staticBody, space->stamp_private, space->curr_dt_private);
//    
//    NSLog(@"Bodies");
//    cpArrayFreeEach(space->bodies_private, dumpBody);
//    
//    NSLog(@"Active Shapes");
//    cpSpatialIndexEach(space->activeShapes_private, dumpShapeFromIndex, 0);
//    
//    NSLog(@"Static Shapes");
//    cpSpatialIndexEach(space->staticShapes_private, dumpShapeFromIndex, 0);
//    
//    NSLog(@"SPACE DUMP ID: %d", PRINT_ID);
//    PRINT_ID++;
//}




/**
 Helper class 
 */
@implementation CurrentForce

+ (id) forceFromSource:(id)source body:(ChipmunkBody*)body vector:(cpVect)vector offset:(cpVect)offset recalc:(void(^)(ChipmunkBody*,ChipmunkShape*,cpVect*,cpVect*))recalc
{
    CurrentForce* f = [[CurrentForce alloc] initWithRecalc:recalc];
    f.source = source;
    f.vector = vector;
    f.offset = offset;
    f.body = body;
    
    return f;
}

+ (id) forceFromSource:(id)source body:(ChipmunkBody*)body vector:(cpVect)vector offset:(cpVect)offset
{
    return [CurrentForce forceFromSource:source body:body vector:vector offset:offset recalc:nil];
}

- (id) initWithRecalc:(void(^)(ChipmunkBody*,ChipmunkShape*,cpVect*,cpVect*))recalc
{
    if (self = [super init])
        _recalc = recalc;
    return self;
}


- (void) applyForce
{
    if (_recalc != nil)
        _recalc(_body, _source, &_vector, &_offset);
    
    ACCELERATOR(accel);
    [_body applyImpulse:cpvmult(_vector, accel) offset:_offset];
}

@end




/**
 This is it, folks.  The star of the show.  It all happens here (well, most of it, anyway)
 */
@implementation GameLayer

//***********************************************************************************
//**** CONSTRUCTOR STUFF ************************************************************
//***********************************************************************************

+(CCScene *) sceneWithLevel:(GameLevel *)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [[GameLayer alloc] initWithLevel:level];;
    	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (id) initWithLevel:(GameLevel*)level
{
    if (self = ([super init]))
    {
        gameLevel = level;
        if (gameLevel.gameConfig.selectedCharacter == nil)
            gameLevel.gameConfig.selectedCharacter = [gameLevel.availableCharacters objectAtIndex:0];
    }
    return self;
}


- (BOOL) eventOccurred:(NSString *)event data:(id)data
{
    if (event == APP_DEACTIVATED && gameLevel != nil && gameLevel.isChanged)
    {
        [gameLevel saveTempFile];
    }
    else if (event == ADBANNER_VISIBLE)
    {
        ADBannerView* adView = (ADBannerView*)data;
        float dy = adView.frame.size.height - (isSmallScreen ? 1 : 0);
        [mainScoreLabel runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-dy)]];
        [mainScoreValue runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-dy)]];
        [mainGemsLabel runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-dy)]];
        [mainGemsValue runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-dy)]];
        
        inPlayDrawer.openPosition = ccp(inPlayDrawer.openPosition.x, inPlayDrawer.openPosition.y - dy);
        if (inPlayDrawer.isOpen)
            [inPlayDrawer open:0.25];
        

        CGSize newSize = CGSizeMake(self.contentSize.width, self.contentSize.height - dy);
        self.contentSize = newSize;
        scrollView.contentSize = newSize;
    }
    else if (event == ADBANNER_HIDDEN)
    {
        ADBannerView* adView = (ADBannerView*)data;
        float dy = adView.frame.size.height - (isSmallScreen ? 1 : 0);
        [mainScoreLabel runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,dy)]];
        [mainScoreValue runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,dy)]];
        [mainGemsLabel runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,dy)]];
        [mainGemsValue runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,dy)]];

        inPlayDrawer.openPosition = ccp(inPlayDrawer.openPosition.x, inPlayDrawer.openPosition.y + dy);
        if (inPlayDrawer.isOpen)
            [inPlayDrawer open:0.25];

        
        CGSize newSize = CGSizeMake(self.contentSize.width, self.contentSize.height + dy);
        self.contentSize = newSize;
        scrollView.contentSize = newSize;
        if (!isSimulating && scrollView.content.position.y > 0)
        {
            //keepNodeOnScreen will do this for us if we're simulating.
            scrollView.content.position = ccp(scrollView.content.position.x, scrollView.content.position.y + dy);
        }
    }
    
    return YES;
}


- (void) leaderboardViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    return;
}

//***********************************************************************************
//**** FIELD SETUP       ************************************************************
//***********************************************************************************

- (void) onExit
{
    [gameLevel unloadResources:gameLayer];
    gameLevel = nil;
    space = nil;
    [self removeAllChildrenWithCleanup:YES];
    gameLayer = nil;
    
    mainScoreLabel = nil;
    mainScoreValue = nil;
    mainGemsLabel = nil;
    mainGemsValue = nil;
    
    for (CCGestureRecognizer* gr in [self gestureRecognizers])
    {
        [self removeGestureRecognizer:gr];
    }
    
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    
    for (NSString* pop in popEffects)
    {
        [[SimpleAudioEngine sharedEngine] unloadEffect:pop];
    }
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"SlideClang.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"WoodThud.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"DrumDonk.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"Tic.mp3"];

    [[EventManager sharedManager] unsubscribe:APP_DEACTIVATED listener:self];
    [[EventManager sharedManager] unsubscribe:ADBANNER_HIDDEN listener:self];
    [[EventManager sharedManager] unsubscribe:ADBANNER_VISIBLE listener:self];
}

- (void) onEnter
{
    [super onEnter];
    self.isTouchEnabled = YES;
    APPCONTROLLER.adsEnabled = YES;

    if ([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tools.plist"] == nil )
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tools.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Menu.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Characters.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SmallCharacters.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelMenuItems.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ObjectDials.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"RecapBoard.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ObstacleSheet.plist"];
    }

    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Tools.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Menu.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Characters.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"SmallCharacters.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"LevelMenuItems.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"ObjectDials.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"RecapBoard.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"ObstacleSheet.png"]];
    
    
    [gameLevel loadResources:self];
    
    popEffects = @[ @"Pop1.mp3", @"Pop2.mp3" ];
    for (NSString* pop in popEffects)
    {
        [[SimpleAudioEngine sharedEngine] preloadEffect:pop];
    }
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"SlideClang.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"WoodThud.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"DrumDonk.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Tic.mp3"];
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    currentForces = [NSMutableArray arrayWithCapacity:10];
    disabledWalls = [NSMutableDictionary dictionaryWithCapacity:5];
    
    
    if ([gameLevel hasTempFile])
    {
        [gameLevel loadTempFile:YES]; // YES = delete the file
    }
    else
    {
        [gameLevel load];
    }
    
    toggledSprites = [NSMutableDictionary dictionary];
    for (NSString* name in [gameLevel.namedSprites keyEnumerator])
    {
        CCSprite* sprite = [gameLevel.namedSprites objectForKey:name];
        [toggledSprites setObject:@(sprite.opacity == 0 ? 0 : 1) forKey:name];
    }
    
    score = gameLevel.gameData.score;
    gems = gameLevel.gameData.gems;
    distance = gameLevel.gameData.distance;

    
    [self createMenu];
    
    [self initPhysics];
    
    gameLayer = [CCNode node];
    gameLayer.contentSize = gameLevel.gameSize;
    
    [gameLevel addSceneryToNode:gameLayer staticNode:self];
        
    if (gameLevel.debug)
    {
        CPDebugLayer* debug = [CPDebugLayer debugLayerForSpace:space.space
                                                       options:@{ CPDebugLayerLineWidth : [NSNumber numberWithFloat:1.0f]}];
        [gameLayer addChild:debug];
    
//        RulerNode* ruler = [RulerNode node];
//        ruler.majorTicks = 200;
//        ruler.bgColor = ccc4f(0.0,0.0,0.0,0.0);
//        ruler.fgColor = ccc4f(0.5,0.5,0.5,1.0);
//        ruler.contentSize = gameLevel.gameSize;
//        [gameLayer addChild:ruler z:-999];
    }
    
    scrollView = [ScrollView viewWithContent:gameLayer];
    scrollView.friction = 0.05;
    scrollView.contentSize = screen;
    scrollView.anchorPoint = ccp(0, 0);
    scrollView.position = ccp(0,0); //ccp(screen.width/2,screen.height/2);
    [self addChild:scrollView];
    
    
    CGPoint valueRef = ccp(screen.width-SCRNX(27), screen.height-SCRNY(35.2));
    
    mainScoreValue = NUMBERS_ATLAS;
    mainScoreValue.scale = 0.5;
    mainScoreValue.anchorPoint = ccp(1,0);
    mainScoreValue.position = valueRef;
    [self addChild:mainScoreValue];
    
    mainScoreLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_ScoreLabel", @"Score") fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(mainScoreLabel);
    mainScoreLabel.anchorPoint = ccp(1,0);
    mainScoreLabel.position = ccp(mainScoreValue.boundingBox.origin.x - SCRNX(3), mainScoreValue.position.y+SCRNY(3));
    [self addChild:mainScoreLabel];
    
    mainGemsValue = NUMBERS_ATLAS;
    mainGemsValue.scale = 0.5;
    mainGemsValue.anchorPoint = ccp(1,0);
    mainGemsValue.position = ccp(valueRef.x, mainScoreValue.position.y - SCRNY(31.5));
    [self addChild:mainGemsValue];

    mainGemsLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_BalloonsLabel", @"Balloons") fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(mainGemsLabel);
    mainGemsLabel.anchorPoint = ccp(0,0);
    mainGemsLabel.position = ccp(mainScoreLabel.boundingBox.origin.x, mainGemsValue.position.y + (SCRNY(3)));
    [self addChild:mainGemsLabel];
    
    [self updateScores];

    
    accel2xSprite = [CCSprite spriteWithSpriteFrameName:@"Accelerator2X.png"];
    accel2xSprite.position = ccp(SCRNX(20), SCRNY(30));
    accel2xSprite.anchorPoint = ccp(0,0);
    accel2xSprite.visible = NO;
    accel2xSprite.scale = 0.67;
    [self addChild:accel2xSprite];
    accel2xLabel = NUMBERS_ATLAS;
    accel2xLabel.position = ccp(accel2xSprite.position.x + SCRNX(50), accel2xSprite.position.y + SCRNY(7));
    accel2xLabel.visible = NO;
    [self addChild:accel2xLabel];
    accel2xLabel.string = @"0";


    accelHalfXSprite = [CCSprite spriteWithSpriteFrameName:@"AcceleratorHalfX.png"];
    accelHalfXSprite.position = ccp(accel2xSprite.position.x, accel2xSprite.position.y + SCRNY(55));
    accelHalfXSprite.anchorPoint = ccp(0,0);
    accelHalfXSprite.visible = NO;
    accelHalfXSprite.scale = 0.67;
    [self addChild:accelHalfXSprite];
    accelHalfXLabel = NUMBERS_ATLAS;
    accelHalfXLabel.position = ccp(accelHalfXSprite.position.x + SCRNX(50), accelHalfXSprite.position.y + SCRNY(7));
    accelHalfXLabel.visible = NO;
    [self addChild:accelHalfXLabel];
    accelHalfXLabel.string = @"0";

    antiGravitySprite = [CCSprite spriteWithSpriteFrameName:@"AntiGravity.png"];
    antiGravitySprite.position = ccp(accelHalfXSprite.position.x, accelHalfXSprite.position.y + SCRNY(55));
    antiGravitySprite.anchorPoint = ccp(0,0);
    antiGravitySprite.visible = NO;
    antiGravitySprite.scale = 0.67;
    [self addChild:antiGravitySprite];
    antiGravityLabel = NUMBERS_ATLAS;
    antiGravityLabel.position = ccp(antiGravitySprite.position.x + SCRNX(50), antiGravitySprite.position.y + SCRNY(7));
    antiGravityLabel.visible = NO;
    [self addChild:antiGravityLabel];
    antiGravityLabel.string = @"0";
    
    [self createObjectDrawer];
    [self createCharacterDrawer];
    
    
    [self addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UIPinchGestureRecognizer alloc] init] target:self action:@selector(fieldPinched:item:)]];
    
    
    for (ActiveFieldObject* obj in gameLevel.gameConfig.activeFieldObjects)
    {
        [self addObjectToField:obj];
    }
    
    for (ActiveFieldObject* obj in gameLevel.staticFieldObjects)
    {
        [self addObjectToField:obj];
    }
   
    NSArray* frames = @[
        ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Poof01.png"]).displayFrame,
        ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Poof02.png"]).displayFrame,
        ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Poof03.png"]).displayFrame,
        ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Poof04.png"]).displayFrame,
        ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Poof05.png"]).displayFrame
    ];
    
    CCAnimation* poofAnimation = [CCAnimation animationWithSpriteFrames:frames delay:0.1];
    [[CCAnimationCache sharedAnimationCache] addAnimation:poofAnimation name:@"poof"];
    
    characterSprite = [PhysicsSprite spriteWithSpriteFrame:gameLevel.gameConfig.selectedCharacter.normalSprite];
    [characterSprite setPhysicsBody:character.body];
    [gameLayer addChild:characterSprite z:10000];
    
    offScreenPointer = [CCSprite spriteWithSpriteFrameName:@"OffScreenPointer.png"];
    offScreenPointer.anchorPoint = ccp(0.5, 1.0);
    offScreenPointer.position = ccp(0, gameLevel.gameSize.height-2);
    offScreenPointer.visible = NO;
    [gameLayer addChild:offScreenPointer z:9999999];
    
    [scrollView keepNodeOnScreen:characterSprite withMargin:CGSizeMake(SCRNX(300),SCRNY(200))];
    
    [self resetField];
    
    [self enterConfigurationState];
    
    if ([Settings globalSettings].showCharacterTutorial)
    {
        characterTutPos.y = menuDrawer.contentSize.height;
        TutorialDialog* tut = [[TutorialDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Character",
                                                                                        @"Tap here to\nselect your\ncharacter")
                                                                   at:ccp(characterTutPos.x + SCRNX(120),
                                                                          characterTutPos.y + SCRNX(80))
                                                          anchorPoint:ccp(0, 0)
                                                             scaledTo:NSLocalizedString(@"GameLayer_Tutorial_Character_Scale",@"1.0")
                                                              arrowTo:characterTutPos];
        [tut setCloseHandler:^(id sourceDlg){
            objectTutPos.y = characterTutPos.y;
            TutorialDialog* tut2 = [[TutorialDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Object",
                                                                                             @"Tap here to\nadd objects to\nthe field")
                                                                        at:ccp(objectTutPos.x + SCRNX(120),
                                                                               objectTutPos.y + SCRNX(80))
                                                               anchorPoint:ccp(0,0)
                                                                  scaledTo:NSLocalizedString(@"GameLayer_Tutorial_Object_Scale",@"1.0")
                                                                   arrowTo:objectTutPos];
            [self addChild:tut2 z:9999999];
            [Settings globalSettings].showObjectTutorial = NO;
            [[Settings globalSettings] save];
        }];
        [self addChild:tut z:9999999];
        [Settings globalSettings].showCharacterTutorial = NO;
        [[Settings globalSettings] save];
    }
    
    [[EventManager sharedManager] subscribe:APP_DEACTIVATED listener:self];
    [[EventManager sharedManager] subscribe:ADBANNER_HIDDEN listener:self];
    [[EventManager sharedManager] subscribe:ADBANNER_VISIBLE listener:self];
}



-(void) initPhysics
{
    
	space = [gameLevel createSpace];
    //cpSpaceUseSpatialHash(space.space, 50, 10);
    space.sleepTimeThreshold = 0.75;
    space.idleSpeedThreshold = 0;
    space.collisionPersistence = 1;
    
    gameLevel.launchPad.elasticity = 0.0f;
    gameLevel.launchPad.friction = 0.0;
    
    gameLevel.launchSensor.sensor = YES;
    gameLevel.launchSensor.collisionType = CT_LaunchPad;
    
    gameLevel.target.elasticity = 0;
    gameLevel.target.friction = 2.5;
    gameLevel.target.collisionType = CT_Target;
    
    
    CharacterDefinition* chDef = gameLevel.gameConfig.selectedCharacter;
    character = [[chDef createInSpace:space position:[self characterStartingPosition] angle:0].shapes objectAtIndex:0];
    
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_LaunchPad begin:@selector(chLaunchBegin:space:) preSolve:nil postSolve:nil separate:@selector(chLaunchEnd:space:)];
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_LaunchPadSegment begin:@selector(chNoBottomCollisionHit:space:) preSolve:nil postSolve:nil separate:nil];
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_NoBottomCollision begin:@selector(chNoBottomCollisionHit:space:) preSolve:nil postSolve:nil separate:nil];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Target begin:@selector(chTargetHit:space:) preSolve:nil postSolve:nil separate:@selector(chTargetLeft:space:)];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Blower begin:@selector(chBlowerHit:space:) preSolve:nil postSolve:nil separate:@selector(chBlowerLeft:space:)];
    [space addCollisionHandler:self typeA:CT_Projectile typeB:CT_Blower begin:@selector(chBlowerHit:space:) preSolve:nil postSolve:nil separate:@selector(chBlowerLeft:space:)];
    [space addCollisionHandler:self typeA:CT_Projectile_Bird typeB:CT_Blower begin:@selector(chBlowerHit:space:) preSolve:nil postSolve:nil separate:@selector(chBlowerLeft:space:)];
    [space addCollisionHandler:self typeA:CT_Projectile_Plank typeB:CT_Blower begin:@selector(chBlowerHit:space:) preSolve:nil postSolve:nil separate:@selector(chBlowerLeft:space:)];
    [space addCollisionHandler:self typeA:CT_Projectile_Slide typeB:CT_Blower begin:@selector(chBlowerHit:space:) preSolve:nil postSolve:nil separate:@selector(chBlowerLeft:space:)];

    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_BlowerBody begin:@selector(chBlowerBodyHit:space:) preSolve:nil postSolve:nil separate:nil];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Trampoline begin:nil preSolve:nil postSolve:nil separate:@selector(chTrampolineLeft:space:)];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Gem begin:@selector(chGemHit:space:) preSolve:nil postSolve:nil separate:nil];
    
    
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Sensor begin:@selector(chSensorBegin:space:) preSolve:nil postSolve:nil separate:@selector(chSensorEnd:space:)];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_AreaSensor begin:@selector(chSensorBegin:space:) preSolve:nil postSolve:nil separate:@selector(chSensorEnd:space:)];
    
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_NamedWall begin:@selector(chNamedWallHit:space:) preSolve:nil postSolve:nil separate:nil];
    
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Launcher begin:@selector(chLauncherHit:space:) preSolve:nil postSolve:nil separate:@selector(chLauncherLeft:space:)];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Plank begin:@selector(chPlankHit:space:) preSolve:nil postSolve:nil separate:nil];
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Slide begin:@selector(chSlideHit:space:) preSolve:nil postSolve:nil separate:nil];
    
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Projectile_Plank begin:@selector(chPlankHit:space:) preSolve:nil postSolve:nil separate:nil];
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Projectile_Bird begin:@selector(chPlankHit:space:) preSolve:nil postSolve:nil separate:nil];
    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Projectile_Slide begin:@selector(chSlideHit:space:) preSolve:nil postSolve:nil separate:nil];

    [space addCollisionHandler:self typeA:CT_Character typeB:CT_Accelerator begin:@selector(chAcceleratorHit:space:) preSolve:nil postSolve:nil separate:nil];
}



- (void) createObjectDrawer
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    CCSprite* drawerBack = [CCSprite spriteWithFile:@"ObjectDrawer.png"];
   
    
    // Create the Object Drawer
    objectDrawer = [Drawer node];
    objectDrawer.contentSize = drawerBack.contentSize;
    objectDrawer.anchorPoint = ccp(0.5, 0);
    
    objectDrawer.closedPosition = ccp( screen.width/2, SCRNY(-10) - drawerBack.contentSize.height );
    objectDrawer.openPosition = ccp(objectDrawer.closedPosition.x, menuDrawer.contentSize.height);
    objectDrawer.position = objectDrawer.closedPosition;
    objectDrawer.isTouchEnabled = YES;
    objectDrawer.clipContents = YES;

    [self addChild:objectDrawer z:menuDrawer.zOrder-1];
    
    drawerBack.anchorPoint = ccp(.5,.5);
    drawerBack.position = ccp(objectDrawer.contentSize.width/2, objectDrawer.contentSize.height/2);
    [objectDrawer addChild:drawerBack z:-999];
    
    
    UISwipeGestureRecognizer* downSwipe = [[UISwipeGestureRecognizer alloc] init];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [objectDrawer addGestureRecognizer:[GestureRecognizerWithBlock recognizer:downSwipe block:^(UIGestureRecognizer* recognizer, CCNode* item){
            [objectDrawer close:0.15];
    }]];
    
    
    
    CCNode* objHolder = [CCNode node];
    objHolder.anchorPoint = ccp(0,0);
    objHolder.position = ccp(0,0);
    
    float x = SCRNX(30) + ((AvailableFieldObject*)[gameLevel.availableFieldObjects objectAtIndex:0]).definition.gameSprite.originalSize.width/2;
    AvailableFieldObject* lastObj;
    for (AvailableFieldObject* obj in gameLevel.availableFieldObjects)
    {
        CCSprite* objSprite = [CCSprite spriteWithSpriteFrame:obj.definition.gameSprite];
        objSprite.anchorPoint = ccp(0.5,0.5);
        objSprite.position = ccp(x, (objectDrawer.contentSize.height-SCRNY(40))/2);
        if (obj.definition.type != FieldObjectType_Launcher
            && obj.definition.type != FieldObjectType_Accelerator2X
            && obj.definition.type != FieldObjectType_AcceleratorHalfX
            && obj.definition.type != FieldObjectType_AntiGravity
            && obj.definition.type != FieldObjectType_Aligner)
        {
            objSprite.rotation = -30;
        }
        objSprite.opacity = 255;
        objSprite.isTouchEnabled = YES;
        [objHolder addChild:objSprite];
        
        [objSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item)
                                         {
                                             [self itemTappedInDrawer:item];
                                         }]];
        
        // The sprites swallow the pan gesture, so we'll need to capture it and forward it to the scroller
        [objSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UIPanGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item)
                                         {
                                             [objScrollView forwardPanEvent:r node:item];
                                         }]];
    
        obj.menuItem = objSprite;
        //        x += objSprite.contentSize.width + SCRNX(60);
        x += objSprite.boundingBox.size.width + SCRNX(30);
        
        lastObj = obj;
    }
    
    x += SCRNX(20);
    
    CCLabelBMFont* storeSprite = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_ObjectDrawer_Help", @"Help...") fntFile:@"TDFont120.fnt"];
    storeSprite.scale = 0.5;
    storeSprite.anchorPoint = ccp(0.5, 0.5);
    storeSprite.position = ccp(x, (objectDrawer.contentSize.height-SCRNY(40))/2);
    storeSprite.isTouchEnabled = YES;
    [objHolder addChild:storeSprite];
    
    [storeSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item)
    {
        [gameLevel saveTempFile];
        [[CCDirector sharedDirector] replaceScene:[AppStore scene]];
    }]];
    
    [storeSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UIPanGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item)
    {
        [objScrollView forwardPanEvent:r node:item];
    }]];
    
    
    float width = BB_RIGHT(storeSprite) + SCRNX(30);
    objHolder.contentSize = CGSizeMake(width, objectDrawer.contentSize.height-SCRNY(40));
    
    
    for (AvailableFieldObject* afo in gameLevel.availableFieldObjects)
    {
        afo.countLabel = NUMBERS_ATLAS;
        afo.countLabel.scale = 0.5;
        afo.countLabel.anchorPoint = ccp(0.5,0);
        afo.countLabel.position = ccp(afo.menuItem.position.x, SCRNX(20));
        [objHolder addChild:afo.countLabel];
    }
    
    objScrollView = [ScrollView viewWithContent:objHolder foreground:nil background:nil];
    objScrollView.contentSize = CGSizeMake(objectDrawer.contentSize.width-SCRNX(58), objHolder.contentSize.height);
    objScrollView.anchorPoint = ccp(0,0.5);
    objScrollView.position = ccp(SCRNX(17), objectDrawer.contentSize.height/2);
    objScrollView.friction = 0.15;
    objScrollView.clipContents = YES;
    
    [objectDrawer addChild:objScrollView];

   
    [self updateObjectAvailability];

}


- (void) createCharacterDrawer
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
        
    // Create the Character Drawer
    characterDrawer = [Drawer node];
    characterDrawer.contentSize = CGSizeMake(screen.width * .65, screen.height * .25);
    characterDrawer.anchorPoint = ccp(0.5, 0);
    characterDrawer.closedPosition = ccp( screen.width/2, SCRNY(-10) - characterDrawer.contentSize.height );
    characterDrawer.openPosition = ccp(objectDrawer.closedPosition.x, menuDrawer.contentSize.height);
    characterDrawer.position = characterDrawer.closedPosition;
    characterDrawer.isTouchEnabled = YES;
    [self addChild:characterDrawer z:menuDrawer.zOrder-1];
    
    UISwipeGestureRecognizer* downSwipe = [[UISwipeGestureRecognizer alloc] init];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    
    [characterDrawer addGestureRecognizer:[GestureRecognizerWithBlock recognizer:downSwipe block:^(UIGestureRecognizer* recognizer, CCNode* item)
    {
        if (characterDrawer.isOpen)
            [characterDrawer close:0.25];
    }]];
    
    CCSprite* drawerBack = [CCSprite spriteWithFile:@"CharacterDrawer.png"];;
    //drawerBack.contentSize = CGSizeMake(characterDrawer.contentSize.width-5, characterDrawer.contentSize.height-6);
    drawerBack.scaleX = (characterDrawer.contentSize.width / drawerBack.contentSize.width);
    drawerBack.scaleY = (characterDrawer.contentSize.height / drawerBack.contentSize.height);
    drawerBack.anchorPoint = ccp(.5,.45);
    drawerBack.position = ccp(characterDrawer.contentSize.width/2, characterDrawer.contentSize.height/2);
    [characterDrawer addChild:drawerBack z:-999];
    
   
    if (gameLevel.gameConfig.selectedCharacter == nil)
        gameLevel.gameConfig.selectedCharacter = [gameLevel.availableCharacters objectAtIndex:0];
    
    
    
    NSMutableArray* charSprites = [NSMutableArray arrayWithCapacity:gameLevel.availableCharacters.count];
    
    float xSpacer = (characterDrawer.contentSize.width)/6;
    
    for (int i=0; i < gameLevel.availableCharacters.count; i++)
    {
        CharacterDefinition* ch = [gameLevel.availableCharacters objectAtIndex:i];
        CCSprite* chSprite;
        
        if (ch == gameLevel.gameConfig.selectedCharacter)
            chSprite = [CCSprite spriteWithSpriteFrame:ch.happyBigSprite];
        else
            chSprite = [CCSprite spriteWithSpriteFrame:ch.normalBigSprite];
        
        [charSprites addObject:chSprite];
        
        chSprite.anchorPoint = ccp(0.5, 0);
        chSprite.position = ccp(xSpacer*(i+1), characterDrawer.contentSize.height/6);
        chSprite.isTouchEnabled = YES;
        if (isSmallScreen)
            chSprite.scale = 0.8;
        chSprite.tag = i;
        [characterDrawer addChild:chSprite];
        
        
        [chSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
            
            for (CCSprite* sp in charSprites)
            {
                CharacterDefinition* ch = [gameLevel.availableCharacters objectAtIndex:sp.tag];
                if (sp == item)
                {
                    sp.displayFrame = ch.happyBigSprite;
                    gameLevel.gameConfig.selectedCharacter = ch;
                    if (character != nil)
                    {
                        [space removeShape:character];
                        [space removeBody:character.body];
                    }
                    character = [[ch createInSpace:space position:characterSprite.position angle:-CC_DEGREES_TO_RADIANS(characterSprite.rotation)].shapes objectAtIndex:0];
                    characterSprite.displayFrame = ch.normalSprite;
                    [characterSprite setPhysicsBody:character.body];
                }
                else
                {
                    sp.displayFrame = ch.normalBigSprite;
                }
            }
        }]];

    }
   
}


- (CCTexture2D*) createColorTexture:(ccColor3B) color size:(CGSize)size
{
    GLubyte buffer[4];
    buffer[0] = color.r;
    buffer[1] = color.g;
    buffer[2] = color.b;
    buffer[3] = 0xff;
    
    CCTexture2D* texture = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:1 pixelsHigh:1 contentSize:size];
    return texture;
}


-(void) createMenu
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
   
    menuDrawer = [Drawer node];
    menuDrawer.contentSize = CGSizeMake(screen.width, screen.height * (isSmallScreen ? 0.15 : 0.10));
    menuDrawer.anchorPoint = ccp(0,0);
    menuDrawer.position = ccp(0,0);
    menuDrawer.closedPosition = ccp( screen.width - SCRNX(100), 0 );
    menuDrawer.openPosition = ccp(0,0);
    menuDrawer.isTouchEnabled = YES;
    [self addChild:menuDrawer z:99999];
    [menuDrawer open:0];
    
    CCSprite* drawerBack = [[CCSprite alloc] init];
    drawerBack.contentSize = menuDrawer.contentSize;
    [drawerBack setTexture:[self createColorTexture:ccc3(0xff, 0xff, 0xff) size:drawerBack.contentSize]];
    [drawerBack setTextureRect:CGRectMake(0, 0, drawerBack.contentSize.width, drawerBack.contentSize.height)];
    drawerBack.opacity = 128;
    drawerBack.anchorPoint = ccp(0,0);
    drawerBack.position = ccp(0,0);
    [menuDrawer addChild:drawerBack z:-999];
    
    if (gameLevel.gameConfig.selectedCharacter == nil)
        gameLevel.gameConfig.selectedCharacter = [gameLevel.availableCharacters objectAtIndex:0];
    
    
    #define NEW_MENU_BUTTON(DRAWER,VAR,IMAGE,X) CCSprite* VAR = [CCSprite spriteWithSpriteFrameName:IMAGE]; \
                                         VAR.anchorPoint = ccp(0.5,0.5); \
                                         VAR.position = ccp(X, menuDrawer.contentSize.height/2); \
                                         VAR.isTouchEnabled = YES; \
                                         [DRAWER addChild:VAR];

    
    #define SS(A) (isSmallScreen ? A-15 : A)
    
    NEW_MENU_BUTTON(menuDrawer, backButton, @"Back.png", SCRNX(50));
    NEW_MENU_BUTTON(menuDrawer, characterButton, @"SteveHappy.png", SCRNX(SS(200)));
    characterButton.scale = 0.6;
    NEW_MENU_BUTTON(menuDrawer, objectButton, @"Blower.png", SCRNX(SS(335)));
    objectButton.scale = 0.7;
    objectButton.rotation = 40;
    NEW_MENU_BUTTON(menuDrawer, goButton, @"Go.png", SCRNX(SS(470)));
    NEW_MENU_BUTTON(menuDrawer, resetButton, @"Reset.png", SCRNX(SS(600)));
    
    CCLabelBMFont* clearAllButton = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_ClearAllLabel", @"Clear\nAll") fntFile:@"TDFontRed72.fnt"];
    clearAllButton.alignment = kCCTextAlignmentCenter;
    clearAllButton.scale = 0.9;
    clearAllButton.anchorPoint = ccp(0.5,0.5);
    clearAllButton.position = ccp(SCRNX(SS(740)), menuDrawer.contentSize.height*1.1/2);
    clearAllButton.isTouchEnabled = YES;
    [menuDrawer addChild:clearAllButton];
    //NEW_MENU_BUTTON(menuDrawer, clearAllButton, @"ClearAll.png", SCRNX(SS(750)));
    
    NEW_MENU_BUTTON(menuDrawer, statsButton, @"Stats.png", SCRNX(SS(875)));
    NEW_MENU_BUTTON(menuDrawer, toggleButton, @"ToggleMenu.png", menuDrawer.contentSize.width - SCRNX(30));
    
    characterTutPos = characterButton.position;
    objectTutPos = objectButton.position;
    
    
    [goButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                   {
                                       AUDIOTIC1;
                                       [self enterSimulationState];
                                   }]];
    
    [toggleButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                   {
                                       CGPoint tmpPos = backButton.position;
                                       backButton.position = toggleButton.position;
                                       toggleButton.position = tmpPos;
                                       [self toggleDrawer:menuDrawer];
                                   }]];
    
    [backButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                      {
                                          AUDIOTIC1;
                                          if (gameLevel.isChanged){
                                              YesNoDialog* yesNo = [[YesNoDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_SaveChangesMsg", @"Save changes?")
                                                              onYes:^(){
                                                                  AUDIOTIC2;
                                                                  [gameLevel saveConfig];
                                                                  [[CCDirector sharedDirector] replaceScene: [LevelMenu scene]];
                                                              }
                                                              onNo:^(){
                                                                  AUDIOTIC2;
                                                                  [[CCDirector sharedDirector] replaceScene: [LevelMenu scene]];
                                                              }];
                                              yesNo.showCancel = YES;
                                              [self addChild:yesNo z:9999999];
                                          }
                                          else
                                          {
                                              [[CCDirector sharedDirector] replaceScene: [LevelMenu scene]];
                                          }
                                      }]];
    
    [resetButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                       {
                                           AUDIOTIC1;
                                           if (isSimulating)
                                               [self unscheduleUpdate];
                                           [self enterConfigurationState];
                                           [self resetField];
                                       }]];
    
    [clearAllButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                       {
                                           AUDIOTIC1;
                                           YesNoDialog* yesNo = [[YesNoDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_AreYouSureMsg", @"Are you sure?")
                                                           onYes:^(){
                                                               AUDIOTIC2;
                                                               [self clearAllObjects];
                                                           }
                                                           onNo:^(){
                                                               AUDIOTIC2;
                                                           }];
                                           [self addChild:yesNo z:9999999];
                                      }]];
    
    [statsButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                       {
                                           AUDIOTIC1;
                                           [self showRecapScreen:NO];
                                       }]];
    
    [characterButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
    {
       AUDIOTIC1;
       if (characterDrawer.isOpen)
       {
           [characterDrawer close:0.15];
       }
       else
       {
           if (objectDrawer.isOpen)
               [objectDrawer close:0.15];
           [characterDrawer open:.25];
           if ([Settings globalSettings].showDrawerTutorial)
           {
               CCCallBlock* showTut = [CCCallBlock actionWithBlock:^()
               {
                   TutorialDialog* tut = [[TutorialDialog alloc]
                                          initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Menu",@"Swipe down to\nclose the\nmenu")
                                          at:ccp(self.contentSize.width/2,
                                                 self.contentSize.height*0.65)
                                          anchorPoint:ccp(.5,.5)
                                          scaledTo:nil
                                          arrowTo:ccp(BB_HORZ_PCT(characterDrawer, 0.40),
                                                      BB_VERT_PCT(characterDrawer, 1.0)+SCRNY(5))];
                   [self addChild:tut z:9999999];
                   [Settings globalSettings].showDrawerTutorial = NO;
                   [[Settings globalSettings] save];
               }];
               [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.30] two:showTut]];
           }
       }
    }]];
    
    [objectButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
    {
       AUDIOTIC1;
       if (objectDrawer.isOpen)
       {
           [objectDrawer close:0.15];
       }
       else
       {
           if (characterDrawer.isOpen)
               [characterDrawer close:0.15];
           [objectDrawer open:.25];
           if ([Settings globalSettings].showDrawerTutorial)
           {
               CCCallBlock* showTut = [CCCallBlock actionWithBlock:^()
               {
                   TutorialDialog* tut = [[TutorialDialog alloc]
                                          initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Menu",@"Swipe down to\nclose the\nmenu")
                                          at:ccp(self.contentSize.width/2,
                                                 self.contentSize.height*0.65)
                                          anchorPoint:ccp(.5,.5)
                                          scaledTo:nil
                                          arrowTo:ccp(BB_HORZ_PCT(objectDrawer, 0.40),
                                                      BB_VERT_PCT(objectDrawer, 1.0)+SCRNY(5))];
                   [self addChild:tut z:9999999];
                   [Settings globalSettings].showDrawerTutorial = NO;
                   [[Settings globalSettings] save];
               }];
               [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.30] two:showTut]];
           }
       }
    }]];
    
    
    inPlayDrawer = [Drawer node];
    inPlayDrawer.contentSize = isSmallScreen ? CGSizeMake(SCRNX(400), SCRNY(85)): CGSizeMake(SCRNX(350),SCRNY(75));
    inPlayDrawer.anchorPoint = ccp(0,0);
    inPlayDrawer.openPosition = ccp(0,screen.height - inPlayDrawer.contentSize.height);
    inPlayDrawer.closedPosition = ccp( 0, screen.height + SCRNY(10) );
    inPlayDrawer.isTouchEnabled = YES;
    [self addChild:inPlayDrawer z:99999];
    [inPlayDrawer close:0];
    
    //NEW_MENU_BUTTON(inPlayDrawer, trackPlayerButton, @"TrackPlayerOn.png", SCRNX(320));
    NEW_MENU_BUTTON(inPlayDrawer, pauseButton, @"Pause.png", SCRNX(50));
    NEW_MENU_BUTTON(inPlayDrawer, inPlayResetButton, @"Reset.png", isSmallScreen ? SCRNX(150) : SCRNX(130));
    NEW_MENU_BUTTON(inPlayDrawer, stopButton, @"Stop.png", isSmallScreen ? SCRNX(250) : SCRNX(210));
    NEW_MENU_BUTTON(inPlayDrawer, soundButton, @"SoundOn.png", isSmallScreen ? SCRNX(350) : SCRNX(290));
    
    soundOnFrame = soundButton.displayFrame;
    soundOffFrame = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SoundOff.png"]).displayFrame;
    if ([Settings globalSettings].sound == YES)
        soundButton.displayFrame = soundOnFrame;
    else
        soundButton.displayFrame = soundOffFrame;
    
//    trackPlayerOnFrame = trackPlayerButton.displayFrame;
//    trackPlayerOffFrame = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"TrackPlayerOff.png"]).displayFrame;
//    if (!isTrackingPlayer)
//        trackPlayerButton.displayFrame = trackPlayerOffFrame;
    
    pauseSpriteFrame = pauseButton.displayFrame;
    
    inPlayResetButton.opacity = 0;
    stopButton.opacity = 0;
    soundButton.opacity = 0;
    
//    [trackPlayerButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
//                                             {
//                                                 isTrackingPlayer = !isTrackingPlayer;  // this is a global variable that will hold its value across levels
//                                                 if (isTrackingPlayer)
//                                                     trackPlayerButton.displayFrame = trackPlayerOnFrame;
//                                                 else
//                                                     trackPlayerButton.displayFrame = trackPlayerOffFrame;
//                                                 
//                                             }]];
    
    [pauseButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                    {
                                        AUDIOTIC2;
                                        isPaused = !isPaused;
                                        if (isPaused)
                                        {
                                            pauseButton.displayFrame = goButton.displayFrame;
                                            [inPlayResetButton runAction:[CCFadeIn actionWithDuration:0.10]];
                                            [stopButton runAction:[CCFadeIn actionWithDuration:0.10]];
                                            [soundButton runAction:[CCFadeIn actionWithDuration:0.10]];
                                        }
                                        else
                                        {
                                            pauseButton.displayFrame = pauseSpriteFrame;
                                            [inPlayResetButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                            [stopButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                            [soundButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                        }
                                    }]];
    
    [stopButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                    {
                                        AUDIOTIC2;
                                        if (stopButton.opacity == 0)
                                            return;
                                        [inPlayResetButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                        [stopButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                        [soundButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                        [self finishSimulationState:NO];
                                        pauseButton.displayFrame = pauseSpriteFrame;
                                    }]];
    
    [inPlayResetButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                      {
                                          AUDIOTIC2;
                                          if (inPlayResetButton.opacity == 0)
                                              return;
                                          [inPlayResetButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                          [stopButton runAction:[CCFadeOut actionWithDuration:0.10]];
                                          [soundButton runAction:[CCFadeOut actionWithDuration:0.10]];

                                          [self resetField];
                                          [self enterSimulationState];
                                          pauseButton.displayFrame = pauseSpriteFrame;
                                      }]];
    
    [soundButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                       {
                                           AUDIOTIC2;
                                           if ([Settings globalSettings].sound == YES)
                                           {
                                               [Settings globalSettings].sound = NO;
                                               soundButton.displayFrame = soundOffFrame;
                                           }
                                           else
                                           {
                                               [Settings globalSettings].sound = YES;
                                               soundButton.displayFrame = soundOnFrame;
                                           }
                                           [SimpleAudioEngine sharedEngine].mute = ![Settings globalSettings].sound;
                                           [[Settings globalSettings] save];
                                       }]];
    
    
                                      
#undef NEW_MENU_BUTTON
    #undef SS
    
}



- (void) showRecapScreen
{
    [self showRecapScreen:YES];
}


- (void) showRecapScreen:(BOOL)showAchievements
{
    
    CGSize screen = [[CCDirector sharedDirector] winSize];

    CCSprite* recapBackground = [CCSprite spriteWithSpriteFrameName:@"RecapBackground.png"];
    recapBackground.anchorPoint = ccp(0,0);
    recapBackground.position = ccp(0,0);
    
    recapScreen = [CCNode node];
    recapScreen.contentSize = recapBackground.contentSize;
    recapScreen.anchorPoint = ccp(.5,.5);
    recapScreen.position = ccp(screen.width/2, screen.height/2);
    [recapScreen addChild:recapBackground];

    
    NSString* titleString = [NSString stringWithFormat:NSLocalizedString(@"GameLayer_RecapTitle", @"Level %d"), gameLevel.ID];
    CCLabelBMFont* title = [CCLabelBMFont labelWithString:titleString fntFile:@"TDFont120.fnt"];
    title.anchorPoint = ccp(.5,1);
    title.position = ccp(recapScreen.contentSize.width/2, recapBackground.contentSize.height - SCRNY(25));
    [recapScreen addChild:title];
    
    if (gameLevel.gameData.distance > 0) // Don't show the character if they haven't run anything.
    {
        CCSprite* recapCharacter = [CCSprite spriteWithSpriteFrame:gameLevel.gameConfig.selectedCharacter.happyBigSprite];
        recapCharacter.anchorPoint = ccp(0.5,0.5);
        recapCharacter.position = ccp(recapScreen.boundingBox.size.width/2, 2*recapScreen.boundingBox.size.height/5);
        if (isRetinaScreen)
            recapCharacter.scale = 1.8;
        //recapCharacter.opacity = 50;
        [recapScreen addChild:recapCharacter];
        
        if (showAchievements == NO)  // must be coming from the stats menu button.  Just show a smiling character.
            recapCharacter.displayFrame = gameLevel.gameConfig.selectedCharacter.normalBigSprite;
        else if (isOnTarget)
            recapCharacter.displayFrame = gameLevel.gameConfig.selectedCharacter.happyBigSprite;
        else
            recapCharacter.displayFrame = gameLevel.gameConfig.selectedCharacter.sadBigSprite;
    }
    
    CCLabelBMFont* lastRunLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_LastRunLabel", @"Last Run") fntFile:@"TDFontYellow96.fnt"];
    lastRunLabel.scale = 0.8;
    lastRunLabel.anchorPoint = ccp(0,0);
    lastRunLabel.position = ccp(SCRNX(85), SCRNY(260));
    [recapScreen addChild:lastRunLabel];
    
    CCLabelBMFont* highScoreLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_HighScoreLabel", @"High Score") fntFile:@"TDFontYellow96.fnt"];
    highScoreLabel.scale = lastRunLabel.scale;
    highScoreLabel.anchorPoint = ccp(0,0);
    highScoreLabel.position = ccp(recapScreen.contentSize.width/2 + SCRNX(70), lastRunLabel.position.y);
    [recapScreen addChild:highScoreLabel];

    
    
    // Last Run Scores
    CCLabelBMFont* scoreLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_ScoreLabel", @"Score") fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(scoreLabel);
    scoreLabel.anchorPoint = ccp(0,0);
    scoreLabel.position = ccp(lastRunLabel.position.x + SCRNX(15), SCRNY(200));
    [recapScreen addChild:scoreLabel];
    
    CCLabelAtlas* recapScore = NUMBERS_ATLAS;
    recapScore.anchorPoint=ccp(1,0);
    recapScore.position = ccp((recapScreen.contentSize.width/2)-SCRNX(70), scoreLabel.position.y);
    recapScore.scale=0.6;
    [recapScreen addChild:recapScore];
    
    
    CCLabelBMFont* gemsLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_BalloonsLabel", @"Balloons") fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(gemsLabel);
    gemsLabel.anchorPoint = ccp(0,0);
    gemsLabel.position = ccp(scoreLabel.position.x, scoreLabel.position.y - (SCRNY(60)));
    [recapScreen addChild:gemsLabel];
    
    CCLabelAtlas* recapGems = NUMBERS_ATLAS;
    recapGems.anchorPoint=ccp(1,0);
    recapGems.position = ccp(recapScore.position.x, gemsLabel.position.y);
    recapGems.scale=0.6;
    [recapScreen addChild:recapGems];
    
    if (isOnTarget && gameLevel.gameData.overallStars > 0)
    {
        NSString* starsName = [NSString stringWithFormat:@"Stars%d.png", gameLevel.gameData.overallStars];
        CCSprite* overallStars = [CCSprite spriteWithSpriteFrameName:starsName];
        overallStars.anchorPoint = ccp(0.5, 1.0);
        overallStars.scale = 1.2;
        overallStars.position =  ccp((gemsLabel.position.x + recapGems.position.x)/2, recapGems.position.y-SCRNY(20));
        [recapScreen addChild:overallStars];
    }
    
    // High Scores
    CCLabelBMFont* hiScoreLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_ScoreLabel", nil) fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(hiScoreLabel);
    hiScoreLabel.anchorPoint = ccp(0,0);
    hiScoreLabel.position = ccp(highScoreLabel.position.x + SCRNX(15), scoreLabel.position.y);
    [recapScreen addChild:hiScoreLabel];
    
    CCLabelAtlas* highScore = NUMBERS_ATLAS;
    highScore.anchorPoint=ccp(1,0);
    highScore.position = ccp((recapScreen.contentSize.width)-SCRNX(100), recapScore.position.y);
    highScore.scale=0.6;
    [recapScreen addChild:highScore];
    
    
    CCLabelBMFont* hiGemsLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_BalloonsLabel", nil) fntFile:@"TDFontYellow96.fnt"];
    TDFONT_MEDIUM(hiGemsLabel);
    hiGemsLabel.anchorPoint = ccp(0,0);
    hiGemsLabel.position = ccp(hiScoreLabel.position.x, gemsLabel.position.y);
    [recapScreen addChild:hiGemsLabel];
    
    CCLabelAtlas* highGems = NUMBERS_ATLAS;
    highGems.anchorPoint=ccp(1,0);
    highGems.position = ccp(highScore.position.x, hiGemsLabel.position.y);
    highGems.scale=0.6;
    [recapScreen addChild:highGems];
    
    if (gameLevel.gameData.highStars > 0)
    {
        NSString* starsName = [NSString stringWithFormat:@"Stars%d.png", gameLevel.gameData.highStars];
        CCSprite* highStars = [CCSprite spriteWithSpriteFrameName:starsName];
        highStars.anchorPoint = ccp(0.5, 1.0);
        highStars.position =  ccp((hiGemsLabel.position.x + highGems.position.x)/2, highGems.position.y-SCRNY(20));
        highStars.scale = 1.2;
        [recapScreen addChild:highStars];
    }
    
    if (isOnTarget)
    {
        recapScore.string = [NSString stringWithFormat:@"%d", gameLevel.gameData.score];
        recapGems.string = [NSString stringWithFormat:@"%d", gameLevel.gameData.gems];
    }
    else
    {
        recapScore.string = @"---";
        recapGems.string = @"---";
    }
    
    highScore.string = [NSString stringWithFormat:@"%d", gameLevel.gameData.highScore];
    highGems.string = [NSString stringWithFormat:@"%d", gameLevel.gameData.highGems];
    
    if (showAchievements)
    {
#define ADD_AWARD(obj, spriteFrame, x, isUpd) if (obj){\
                                        isUpd = YES;\
                                        CCSprite* spr = [CCSprite spriteWithSpriteFrame:spriteFrame];\
                                        spr.scale = 0.5;\
                                        spr.anchorPoint = ccp(1,0);\
                                        spr.position = ccp(x, SCRNX(20));\
                                        [recapScreen addChild:spr];\
                                        x -= (spr.boundingBox.size.width + SCRNX(10)); }
        

//        struct AchievementResult result = { 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, NO, NO, YES, NO, NO };
        struct AchievementResult result = [[Achievements sharedAchievements] applyLevelData:gameLevel];
        
        BOOL isUpdated = NO;
        float x = recapScreen.contentSize.width - SCRNX(30);
        
        ADD_AWARD(result.plank,         [PlankFieldObject definition].gameSprite,               x, isUpdated);
        ADD_AWARD(result.slide,         [SlideFieldObject definition].gameSprite,               x, isUpdated);
        ADD_AWARD(result.trampoline,    [TrampolineFieldObject definition].gameSprite,          x, isUpdated);
        ADD_AWARD(result.trampoline2x,  [Trampoline2xFieldObject definition].gameSprite,        x, isUpdated);
        ADD_AWARD(result.blower,        [AirBlowerFieldObject definition].gameSprite,           x, isUpdated);
        ADD_AWARD(result.blower2x,      [AirBlower2xFieldObject definition].gameSprite,         x, isUpdated);
        ADD_AWARD(result.launcher,      [LauncherFieldObject definition].gameSprite,            x, isUpdated);
        ADD_AWARD(result.accel2X,       [Accelerator2XFieldObject definition].gameSprite,       x, isUpdated);
        ADD_AWARD(result.accelHalfX,    [AcceleratorHalfXFieldObject definition].gameSprite,    x, isUpdated);
        ADD_AWARD(result.antiGravity,   [AntiGravityFieldObject definition].gameSprite,         x, isUpdated);
        ADD_AWARD(result.aligner,       [AlignerFieldObject definition].gameSprite,             x, isUpdated);
        ADD_AWARD(result.bruce,         [CharacterDefinition Bruce].happySprite,                x, isUpdated);
        ADD_AWARD(result.toby,          [CharacterDefinition Toby].happySprite,                 x, isUpdated);
        ADD_AWARD(result.angie,         [CharacterDefinition Angie].happySprite,                x, isUpdated);
        
        if (isUpdated)
        {
            CCLabelBMFont* earnedSprite = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_EarnedLabel", @"Earned") fntFile:@"TDFont120.fnt"];
            TDFONT_MEDIUM(earnedSprite);
            earnedSprite.anchorPoint = ccp(1,0);
            earnedSprite.position = ccp(x-SCRNX(5), SCRNX(20));
            [recapScreen addChild:earnedSprite];
        }
#undef ADD_AWARD
    }

    nextLevelButton = nil;
    
    NSString* nextLevelStr = NSLocalizedString(@"GameLayer_Recap_NextLevel", @"Next Level");
    nextLevelButton = [CCLabelBMFont labelWithString:nextLevelStr fntFile:@"TDFontYellow96.fnt"];
    nextLevelButton.alignment = kCCTextAlignmentCenter;
    nextLevelButton.scale = 0.45;
    nextLevelButton.anchorPoint = ccp(1,0.5);
    nextLevelButton.position = ccp(BB_RIGHT(recapScreen) - SCRNX(60), BB_TOP(recapScreen));
    
    nextLevelButton.opacity = 0;
    nextLevelButton.isTouchEnabled = YES;

    CGPoint nextLvlPos = ccp(BB_RIGHT(recapScreen) - SCRNX(60),
                             recapScreen.boundingBox.origin.y + BB_TOP(title) - title.boundingBox.size.height*0.6);

    if ([Achievements sharedAchievements].level > gameLevel.ID && showAchievements && gameLevel.ID < 10)
    {
        [nextLevelButton runAction:[CCMoveTo actionWithDuration:0.5 position:nextLvlPos]];
        [nextLevelButton runAction:[CCFadeIn actionWithDuration:0.75]];
    }
    else
    {
        nextLevelButton.position = nextLvlPos;
        nextLevelButton.opacity = 255;
    }

    [nextLevelButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
    {
        GameLevel* nextLevel = getLevelForID(gameLevel.ID+1);
        AUDIOTIC1;

        CCCallBlock* loadLevel = [CCCallBlock actionWithBlock:^(void)
        {
            if (nextLevel == nil)
            {
                [[CCDirector sharedDirector] replaceScene: [LevelMenu scene]];
            }
            else
            {
                [[CCDirector sharedDirector] replaceScene: [GameLayer sceneWithLevel:nextLevel]];
            }
            [self removeAllChildrenWithCleanup:YES];
        }];
        
        if (gameLevel.isChanged)
        {
            YesNoDialog* yesNo = [[YesNoDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_SaveChangesMsg", @"Save changes?")
                    onYes:^()
                    {
                        AUDIOTIC2;
                        [gameLevel saveConfig];
                    }
                    onNo:nil
                    onEither:^()
                    {
                        AUDIOTIC2;
                        nextLevelButton.string = NSLocalizedString(@"LevelMenu_LoadingMsg", "Loading...");
                        [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.01] two:loadLevel]];
                    }];
            yesNo.showCancel = YES;
            [self addChild:yesNo z:9999999];
        }
        else
        {
            nextLevelButton.string = NSLocalizedString(@"LevelMenu_LoadingMsg", "Loading...");
            [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.01] two:loadLevel]];
        }
        
    }]];
    
    
    recapScreen.visible = YES;
    [self addChild:recapScreen z:999999];
    
    
    if ([GameCenter sharedInstance].isAvailable && [GameCenter sharedInstance].isAuthenticated)
    {
        gameCenterButton = [CCLabelBMFont labelWithString:NSLocalizedString(@"GameLayer_Recap_LeaderboardsLabel", @"Leaderboards") fntFile:@"TDFont120.fnt"];
        TDFONT_MEDIUM(gameCenterButton);
        gameCenterButton.anchorPoint = ccp(0,0);
        gameCenterButton.position = ccp(recapScreen.boundingBox.origin.x + SCRNX(30),
                                        recapScreen.boundingBox.origin.y + SCRNX(20));
        gameCenterButton.isTouchEnabled = YES;
        
        [gameCenterButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                                {
                                                    AUDIOTIC1;
                                                    [[GameCenter sharedInstance] showLeaderBoard:gameLevel.ID];
                                                }]];
    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    __unsafe_unretained CCNode* _recapScreen = recapScreen;
    CCNode* glass = [self setDialogGlass:nil z:1000001 onTouch:^(id data){
        if (weakSelf->gameCenterButton != nil)
        {
            [weakSelf removeChild:weakSelf->gameCenterButton cleanup:YES];
            weakSelf->gameCenterButton = nil;
        }
        
        if (weakSelf->nextLevelButton != nil)
        {
            [weakSelf removeChild:weakSelf->nextLevelButton cleanup:YES];
            weakSelf->nextLevelButton = nil;
        }
        
        [_recapScreen removeAllChildrenWithCleanup:YES];
        [weakSelf clearDialogGlass];
        [weakSelf enterConfigurationState];
    }];
    
    if (gameCenterButton != nil)
        [self addChild:gameCenterButton z:glass.zOrder+1];
    
    if (nextLevelButton != nil)
        [self addChild:nextLevelButton z:glass.zOrder + 1];
}



- (void) removeRecapScreen
{
    if (recapScreen != nil)
    {
        [recapScreen removeAllChildrenWithCleanup:YES];
        [self removeChild:recapScreen cleanup:YES];
        recapScreen = nil;
    }
    
    if (gameCenterButton != nil)
    {
        [self removeChild:gameCenterButton cleanup:YES];
        gameCenterButton = nil;
    }
}

//***********************************************************************************
//**** GAME EXECUTION                 ***********************************************
//***********************************************************************************



- (void) enterConfigurationState
{
    isSimulating = NO;
    [self removeRecapScreen];
    [objectDrawer runAction:[CCMoveTo actionWithDuration:0.15 position:objectDrawer.closedPosition]];
    [characterDrawer runAction:[CCMoveTo actionWithDuration:0.15 position:characterDrawer.closedPosition]];
    [menuDrawer open:.15];
    [inPlayDrawer close:.15];
    [gameLevel syncAchievements];
    [self updateObjectAvailability];
    
    accel2xSprite.visible = NO;
    accel2xLabel.visible = NO;
    accelHalfXSprite.visible = NO;
    accelHalfXLabel.visible = NO;
    antiGravitySprite.visible = NO;
    antiGravityLabel.visible = NO;
    
    for (ActiveFieldObject* afo in gameLevel.gameConfig.activeFieldObjects)
    {
        afo.sprite.zOrder = AFO_CONFIG_Z;
    }
}


- (void) enterSimulationState
{
    isPaused = NO;
    [self removeRecapScreen];
    
    offScreenPointer.visible = NO;
    
    [gameLevel.gameData clearEventLog];
    
    isSimulating = YES;
    
    if (gameLevel.launchPad == nil)
        isLaunching = NO;
    
    characterSprite.displayFrame = gameLevel.gameConfig.selectedCharacter.normalSprite;
    
    [menuDrawer runAction:[CCMoveTo actionWithDuration:0.15 position:ccp(0,-menuDrawer.contentSize.height-10)]];
    [inPlayDrawer open:0.10];
    [objectDrawer close:0];
    [characterDrawer close:0];
    
    CGPoint offScreen = ccpAdd(objectDrawer.closedPosition, ccp(DrawerOffset+1,0));
    [objectDrawer runAction:[CCMoveTo actionWithDuration:0.15 position:offScreen]];
    
    offScreen = ccpSub(characterDrawer.closedPosition, ccp(DrawerOffset+1,0));
    [characterDrawer runAction:[CCMoveTo actionWithDuration:0.15 position:offScreen]];
        
    [self resetField];
    
    score = 0;
    gems = 0;
    extraScore = 0;
    distance = 0;
    
    for (ActiveFieldObject* afo in gameLevel.gameConfig.activeFieldObjects)
    {
        afo.sprite.zOrder = AFO_SIM_Z;
    }
    
    for (ProjectileSource* ps in gameLevel.projectileSources)
    {
        [ps start];
    }
    
    //dumpSpace(space.space);
    
    mainScoreValue.visible = YES;
    mainGemsValue.visible = YES;
    
    [self updateScores];
    [self scheduleUpdate];
    
}


- (void) finishSimulationState
{
    [self finishSimulationState:YES];
}


- (void) finishSimulationState:(bool)showRecap
{
    isSimulating = NO;
    [self unscheduleUpdate];

    offScreenPointer.visible = NO;
    
    for (ProjectileSource* ps in gameLevel.projectileSources)
        [ps stop];


    if (showRecap == NO)
    {
        [self enterConfigurationState];
        return;
    }
    
    gameLevel.gameData.score = score;
    
    // Figure out balloon Stars
    gameLevel.gameData.gems = gems;
    gameLevel.gameData.gemStars = 0;
    int visibleGems = 0;
    for (GemDefinition* gem in gameLevel.gems)
    {
        if (gem.position.x >= 0 && gem.position.x <= gameLevel.gameSize.width
            && gem.position.y >= 0 && gem.position.y <= gameLevel.gameSize.height)
        {
            visibleGems++;
        }
    }
    
    double gemsPct = gems / (double)visibleGems;
    
    if (visibleGems < 20)
    {
        if (gemsPct > 0) gameLevel.gameData.gemStars = 1;
        if (gemsPct >= .30) gameLevel.gameData.gemStars = 2;
        if (gemsPct >= .50) gameLevel.gameData.gemStars = 3;
        if (gemsPct >= .70) gameLevel.gameData.gemStars = 4;
        if (gemsPct >= .90) gameLevel.gameData.gemStars = 5;
    }
    else if (visibleGems < 35)
    {
        if (gemsPct > 0) gameLevel.gameData.gemStars = 1;
        if (gemsPct >= .15) gameLevel.gameData.gemStars = 2;
        if (gemsPct >= .30) gameLevel.gameData.gemStars = 3;
        if (gemsPct >= .45) gameLevel.gameData.gemStars = 4;
        if (gemsPct >= .60) gameLevel.gameData.gemStars = 5;
    }
    else
    {
        if (gemsPct > 0) gameLevel.gameData.gemStars = 1;
        if (gemsPct >= .10) gameLevel.gameData.gemStars = 2;
        if (gemsPct >= .22) gameLevel.gameData.gemStars = 3;
        if (gemsPct >= .35) gameLevel.gameData.gemStars = 4;
        if (gemsPct >= .50) gameLevel.gameData.gemStars = 5;
    }

    // Figure out distance Stars
    gameLevel.gameData.distance = distance;
    gameLevel.gameData.distanceStars = 0;
    double distanceFactor = distance / MAX(gameLevel.gameSize.width, gameLevel.gameSize.height);
    
    
    if (distanceFactor > 0) gameLevel.gameData.distanceStars = 1;
    if (distanceFactor >= 1.5) gameLevel.gameData.distanceStars = 2;
    if (distanceFactor >= 2.0) gameLevel.gameData.distanceStars = 3;
    if (distanceFactor >= 4.0) gameLevel.gameData.distanceStars = 4;
    if (distanceFactor >= 6.0) gameLevel.gameData.distanceStars = 5;
    
    
    unsigned int combinedStars = gameLevel.gameData.gemStars + gameLevel.gameData.distanceStars;
    if (combinedStars > 0) gameLevel.gameData.overallStars = 1;
    if (combinedStars >= 3) gameLevel.gameData.overallStars = 2;
    if (combinedStars >= 5) gameLevel.gameData.overallStars = 3;
    if (combinedStars >= 7) gameLevel.gameData.overallStars = 4;
    if (combinedStars >= 9) gameLevel.gameData.overallStars = 5;
    
    
    
    gameLevel.gameData.isNewHighScore = NO;
    if (isOnTarget)
    {
        characterSprite.displayFrame = gameLevel.gameConfig.selectedCharacter.happySprite;
    
        if (gameLevel.gameData.score > gameLevel.gameData.highScore && gameLevel.gameData.highScore > 0)
            gameLevel.gameData.isNewHighScore = YES;
        
        gameLevel.gameData.highScore = MAX(score, gameLevel.gameData.highScore);
        gameLevel.gameData.highGems = MAX(gems, gameLevel.gameData.highGems);
        gameLevel.gameData.highGemStars = MIN(5, MAX(gameLevel.gameData.gemStars, gameLevel.gameData.highGemStars));
        gameLevel.gameData.highDistance = MAX(distance, gameLevel.gameData.highDistance);
        gameLevel.gameData.lowDistance = gameLevel.gameData.lowDistance== 0 ? distance : MIN(distance, gameLevel.gameData.lowDistance);
        gameLevel.gameData.highStars = MIN(5, MAX(gameLevel.gameData.overallStars, gameLevel.gameData.highStars));
    }
    else
    {
        characterSprite.displayFrame =  gameLevel.gameConfig.selectedCharacter.sadSprite;
    }
    
    [gameLevel saveData];

    
    accel2xSprite.visible = NO;
    accel2xLabel.visible = NO;
    accelHalfXSprite.visible = NO;
    accelHalfXLabel.visible = NO;
    antiGravitySprite.visible = NO;
    antiGravityLabel.visible = NO;


    
    [self enterRecapState];
}


- (void) enterRecapState
{
    if (isOnTarget)
        [[GameCenter sharedInstance] reportScore:gameLevel.gameData.score forLeaderBoardID:gameLevel.ID];
    
    [self showRecapScreen];
    [inPlayDrawer close:.35];
}


- (void) updateScores
{
    mainScoreValue.string = [NSString stringWithFormat:@"%d", score];
    mainGemsValue.string = [NSString stringWithFormat:@"%d", gems];
}



- (void) visit
{
    [super visit];
    if (!isSimulating)
        [self visit_Configuration];
    
    CGFloat dt = [[CCDirector sharedDirector] animationInterval];
    
    for (ActiveFieldObject* afo in gameLevel.staticFieldObjects)
    {
        if (afo.animations)
        {
            for (Animation* anim in afo.animations)
            {
                [anim frame:dt];
            }
        }
    }
    
}




- (void) visit_Configuration
{
    // Handle auto-scroll of gameLayer when dragged item hits the edge
    if (currentDraggedItem != nil && (lastAdjustment.x != 0 || lastAdjustment.y != 0))
    {
        CGPoint newAdjustment = ccp(0,0);
        
        if (lastAdjustment.x != 0)
            newAdjustment.x = 5 * (lastAdjustment.x < 0 ? -1 : 1);
        
        if (lastAdjustment.y != 0)
            newAdjustment.y = 5 * (lastAdjustment.y < 0 ? -1 : 1);
        
        currentDraggedItem.position = ccpAdd(currentDraggedItem.position, newAdjustment);
        lastAdjustment = [((ScrollView*)gameLayer.parent) keepNodeOnScreen:currentDraggedItem];
    }
    else
    {
        currentDraggedItem = nil;
    }
    
}


-(void) update:(ccTime) delta
{
    if (isSimulating)
        [self update_SimulationMode:delta];
}


-(void) update_SimulationMode:(ccTime) delta
{
    if (isPaused)
        return;
    
	CGFloat dt = [[CCDirector sharedDirector] animationInterval];
    
    CharacterDefinition* characterDef = gameLevel.gameConfig.selectedCharacter;

    for (CurrentForce* force in currentForces)
         [force applyForce];
    
    for (ProjectileSource* ps in gameLevel.projectileSources)
         [ps clockTick:dt space:space playingField:gameLayer];

    [self accelerationTimers:dt];
    
    cpVect lastPos = character.body.pos;
    
    // This is the secret sauce, right here, folks!
    int count = 3;
    for (int i=0; i < count; i++)
        [space step:dt/count];
    // End of secret sauce
    
    cpVect currentPos = character.body.pos;
    cpVect d = cpvsub(currentPos, lastPos);
    
    CGSize screen = self.contentSize; //[[CCDirector sharedDirector] winSize];
    
    if (!isLaunching){
        distance += (unsigned int)(sqrt(d.x*d.x + d.y*d.y)); // * (1024 / screen.width));
        score = distance + extraScore;
    }
    
    if (isTrackingPlayer)
        [scrollView keepNodeOnScreen:characterSprite withMargin:CGSizeMake(screen.width/2, screen.height/2) positionBased:YES];

    if (character.body.pos.x < SCRNX(-100) || character.body.pos.x > gameLevel.gameSize.width+SCRNX(100) || character.body.pos.y < SCRNY(-100))
    {
        [self finishSimulationState];
        return;
    }
    

    // Facial Expressions
    // Check for cringe situation

    BOOL hasNearby = NO;
    
    if (fabs(cpvlength(character.body.vel)) >= characterDef.cringeVelocity && !isLaunching)
    {
        // Find the point that is cringeDistance away in the direction of the character's velocity
        cpVect ch = characterSprite.body.pos;
        cpVect ray = cpvadd(ch,cpvclamp(characterSprite.body.vel, characterDef.cringeDistance));
        
        NSArray* nearestPoints = [space segmentQueryAllFrom:ch to:ray layers:CP_ALL_LAYERS group:CP_NO_GROUP];
        
        for (ChipmunkSegmentQueryInfo* nearby in nearestPoints)
        {
            if (nearby.shape.collisionType != CT_Character && !nearby.shape.sensor)
            {
                hasNearby = YES;
                break;
            }
        }
        
    }
    
    if (fabs(character.body.angVel) > 5 && characterSprite.displayFrame != gameLevel.gameConfig.selectedCharacter.whoaSprite)
        characterSprite.displayFrame = gameLevel.gameConfig.selectedCharacter.whoaSprite;
    
    else if (hasNearby)
        characterSprite.displayFrame = characterDef.cringeSprite;
    
    else if (character.body.vel.y < -400.0)
        characterSprite.displayFrame = characterDef.downwardSprite;
    
    else if (character.body.vel.y > 700.0)
        characterSprite.displayFrame = characterDef.upwardSprite;
    
    else if (characterSprite.displayFrame != characterDef.normalSprite)
        characterSprite.displayFrame = characterDef.normalSprite;
    
    
    static float sleepTimer = 0;
    static CGPoint sleepCheckPos = {0,0};

    if ((fabs(currentPos.x - sleepCheckPos.x) < ALMOST_ZERO)
        && (fabs(currentPos.y - sleepCheckPos.y) < ALMOST_ZERO))
    {
        sleepTimer += dt;
    }
    else
    {
        sleepTimer = 0;
    }
    
    if (sleepTimer >= space.sleepTimeThreshold && !isLaunching)
    {
        [self finishSimulationState];
    }
    
    sleepCheckPos = currentPos;
    
    [self updateScores];
    
    soundEffectTimer--;
    if (soundEffectTimer <= 0)
        lastSoundEffectBody = nil;
    
    if (characterSprite.boundingBox.origin.y > gameLevel.gameSize.height)
    {
        if (offScreenPointer.visible == NO)
            offScreenPointer.visible = YES;
        
        offScreenPointer.position = ccp(character.body.pos.x, offScreenPointer.position.y);
        offScreenPointer.scale = MIN(1.0, MAX(0.1,(character.body.pos.y - gameLevel.gameSize.height) / gameLevel.gameSize.height));
    }
    else if (offScreenPointer.visible == YES)
    {
        offScreenPointer.visible = NO;
    }
    
    // Give the game level a chance to do something periodically
    [gameLevel gameFrame:delta space:space gameLayer:gameLayer];
    
}



- (void) accelerationTimers:(ccTime)dt
{
    int newTime;
    static int last2X = 0;
    static int lastHalf = 0;
    static int lastAnti = 0;
    
    
    if (accel2xTimer > 0)
    {
        accel2xTimer -= dt;
        if (accel2xSprite.visible == NO)
        {
            accel2xSprite.visible = YES;
            accel2xLabel.visible = YES;
            //[accel2xSprite runAction:[CCFadeIn actionWithDuration:0.15]];
            //[accel2xLabel runAction:[CCFadeIn actionWithDuration:0.15]];
        }
        newTime = (int)accel2xTimer;
        if (newTime != last2X)
        {
            accel2xLabel.string = [NSString stringWithFormat:@"%d",newTime+1];
        }
        last2X = newTime;
    }
    else
    {
        if (accel2xSprite.visible == YES)
        {
            accel2xSprite.visible = NO;
            accel2xLabel.visible = NO;
            //[accel2xSprite runAction:[CCFadeOut actionWithDuration:0.15]];
            //[accel2xLabel runAction:[CCFadeOut actionWithDuration:0.15]];
        }
    }
    
    if (accelHalfXTimer > 0)
    {
        accelHalfXTimer -= dt;
        if (accelHalfXSprite.visible == NO)
        {
            accelHalfXSprite.visible = YES;
            accelHalfXLabel.visible = YES;
            //[accelHalfXSprite runAction:[CCFadeIn actionWithDuration:0.15]];
            //[accelHalfXLabel runAction:[CCFadeIn actionWithDuration:0.15]];
        }
        newTime = (int)accelHalfXTimer;
        if (newTime != lastHalf)
        {
            accelHalfXLabel.string = [NSString stringWithFormat:@"%d",newTime+1];
        }
        lastHalf = newTime;
    }
    else
    {
        if (accelHalfXSprite.visible == YES)
        {
            accelHalfXSprite.visible = NO;
            accelHalfXLabel.visible = NO;
            //[accelHalfXSprite runAction:[CCFadeOut actionWithDuration:0.15]];
            //[accelHalfXLabel runAction:[CCFadeOut actionWithDuration:0.15]];
        }
    }
    
    if (antiGravityTimer > 0)
    {
        antiGravityTimer -= dt;
        if (antiGravitySprite.visible == NO)
        {
            space.gravity = cpv(space.gravity.x, -space.gravity.y);
            antiGravitySprite.visible = YES;
            antiGravityLabel.visible = YES;
            //[antiGravitySprite runAction:[CCFadeIn actionWithDuration:0.15]];
            //[antiGravityLabel runAction:[CCFadeIn actionWithDuration:0.15]];
        }
        newTime = (int)antiGravityTimer;
        if (newTime != lastAnti)
        {
            antiGravityLabel.string = [NSString stringWithFormat:@"%d",newTime+1];
        }
        lastAnti = newTime;
    }
    else
    {
        if (antiGravitySprite.visible == YES)
        {
            space.gravity = cpv(space.gravity.x, -space.gravity.y);
            antiGravitySprite.visible = NO;
            antiGravityLabel.visible = NO;
            //[antiGravitySprite runAction:[CCFadeOut actionWithDuration:0.15]];
            //[antiGravityLabel runAction:[CCFadeOut actionWithDuration:0.15]];
        }
    }
}


//***********************************************************************************
//**** FIELD MANAGEMENT AND UTILITIES ***********************************************
//***********************************************************************************


- (CGPoint) characterStartingPosition
{
    CGSize sz = gameLevel.gameConfig.selectedCharacter.normalSprite.originalSize;
    cpBB chBox;
    chBox.b = 0 - sz.height/2;
    chBox.l = 0 - sz.width/2;
    chBox.t = sz.height/2;
    chBox.r = sz.width/2;

    ActiveFieldObject* launcher = nil;
    for (ActiveFieldObject* afo in gameLevel.gameConfig.activeFieldObjects)
    {
        if (afo.definition.type == FieldObjectType_Launcher)
        {
            launcher = afo;
            break;
        }
    }
    
    if (launcher)
    {
        return launcher.position;
    }
    else
    {
        if (gameLevel.launchPad == nil)
        {
            return ccp(gameLevel.gameSize.width/3, gameLevel.gameSize.height/3);
        }
        else
        {
            if (gameLevel.launchForce.x < 0)
                return ccp(gameLevel.launchPad.bb.r - chBox.r - 10,
                           gameLevel.launchPad.bb.t + chBox.t);
            else
                return ccp(gameLevel.launchPad.bb.l + chBox.r + 10,
                           gameLevel.launchPad.bb.t + chBox.t);
        }
    }
}


- (void) resetField
{
    for (ActiveFieldObject* obj in gameLevel.gameConfig.activeFieldObjects)
    {
        obj.sprite.displayFrame = obj.definition.gameSprite;
    }
    activeItem = nil;
    
    for (ProjectileSource* ps in gameLevel.projectileSources)
    {
        [ps reset:space field:gameLayer];
    }
    
    // clear all current forces
    [currentForces removeAllObjects];
    
    // Set character position back to launchPad
    characterSprite.position = [self characterStartingPosition];
    characterSprite.rotation = 0;
    characterSprite.displayFrame = gameLevel.gameConfig.selectedCharacter.normalSprite;
    
    for (GemDefinition* gem in gameLevel.gems)
    {
        if (gem.isActive == NO)
        {
            //gem.shape.body.pos = cpv(gem.position.x, gem.position.y);
            //[space addStaticShape:gem.shape];
            CCSprite* gemSprite = [CCSprite spriteWithSpriteFrameName:gem.spriteName];
            gemSprite.anchorPoint = ccp(0.5,0.5);
            gemSprite.position = gem.shape.body.pos;
            gem.sprite = gemSprite;
            [gameLayer addChild:gemSprite z:501];
            
            if (gemSprite.position.x >= 0 && gemSprite.position.x <= gameLevel.gameSize.width
                && gemSprite.position.y >= 0 && gemSprite.position.y <= gameLevel.gameSize.height)
            {
                CCSequence* jiggle = [CCSequence actionWithArray:@[
                                                                  [CCRotateTo actionWithDuration:0.3 angle:-(1+rand()%5)],
                                                                  [CCRotateTo actionWithDuration:0.4 angle:1+rand()%5],
                                      [CCDelayTime actionWithDuration:(rand()%10)/100.0]
                                                                  ]];
                [gemSprite runAction:[CCRepeatForever actionWithAction:jiggle]];
            }
            
            gem.isActive = YES;
        }
    }
    
    characterSprite.body.vel = cpvzero;
    characterSprite.body.angle = 0;
    characterSprite.body.angVel = 0;
    [characterSprite.body resetForces];
    /* this is the ugly part */
    characterSprite.body.body->v_bias_private = cpvzero;
    characterSprite.body.body->w_bias_private = 0;
    [space reindexShapesForBody:characterSprite.body];
    
    for (ChipmunkBody* body in space.bodies)
    {
        body.vel = cpvzero;
        body.angVel = 0;
        [body resetForces];
        body.body->v_bias_private = cpvzero;
        body.body->w_bias_private = 0;
        [space reindexShapesForBody:body];
        for (ChipmunkShape* shape in body.shapes)
        {
            shape.surfaceVel = cpvzero;
        }
    }
    space.space->curr_dt_private = 0;
    space.space->stamp_private = 0;
    
    [disabledWalls removeAllObjects];
    for (Sensor* sensor in gameLevel.sensors)
    {
        if (sensor.type == TogglePhysics_Sensor)
        {
            if (sensor.indicatorName != nil)
            {
                CCSprite* indicator = [gameLevel getNamedSprite:sensor.indicatorName];
                indicator.opacity = 0;
            }
        }
    }
    
    [gameLevel resetLevel:space gameLayer:gameLayer];
    launcherDone = NO;

    
    [scrollView keepNodeOnScreen:characterSprite withMargin:CGSizeMake(SCRNX(300),SCRNY(200))];
    
    lastSoundEffectBody = 0;
    cpResetShapeIdCounter();
    
    accel2xTimer = 0;
    accel2xSprite.visible = NO;
    accelHalfXTimer = 0;
    accelHalfXSprite.visible = NO;
    antiGravityTimer = 0;
    antiGravitySprite.visible = NO;
    if (space.gravity.y > 0)
        space.gravity = cpv(space.gravity.x, -space.gravity.y);
    
    [space reindexStatic];
    
#if 0
    // Dump the body
    cpBody* body = characterSprite.body.body;
    NSLog(@"Body");
    NSLog(@"  velocity_func   = %p", body->velocity_func);
    NSLog(@"  position_func   = %p", body->position_func);
    NSLog(@"  mass(m)         = %f", body->m);
    NSLog(@"  inv mass        = %f", body->m_inv);
    NSLog(@"  moment(i)       = %f", body->i);
    NSLog(@"  inv moment      = %f", body->i_inv);
    NSLog(@"  position        = %f,%f", body->p.x, body->p.y);
    NSLog(@"  velocity        = %f,%f", body->v.x, body->v.y);
    NSLog(@"  force           = %f,%f", body->f.x, body->f.y);
    NSLog(@"  rotation(a)     = %f", body->a);
    NSLog(@"  rotation vel(w) = %f", body->w);
    NSLog(@"  torque(t)       = %f", body->t);
    NSLog(@"  rotation(cache) = %f,%f", body->rot.x, body->rot.y);
    NSLog(@"  data            = %p", body->data);
    NSLog(@"  vel limit       = %f", body->v_limit);
    NSLog(@"  rot limit       = %f", body->w_limit);
    NSLog(@"  v bias          = %f,%f", body->v_bias_private.x, body->v_bias_private.y);
    NSLog(@"  w bias          = %f", body->w_bias_private);
#endif
    
}





- (ActiveFieldObject*) getActiveObjectFromNode:(CCNode*) node
{
    for (ActiveFieldObject* obj in gameLevel.gameConfig.activeFieldObjects)
    {
        if (obj.sprite == node)
            return obj;
    }
    return nil;
}

- (AvailableFieldObject*) getAvailableObjectFromNode:(CCNode*) node
{
    for (AvailableFieldObject* obj in gameLevel.availableFieldObjects)
    {
        if (obj.menuItem == node)
            return obj;
    }
    return nil;
}


- (ActiveFieldObject*) getActiveFieldObjectForBody:(ChipmunkBody*) body
{
    for(ActiveFieldObject* obj in gameLevel.gameConfig.activeFieldObjects)
    {
        if (body == obj.body)
            return obj;
    }
    return nil;
}

- (GemDefinition*) getGemForShape:(ChipmunkShape*)shape
{
    for (GemDefinition* gem in gameLevel.gems)
    {
        if (gem.shape == shape)
            return gem;
    }
    return nil;
}



- (void) addObjectToField:(ActiveFieldObject*) obj
{
    if (obj.definition == nil)
        return;
    
    if (obj.body == nil)
    {
        obj.body = [obj.definition createInSpace:space position:obj.position angle:obj.settings.rotation rogue:(obj.animations != nil)];
    }
    
    PhysicsSprite* newItem = [PhysicsSprite spriteWithSpriteFrame:obj.definition.gameSprite];
    [newItem setPhysicsBody:obj.body];
    newItem.anchorPoint = ccp(0.5, obj.definition.anchorPoint.y);
    newItem.position = obj.position;
    newItem.rotation = obj.settings.rotation;
    obj.sprite = newItem;
    
    [obj setAnimationBody:obj.body];
    
    newItem.isTouchEnabled = YES;
    [gameLayer addChild:newItem z:AFO_CONFIG_Z];
    
    [newItem addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UIPanGestureRecognizer alloc] init] target:self action:@selector(itemDraggedInField:item:)]];
    
    [newItem addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UILongPressGestureRecognizer alloc] init] target:self action:@selector(itemLongPressedInField:item:)]];
    
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] init];
    doubleTap.numberOfTapsRequired = 2;
    
    [newItem addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:doubleTap target:self action:@selector(itemDoubleTappedInField:item:)]];
    
}


- (void) clearAllObjects
{
    for (ActiveFieldObject* obj in gameLevel.gameConfig.activeFieldObjects)
    {
        for (ChipmunkShape* shape in obj.body.shapes)
            [space removeShape:shape];
        
        [gameLayer removeChild:obj.sprite cleanup:YES];
    }
    [gameLevel.gameConfig.activeFieldObjects removeAllObjects];
    [self updateObjectAvailability];
    [space reindexStatic];
    gameLevel.isChanged = YES;
}



- (void) toggleDrawer:(Drawer*) drawer;
{
    if (isSimulating)
        return;
    
    if (drawer.isOpen)
        [drawer close:0.15];
    else
        [drawer open:0.25];
}


- (void) addCurrentForce:(cpVect)vector body:(ChipmunkBody*)body offset:(cpVect)offset source:(id)source recalc:(void(^)(ChipmunkBody*,ChipmunkShape*,cpVect*,cpVect*))recalc
{
    CurrentForce* f = [CurrentForce forceFromSource:source body:body vector:vector offset:offset recalc:recalc];
    [currentForces addObject:f];
}


- (void) removeCurrentForceOn:(ChipmunkBody*)body source:(id) source
{
    NSMutableArray* forcesToRemove = [NSMutableArray arrayWithCapacity:currentForces.count];
    for (CurrentForce* force in currentForces)
    {
        if (force.body == body && force.source == source)
            [forcesToRemove addObject:force];
    }
    
    for (CurrentForce* force in forcesToRemove)
        [currentForces removeObject:force];
}






//***********************************************************************************
//**** EVENT HANDLERS                 ***********************************************
//***********************************************************************************


- (void) itemTappedInDrawer:(CCNode*) item
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CGPoint screenMid = ccp(screen.width/2, screen.height/2);
    if (isSmallScreen)
        screenMid = ccp(screen.width/2, screen.height * 0.65);
    
    // Make sure we haven't hit the max for this object
    AvailableFieldObject* availableObj = [self getAvailableObjectFromNode:item];
    if (availableObj == nil)
        return;
    
    int activeObjCount = 0;
    for (ActiveFieldObject* activeObj in gameLevel.gameConfig.activeFieldObjects)
    {
        if (activeObj.definition == availableObj.definition)
            activeObjCount++;
    }
    
    if (activeObjCount >= availableObj.count)
        return;
    
    AUDIOTIC1;
    ActiveFieldObject* obj = [[ActiveFieldObject alloc] init];
    obj.definition = availableObj.definition;
    obj.position = [gameLayer convertToNodeSpace:screenMid];
    obj.settings = [obj.definition getDefaultSettings];
    [gameLevel.gameConfig.activeFieldObjects addObject:obj];
    
    [self addObjectToField:obj];
    
    [self updateObjectAvailability];
    gameLevel.isChanged = YES;
    
    if ([Settings globalSettings].showRotateTutorial)
    {
        CGPoint pos = ccp((screen.width/2) + item.contentSize.width/2 + SCRNX(10), screen.height*0.53);
        TutorialDialog* tut = [[TutorialDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Rotate",
                                                                                        @"Tap and hold\nto rotate the\nobject")
                                                                   at:ccp(self.contentSize.width*0.83,
                                                                          self.contentSize.height*0.3)
                                                          anchorPoint:ccp(.5,.5)
                                                             scaledTo:nil
                                                              arrowTo:pos];
        [tut setCloseHandler:^(id sourceDlg){
            objectTutPos.y = characterTutPos.y;
            TutorialDialog* tut2 = [[TutorialDialog alloc] initWithMessage:NSLocalizedString(@"GameLayer_Tutorial_Delete",
                                                                                             @"Double tap\nto delete the\nobject")
                                                                        at:ccp(self.contentSize.width*0.83,
                                                                               self.contentSize.height*0.5)
                                                               anchorPoint:ccp(.5,.5)
                                                                  scaledTo:nil
                                                                   arrowTo:pos];
            [self addChild:tut2 z:9999999];
        }];
        
        [self addChild:tut z:9999999];
        [Settings globalSettings].showRotateTutorial = NO;
        [[Settings globalSettings] save];
    }
}


- (void) updateObjectAvailability
{
    for (AvailableFieldObject* availableObj in gameLevel.availableFieldObjects)
    {
        int count = 0;
        for (ActiveFieldObject* activeObj in gameLevel.gameConfig.activeFieldObjects)
        {
            if (activeObj.definition == availableObj.definition)
                count++;
        }
        
        availableObj.countLabel.string = [NSString stringWithFormat:@"%d", availableObj.count - count];
        
        if (count >= availableObj.count)
        {
            availableObj.menuItem.opacity = 100;
        }
        else
        {
            availableObj.menuItem.opacity = 255;
        }
    }
}


- (CCNode*) setDialogGlass:(id) anyData z:(long)z onTouch:(void (^)(id))block
{
    dialogGlassTouched = block;
    dialogGlassData = anyData;
    
    dialogGlass = [CCNode node];
    dialogGlass.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    dialogGlass.isTouchEnabled = YES;
    [dialogGlass addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(dialogGlassTouchHandler:item:)]];
    [self addChild:dialogGlass z:z];
    
    return dialogGlass;
}

- (void) clearDialogGlass
{
    if (dialogGlass == nil)
        return;
    [dialogGlass removeAllChildrenWithCleanup:YES];
    [self removeChild:dialogGlass cleanup:YES];
    dialogGlass = nil;
    dialogGlassData = nil;
    dialogGlassTouched = nil;
}

- (void) dialogGlassTouchHandler:(UIGestureRecognizer*)recognizer item:(CCNode*)item
{
    if (dialogGlassTouched != nil)
        dialogGlassTouched(dialogGlassData);
}


- (void) itemDraggedInField:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    if (isSimulating)
        return;
    
    ActiveFieldObject* obj = [self getActiveObjectFromNode:item];
    if (obj == nil)
        return;
    
    
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) recognizer;
    CGPoint motion = [pan translationInView:pan.view];
    motion.x /= gameLayer.scale;
    motion.y /= gameLayer.scale;
    item.position = ccp(item.position.x + motion.x, item.position.y - motion.y);
    [pan setTranslation:ccp(0,0) inView:pan.view];

    lastAdjustment = [((ScrollView*)gameLayer.parent) keepNodeOnScreen:item];
    currentDraggedItem = item;
    
    obj.position = item.position;
    [space reindexStatic];
    
    gameLevel.isChanged = YES;
}


- (void) itemLongPressedInField:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    if (isSimulating)
        return;
    
    if (recognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CCSprite* sprite;
        
    if (item == activeItem)
    {
        activeItem = nil;
        return;
    }
    
    sprite = (CCSprite*) item;
    //sprite.displayFrame = [self getActiveObjectFromNode:item].definition.designSprite;
    
    activeItem = item;
    
    // Show the ObjectDial
    if (activeItem != nil)
    {
        ActiveFieldObject* afo = [self getActiveObjectFromNode:item];
        if (afo)
        {
            SettingsDialog* dialog = [afo.definition getSettingsDialog];
            if (dialog == nil)
                return;
            AUDIOTIC1;
            dialog.settings = afo.settings;
            dialog.activeSprite = sprite;
            [dialog setCloseHandler:^(id sourceDlg){
                SettingsDialog* dlg = (SettingsDialog*)sourceDlg;
                if (dlg.settings.isChanged)
                {
                    [afo applySettings:dlg.settings];
                    gameLevel.isChanged = YES;
                }
                activeItem = nil;
            }];
            [self addChild:dialog z:9999999];
        }
    }
    
}



- (void) itemDoubleTappedInField:(UIGestureRecognizer*) recognizer item:(CCNode*) item
{
    if (isSimulating)
        return;
    
    if (recognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    if (activeItem == item)
        activeItem = nil;
    
    AUDIOTIC2;
    [gameLayer removeChild:item cleanup:YES];
    
    ActiveFieldObject* obj = [self getActiveObjectFromNode:item];
    if (obj != nil)
    {
        if (obj.body != nil)
        {
            for (ChipmunkShape* shape in obj.body.shapes)
                [space removeStaticShape:shape];

            if (! obj.body.isRogue)
                [space removeBody:obj.body];
        }
        [gameLevel.gameConfig.activeFieldObjects removeObject:obj];
        [self updateObjectAvailability];
    }
    
    [space reindexStatic];
    
    gameLevel.isChanged = YES;
    
}



- (cpVect) calculatePitchAndGain:(cpArbiter*) arbiter
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A,&B);
    ChipmunkShape* shapeA = A->data;
    ChipmunkShape* shapeB = B->data;
    
    if (cpArbiterGetCount(arbiter) == 0)
    {
        // Not sure why we have a collision with no points, but the call to GetPoint below
        // crashes if it's 0.
        return cpv(0,0);
    }
    
    // Get the distance from the collision point to the center of the object.
    cpVect point = cpArbiterGetPoint(arbiter, 0);
    cpVect d = cpvsub(point, shapeB.body.pos);
    float dist = sqrtf( (d.x*d.x) + (d.y*d.y) );  //More pythagorean theorem
    
    // Get the size of the object being hit (distance between b,l and t,r)
    d = cpvsub(cpv(shapeB.bb.l, shapeB.bb.b), cpv(shapeB.bb.r, shapeB.bb.t));
    float objWidth = sqrtf( (d.x*d.x) + (d.y*d.y) );
    
    float pitchAdj = 0.1 * (dist/objWidth);
    float velocityA = sqrtf( (shapeA.body.vel.x * shapeA.body.vel.x) + (shapeA.body.vel.y * shapeA.body.vel.y) );  // faster = louder
    float velocityB = sqrtf( (shapeB.body.vel.x * shapeB.body.vel.x) + (shapeB.body.vel.y * shapeB.body.vel.y) );
    
    float mass = (shapeA.body.mass == INFINITY ? 1.0 : shapeA.body.mass) + (shapeB.body.mass == INFINITY ? 1.0 : shapeB.body.mass);
    float force = mass * (velocityA + velocityB);
    
    float gainAdj = 500.0 / force;  // This constant is derived by trial and error.
    
    return cpv(pitchAdj, gainAdj); // cheesy return struct, but it's my game, I can do it if I want to.
}




- (void) playCollisionSound:(NSString*)soundFile pitch:(float)pitch pan:(float)pan gain:(float)gain body:(cpBody*)body
{
    if (pitch < 0)
        return;
    
    if (gain < 0)
        gain = 0.001;
    [[SimpleAudioEngine sharedEngine] playEffect:soundFile pitch:pitch pan:pan gain:gain];

}


- (void) fieldPinched:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*) recognizer;
    
    static float lastScale = 0;
    float diff;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        lastScale = 1.0;
    }
    
    diff = pinch.scale - lastScale;
    lastScale = pinch.scale;
    

    // Only scale down to the first edge -- don't let any non-field area be displayed.
    float newScale = gameLayer.scale + diff;
    if (gameLayer.contentSize.width * newScale <= scrollView.contentSize.width
        || gameLayer.contentSize.height * newScale <= scrollView.contentSize.height)
        return;

    CGPoint focus = [self convertToNodeSpace:[pinch locationInView:[[CCDirector sharedDirector]view]]];
    focus.y = scrollView.contentSize.height - focus.y; // Flip the Y
    [scrollView scaleContent:MIN(isSmallScreen ? 2.5 : 1.0, gameLayer.scale + diff)
                  focalPoint:focus]; // can't be greater than 1.0 or 2.5 (if small screen)
}


- (bool) chLaunchBegin:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* shapeA;
    cpShape* shapeB;
    cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    if (shapeA->body->p.y < shapeB->bb.b)  // For static bodies, the shape has a "position".  The body is "theoretical".
        return NO;

    if (shapeB->sensor)
    {
        isLaunching = YES;
        [self addCurrentForce:cpv(SCALE(gameLevel.launchForce.x), SCALE(gameLevel.launchForce.y))
                         body:character.body offset:cpvzero source:@"launchpad" recalc:nil];
    }
    
    return YES;
}


- (void) chLaunchEnd:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    isLaunching = NO;
    [self removeCurrentForceOn:character.body source:@"launchpad"];
}


- (bool) chNoBottomCollisionHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* shapeA;
    cpShape* shapeB;
    cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    if (shapeA->body->p.y < shapeB->bb.b)  // For static bodies, the shape has a "position".  The body is "theoretical".
        return NO;

    return YES;
}


- (bool) chTargetHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    [gameLevel.gameData addEvent:TargetTouched data:nil];
    isOnTarget = YES;
    return YES;
}

- (void) chTargetLeft:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    isOnTarget = NO;
    [gameLevel.gameData addEvent:TargetLeft data:nil];
}







- (bool) chBlowerHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* shapeA;
    cpShape* shapeB;
    cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    ChipmunkShape* shA = shapeA->data;

    __unsafe_unretained typeof(self) weakSelf = self;
    [self addCurrentForce:cpv(0,0) body:shA.body offset:cpvzero source:shapeB->data recalc:^(ChipmunkBody* characterBody, ChipmunkShape* sensor, cpVect* vect, cpVect* offset)
    {
        *offset = cpvzero;
        *vect = cpvzero;

        ChipmunkSegmentShape* shape = (ChipmunkSegmentShape*)sensor;
        cpSegmentShape* pShape = (cpSegmentShape*)shape.shape;
        // Find where the blower sensor intersects the character and use that as the offset.
        cpVect A = pShape->ta;
        cpVect B = pShape->tb;
        
        NSArray* nearestPoints = [weakSelf->space segmentQueryAllFrom:A
                                                                   to:B
                                                               layers:CP_ALL_LAYERS
                                                                group:CP_NO_GROUP];
        
        if (nearestPoints.count == 0)
            return;
        

        // Find the closest point along the segment.
        ChipmunkSegmentQueryInfo* nearestPoint = nil;
        for (ChipmunkSegmentQueryInfo* pt in nearestPoints)
        {
            if (pt.shape.body.body == characterBody.body)
            {
                if (nearestPoint == nil || pt.dist < nearestPoint.dist)
                    nearestPoint = pt;
            }
        }
        
        if (nearestPoint == nil)
            return;

        
        AirBlowerFieldObject* blower = (AirBlowerFieldObject*) [weakSelf getActiveFieldObjectForBody:sensor.body].definition;
        
        float x = sinf(sensor.body.angle);
        float y = cosf(sensor.body.angle);
        
        //cpVect d = cpvsub(nearestPoint.point, A);
        //float dist = sqrtf( (d.x*d.x) + (d.y*d.y) );  // Pythagorus ROCKS!
        
        float distanceFactor = nearestPoint.dist / blower.sensorLength;
        if (distanceFactor > 1.0)
            distanceFactor = 1;
        
        float force = (blower.blowerForce - (blower.blowerForce * distanceFactor));
        *vect = cpv(x * -force, y * force);
        *offset = cpvsub(nearestPoint.point, characterBody.pos);
    }];

    return YES;
}



- (void) chBlowerLeft:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A,&B);
    [self removeCurrentForceOn:((ChipmunkShape*)A->data).body source:B->data];
}
                                                                                                                                 



//- (bool) chTrampolineHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
//{
//    cpBody* A;
//    cpBody* B;
//    cpArbiterGetBodies(arbiter, &A,&B);
//    ChipmunkBody* bodyA = A->data;
//    ChipmunkBody* bodyB = B->data;
//    TrampolineFieldObject* tramp = (TrampolineFieldObject*) [self getActiveFieldObjectForBody:bodyB].definition;
//    
//    float x = sinf(bodyB.angle);
//    float y = cosf(bodyB.angle);
//
//    cpVect v = cpv(SCRNX(-x * tramp.trampolineForce),SCRNY(y * tramp.trampolineForce));
//    [bodyA applyImpulse:v offset:cpvzero];
//    
//    if (cpArbiterIsFirstContact(arbiter))
//    {
//        cpVect adj = [self calculatePitchAndGain:arbiter];
//        [self playCollisionSound:@"DrumDonk.mp3" pitch:.4 + adj.x pan:0 gain:.05 + adj.y body:B];
//    }
//
//    return YES;
//}

- (bool) chTrampolineLeft:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpBody* A;
    cpBody* B;
    cpArbiterGetBodies(arbiter, &A,&B);
    ChipmunkBody* bodyA = A->data;
    ChipmunkBody* bodyB = B->data;
    TrampolineFieldObject* tramp = (TrampolineFieldObject*) [self getActiveFieldObjectForBody:bodyB].definition;
    
    float x = sinf(bodyB.angle);
    float y = cosf(bodyB.angle);
    
    ACCELERATOR(accel);
    cpVect v = cpv(-x * tramp.trampolineForce,y * tramp.trampolineForce);
    [bodyA applyImpulse:cpvmult(v,accel) offset:cpvzero];
    
    [self playCollisionSound:@"DrumDonk.mp3" pitch:1 pan:0 gain:0.5 body:B];
    
    return YES;
}


- (bool) chGemHit:(cpArbiter*)arbiter space:(ChipmunkSpace*)aSpace
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A,&B);
    ChipmunkShape* shapeB = B->data;
    
    GemDefinition* gem = [self getGemForShape:shapeB];
    if (gem != nil && gem.isActive)
    {
        gems++;
        switch( gem.type )
        {
            case 0: extraScore += 1000; break;
            case 1: extraScore += 5000; break;
            case 2: extraScore += 25000; break;
            default: break;
        }
        
        gem.isActive = NO;
        
        CCAnimation* poofAnimation = [[CCAnimationCache sharedAnimationCache] animationByName:@"poof"];
        CCAnimate* poof = [CCAnimate actionWithAnimation:poofAnimation];
        poof.duration = 0.25;

        CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
            [gameLayer removeChild:gem.sprite cleanup:YES];
            gem.sprite = nil;
        }];
        
        [gem.sprite runAction:[CCSequence actions:poof, cleanup, nil]];
        
        NSString* pop = [popEffects objectAtIndex:rand()%2];
        [self playCollisionSound:pop pitch:1.2 pan:1.0 gain:1.0 body:B->body];
    }
    
    return NO;
}





- (bool) chSensorBegin:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A, &B);
    //ChipmunkShape* shapeA = A->data;
    ChipmunkSegmentShape* shapeB = B->data;
    
    Sensor* sensor = shapeB.data;
    if (sensor.type == ApplyForce_Sensor)
    {
        cpVect v = cpv(SCALE_FORCE(sensor.forceX), SCALE_FORCE(sensor.forceY));
        [self addCurrentForce:v body:character.body offset:cpvzero source:shapeB recalc:nil];
    }
    else if (sensor.type == TogglePhysics_Sensor)
    {
        if ([disabledWalls objectForKey:sensor.physicsName] == nil)     // Toggle is Active
        {
            [disabledWalls setObject:@"" forKey:sensor.physicsName];
            if (sensor.indicatorName != nil)
            {
                CCSprite* sprite = [gameLevel getNamedSprite:sensor.indicatorName];
                if (sprite)
                {
                    [sprite stopAllActions];
                    [sprite runAction:[CCFadeIn actionWithDuration:.15]];
                }
            }
        }
        else                                                            // Toggle is Inactive
        {
            [disabledWalls removeObjectForKey:sensor.physicsName];
            if (sensor.indicatorName != nil)
            {
                CCSprite* sprite = [gameLevel getNamedSprite:sensor.indicatorName];
                if (sprite)
                {
                    [sprite stopAllActions];
                    [sprite runAction:[CCFadeOut actionWithDuration:.15]];
                }
            }
        }
    }
    else if (sensor.type == ToggleSprite_Sensor)
    {
        if (sensor.spriteNames.count > 0)
        {
            ToggleType visible = Toggle_Undefined;
            
            if (shapeB.collisionType == CT_AreaSensor)
            {
                visible = sensor.inArea;
            }
            else
            {
                visible = Toggle_Toggle;
            }
            
            if (visible != Toggle_Undefined || shapeB.collisionType == CT_AreaSensor)
            {
            
                for (NSString* name in sensor.spriteNames)
                {
                    CCSprite* sprite = [gameLevel getNamedSprite:name];
                    int visCounter = [[toggledSprites objectForKey:name] integerValue];
                    
                    if (visible == Toggle_On || (visible == Toggle_Toggle && visCounter <= 0))
                    {
                        visCounter++;
                        if (visible == Toggle_Toggle)
                            visCounter = 1;
                        
                        if (sprite.opacity == 0 && visCounter >= 0)
                        {
                            [sprite stopAllActions];
                            [sprite runAction:[CCFadeIn actionWithDuration:.15]];
                        }
                    }
                    else if (visible == Toggle_Off || (visible == Toggle_Toggle && visCounter > 0))
                    {
                        visCounter--;
                        if (visible == Toggle_Toggle)
                            visCounter = 0;
                        
                        if (sprite.opacity == 255 && visCounter <= 0)
                        {
                            [sprite stopAllActions];
                            [sprite runAction:[CCFadeOut actionWithDuration:.15]];
                        }
                    }
                    
                    [toggledSprites setObject:@(visCounter) forKey:name];
                }
            }
        }
    }
    
    
    return YES;
}





- (void) chSensorEnd:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A, &B);
    ChipmunkShape* shapeA = A->data;
    ChipmunkShape* shapeB = B->data;
    Sensor* sensor = shapeB.data;

    if (sensor.type == ApplyForce_Sensor)
    {
        [self removeCurrentForceOn:shapeA.body source:shapeB];
    }
    
    else if (sensor.type == ToggleSprite_Sensor)
    {
        if (sensor.spriteNames.count > 0)
        {
            ToggleType visible = Toggle_Undefined;
            
            if (shapeB.collisionType == CT_AreaSensor)
            {
                visible = sensor.inArea == Toggle_On ? Toggle_Off : Toggle_On;
            }
            
            
            if (visible != Toggle_Undefined || shapeB.collisionType == CT_AreaSensor)
            {

                for (NSString* name in sensor.spriteNames)
                {
                    CCSprite* sprite = [gameLevel getNamedSprite:name];
                    int visCounter = [[toggledSprites objectForKey:name] integerValue];
                    
                    if (visible == Toggle_On)
                    {
                        visCounter++;
                        if (sprite.opacity == 0 && visCounter >= 0)  // Yes, test for equal to 0 in both cases.  0 = time to change it.
                        {
                            [sprite stopAllActions];
                            [sprite runAction:[CCFadeIn actionWithDuration:.15]];
                        }
                    }
                    else 
                    {
                        visCounter--;
                        if (sprite.opacity == 255 && visCounter <= 0)
                        {
                            [sprite stopAllActions];
                            [sprite runAction:[CCFadeOut actionWithDuration:.15]];
                        }
                    }
                    [toggledSprites setObject:@(visCounter) forKey:name];
                }
                    
            }
        }
    }
}


- (bool) chNamedWallHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
    cpShape* A;
    cpShape* B;
    cpArbiterGetShapes(arbiter, &A, &B);
    ChipmunkShape* shapeB = B->data;
    
    return ([disabledWalls objectForKey:(NSString*)shapeB.data] == nil);
}


//- (bool) chBouldersCollided:(cpArbiter*) arbiter space:(ChipmunkSpace*) aSpace
//{
//    cpShape* A;
//    cpShape* B;
//    cpArbiterGetShapes(arbiter, &A,&B);
//    
//    ChipmunkShape* shapeA = A->data;
//    ChipmunkShape* shapeB = B->data;
//    [space addPostStepRemoval:shapeA];
//    [space addPostStepRemoval:shapeB];
//    
//    CCSprite* ASprite = (CCSprite*)shapeA.body.data;
//    CCSprite* BSprite = (CCSprite*)shapeB.body.data;
//
//    CCAnimation* poofAnimation = [[CCAnimationCache sharedAnimationCache] animationByName:@"poof"];
//    CCAnimate* poof = [CCAnimate actionWithAnimation:poofAnimation];
//    poof.duration = 0.25;
//    
//    CCDelayTime* delay = [CCDelayTime actionWithDuration:0.25];
//    
//    CCCallBlock* cleanupA = [CCCallBlock actionWithBlock:^(void){
//        [gameLayer removeChild:ASprite cleanup:YES];
//    }];
//    
//    CCCallBlock* cleanupB = [CCCallBlock actionWithBlock:^(void){
//        [gameLayer removeChild:BSprite cleanup:YES];
//    }];
//    
//    [ASprite runAction:[CCSequence actions:delay, poof, cleanupA, nil]];
//    [BSprite runAction:[CCSequence actions:delay, poof, cleanupB, nil]];
//    
//    return YES;
//}


- (bool) chLauncherHit:(cpArbiter*) arbiter space:(ChipmunkSpace*) aSpace
{
    if (isLaunching || launcherDone)
        return NO;
    
    ActiveFieldObject* launcher = nil;
    for (ActiveFieldObject* afo in gameLevel.gameConfig.activeFieldObjects)
    {
        if (afo.definition.type == FieldObjectType_Launcher)
        {
            launcher = afo;
            break;
        }
    }
    
    if (launcher == nil) // Not sure why?
        return NO;
    
    characterSprite.body.vel = cpvzero;
    characterSprite.body.angVel = 0;
    
    double x = -sinf(launcher.body.angle);
    double y = cosf(launcher.body.angle);
    
    cpVect vector = cpv(x,y);
    double strength = (double)((LauncherObjectSettings*)launcher.settings).strength;
    
    cpVect impulse = cpvmult(vector, SCALE_FORCE(4000)*(strength/100.0)*(isSmallScreen ? 0.5 : 1));
    [characterSprite.body applyImpulse:impulse offset:cpvzero];
    isLaunching = YES;
    return YES;
}


- (void) chLauncherLeft:(cpArbiter*) arbiter space:(ChipmunkSpace*) aSpace
{
    isLaunching = NO;
    launcherDone = YES;
}





- (bool) chSlideHit:(cpArbiter*)arbiter space:(ChipmunkSpace*)aSpace
{
    if (cpArbiterIsFirstContact(arbiter) || cpArbiterGetCount(arbiter) == 1)
    {
        cpVect adj = [self calculatePitchAndGain:arbiter];
        cpBody *A, *B;
        cpArbiterGetBodies(arbiter, &A, &B);
        [self playCollisionSound:@"SlideClang.mp3" pitch:.4 + adj.x pan:0 gain:1 - adj.y body:B];
    }
    
    return YES;
}

- (bool) chBlowerBodyHit:(cpArbiter*)arbiter space:(ChipmunkSpace*)aSpace
{
    if (cpArbiterIsFirstContact(arbiter) || cpArbiterGetCount(arbiter) == 1)
    {
        cpVect adj = [self calculatePitchAndGain:arbiter];
        cpBody *A, *B;
        cpArbiterGetBodies(arbiter, &A, &B);
        [self playCollisionSound:@"SlideClang.mp3" pitch:.2 + adj.x pan:0 gain:.5 - adj.y body:B];
    }
    
    return YES;
}

- (bool) chPlankHit:(cpArbiter*)arbiter space:(ChipmunkSpace*)aSpace
{
    if (cpArbiterIsFirstContact(arbiter) || cpArbiterGetCount(arbiter) == 1)
    {
        cpVect adj = [self calculatePitchAndGain:arbiter];
        cpBody *A, *B;
        cpArbiterGetBodies(arbiter, &A, &B);
        [self playCollisionSound:@"WoodThud.mp3" pitch:.4 + adj.x pan:0 gain:1 - adj.y body:B];
    }
    
    return YES;
}


- (bool) chAcceleratorHit:(cpArbiter*)arbiter space:(ChipmunkSpace*)aSpace
{
    cpBody* A;
    cpBody* B;
    cpArbiterGetBodies(arbiter, &A,&B);
    ChipmunkBody* bodyB = B->data;
    FieldObjectDefinition* obj = [self getActiveFieldObjectForBody:bodyB].definition;
    
    FieldObjectType objType;
    
    if (obj != nil)
    {
        objType = obj.type;
    }
    else
    {
        Projectile* p = [gameLevel findProjectileForBody:bodyB];
        if (p == nil)
            return NO;
        objType = p.objType;
    }
    
    switch(objType)
    {
        case FieldObjectType_Accelerator2X:
            accel2xTimer += 5.0;
            break;
        case FieldObjectType_AcceleratorHalfX:
            accelHalfXTimer += 5.0;
            break;
        case FieldObjectType_AntiGravity:
            antiGravityTimer += 5.0;
            break;
        case FieldObjectType_Aligner:
            character.body.angVel = 0;
            characterSprite.body.body->v_bias_private = cpvzero;
            characterSprite.body.body->w_bias_private = 0;
            [characterSprite.body resetForces];
            [characterSprite runAction:[CCRotateTo actionWithDuration:0.15 angle:-CC_RADIANS_TO_DEGREES(bodyB.angle)]];
            break;
        default:
            break;
    }

    //TODO: Need some kind of "poof" sound effect.
    
    return NO;
}



@end

