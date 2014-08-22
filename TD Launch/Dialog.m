//
//  Dialog.m
//  TD Launch
//
//  Created by Kent Anderson on 7/13/13.
//
//

#import "Dialog.h"
#import "CCGestureRecognizer.h"
#import "GestureRecognizerWithBlock.h"
#import "AppDelegate.h"

@implementation Dialog
// The dialog fills the whole screen and acts as the "glass" that detects touches off the main
// content of the dialog.

- (void) setCloseHandler:(void (^)(id))handler
{
    _dialogClosed = handler;
}


- (void) onEnter
{
    [super onEnter];
    self.contentSize = self.parent.contentSize;
    self.position = ccp(0,0);
    
    _glass = [CCNode node];
    _glass.contentSize = self.contentSize;
    _glass.anchorPoint = ccp(0,0);
    _glass.position = self.position;
    [self addChild:_glass];
    
    _glass.isTouchEnabled = YES;
    
    [_glass addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item){
        if (_ignoreGlassTouch)
            return;
        [self closeDialog];
    }]];

}


- (void) onExit
{
    [super onExit];
    _glass = nil;
    _dialogClosed = nil;
    
    for( CCGestureRecognizer* gr in [self gestureRecognizers])
        [self removeGestureRecognizer:gr];
}


- (void) closeDialog
{
    if (_dialogClosed)
    {
        _dialogClosed(self);
    }
    [self removeChild:_glass cleanup:YES];
    [self.parent removeChild:self cleanup:YES];
}

- (CGPoint) adjustPointForBannerAd:(CGPoint)point
{
    if (!APPCONTROLLER.adBannerVisible)
        return point;
    
    return CGPointMake(point.x, point.y - APPCONTROLLER.iAdView.bounds.size.height);
}

@end
