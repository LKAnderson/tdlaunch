//
//  AppDelegate.h
//  TD Launch
//
//  Created by Kent Anderson on 8/7/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "cocos2d.h"


#define APPCONTROLLER ((AppController*)[[UIApplication sharedApplication] delegate])


@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate, ADBannerViewDelegate >
{
	UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (readonly) ADBannerView* iAdView;

- (void) setAdsEnabled:(BOOL)enabled;

@end
