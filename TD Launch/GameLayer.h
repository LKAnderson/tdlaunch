//
//  ConfigurationLayer.h
//  TD Launch
//
//  Created by Kent Anderson on 8/25/12.
//
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "Drawer.h"
#import "ScrollView.h"
#import "Character.h"
#import "GameLevel.h"
#import "PhysicsSprite.h"
#import "EventManager.h"

@interface GameLayer : CCLayer <EventListener>
{
    ChipmunkSpace* space;
    ChipmunkShape* character;
    PhysicsSprite* characterSprite;

    CCLabelBMFont* mainScoreLabel;
    CCLabelAtlas* mainScoreValue;
    CCLabelBMFont* mainGemsLabel;
    CCLabelAtlas* mainGemsValue;
    
    CCNode* gameLayer;
    ScrollView* scrollView;
    
    CCNode* recapScreen;
    CCNode* awardPanel;
    
    Drawer* objectDrawer;
    ScrollView* objScrollView;
    Drawer* characterDrawer;
    Drawer* menuDrawer;
    Drawer* inPlayDrawer;
    
    CCSprite* offScreenPointer;
    
    CCSpriteFrame* pauseSpriteFrame;
    CCSpriteFrame* trackPlayerOnFrame;
    CCSpriteFrame* trackPlayerOffFrame;
    CCSpriteFrame* soundOnFrame;
    CCSpriteFrame* soundOffFrame;
    
    GameLevel* gameLevel;
    NSMutableArray* currentForces;
    NSMutableDictionary* disabledWalls;
    
    
    NSMutableDictionary* toggledSprites;
    
    bool isLaunching;
    bool launcherDone;
    bool isOnTarget;
    
    bool isSimulating;
    bool isPaused;
    
    CCSprite* accel2xSprite;
    CCLabelAtlas* accel2xLabel;
    
    CCSprite* accelHalfXSprite;
    CCLabelAtlas* accelHalfXLabel;
    
    CCSprite* antiGravitySprite;
    CCLabelAtlas* antiGravityLabel;
    
    NSArray* popEffects;
    cpBody* lastSoundEffectBody;
    int soundEffectTimer;
    
    CGPoint characterTutPos;
    CGPoint objectTutPos;
    CGPoint drawerTutPos;
    
    CCNode* dialogGlass;
    void(^dialogGlassTouched) (id);
    id dialogGlassData;
    CCLabelBMFont* gameCenterButton;
    CCLabelBMFont* nextLevelButton;
    
    CCNode* activeItem;
   
    CCNode* currentDraggedItem;
    CGPoint lastAdjustment;
    
    unsigned int score;
    unsigned int gems;
    unsigned int extraScore;
    unsigned int distance;
    
    BOOL isNewHighScore;
    BOOL isNewHighGems;
    BOOL isNewHighDistance;
    BOOL isNewLowDistance;
    
}


+(CCScene *) sceneWithLevel:(GameLevel*)level;

@end


@interface CurrentForce : NSObject
{
    void (^_recalc)(ChipmunkBody*, ChipmunkShape*, cpVect*, cpVect*);
}

@property __weak id source;
@property cpVect vector;
@property cpVect offset;
@property ChipmunkBody* body;

- (id) initWithRecalc:(void(^)(ChipmunkBody*,ChipmunkShape*,cpVect*,cpVect*))recalc;
+ (id) forceFromSource:(id)source body:(ChipmunkBody*)body vector:(cpVect)vector offset:(cpVect)offset;
+ (id) forceFromSource:(id)source body:(ChipmunkBody*)body vector:(cpVect)vector offset:(cpVect)offset recalc:(void(^)(ChipmunkBody*,ChipmunkShape*,cpVect*,cpVect*))recalc;
- (void) applyForce;
@end