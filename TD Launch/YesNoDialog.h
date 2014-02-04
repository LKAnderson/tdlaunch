//
//  YesNoDialog.h
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import "Dialog.h"

@interface YesNoDialog : Dialog
{
    CCNode* _dialog;
    CCSprite* _dialogBack;
    CCSprite* _yesButton;
    CCSprite* _noButton;
    CCLabelBMFont* _cancelButton;
    CCLabelBMFont* _msg;
    
    void (^_onYes)(void);
    void (^_onNo)(void);
}

@property NSString* msgName;
@property bool showCancel;

- (YesNoDialog*) initWithMessage:(NSString*)msgName onYes:(void(^)())onYes onNo:(void(^)())onNo;

- (void) setYesHandler:(void (^)(void))handler;
- (void) setNoHandler:(void (^)(void))handler;


@end
