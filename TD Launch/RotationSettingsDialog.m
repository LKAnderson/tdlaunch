//
//  RotationSettingsDialog.m
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import <cocos2d.h>
#import "RotationSettingsDialog.h"
#import "CCGestureRecognizer.h"
#import "GestureRecognizerWithBlock.h"
#import "Screen.h"

#import <SimpleAudioEngine.h>

#define OBJECT_DIAL_OFFSET SCRNY(35.415) 


@implementation RotationSettingsDialog

- (id) init
{
    if (self = [super init])
    {
        self.dialogOffsetX = 0;
        self.dialogOffsetY = OBJECT_DIAL_OFFSET;
        self.dialogSpriteName = @"ObjectDialReg.png";
    }
    return self;
}


- (void) onEnter
{
    [super onEnter];
    
    _objectDial = [CCSprite spriteWithSpriteFrameName:self.dialogSpriteName];
    _objectDial.anchorPoint = ccp(0.5,0.5);
    _objectDial.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:_objectDial];
    
    
    _objectDial.isTouchEnabled = YES;
    [_objectDial addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc] init] target:self action:@selector(objectDialTapped:item:)]];
    [_objectDial addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UILongPressGestureRecognizer alloc] init] target:self action:@selector(objectDialLongPressed:item:)]];
    [_objectDial addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UIPanGestureRecognizer alloc] init] target:self action:@selector(objectDialPanned:item:)]];
    
    _longPressInProgress = NO;
    
    
    if (self.activeSprite)
    {
        _objectDialSprite = [CCSprite spriteWithSpriteFrame:self.activeSprite.displayFrame];
        self.settings.rotation = self.activeSprite.rotation;
        _objectDialSprite.rotation = self.activeSprite.rotation;
        _objectDialSprite.anchorPoint = self.activeSprite.anchorPoint;
        _objectDialSprite.position = ccp(_objectDial.position.x + self.dialogOffsetX, _objectDial.position.y + self.dialogOffsetY);
        [self addChild:_objectDialSprite];
    }
    
    NSString* rotString = [NSString stringWithFormat:@"%0.1fº", [self getRotation:_objectDialSprite.rotation]];
    _dialRotationValue = [CCLabelTTF labelWithString:rotString dimensions:CGSizeMake(SCRNX(99),SCRNY(45)) hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:(isSmallScreen ? 12 : 24)];
    _dialRotationValue.anchorPoint = ccp(0.5,0.5);
    _dialRotationValue.position = ccp(_objectDial.position.x + _dialogOffsetX, _objectDial.position.y - SCRNY(145));
    [self addChild:_dialRotationValue];
}

- (void) onExit
{
    [super onExit];
    [self removeChild:_objectDial cleanup:YES];
    [self removeChild:_objectDialSprite cleanup:YES];
    [self removeChild:_dialRotationValue cleanup:YES];
    _objectDial = nil;
    _objectDialSprite = nil;
    _dialRotationValue = nil;
    self.activeSprite = nil;
}


- (CCSprite*) getDialogSprite
{
    return _objectDial;
}

- (double) getRotation:(double)rot
{
    while (rot >= 360.0)
        rot -= 360.0;
    
    if (rot > 180.0)
        rot -= 360.0;
    else if (rot < -180.0)
        rot += 360.0;
    
    return rot;
}




- (double) getDialAngle:(CGPoint) point
{
    double radius = sqrt( (point.x * point.x) + (point.y * point.y) );
    
    // Quadrant I
    double angle = asin(fabs(point.x/radius)) * (180/M_PI);
    
    // Quadrant II
    if (point.x >= 0 && point.y < 0)
        angle = 180 - angle;
    
    // Quadrant III
    else if (point.x < 0 && point.y < 0)
        angle = -180 + angle;
    
    else if (point.x < 0 && point.y >= 0)
        angle = -angle;
    
    return angle;
    
}


- (void) setObjectDialValue:(double) value
{
    if (fabs(value) < 0.1) // Just lock it into 0
        value = 0.0;
    
    self.settings.rotation = [self getRotation:value];
    _objectDialSprite.rotation = self.settings.rotation;
    
    if (self.activeSprite)
    {
        self.activeSprite.rotation = self.settings.rotation;
    }
    
    NSString* rotString = [NSString stringWithFormat:@"%0.1fº", self.settings.rotation];
    [_dialRotationValue setString:rotString];
    
}

#define OBJECTDIAL_DECREMENT_KEY(p) (p.x - _dialogOffsetX < SCRNX(-72) && p.y < SCRNY(-90))
#define OBJECTDIAL_INCREMENT_KEY(p) (p.x - _dialogOffsetX > SCRNX(72) && p.y < SCRNY(-90))

- (void) objectDialTapped:(UIGestureRecognizer*) recognizer item:(CCNode*) item
{
    // figure out where the tap is
    UITapGestureRecognizer* tap = (UITapGestureRecognizer*)recognizer;
    
    
    CGPoint pTap = [tap locationInView:[[CCDirector sharedDirector] view]];
    CGPoint pDial = [_objectDial convertToNodeSpaceAR:pTap];
    pDial = [self adjustPointForBannerAd:pDial];
    pDial = ccp(pDial.x, -pDial.y);
    
    // if decrement
    if (OBJECTDIAL_DECREMENT_KEY(pDial)) // lower left
    {
        [self setObjectDialValue:self.settings.rotation - 0.1];
        AUDIOTIC2;
    }
    else if (OBJECTDIAL_INCREMENT_KEY(pDial)) // lower right
    {
        [self setObjectDialValue:self.settings.rotation + 0.1];
        AUDIOTIC2;
    }
    else
    {
        // see if they've "touched" the dial
        CGPoint touchDiff = ccpSub(pDial, ccp(0,OBJECT_DIAL_OFFSET));
        double radius = sqrt( (touchDiff.x * touchDiff.x) + (touchDiff.y * touchDiff.y) );  // thanks, Pythagorus!
        if (radius >= SCRNX(30) && radius <= SCRNY(170))
        {
            [self setObjectDialValue:[self getDialAngle:touchDiff]];
        }
    }
    
    self.settings.isChanged = YES;
    _longPressInProgress = NO;
}





- (void) objectDialLongPressed:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    // figure out where the tap is
    UILongPressGestureRecognizer* press = (UILongPressGestureRecognizer*)recognizer;
    if (press.state == UIGestureRecognizerStateBegan)
    {
        _longPressInProgress = YES;
        _dialIncrementTimer = 0;
        _dialIncrementValue = 0.1;
        [self schedule:@selector(dialLongPressTimer) interval:0.1];
    }
    else if (press.state == UIGestureRecognizerStateEnded)
    {
        _longPressInProgress = NO;
    }
    
    CGPoint pTap = [press locationInView:[[CCDirector sharedDirector] view]];
    CGPoint pDial = [_objectDial convertToNodeSpaceAR:pTap];
    pDial = [self adjustPointForBannerAd:pDial];
    pDial = ccp(pDial.x, -pDial.y);
    
    // if decrement
    if (OBJECTDIAL_DECREMENT_KEY(pDial))
    {
        _dialLongPressIncrement = NO;
    }
    else if (OBJECTDIAL_INCREMENT_KEY(pDial))
    {
        _dialLongPressIncrement = YES;
    }
    else
    {
        _longPressInProgress = NO;
    }
    
    AUDIOTIC2;
    self.settings.isChanged = YES;
}


- (void) dialLongPressTimer
{
    if (_longPressInProgress == NO)
    {
        [self unschedule:@selector(dialLongPressTimer)];
        return;
    }
    
    _dialIncrementTimer++;
    if (_dialIncrementTimer > 50)        // 5 seconds
        _dialIncrementValue = 15.0;
    
    else if (_dialIncrementTimer > 30)    // 3 seconds
        _dialIncrementValue = 5.0;
    
    else if (_dialIncrementTimer > 20)    // 2 seconds
        _dialIncrementValue = 1.0;
    
    else if (_dialIncrementTimer > 10)    // 1 seconds
        _dialIncrementValue = 0.5;
    
    if (_dialLongPressIncrement)
        [self setObjectDialValue:self.settings.rotation + _dialIncrementValue];
    else
        [self setObjectDialValue:self.settings.rotation - _dialIncrementValue];
    
    AUDIOTIC2;
    
    self.settings.isChanged = YES;
}


- (void) objectDialPanned:(UIGestureRecognizer*)recognizer item:(CCNode*) item
{
    if (_longPressInProgress)
    {
        return;
    }
    
    // figure out where the tap is
    UIPanGestureRecognizer* tap = (UIPanGestureRecognizer*)recognizer;
    
    CGPoint pTap = [tap locationInView:[[CCDirector sharedDirector] view]];
    CGPoint pDial = [_objectDial convertToNodeSpaceAR:pTap];
    pDial = [self adjustPointForBannerAd:pDial];
    pDial = ccp(pDial.x, -pDial.y);
    
    // see if they've "touched" the dial
    CGPoint touchDiff = ccpSub(pDial, ccp(self.dialogOffsetX,self.dialogOffsetY));
    double radius = sqrt( (touchDiff.x * touchDiff.x) + (touchDiff.y * touchDiff.y) );  // thanks, Pythagorus!
    if (radius >= SCRNX(30) && radius <= SCRNY(170))
    {
        [self setObjectDialValue:[self getDialAngle:touchDiff]];
    }
    
    _longPressInProgress = NO;
    self.settings.isChanged = YES;
}


@end