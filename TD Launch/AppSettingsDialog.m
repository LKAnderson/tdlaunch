//
//  AppSettingsDialog.m
//  TD Launch
//
//  Created by Kent Anderson on 1/7/14.
//
//

#import "AppSettingsDialog.h"
#import "Settings.h"
#import "Screen.h"
#import "GameCenter.h"
#import "SimpleAudioEngine.h"
#import "EventManager.h"
#import "Achievements.h"

@implementation AppSettingsDialog

- (void) onEnter
{
    [super onEnter];
    
    checked = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Checkbox_Filled.png"]).displayFrame;
    unchecked = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Checkbox_Empty.png"]).displayFrame;
    
    CCSprite* dialogBack = [CCSprite spriteWithSpriteFrameName:@"DialogBack.png"];

    CCNode* dialog = [CCNode node];
    dialog.anchorPoint = ccp(0.5,0.5);
    dialog.position = ccp(self.parent.contentSize.width/2, self.parent.contentSize.height/2);
    dialog.contentSize = dialogBack.contentSize;
    [self addChild:dialog];
    
    dialogBack.anchorPoint = ccp(0,0);
    dialogBack.position = ccp(0,0);
    [dialog addChild:dialogBack];
    
    gcCheckbox = [CCSprite spriteWithSpriteFrameName:@"Checkbox_Empty.png"];
    gcCheckbox.anchorPoint = ccp(0,0);
    gcCheckbox.position = ccp(dialog.contentSize.width * .09, dialog.contentSize.height * .67);
    [dialog addChild:gcCheckbox];
    
    CCLabelBMFont* gcLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"AppSettingsDialog_GameCenterLabel", @"GameCenter") fntFile:@"TDFont120.fnt"];
    gcLabel.anchorPoint = ccp(0,0);
    gcLabel.position = ccp(gcCheckbox.position.x + (1.6 * gcCheckbox.contentSize.width), gcCheckbox.position.y);
    [dialog addChild:gcLabel];
    
    soundCheckbox = [CCSprite spriteWithSpriteFrameName:@"Checkbox_Filled.png"];
    soundCheckbox.anchorPoint = ccp(0,0);
    soundCheckbox.position = ccp(gcCheckbox.position.x, dialog.contentSize.height * .40);
    [dialog addChild:soundCheckbox];
    
    CCLabelBMFont* soundLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"AppSettingsDialog_SoundLabel", @"Sound") fntFile:@"TDFont120.fnt"];
    soundLabel.anchorPoint = ccp(0,0);
    soundLabel.position = ccp(gcLabel.position.x, soundCheckbox.position.y);
    [dialog addChild:soundLabel];
    
    
    tutorialCheckbox = [CCSprite spriteWithSpriteFrameName:@"Checkbox_Empty.png"];
    tutorialCheckbox.anchorPoint = ccp(0,0);
    tutorialCheckbox.position = ccp(gcCheckbox.position.x, dialog.contentSize.height * .13);
    [dialog addChild:tutorialCheckbox];
    
    CCLabelBMFont* tutorialLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"AppSettingsDialog_TutorialLabel", @"Tutorial") fntFile:@"TDFont120.fnt"];
    tutorialLabel.anchorPoint = ccp(0,0);
    tutorialLabel.position = ccp(gcLabel.position.x, tutorialCheckbox.position.y);
    [dialog addChild:tutorialLabel];
    
    
    [self syncCheckboxes];


    if ([Achievements sharedAchievements].isTampered)
    {
        gcCheckbox.opacity = 128;
        gcLabel.opacity = 128;
    }
    else
    {
        gcCheckbox.isTouchEnabled = YES;
        [gcCheckbox addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleGameCenter:item:)]];

        gcLabel.isTouchEnabled = YES;
        [gcLabel addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleGameCenter:item:)]];
    }
    
    
    soundCheckbox.isTouchEnabled = YES;
    [soundCheckbox addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleSound:item:)]];
    
    soundLabel.isTouchEnabled = YES;
    [soundLabel addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleSound:item:)]];
    
    tutorialCheckbox.isTouchEnabled = YES;
    [tutorialCheckbox addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleTutorial:item:)]];
    
    tutorialLabel.isTouchEnabled = YES;
    [tutorialLabel addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(toggleTutorial:item:)]];

}


- (void) onExit
{
    [super onExit];
    [[Settings globalSettings] save];
    
    if ([Settings globalSettings].gameCenter == NO)
        [[EventManager sharedManager] publish:GAMECENTER_UNAVAILABLE data:nil];
    
    [GameCenter sharedInstance].enabled = [Settings globalSettings].gameCenter;
}



- (void) syncCheckboxes
{
    if ([Settings globalSettings].gameCenter == YES && [Achievements sharedAchievements].isTampered == NO)
        gcCheckbox.displayFrame = checked;
    else
        gcCheckbox.displayFrame = unchecked;
    
    if ([Settings globalSettings].sound == YES)
        soundCheckbox.displayFrame = checked;
    else
        soundCheckbox.displayFrame = unchecked;
    
    if ([Settings globalSettings].showTutorial == YES)
        tutorialCheckbox.displayFrame = checked;
    else
        tutorialCheckbox.displayFrame = unchecked;
}


- (void) toggleGameCenter:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    [Settings globalSettings].gameCenter = ! [Settings globalSettings].gameCenter;
    [self syncCheckboxes];
    AUDIOTIC1;
        
}

- (void) toggleSound:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    [Settings globalSettings].sound = ! [Settings globalSettings].sound;
    [self syncCheckboxes];
    [SimpleAudioEngine sharedEngine].mute = ![Settings globalSettings].sound;
    AUDIOTIC1;
}


- (void) toggleTutorial:(UIGestureRecognizer*)recognizer item:(CCNode*)item
{
    // I know, bad use of a singleton...
    Settings* s = [Settings globalSettings];
    s.showCharacterTutorial = s.showDrawerTutorial = s.showObjectTutorial = s.showRotateTutorial = !s.showTutorial;
    [self syncCheckboxes];
    AUDIOTIC1;
 }

@end
