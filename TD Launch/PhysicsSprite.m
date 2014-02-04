//
//  PhysicsSprite.m
//  TD Launch
//
//  Created by Kent Anderson on 8/7/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "PhysicsSprite.h"

// callback to remove Shapes from the Space
void removeShape( cpBody *body, cpShape *shape, void *data )
{
	cpShapeFree( shape );
}

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(ChipmunkBody *)body
{
	body_ = body;
}

-(ChipmunkBody*) body
{
    return body_;
}


-(CGPoint) position
{
    return body_.pos;
}

- (void) setPosition:(CGPoint)position
{
    body_.pos = position;
}

- (float) rotation
{
    return -CC_RADIANS_TO_DEGREES(body_.angle);
}

- (void) setRotation:(float)rotation
{
    body_.angle = -CC_DEGREES_TO_RADIANS(rotation);
}

// this method will only get called if the sprite is batched.
// return YES if the physic's values (angles, position ) changed.
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	CGFloat x = body_.pos.x;
	CGFloat y = body_.pos.y;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	CGFloat c = body_.rot.x;
	CGFloat s = body_.rot.y;
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Translate, Rot, anchor Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );
	
	return transform_;
}

//-(void) dealloc
//{
//	cpBodyEachShape(body_, removeShape, NULL);
//	cpBodyFree( body_ );
//	
//	//[super dealloc];
//}

@end
