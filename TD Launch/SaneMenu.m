//
//  VerticalMenu.m
//  TD Launch
//
//  Created by Kent Anderson on 9/5/12.
//
//

#import "SaneMenu.h"

@implementation SaneMenu


- (id) init
{
    if (self = [super init])
    {
        self.ignoreAnchorPointForPosition = NO;
    }
    
    return self;
}


- (CGSize) calculateSizeForVertical:(float)vpad hpad:(float)hpad
{
    CGSize size = CGSizeMake(0,vpad);
    for (CCNode* child in self.children)
    {
        float width = child.boundingBox.size.width + (2*hpad);
        if (width > size.width)
            size.width = width;
        size.height += child.boundingBox.size.height;
        size.height += vpad;
    }

    return size;
}


- (CGSize) calculateSizeForHorizontal:(float)vpad hpad:(float)hpad
{
    CGSize size = CGSizeMake(hpad,0);
    for (CCNode* child in self.children)
    {
        float height = child.boundingBox.size.height + (2*vpad);
        if (height > size.height)
            size.height = height;
        size.width += child.boundingBox.size.width + hpad;
    }
    
    return size;
}


- (void) alignItemsVertically
{
    [self alignItemsVerticallyWithPadding:0];
}

- (void) alignItemsVerticallyWithPadding:(float)vpadding
{
    float x;
    float y = vpadding;
    
    // start at the bottom and work our way up.
    for (int i=self.children.count-1; i >= 0; i--)
    {
        CCNode* child = [self.children objectAtIndex:i];
        child.anchorPoint = ccp(0.5,0);
        
        x = self.contentSize.width / 2;
        child.position = ccp(x,y);
        y += child.boundingBox.size.height;
        y += vpadding;
    }
    
}


- (void) alignItemsHorizontally
{
    [self alignItemsVerticallyWithPadding:0];
}

- (void) alignItemsHorizontallyWithPadding:(float)hpadding
{
    float x = 0;
    float y = self.contentSize.height/2;
    
    // start at the bottom and work our way up.
    for (int i=0; i < self.children.count; i++)
    {
        CCNode* child = [self.children objectAtIndex:i];
        child.anchorPoint = ccp(0.5,0.5);
        x += child.contentSize.width / 2;
        child.position = ccp(x,y);
        x += (child.contentSize.width / 2) + hpadding;
    }
}



- (void) draw
{
    if (_debug)
    {
        ccDrawSolidRect(ccp(0,0), ccp(self.contentSize.width,self.contentSize.height), ccc4f(1.0, 1.0, 1.0, 0.3));
    }
    
    [super draw];
    
    if (_debug)
    {
        ccDrawColor4F(0,1,0,1);
        ccDrawRect(ccp(0,0), ccp(self.contentSize.width,self.contentSize.height));
        
        for (CCNode* child in self.children)
        {
            ccDrawRect(child.boundingBox.origin, ccp(child.boundingBox.origin.x + child.boundingBox.size.width,
                                                     child.boundingBox.origin.y + child.boundingBox.size.height));
        }
    }
}

@end
