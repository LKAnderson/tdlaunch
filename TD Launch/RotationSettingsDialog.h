//
//  RotationSettingsDialog.h
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import <cocos2d.h>
#import "Dialog.h"
#import "FieldObject.h"

@interface RotationSettingsDialog : SettingsDialog
{    
    CCSprite* _objectDial;
    CCSprite* _objectDialSprite;
    CCLabelTTF* _dialRotationValue;
    bool _longPressInProgress;
    bool _dialLongPressIncrement;
    double _dialIncrementValue;
    int _dialIncrementTimer;
}

@property NSString* dialogSpriteName;
@property double dialogOffsetX;
@property double dialogOffsetY;

- (CCSprite*) getDialogSprite;

@end
