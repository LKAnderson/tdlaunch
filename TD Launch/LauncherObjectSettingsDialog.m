//
//  LauncherObjectSettingsDialog.m
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import "LauncherObjectSettingsDialog.h"
#import "FieldObject.h"
#import "GestureRecognizerWithBlock.h"
#import "Screen.h"


#define OBJECT_DIAL_EXT_OFFSET SCRNY(35.415)

@implementation LauncherObjectSettingsDialog

- (id) init
{
    if (self = [super init])
    {
        self.dialogSpriteName = @"ObjectDialExt.png";
        self.dialogOffsetY = OBJECT_DIAL_EXT_OFFSET;
        self.dialogOffsetX = SCRNX(-52.948);
        self.settings = [[LauncherObjectSettings alloc] init];
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
    
    CCSprite* dlgSprite = [self getDialogSprite];

    _barsBackBlack = [ColoredNode node];
    _barsBackBlack.fillColor = ccc3(0,0,0);
    _barsBackBlack.contentSize = CGSizeMake(SCRNX(62),SCRNY(161));
    _barsBackBlack.anchorPoint = ccp(0, 0.5);
    _barsBackBlack.position = ccp(dlgSprite.position.x + SCRNX(139), dlgSprite.position.y + self.dialogOffsetY);
    [self addChild:_barsBackBlack z:-2];
    
    _barsBackRed = [ColoredNode node];
    _barsBackRed.fillColor = ccc3(255,0,0);
    _barsBackRed.contentSize = CGSizeMake(_barsBackBlack.contentSize.width, _barsBackBlack.contentSize.height * (launcherSettings.strength/100));
    _barsBackRed.anchorPoint = ccp(0,0);
    _barsBackRed.position = _barsBackBlack.boundingBox.origin;
    [self addChild:_barsBackRed z:-1];

    _sliderTouch = [CCNode node];
    _sliderTouch.contentSize = _barsBackBlack.contentSize;
    _sliderTouch.anchorPoint = ccp(0,0);
    _sliderTouch.position = _barsBackBlack.boundingBox.origin;
    [self addChild:_sliderTouch z:1];
    
    _sliderTouch.isTouchEnabled = YES;
    [_sliderTouch addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(sliderTapped:item:)]];
    [_sliderTouch addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UIPanGestureRecognizer alloc] init] target:self action:@selector(sliderPanned:item:)]];
    
    // TODO: Make these better fonts.
    NSString* strengthStr = @"0";
    _strengthLabel = [CCLabelTTF labelWithString:strengthStr dimensions:CGSizeMake(SCRNX(75),SCRNY(45)) hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:(isSmallScreen ? 12 : 24)];
    _strengthLabel.anchorPoint = ccp(0.5,0.5);
    _strengthLabel.opacity = 230;
    _strengthLabel.position = ccp(_sliderTouch.boundingBox.origin.x + _sliderTouch.contentSize.width/2,
                                  _sliderTouch.boundingBox.origin.y + _sliderTouch.contentSize.height/2 - self.dialogOffsetY - SCRNY(145));
    [self addChild:_strengthLabel];
    
    CCNode* increment = [CCNode node];
    increment.contentSize = CGSizeMake(_sliderTouch.contentSize.width, SCRNY(50));
    increment.anchorPoint = ccp(0,0);
    increment.position = ccp(_sliderTouch.position.x, _sliderTouch.boundingBox.origin.y + _sliderTouch.boundingBox.size.height + SCRNY(5));
    increment.isTouchEnabled = YES;
    [self addChild:increment];
        
    CCNode* decrement = [CCNode node];
    decrement.contentSize = increment.contentSize;
    decrement.anchorPoint = ccp(0,1);
    decrement.position = ccp(_sliderTouch.position.x, _sliderTouch.position.y - SCRNY(5));
    decrement.isTouchEnabled = YES;
    [self addChild:decrement];
    
    [increment addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item) {
        LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
        if (launcherSettings.strength < 100)
        {
            launcherSettings.strength++;
            self.settings.isChanged = YES;
            [self updateStrengthBar];
        }
    }]];
    
    
    [increment addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UILongPressGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item) {
        LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
        if (launcherSettings.strength < 100)
        {
            launcherSettings.strength++;
            self.settings.isChanged = YES;
            [self updateStrengthBar];
        }
    }]];
    

    [decrement addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item) {
        LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
        if (launcherSettings.strength > 1)
        {
            launcherSettings.strength--;
            self.settings.isChanged = YES;
            [self updateStrengthBar];
        }
    }]];

    [decrement addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UILongPressGestureRecognizer alloc] init] block:^(UIGestureRecognizer* recognizer, CCNode* item) {
        LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
        if (launcherSettings.strength > 1)
        {
            launcherSettings.strength--;
            self.settings.isChanged = YES;
            [self updateStrengthBar];
        }
    }]];
    
    [self updateStrengthBar];
    
}


- (void) onExit
{
    [super onExit];
    [self removeAllChildrenWithCleanup:YES];
    _barsBackBlack = nil;
    _barsBackRed = nil;
    _sliderTouch = nil;
}


- (void) updateStrengthBar
{
    LauncherObjectSettings* launcherSettings = (LauncherObjectSettings*)self.settings;
    [_barsBackRed resizeTo:CGSizeMake(_barsBackRed.contentSize.width, _sliderTouch.contentSize.height * (launcherSettings.strength/100.0))];
    _strengthLabel.string = [NSString stringWithFormat:@"%d", launcherSettings.strength];
}


- (void) sliderTapped:(UIGestureRecognizer*) recognizer item:(CCNode*) item
{
    // figure out where the tap is
    UITapGestureRecognizer* tap = (UITapGestureRecognizer*)recognizer;
    
    CGPoint pTap = [tap locationInView:[[CCDirector sharedDirector] view]];
    CGPoint pSlider = [_sliderTouch convertToNodeSpaceAR:pTap];
    double position = (_sliderTouch.contentSize.height/2) - pSlider.y;  // AR call seems to assume 0.5,0.5? Weird. Can't wait for SpriteKit!

    LauncherObjectSettings* settings = (LauncherObjectSettings*)self.settings;
    settings.strength = (uint)(100*position / _sliderTouch.contentSize.height);
    if (settings.strength < 1) settings.strength = 1;
    else if (settings.strength > 100) settings.strength = 100;
    [self updateStrengthBar];
    
    self.settings.isChanged = YES;
}






- (void) sliderPanned:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    if (_objectDial == nil)
        return;
    
    
    // figure out where the tap is
    UIPanGestureRecognizer* tap = (UIPanGestureRecognizer*)recognizer;
    
    CGPoint pTap = [tap locationInView:[[CCDirector sharedDirector] view]];
    CGPoint pSlider = [_sliderTouch convertToNodeSpaceAR:pTap];
    double position = (_sliderTouch.contentSize.height/2) - pSlider.y;
    
    LauncherObjectSettings* settings = (LauncherObjectSettings*)self.settings;
    settings.strength = (uint)(100*position / _sliderTouch.contentSize.height);
    if (settings.strength < 1) settings.strength = 1;
    else if (settings.strength > 100) settings.strength = 100;
    [self updateStrengthBar];
    
    self.settings.isChanged = YES;
}


@end
