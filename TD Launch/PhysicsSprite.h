//
//  PhysicsSprite.h
//  TD Launch
//
//  Created by Kent Anderson on 8/7/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#include "ObjectiveChipmunk.h"

@interface PhysicsSprite : CCSprite
{
	ChipmunkBody *body_;	// strong ref
}

@property (readonly) ChipmunkBody*  body;

-(void) setPhysicsBody:(ChipmunkBody*)body;

@end