//
//  GameLevel.h
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import <ObjectiveChipmunk.h>
#import <Foundation/Foundation.h>
#import <cocos2d.h>
#import "GameData.h"



@interface GameLevel : NSObject
{
    NSDictionary* _plist;
    int _ID;
    CGSize _gameSize;
    GameData* _gameData;
    NSMutableArray* _availableCharacters;
    NSMutableArray* _availableFieldObjects;
    NSMutableArray* _staticFieldObjects;
    NSMutableArray* _gems;
    NSMutableArray* _sensors;
    NSMutableDictionary* _namedSprites;
    ChipmunkShape* _launchPad;
    ChipmunkShape* _launchSensor;
    cpVect _launchForce;
    ChipmunkShape* _target;
    bool _debug;
    bool _isChanged;
}

@property int ID;
@property CGSize gameSize;
@property GameData* gameConfig;
@property GameData* gameData;

@property (readonly) NSMutableArray* availableFieldObjects;
@property (readonly) NSMutableArray* staticFieldObjects;
@property (readonly) NSMutableArray* availableCharacters;
@property (readonly) NSMutableArray* gems;
@property (readonly) NSMutableDictionary* namedSprites;
@property (readonly) NSMutableArray* sensors;
@property (readonly) NSMutableArray* projectileSources;

@property ChipmunkShape* launchPad;
@property ChipmunkShape* launchSensor;
@property cpVect launchForce;
@property ChipmunkShape* target;
@property bool isChanged;

@property bool debug;

- (id) initWithPlist:(NSDictionary*)plist;
- (ChipmunkSpace*) createSpace;

- (BOOL) hasTempFile;
- (id) load;
- (id) loadTempFile:(BOOL)deleteFile;
- (id) loadConfigFromFile:(NSString*)filename;
- (id) loadDataFromFile:(NSString*)filename;
- (void) saveConfig;
- (void) saveData;
- (void) saveTempFile;
- (void) saveConfigToFile:(NSString*)filename;
- (void) saveDataToFile:(NSString*)filename;


- (void) loadResources:(CCNode*)node;
- (void) unloadResources:(CCNode*)node;
- (void) addSceneryToNode:(CCNode*)node staticNode:(CCNode*)staticNode;
- (CCSprite*) loadImage:(NSString*)imageName;
- (CCSprite*) getNamedSprite: (NSString*)name;


- (void) gameFrame:(ccTime) dt space:(ChipmunkSpace*) space gameLayer:(CCNode*) gameLayer;
- (void) resetLevel:(ChipmunkSpace*) space gameLayer:(CCNode*) gameLayer;

- (void) syncAchievements;

- (Projectile*) findProjectileForBody:(ChipmunkBody*)body;

@end
