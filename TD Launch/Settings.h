//
//  Settings.h
//  TD Launch
//
//  Created by Kent Anderson on 9/16/13.
//
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject <NSCoding>

@property BOOL sound;
@property BOOL gameCenter;
@property BOOL showCharacterTutorial;
@property BOOL showObjectTutorial;
@property BOOL showDrawerTutorial;
@property BOOL showRotateTutorial;
@property (readonly) BOOL showTutorial;

+ (Settings*) globalSettings;
- (void) save;
@end

