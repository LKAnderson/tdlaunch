//
//  GameCenter.h
//  TD Launch
//
//  Created by Kent Anderson on 1/1/14.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "EventManager.h"

@interface GameCenter : NSObject <GKGameCenterControllerDelegate, EventListener>
{
    BOOL _enabled;
    BOOL _noGameCenterWarningDisplayed;
}

@property BOOL enabled;
@property (readonly) BOOL isAvailable;
@property (readonly) BOOL isAuthenticated;

+ (GameCenter*) sharedInstance;

- (void) setEnabled:(BOOL)enabled;
- (void) authenticateLocalPlayer;
- (void) showMessage:(NSString*)message title:(NSString*)title;
- (void) showLeaderBoard:(int)leaderBoardID;
- (void) reportScore:(int64_t) score forLeaderBoardID:(int) levelId;

@end
