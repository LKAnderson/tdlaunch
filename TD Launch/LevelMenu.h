//
//  LevelMenu.h
//  TD Launch
//
//  Created by Kent Anderson on 8/22/12.
//
//

#import "cocos2d.h"
#import "EventManager.h"

@interface LevelMenu : CCLayer <EventListener>
{
    NSArray* menuButtons;
    NSArray* menuStars;
    NSArray* levelData;
    CCNode* buttonPanel;
    CCSprite* touchFlash;
    CCLabelBMFont* loadingMsg;
    CCSprite* background;
    CCLabelBMFont* aboutIcon;
    CCSprite* aboutScreen;
    CCLabelBMFont* gameCenterButton;
    CCSpriteFrame* soundOnFrame;
    CCSpriteFrame* soundOffFrame;
    
}

+ (CCScene*) scene;
@end
