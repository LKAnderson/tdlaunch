//
//  LevelMenu.m
//  TD Launch
//
//  Created by Kent Anderson on 8/22/12.
//
//

#import "LevelMenu.h"
#import "GameLayer.h"
#import "MainMenu.h"
#import "ScrollView.h"

#import "ColoredNode.h"
#import "RulerNode.h"
#import "SaneMenu.h"
#import "Screen.h"

#import "AppStore.h"

//#import "Level0.h"
#import "Level1.h"
#import "Level2.h"
#import "Level3.h"
#import "Level4.h"
#import "Level5.h"
#import "Level6.h"
#import "Level7.h"
#import "Level8.h"
#import "Level9.h"
#import "Level10.h"

#import "GestureRecognizerWithBlock.h"

#import "Settings.h"
#import "AppSettingsDialog.h"
#import "Achievements.h"
#import "GameCenter.h"

#import "AppDelegate.h"

#import <SimpleAudioEngine.h>


// This will stick around and remember which level we were on.
static int SelectedLevel = 1;



// This is defined here so others can call it if they want
GameLevel* getLevelForID(int ID)
{
    GameLevel* level = nil;
    
    switch(ID)
    {
        case 1: level = [[[GameLevel_1 alloc] init] load]; break;
        case 2: level = [[[GameLevel_2 alloc] init] load]; break;
        case 3: level = [[[GameLevel_3 alloc] init] load]; break;
        case 4: level = [[[GameLevel_4 alloc] init] load]; break;
        case 5: level = [[[GameLevel_5 alloc] init] load]; break;
        case 6: level = [[[GameLevel_6 alloc] init] load]; break;
        case 7: level = [[[GameLevel_7 alloc] init] load]; break;
        case 8: level = [[[GameLevel_8 alloc] init] load]; break;
        case 9: level = [[[GameLevel_9 alloc] init] load]; break;
        case 10: level = [[[GameLevel_10 alloc] init] load]; break;
    }
    
    return level;
}


@implementation LevelMenu

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	LevelMenu *layer = [LevelMenu node];
	[scene addChild: layer];
	return scene;
}




- (void) onEnter
{
    [super onEnter];
    self.isTouchEnabled = YES;
    
    APPCONTROLLER.adsEnabled = NO;

    
    // Try to unload as many graphics as we can.
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    //[[CCTextureCache sharedTextureCache] removeAllTextures];
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Menu.plist"] == nil)
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Menu.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelMenuItems.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tools.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Characters.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SmallCharacters.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ObstacleSheet.plist"];
    }
    
    CCSpriteBatchNode* menuSprites = [CCSpriteBatchNode batchNodeWithFile:@"Menu.png"];
    [self addChild:menuSprites];
    
    CCSpriteBatchNode* menuItemSprites = [CCSpriteBatchNode batchNodeWithFile:@"LevelMenuItems.png"];
    [self addChild:menuItemSprites];
    
    // These are not used in this scene, but they have to be loaded in order to load the game data files.
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Tools.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Characters.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"SmallCharacters.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"ObstacleSheet.png"]];


    [self loadLevelData];
    
    //self.isAccelerometerEnabled = YES;
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    self.contentSize = screen;
    
    background = [CCSprite spriteWithFile:@"LevelMenu.png"];
    background.anchorPoint = ccp(0.5,0.5);
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:background];
    
   

   
    NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray* stars = [NSMutableArray arrayWithCapacity:10];
    for (int i=1; i <= 10; i++)
    {
        NSString* fileName = [NSString stringWithFormat:@"Level%dButton.png", i];
        CCSprite* button = [CCSprite spriteWithSpriteFrameName:fileName];
        [buttons addObject:button];
        button.isTouchEnabled = YES;
        [button addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(buttonTouched:item:)]];
        
        GameData* gameData = nil;
        if (levelData.count >= i)
            gameData = [levelData objectAtIndex:i-1];
        fileName = [NSString stringWithFormat:@"Stars%d.png", gameData.highStars == 0 ? 1 : gameData.highStars];
        CCSprite* star = [CCSprite spriteWithSpriteFrameName:fileName];
        if (gameData.highStars == 0)
            star.visible = NO;
        [stars setObject:star atIndexedSubscript:i-1];
    }
    menuButtons = buttons;
    menuStars = stars;
    
    // Now position them
    CGSize buttonGap = isSmallScreen ? CGSizeMake(50, 30) : CGSizeMake( 50, 30 );
    CCSprite* button1 = [menuButtons objectAtIndex:0];
    
    buttonPanel = [CCNode node];
    buttonPanel.contentSize = CGSizeMake((button1.boundingBox.size.width * 4) + (buttonGap.width * 3)
                                         + (isSmallScreen ? button1.boundingBox.size.width * .5 : 0),
                                         (button1.boundingBox.size.height * 3) + (buttonGap.height * 2)
                                         + (isSmallScreen ? button1.boundingBox.size.height * .5 : 0));
    
    for (int i=1, x=0, y=0; i <= 10; i++, x += button1.contentSize.width + buttonGap.width)
    {
        if (i == 5 || i == 9)
        {
            x = 0;
            if (i == 9)
                x += button1.contentSize.width + buttonGap.width;
            y += button1.contentSize.height + buttonGap.height;
        }
        
        CCSprite* button = [menuButtons objectAtIndex:i-1];
        CCSprite* star = [menuStars objectAtIndex:i-1];
        if (isSmallScreen)
        {
            button.scale = 1.8;
            star.scale = 1.8;
        }
        button.anchorPoint = ccp( 0, 1 );
        button.position = ccp(x, buttonPanel.contentSize.height - y); // inverted coords
        [buttonPanel addChild:button];
        
        if (i > [Achievements sharedAchievements].level)
        {
            button.opacity = 128;
            star.visible = NO;
        }
        
        if (star.visible == YES)
        {
            star.anchorPoint = ccp( 0.5, 1 );
            star.position = ccp(button.boundingBox.origin.x + button.boundingBox.size.width/2,
                                button.boundingBox.origin.y + (isSmallScreen ? 18 : 3));
            //            star.position = ccp(button.position.x + button.contentSize.width/2, 3 + button.position.y - button.contentSize.height);
            [buttonPanel addChild:star];
        }

    }

    
//    touchFlash = [CCSprite spriteWithSpriteFrameName:@"TouchFlash.png"];
//    touchFlash.opacity = 0;
//    touchFlash.anchorPoint = ccp(0.5, 0.5);
//    touchFlash.position = ccp(0,0);
//    [buttonPanel addChild:touchFlash z:-99];
    
    loadingMsg = [CCLabelBMFont labelWithString:NSLocalizedString(@"LevelMenu_LoadingMsg", @"Loading...") fntFile:@"TDFont120.fnt"];
    TDFONT_MEDIUMLARGE(loadingMsg);
    loadingMsg.anchorPoint = ccp(0.5,0.5);
    loadingMsg.position = ccp(screen.width/2, isSmallScreen ? screen.height * .90 : screen.height * .20);
    loadingMsg.visible = NO;
    [self addChild:loadingMsg];
    
    buttonPanel.anchorPoint = ccp(0.5,1);
    buttonPanel.position = ccp(self.contentSize.width/2, self.contentSize.height*0.8);
    [self addChild:buttonPanel];
    
    
    
    self.isTouchEnabled = YES;
    //[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    
    if ([Settings globalSettings].sound == NO)
        [SimpleAudioEngine sharedEngine].mute = YES;
    else
        [SimpleAudioEngine sharedEngine].mute = NO;
    
    
    aboutScreen = nil;
    aboutIcon = [CCLabelBMFont labelWithString:NSLocalizedString(@"LevelMenu_AboutLabel", @"About") fntFile:@"TDFont120.fnt"];
    TDFONT_MEDIUM(aboutIcon);
    if (isSmallScreen)
        TDFONT_MEDIUMLARGE(aboutIcon);
    aboutIcon.anchorPoint = ccp(0,0);
    if (isSmallScreen)
        aboutIcon.position = ccp(screen.width*0.07, screen.height*0.075);
    else
        aboutIcon.position = ccp(screen.width*0.04, screen.height*0.05);
    aboutIcon.isTouchEnabled = YES;
    [self addChild:aboutIcon z:9999];
    [aboutIcon addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleAbout:item:)]];
    
    
    
    CCLabelBMFont* settingsButton = [CCLabelBMFont labelWithString:NSLocalizedString(@"LevelMenu_OptionsLabel", @"Options") fntFile:@"TDFont120.fnt"];
    TDFONT_MEDIUM(settingsButton);
    if (isSmallScreen)
        TDFONT_MEDIUMLARGE(settingsButton);
    settingsButton.anchorPoint = ccp(1,0);
    if (isSmallScreen)
        settingsButton.position = ccp(screen.width * 0.93, aboutIcon.position.y);
    else
        settingsButton.position = ccp(screen.width * 0.96, aboutIcon.position.y);
    settingsButton.isTouchEnabled = YES;
    [self addChild:settingsButton];
    [settingsButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                      {
                                          AUDIOTIC1;
                                          AppSettingsDialog* settings = [[AppSettingsDialog alloc] init];
                                          [self addChild:settings];
                                      }]];


    
    
    
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"BackMusic.m4a" loop:YES];
    
    gameCenterButton = [CCLabelBMFont labelWithString:NSLocalizedString(@"LevelMenu_LeaderboardsLabel", @"Leaderboards") fntFile:@"TDFont120.fnt"];
    TDFONT_MEDIUM(gameCenterButton);
    if (isSmallScreen)
        TDFONT_MEDIUMLARGE(gameCenterButton);
    gameCenterButton.anchorPoint = ccp(0.5, 0);
    gameCenterButton.position = ccp(screen.width/2, aboutIcon.position.y);
    gameCenterButton.opacity = 0;
    gameCenterButton.isTouchEnabled = YES;
    [self addChild:gameCenterButton];
    [gameCenterButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                       {
                                           AUDIOTIC1;
                                           [[GameCenter sharedInstance] showLeaderBoard:1];
                                       }]];
    gameCenterButton.isTouchEnabled = NO;
    
    
    CCLabelBMFont* storeSprite = [CCLabelBMFont labelWithString:NSLocalizedString(@"LevelMenu_StoreLabel", @"Store") fntFile:@"TDFont120.fnt"];
    TDFONT_MEDIUM(storeSprite);
    if (isSmallScreen)
        TDFONT_MEDIUMLARGE(storeSprite);
    storeSprite.scale *= 1.2;
    storeSprite.anchorPoint = ccp(0.5, 0);
    storeSprite.position = ccp(BB_LEFT(settingsButton) + BB_WIDTH(settingsButton)/2,
                               BB_TOP(settingsButton) + SCRNY(30));
    storeSprite.isTouchEnabled = YES;
    [self addChild:storeSprite];
    
    [storeSprite addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item)
                                       {
                                           [[CCDirector sharedDirector] replaceScene:[AppStore sceneAsStore]];
                                       }]];
    
    
    [[EventManager sharedManager] subscribe:GAMECENTER_AVAILABLE listener:self];
    [[EventManager sharedManager] subscribe:GAMECENTER_UNAVAILABLE listener:self];
    
    if ([GameCenter sharedInstance].isAvailable && [GameCenter sharedInstance].isAuthenticated)
    {
        [self eventOccurred:GAMECENTER_AVAILABLE data:nil];
    }
}


- (BOOL) eventOccurred:(NSString*)event data:(id)data
{
    if (event == GAMECENTER_UNAVAILABLE)
    {
        if (gameCenterButton.opacity > 0)
            [gameCenterButton runAction:[CCFadeOut actionWithDuration:0.25]];
        gameCenterButton.isTouchEnabled = NO;
    }
    else if (event == GAMECENTER_AVAILABLE)
    {
        if (gameCenterButton.opacity < 255)
            [gameCenterButton runAction:[CCFadeIn actionWithDuration:0.25]];
        gameCenterButton.isTouchEnabled = YES;
    }
    
    return YES;
}


-(void) update:(ccTime) delta
{
    // empty, just need it so about screen can fade in and out
}

- (void) toggleAbout:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    if (aboutScreen == nil)
    {
        CGSize screen = [[CCDirector sharedDirector] winSize];
        aboutScreen = [CCSprite spriteWithFile:@"AboutScreen.png"];
        aboutScreen.anchorPoint = ccp(0.5,0.5);
        aboutScreen.position = ccp(screen.width/2, screen.height/2);
        aboutScreen.opacity = 0;
        aboutScreen.isTouchEnabled = YES;
        [self addChild:aboutScreen z:99999];
        [aboutScreen addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleAbout:item:)]]; // Yes, call ourself again.
        
        CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
            [self unscheduleUpdate];
        }];
        
        CCLabelTTF* p1 = [CCLabelTTF labelWithString:NSLocalizedString(@"About_WhatDoYouGet", @"What do you get...") fontName:@"AmericanTypewriter" fontSize:SCALE(24)];
        p1.dimensions = p1.boundingBox.size;
        p1.horizontalAlignment = kCCTextAlignmentLeft;
        p1.anchorPoint = ccp(0,1);
        p1.position = ccp(SCRNX(175), SCRNY(675));
        p1.color = ccc3(0,0,0);
        [aboutScreen addChild:p1];
        
        
        CCLabelTTF* thisIsIt = [CCLabelTTF labelWithString:NSLocalizedString(@"About_ThisIsIt", @"You're lookin' at it!") fontName:@"Futura-CondensedExtraBold" fontSize:SCALE(48)];
        
        thisIsIt.anchorPoint = ccp(0,1);
        thisIsIt.position = ccp(SCRNX(220), SCRNY(590));
        thisIsIt.color = ccc3(240,0,0);
        [aboutScreen addChild:thisIsIt];
                          
        
        CCLabelTTF* tdlTitle = [CCLabelTTF labelWithString:@"Tree Dudes Launch" fontName:@"Futura-CondensedExtraBold" fontSize:SCALE(28)];
        tdlTitle.anchorPoint = ccp(0,1);
        tdlTitle.position = ccp(SCRNX(175), SCRNY(400));
        tdlTitle.color = ccc3(0,0,0);
        [aboutScreen addChild:tdlTitle];
        
        CCLabelTTF* p2 = [CCLabelTTF labelWithString:NSLocalizedString(@"About_TDLIsAGame", @"is a game about...") fontName:@"AmericanTypewriter" fontSize:SCALE(24)];
        p2.dimensions = p2.boundingBox.size;
        p2.horizontalAlignment = kCCTextAlignmentLeft;
        p2.anchorPoint = ccp(0,1);
        p2.position = ccp(SCRNX(175), SCRNY(394));
        p2.color = ccc3(0,0,0);
        [aboutScreen addChild:p2];
        
        CCLabelTTF* p3 = [CCLabelTTF labelWithString:NSLocalizedString(@"About_Feedback", @"You can let us know at") fontName:@"AmericanTypewriter" fontSize:SCALE(24)];
        p3.dimensions = p3.boundingBox.size;
        p3.horizontalAlignment = kCCTextAlignmentLeft;
        p3.anchorPoint = ccp(0,1);
        p3.position = ccp(SCRNX(175), SCRNY(130));
        p3.color = ccc3(0,0,0);
        [aboutScreen addChild:p3];
        
        CCLabelTTF* feedback = [CCLabelTTF labelWithString:NSLocalizedString(@"About_Feedback_Address", @"feedback@kornerstoane.com") fontName:@"AmericanTypewriter-Bold" fontSize:SCALE(24)];
        feedback.anchorPoint = ccp(0,1);
        feedback.position = ccp(p3.boundingBox.origin.x + p3.boundingBox.size.width + SCRNX(7), SCRNY(131));
        feedback.color = ccc3(0,0,0);
        [aboutScreen addChild:feedback];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *build = [NSString stringWithFormat:@"Version %@", infoDictionary[(NSString*)kCFBundleVersionKey]];
        CCLabelBMFont* versionLabel = [CCLabelBMFont labelWithString:build fntFile:@"TDFontYellow96.fnt"];
        versionLabel.scale = 0.4;
        versionLabel.anchorPoint = ccp(0.5, 0);
        versionLabel.position = ccp(aboutScreen.contentSize.width/2, SCRNY(30));
        [aboutScreen addChild:versionLabel];
    
        
        [aboutScreen runAction:[CCSequence actions:[CCFadeIn actionWithDuration:.15], cleanup, nil]];

    }
    else
    {
        CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
            [self unscheduleUpdate];
            [aboutScreen removeAllChildrenWithCleanup:YES];
            [self removeChild:aboutScreen cleanup:YES];
            aboutScreen = nil;
        }];

        [aboutScreen runAction:[CCSequence actions:[CCFadeOut actionWithDuration:.15], cleanup, nil]];
    }
    
    [self scheduleUpdate];
    AUDIOTIC1;
}


-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
#define ACCEL_FILTER(VAR, INPUT) VAR = ((INPUT * 0.6) + (VAR * 0.4))

    static float x=0, y=0, z=0;
    
    ACCEL_FILTER(x, acceleration.x);
    ACCEL_FILTER(y, acceleration.y);
    ACCEL_FILTER(z, acceleration.z);
    
    //NSLog(@"%f, %f, %f", x, y, z);
    
    float diffX = 15 * y;
    float diffY = 15 * (z + .25);  // natural "0" position for z is roughly 45 deg angle
    [background runAction:[CCMoveTo actionWithDuration:1.0/30 position:ccp(self.contentSize.width/2 - diffX, self.contentSize.height/2 + diffY)]];

#undef ACCEL_FILTER
}


- (void) onExit
{
    [[EventManager sharedManager] unsubscribe:GAMECENTER_AVAILABLE listener:self];
    [[EventManager sharedManager] unsubscribe:GAMECENTER_UNAVAILABLE listener:self];
    [self removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [super onExit];
}



- (void)buttonTouched:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    
    SelectedLevel = 0;
    CCSprite* button = nil;
    for (int i=0; i < 10; i++)
    {
#ifndef DEBUG
        if (i >= [Achievements sharedAchievements].level)
            continue;  // skip unearned levels
#endif
        
        button = [menuButtons objectAtIndex:i];
        if (button == item)
        {
            SelectedLevel = i+1;
            break;
        }
    }
    
    if (SelectedLevel == 0)
        return;
    
    if (SelectedLevel > 0)
    {
        AUDIOTIC1;
        loadingMsg.visible = YES;
        [self scheduleOnce:@selector(loadSelectedLevel) delay:0.01];
    }
        
    return;
}



- (void) loadSelectedLevel
{
    GameLevel* level = getLevelForID(SelectedLevel);
    
    if (level == nil)
        return;
    
    [[CCDirector sharedDirector] replaceScene: [GameLayer sceneWithLevel:level]];
    [self removeAllChildrenWithCleanup:YES];
}


- (void) loadLevelData
{
    NSMutableArray* data = [NSMutableArray arrayWithCapacity:10];
    
    [data addObject:((GameLevel*)[[[GameLevel_1 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_2 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_3 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_4 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_5 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_6 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_7 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_8 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_9 alloc] init] load]).gameData];
    [data addObject:((GameLevel*)[[[GameLevel_10 alloc] init] load]).gameData];

    levelData = data;
}

@end
