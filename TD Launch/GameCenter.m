//
//  GameCenter.m
//  TD Launch
//
//  Created by Kent Anderson on 1/1/14.
//
//

#import "GameCenter.h"
#import "AppDelegate.h"
#import "Screen.h"
#import "Settings.h"
#import "Achievements.h"

@implementation GameCenter

static GameCenter* _instance = nil;
+ (GameCenter*) sharedInstance
{
    if (_instance == nil)
        _instance = [[GameCenter alloc] init];
    return _instance;
}


- (id) init
{
    if (self = [super init])
    {
        _isAuthenticated = NO;
        _isAvailable = (NSClassFromString(@"GKLocalPlayer") != nil);
        _enabled = [Settings globalSettings].gameCenter;
        _noGameCenterWarningDisplayed = NO;
    }
    return self;
}


- (BOOL) enabled
{
    return _enabled && ([Achievements sharedAchievements].isTampered == NO);
}

- (void) setEnabled:(BOOL)enabled
{
    if ([Achievements sharedAchievements].isTampered)
        return;
    
    _enabled = enabled;
    if (_enabled)
    {
        [self authenticateLocalPlayer];
    }
}


- (void) authenticateLocalPlayer
{
    if ([Achievements sharedAchievements].isTampered)
        return;
    
    if (!_isAvailable || !_enabled)
        return;
    
    // If we're already authenticated, it must be because they are fiddling with the settings.
    // Go ahead and send the event, in case GameCenter doesn't call us back, below.
    if (_isAuthenticated)
        [[EventManager sharedManager] publish:GAMECENTER_AVAILABLE data:nil];
    
    _noGameCenterWarningDisplayed = NO;
    
    GKLocalPlayer* player = [GKLocalPlayer localPlayer];
    player.authenticateHandler = ^(UIViewController* viewController, NSError* error)
    {
        _isAvailable = YES;
        
        if (viewController != nil)
        {
            // Show the GameCenter UI
            GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
            if (gameCenterController != nil)
            {
                gameCenterController.gameCenterDelegate = self;
                [self showGameCenterUI:gameCenterController];
            }
            
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            _isAuthenticated = YES;            
            [[EventManager sharedManager] publish:GAMECENTER_AVAILABLE data:nil];
        }
        else
        {
            _isAvailable = NO;
            [[EventManager sharedManager] publish:GAMECENTER_UNAVAILABLE data:nil];
        }
    };
}


- (void) showGameCenterUI:(UIViewController*) viewController
{
    if (! _isAvailable || ! _enabled)
        return;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] presentViewController:viewController animated:YES completion:nil];
}


- (void) dismissGameCenterUI
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) showMessage:(NSString*)message title:(NSString*)title
{
    [GKNotificationBanner showBannerWithTitle:title message:message completionHandler:nil];
}


- (BOOL) eventOccurred:(NSString *)event data:(id)data
{
    if (event == APP_DEACTIVATED)
    {
        _isAvailable = NO;
        _isAuthenticated = NO;
    }
    return YES;
}


- (NSString*) getLeaderBoardID:(int)levelId
{
    return [NSString stringWithFormat:@"TDLaunch_Leaderboard_%d", levelId];
}


- (void) reportScore:(int64_t) score forLeaderBoardID:(int) levelId
{
    if ([Achievements sharedAchievements].isTampered)
        return;
    
    if (! _isAvailable || ! _enabled)
        return;
    
    if (! _isAuthenticated)
    {
        if (_noGameCenterWarningDisplayed == NO)
        {
            [self showMessage:NSLocalizedString(@"GameCenter_NoGameCenterMsg", @"GameCenter is unavailable. Your score could not be reported.") title:NSLocalizedString(@"GameCenter_LeaderboardTitle", @"GameCenter Leaderboards")];
            _noGameCenterWarningDisplayed = YES;
        }
        return;
    }
    
    NSString* leaderBoardID = [self getLeaderBoardID:levelId];
    
    GKScore* scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leaderBoardID];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:nil];
}


- (void) showLeaderBoard:(int)levelId
{
    //NSString* leaderBoardID = [self getLeaderBoardID:levelId];
    
    GKGameCenterViewController* viewController = [[GKGameCenterViewController alloc] init];
    viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    viewController.gameCenterDelegate = self;
    [self showGameCenterUI:viewController];
}


- (void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissGameCenterUI];
}

@end
