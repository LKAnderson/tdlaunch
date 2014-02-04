//
//  Animation.h
//  TD Launch
//
//  Created by Kent Anderson on 10/10/12.
//
//

#import <Foundation/Foundation.h>
#import <ObjectiveChipmunk.h>


@interface Animation : NSObject


@property ChipmunkBody* body;

- (BOOL) frame:(float)clockRate;  // Return NO to end the animation
- (void) reset;

@end



@interface RotationAnimation : Animation

@property BOOL isClockwise;
@property float frequency;

@end


@interface OscillationAnimation: Animation
{
    int _direction;
}

@property CGPoint homePosition;

@property float rangeBegin;
@property float rangeEnd;
@property float frequency;

@property BOOL isHorizontal;

@end



@interface SpriteAnimation: Animation
{
    int _counter;
    int _frameIndex;
}

@property NSArray* frames;
@property CCSpriteFrame* finishFrame;
@property float frequency;
@property BOOL repeat;
@property CCSprite* sprite;

@end


@interface AnimatedPathSegment : NSObject
@property CGPoint from;
@property CGPoint to;
@property float duration;
+ (AnimatedPathSegment*) createSegmentFrom:(CGPoint)from to:(CGPoint)to duration:(float)duration;
@end


@interface FollowPathAnimation: Animation
{
    int _nextSegment;
    float _segmentTimeRemaining;
}
@property NSMutableArray* segments; // Holds AnimatedPathSegment
@property BOOL loop;
@end