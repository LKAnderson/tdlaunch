//
//  Dialog.h
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import "cocos2d.h"

@interface Dialog : CCNode
{
    CCNode* _glass;
    void(^_dialogClosed)(id);
}

@property bool ignoreGlassTouch;

- (void) setCloseHandler:(void (^)(id))handler;
- (void) closeDialog;
@end



