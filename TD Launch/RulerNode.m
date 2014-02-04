//
//  RulerNode.m
//  TD Launch
//
//  Created by Kent Anderson on 8/25/12.
//
//

#import "RulerNode.h"

@implementation RulerNode


- (id) init
{
    if (self = [super init])
    {
        _fontSize = CGSizeMake(7, 10);
        _majorTicks = 100;
        _fgColor = ccc4f(1.0, 1.0, 1.0, 1.0);
        _bgColor = ccc4f(0, 0, 0, 0);
    }
    return self;
}


- (void) drawDigit:(int) digit at:(CGPoint) point
{
    int left = point.x;
    int bottom = point.y;
    int top = point.y + _fontSize.height;
    int right = point.x + _fontSize.width;
    int hHalf = point.x + (right-left)/2;
    int vHalf = point.y + (top-bottom)/2;
    //int vQtr = bottom + vHalf/2;
    
    switch(digit)
    {
        case 0:
            ccDrawRect(ccp(left,bottom), ccp(right,top));
            ccDrawLine(ccp(left,bottom), ccp(right,top));
            break;
            
        case 1:
            ccDrawLine(ccp(hHalf, bottom), ccp(hHalf, top));
            break;
            
        case 2:
            ccDrawLine(ccp(left,top), ccp(right,top));
            ccDrawLine(ccp(right,top), ccp(left,bottom));
            ccDrawLine(ccp(left,bottom), ccp(right,bottom));
            break;
            
        case 3:
            ccDrawLine(ccp(left,top), ccp(right,top));
            ccDrawLine(ccp(right,top), ccp(hHalf, vHalf));
            ccDrawLine(ccp(hHalf,vHalf), ccp(right, bottom));
            ccDrawLine(ccp(right,bottom), ccp(left,bottom));
            break;
            
        case 4:
            ccDrawLine(ccp(right,vHalf), ccp(left,vHalf));
            ccDrawLine(ccp(left,vHalf), ccp(right,top));
            ccDrawLine(ccp(right,top), ccp(right,bottom));
            break;
            
        case 5:
            ccDrawLine(ccp(left,bottom), ccp(right,bottom));
            ccDrawLine(ccp(right,bottom), ccp(right, vHalf));
            ccDrawLine(ccp(right,vHalf), ccp(left, vHalf));
            ccDrawLine(ccp(left,vHalf), ccp(left, top));
            ccDrawLine(ccp(left, top), ccp(right, top));
            break;
            
        case 6:
            ccDrawLine(ccp(left, vHalf), ccp(right, vHalf));
            ccDrawLine(ccp(right,vHalf), ccp(right,bottom));
            ccDrawLine(ccp(right,bottom), ccp(left,bottom));
            ccDrawLine(ccp(left,bottom), ccp(left,top));
            ccDrawLine(ccp(left,top), ccp(right,top));
            break;
            
        case 7:
            ccDrawLine(ccp(left,top), ccp(right,top));
            ccDrawLine(ccp(right,top), ccp(hHalf,bottom));
            break;
            
        case 8:
            ccDrawRect(ccp(left,bottom), ccp(right,top));
            ccDrawLine(ccp(left,vHalf), ccp(right,vHalf));
            break;
            
        case 9:
            ccDrawLine(ccp(right,vHalf), ccp(left,vHalf));
            ccDrawLine(ccp(left,vHalf), ccp(left,top));
            ccDrawLine(ccp(left,top), ccp(right,top));
            ccDrawLine(ccp(right,top), ccp(right,bottom));
            break;
    }
    

}

- (void) drawNumber:(int) number at:(CGPoint)point
{
    // We have to work backward from the left :( numbers are so inconvenient!
    int tensPlace = 1;
    while (pow(10, tensPlace) <= number)
        tensPlace++;
    
    tensPlace--;
    
    int x = 0;
    while (tensPlace >= 0)
    {
        int digit = ((int)(number / pow(10, tensPlace))) % 10;
        [self drawDigit:digit at:ccp(point.x + x, point.y)];
        x += _fontSize.width + 2;
        tensPlace--;
    }
}


- (void) draw
{
    [super draw];
    glLineWidth(1.0);
    ccDrawSolidRect(ccp(0,0), ccp(self.contentSize.width, self.contentSize.height), _bgColor);
    
    ccDrawColor4F(_fgColor.r, _fgColor.g, _fgColor.b, _fgColor.a);

    ccDrawRect(ccp(0,0), ccp(self.contentSize.width,self.contentSize.height));
    ccDrawRect(ccp(1,1), ccp(self.contentSize.width-1, self.contentSize.height-1));
    
    for (int x=_majorTicks; x < self.contentSize.width; x += _majorTicks)
        ccDrawLine( ccp(x, 0), ccp(x, self.contentSize.height));
        
    for (int y=_majorTicks; y < self.contentSize.height; y += _majorTicks)
        ccDrawLine( ccp(0, y), ccp(self.contentSize.width, y));
    
    for (int x=_majorTicks; x < self.contentSize.width; x += _majorTicks)
    {
        [self drawNumber:x at:ccp(x+5, 5)];
        [self drawNumber:x at:ccp(x+5, self.contentSize.height/2 - _fontSize.height - 5)];
        [self drawNumber:x at:ccp(x+5, self.contentSize.height - _fontSize.height - 5)];
    }
    
    for (int y=_majorTicks; y < self.contentSize.height; y += _majorTicks)
    {
        [self drawNumber:y at:ccp(5, y+5)];
        [self drawNumber:y at:ccp(self.contentSize.width/2 + 5, y+5)];
        [self drawNumber:y at:ccp(self.contentSize.width - _fontSize.width + 5, y+5)];
    }
}

@end
