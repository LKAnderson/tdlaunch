//
//  YesNoDialog.m
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import "YesNoDialog.h"
#import "GestureRecognizerWithBlock.h"
#import "Screen.h"

@implementation YesNoDialog

- (YesNoDialog*) initWithMessage:(NSString *)msgName onYes:(void (^)())onYes onNo:(void (^)())onNo
{
    if (self = [super init])
    {
        _msgName = msgName;
        _onYes = onYes;
        _onNo = onNo;
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    self.ignoreGlassTouch = YES;
    
    _dialogBack = [CCSprite spriteWithSpriteFrameName:@"DialogBack.png"];
    _yesButton = [CCSprite spriteWithSpriteFrameName:@"YesButton.png"];
    _noButton = [CCSprite spriteWithSpriteFrameName:@"NoButton.png"];
    _msg = [CCLabelBMFont labelWithString:_msgName fntFile:@"TDFont120.fnt"];
    _msg.alignment = kCCTextAlignmentCenter;
    
    _dialog = [CCNode node];
    _dialog.contentSize = _dialogBack.contentSize;
    _dialog.anchorPoint = ccp(0.5,0.5);
    _dialog.position = ccp(self.parent.contentSize.width/2, self.parent.contentSize.height/2);
    [self addChild:_dialog];
    
    _dialogBack.anchorPoint = ccp(0.5,0.5);
    _dialogBack.position = ccp(_dialog.contentSize.width/2, _dialog.contentSize.height/2);
    [_dialog addChild:_dialogBack];
    
    _yesButton.anchorPoint = ccp(0.5,0.5);
    _yesButton.position = ccp(_dialog.contentSize.width*.30, _dialog.contentSize.height*.30);
    _yesButton.isTouchEnabled = YES;
    [_dialog addChild:_yesButton];
    
    CCLabelBMFont* yesLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"YesNoDialog_YesButtonLabel", @"Yes") fntFile:@"TDFont120.fnt"];
    yesLabel.scale = 0.80;
    yesLabel.anchorPoint = ccp(0.55,0.31);
    yesLabel.position = ccp(_yesButton.contentSize.width/2, _yesButton.contentSize.height/2);
    [_yesButton addChild:yesLabel];
    
    
    _noButton.anchorPoint = ccp(0.5,0.5);
    _noButton.position = ccp(_dialog.contentSize.width*.70, _dialog.contentSize.height*.30);
    _noButton.isTouchEnabled = YES;
    [_dialog addChild:_noButton];
    
    CCLabelBMFont* noLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"YesNoDialog_NoButtonLabel", @"No") fntFile:@"TDFont120.fnt"];
    noLabel.scale = 0.80;
    noLabel.anchorPoint = ccp(0.55,0.31);
    noLabel.position = ccp(_noButton.contentSize.width/2, _noButton.contentSize.height/2);
    [_noButton addChild:noLabel];
    
    if (_showCancel)
    {
        _cancelButton = [CCLabelBMFont labelWithString:NSLocalizedString(@"YesNoDialog_CancelLabel", @"Cancel") fntFile:@"TDFontYellow96.fnt"];
        TDFONT_MEDIUM(_cancelButton);
        _cancelButton.anchorPoint = ccp(0.55,0);
        _cancelButton.position = ccp(_dialog.contentSize.width/2, SCRNY(15));
        _cancelButton.isTouchEnabled = YES;
        _cancelButton.scale = 0.70;
        [_dialog addChild:_cancelButton];
        
        [_cancelButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                            {
                                                [self closeDialog];
                                            }]];
    }
    
    
    
    _msg.anchorPoint = ccp(0.5,0.5);
    _msg.position = ccp(_dialog.contentSize.width/2, _dialog.contentSize.height*.70);
    [_dialog addChild:_msg];
    
    [_yesButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                     {
                                         if (_onYes)
                                             _onYes();
                                         [self closeDialog];
                                     }]];
    
    [_noButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item)
                                    {
                                        if (_onNo)
                                            _onNo();
                                        [self closeDialog];
                                    }]];
    
}




- (void) onExit
{
    [super onExit];
    [_dialog removeAllChildrenWithCleanup:YES];
    _dialog = nil;
    _dialogBack = nil;
    _yesButton = nil;
    _noButton = nil;
    _msg = nil;
    _onYes = nil;
    _onNo = nil;
}

- (void) setYesHandler:(void (^)(void))handler
{
    _onYes = handler;
}

- (void) setNoHandler:(void (^)(void))handler
{
    _onNo = handler;
}

@end
