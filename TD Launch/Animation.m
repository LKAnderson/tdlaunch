//
//  Animation.m
//  TD Launch
//
//  Created by Kent Anderson on 10/10/12.
//
//

#import <cocos2d.h>
#import "Animation.h"


@implementation Animation


- (BOOL) frame:(float)clockRate
{
    /* abstract base class */
    return NO;
}

- (void) reset
{
}

@end




@implementation RotationAnimation



- (BOOL) frame:(float)clockRate
{
    self.body.angVel = CC_DEGREES_TO_RADIANS(360) * self.frequency * (self.isClockwise ? -1 : 1);
    cpBodyUpdatePosition(self.body.body, clockRate);
    return YES;
}


@end


@implementation OscillationAnimation

- (id) init
{
    if (self = [super init])
    {
        _direction = 1;
    }
    return self;
}

- (BOOL) frame:(float)clockRate
{
    cpVect delta = cpv(0,0);
    float range = fabsf(_rangeEnd - _rangeBegin);
    
    if (_isHorizontal == YES)
        delta.x = range * clockRate * _frequency * _direction;
    else
        delta.y = range * clockRate * _frequency * _direction;
    
    cpVect pos = self.body.pos;
    pos = cpvadd(pos, delta);
    
    if (_isHorizontal)
    {
        if (pos.x <= _rangeBegin || pos.x >= _rangeEnd)
            _direction *= -1;
    }
    else
    {
        if (pos.y <= _rangeBegin || pos.y >= _rangeEnd)
            _direction *= -1;
    }
    
    self.body.pos = pos;
    
    cpBodyUpdatePosition(self.body.body, clockRate);
    return YES;
}


@end

@implementation SpriteAnimation: Animation


- (id) init
{
    if (self = [super init])
    {
        _counter = 0;
        _frameIndex = 0;
    }
    return self;
}


- (BOOL) frame:(float)clockRate
{
    if (_frameIndex >= _frames.count)
    {
        if (!_repeat)
        {
            [_sprite setDisplayFrame:_finishFrame];
            return NO;
        }
        _frameIndex = 0;
    }
    
    if (_counter == 0)
    {
        [_sprite setDisplayFrame:(CCSpriteFrame*)[_frames objectAtIndex:_frameIndex]];
        _frameIndex++;
        _counter = 60 * _frequency;  // reset for next frame
    }
    
    return YES;
}

@end


@implementation AnimatedPathSegment
+ (AnimatedPathSegment*) createSegmentFrom:(CGPoint)from to:(CGPoint)to duration:(float)duration
{
    AnimatedPathSegment* seg = [[AnimatedPathSegment alloc] init];
    seg.from = from;
    seg.to = to;
    seg.duration = duration;
    return seg;
}
@end


@implementation FollowPathAnimation: Animation


- (id) init
{
    if (self = [super init])
    {
        _nextSegment = 0;
        _segments = [NSMutableArray array];
    }
    return self;
}

- (void) reset
{
    _nextSegment = 0;
    _segmentTimeRemaining = ((AnimatedPathSegment*)[_segments firstObject]).duration;
}

- (BOOL) frame:(float)clockRate
{
    // We're going to animate this ourselves.  We'll keep track of how much
    // time has elapsed on the current segment so we can figure out how much
    // we time we have left to move the remaining distance of the segment.
    // This way we only have to worry about where we are in this frame,
    // and how much farther we have to go.
    if (_nextSegment >= _segments.count)
    {
        if (_loop)
        {
            AnimatedPathSegment* segment = [_segments firstObject];
            self.body.pos = segment.from;
            _nextSegment = 0;
            _segmentTimeRemaining = segment.duration;
        }
        else
        {
            return NO;
        }
    }
    
    if (_segmentTimeRemaining <= 0)
    {
        _segmentTimeRemaining = ((AnimatedPathSegment*)[_segments objectAtIndex:_nextSegment]).duration;
    }
    
    AnimatedPathSegment* segment = [_segments objectAtIndex:_nextSegment];
    
    // What % of timeRemaining is the current frame time (clockRate)?
    float pctToMove = clockRate / _segmentTimeRemaining;
    
    // What is the distance between our current position and the end of the segment?
    // Distance to move this frame is the pctToMove * the distance.
    CGPoint dist = CGPointMake((segment.to.x - self.body.pos.x)*pctToMove, (segment.to.y - self.body.pos.y)*pctToMove);
    CGPoint next = CGPointMake(self.body.pos.x + dist.x, self.body.pos.y + dist.y);
    
    // Figure out whether we're past the _to_ point.
    if (dist.x < 0 && next.x < segment.to.x)
        next.x = segment.to.x;
    else if (dist.x > 0 && next.x > segment.to.x)
        next.x = segment.to.x;
    
    if (dist.y < 0 && next.y < segment.to.y)
        next.y = segment.to.y;
    else if (dist.y > 0 && next.y > segment.to.y)
        next.y = segment.to.y;
    
    self.body.pos = cpv(next.x, next.y);
    cpBodyUpdatePosition(self.body.body, clockRate);
    _segmentTimeRemaining -= clockRate;
    
    if (next.x == segment.to.x && next.y == segment.to.y)
    {
        _nextSegment++;
        // MAYBE: Figure out the angle for the next segment and
        // Animate to it.
    }
    
    return YES;
}



@end