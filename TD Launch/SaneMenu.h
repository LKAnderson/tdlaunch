//
//  VerticalMenu.h
//  TD Launch
//
//  Created by Kent Anderson on 9/5/12.
//
//

#import "cocos2d.h"

@interface SaneMenu : CCMenu

@property bool debug;

- (CGSize) calculateSizeForVertical:(float)vpad hpad:(float)hpad;
- (CGSize) calculateSizeForHorizontal:(float)vpad hpad:(float)hpad;

@end
