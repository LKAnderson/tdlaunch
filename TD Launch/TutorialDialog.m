//
//  TutorialDialog.m
//  TD Launch
//
//  Created by Kent Anderson on 9/19/13.
//
//

#import "TutorialDialog.h"

@implementation TutorialDialog

- (TutorialDialog*) initWithMessage:(NSString*)message at:(CGPoint)position anchorPoint:(CGPoint)anchorPoint scaledTo:(NSString*)scaleStr arrowTo:(CGPoint)arrowTo
{
    if (self = [super init])
    {
        _message = message;
        _scale = [scaleStr floatValue];
        if (_scale == 0)
            _scale = 1.0;
        _position = position;
        _anchorPoint = anchorPoint;
        _arrowTo = arrowTo;
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    self.ignoreGlassTouch = NO;

    CCSprite* dialogBack = [CCSprite spriteWithSpriteFrameName:@"TutorialBack1.png"];
    dialogBack.anchorPoint = _anchorPoint;
    dialogBack.position = _position;
    [self addChild:dialogBack];
    
    CCLabelBMFont* msgLabel = [CCLabelBMFont labelWithString:_message fntFile:@"TDFontRed72.fnt"];
    msgLabel.alignment = kCCTextAlignmentCenter;
    msgLabel.scale = _scale;
    msgLabel.anchorPoint = ccp(0.5, 0.5);
    msgLabel.position = ccp(dialogBack.boundingBox.origin.x + (dialogBack.boundingBox.size.width/2),
                            dialogBack.boundingBox.origin.y + (1.1*dialogBack.boundingBox.size.height/2));
    [self addChild:msgLabel];

    CCSprite* arrow = [CCSprite spriteWithSpriteFrameName:@"TutorialArrow.png"];
    arrow.anchorPoint = ccp(0.5, 1.0);
    arrow.position = _arrowTo;
    // Rotate the arrow to an angle along the line between the arrow tip and the
    // center of the dialog (which is where msgLabel has been positioned
    CGPoint diff = ccp(arrow.position.x - msgLabel.position.x,
                       arrow.position.y - msgLabel.position.y);
    
    double radius = sqrt( (diff.x * diff.x) + (diff.y * diff.y) );
    
    // Quadrant I
    double angle = asin(fabs(diff.x/radius)) * (180/M_PI);
    
    // Quadrant II
    if (diff.x >= 0 && diff.y < 0)
        angle = 180 - angle;
    
    // Quadrant III
    else if (diff.x < 0 && diff.y < 0)
        angle = -180 + angle;
    
    else if (diff.x < 0 && diff.y >= 0)
        angle = -angle;
    
    arrow.rotation = angle;
    
    [self addChild:arrow]; // z:dialogBack.zOrder-1];
}


- (void) onExit
{
    [super onExit];
    [self removeAllChildrenWithCleanup:YES];
}

@end
