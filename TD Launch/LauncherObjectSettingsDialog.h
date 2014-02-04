//
//  LauncherObjectSettingsDialog.h
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import <cocos2d.h>
#import "RotationSettingsDialog.h"
#import "ColoredNode.h"

@interface LauncherObjectSettingsDialog : RotationSettingsDialog
{
    ColoredNode* _barsBackBlack;
    ColoredNode* _barsBackRed;
    CCNode* _sliderTouch;
    CCLabelTTF* _strengthLabel;
}
@end
