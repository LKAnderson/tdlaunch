//
//  ColoredNode.m
//  TD Launch
//
//  Created by Kent Anderson on 8/23/12.
//
//

#import "ColoredNode.h"

@implementation ColoredNode


- (void) onEnter
{
    [self resizeTo:self.contentSize];
}


- (void) resizeTo:(CGSize)size
{
    self.contentSize = size;
    [self setTexture:[self createColorTexture:_fillColor size:size]];
    [self setTextureRect:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
}


- (CCTexture2D*) createColorTexture:(ccColor3B) color size:(CGSize)size
{
    GLubyte buffer[4];
    buffer[0] = color.r;
    buffer[1] = color.g;
    buffer[2] = color.b;
    buffer[3] = 0xff;
    
    CCTexture2D* texture = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:1 pixelsHigh:1 contentSize:size];
    return texture;
}

- (void) onExit
{
    [super onExit];
    [self setTexture:nil];
}

@end
