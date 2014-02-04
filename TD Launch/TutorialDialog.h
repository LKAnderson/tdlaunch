//
//  TutorialDialog.h
//  TD Launch
//
//  Created by Kent Anderson on 9/19/13.
//
//

#import "Dialog.h"

@interface TutorialDialog : Dialog
{
    NSString* _message;
    float _scale;
    CGPoint _position;
    CGPoint _anchorPoint;
    CGPoint _arrowTo;
}

- (TutorialDialog*) initWithMessage:(NSString*)message at:(CGPoint)position anchorPoint:(CGPoint)anchorPoint scaledTo:(NSString*)scaleStr arrowTo:(CGPoint)arrowTo;

@end
