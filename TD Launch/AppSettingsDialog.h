//
//  AppSettingsDialog.h
//  TD Launch
//
//  Created by Kent Anderson on 1/7/14.
//
//

#import "Dialog.h"

@interface AppSettingsDialog : Dialog
{
    CCSpriteFrame* checked;
    CCSpriteFrame* unchecked;
    
    CCSprite* gcCheckbox;
    CCSprite* soundCheckbox;
    CCSprite* tutorialCheckbox;
}
@end
