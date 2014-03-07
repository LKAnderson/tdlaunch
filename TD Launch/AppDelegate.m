//
//  AppDelegate.mm
//  TD Launch
//
//  Created by Kent Anderson on 8/7/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "Screen.h"
#import "Settings.h"
#import "EventManager.h"
#import "GameCenter.h"
#import "Achievements.h"

#import <SimpleAudioEngine.h>
#import <AVFoundation/AVFoundation.h>


unsigned int getCurrentTime()
{
    struct timeval timeVal;
    gettimeofday(&timeVal, (void*)0);
    return (unsigned int)(((1000000*timeVal.tv_sec) + timeVal.tv_usec) / 1000);
}

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Seed random()
    srandom(getCurrentTime());
    
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Multiple Touches enabled
	[glView setMultipleTouchEnabled:YES];
   
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
    
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( [director_ enableRetinaDisplay:YES] )
    {
        isRetinaScreen = YES;
    }
    else
    {
        isRetinaScreen = NO;
		CCLOG(@"Retina Display Not supported");
    }
    
    // this is defined in Screen.h
    CGSize s = [director_ winSize];
    isSmallScreen = !(s.width >= 1024 || s.height >= 1024);
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-ipad"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 
	
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    [[GameCenter sharedInstance] authenticateLocalPlayer];
	
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Tic.mp3"];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
	// make main window visible
	[window_ makeKeyAndVisible];
    
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];

    [[EventManager sharedManager] publish:APP_DEACTIVATED data:nil];

}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
    
    [[EventManager sharedManager] publish:APP_ACTIVATED data:nil];
    
    if ([Achievements sharedAchievements].purchasedProducts.count == 0)
    {
        // This must be a fresh install, so ask the App Store what they've purchased.
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
    [[Settings globalSettings] save];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


// ADBannerViewDelegate Methods


- (void) setAdsEnabled:(BOOL)enabled
{
#ifndef DEBUG
    if ([Achievements sharedAchievements].purchasedProducts.count > 0)
    {
        _adsEnabled = NO;
        return;
    }
#endif
    
    _adsEnabled = enabled;
    if (_adsEnabled == YES)
    {
        if (_iAdView == nil)
        {
            _iAdView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            _iAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _iAdView.delegate = self;
            _iAdView.hidden = YES;
            CGRect bannerFrame = _iAdView.frame;
            bannerFrame.size = [_iAdView sizeThatFits:director_.view.frame.size];
            _iAdView.frame = CGRectOffset(bannerFrame, 0, -_iAdView.frame.size.height);
            [director_.view addSubview:_iAdView];
        }
    }
    else
    {
        [self hideAdBanner];
    }
}




- (void) showAdBanner
{
    if (_adsEnabled && _iAdView.hidden == YES)
    {
        _iAdView.hidden = NO;
        
        [UIView animateWithDuration:0.5
         
                         animations:^(void){
                             _iAdView.frame = CGRectOffset(_iAdView.frame, 0, _iAdView.frame.size.height * (isSmallScreen ? 1.5 : 1));
                         }
         
                         completion:^(BOOL finished){
                             [[EventManager sharedManager] publish:ADBANNER_VISIBLE data:_iAdView];
                         }];
    }
}

- (void) hideAdBanner
{
    if (_iAdView != nil && _iAdView.hidden == NO)
    {
        [[EventManager sharedManager] publish:ADBANNER_HIDDEN data:_iAdView];
        
        [UIView animateWithDuration:0.5
         
                         animations:^(void){
                             _iAdView.frame = CGRectOffset(_iAdView.frame, 0, -_iAdView.frame.size.height * (isSmallScreen ? 1.5 : 1));
                         }
         
                         completion:^(BOOL finished){
                             _iAdView.hidden = YES;
                             if (_adsEnabled == NO)
                             {
                                 [_iAdView removeFromSuperview];
                                 _iAdView = nil;
                             }
                         }];
    }
}


- (void) bannerViewWillLoadAd:(ADBannerView *)banner
{
}

- (void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self showAdBanner];
}

- (void) bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self hideAdBanner];
}


// SKPaymentTransactionObserver methods

- (SKProduct*) findInAppProduct:(NSString*)productIdentifier
{
    for (SKProduct* product in _inAppProducts)
    {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            return product;
        }
    }
    return nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* txn in transactions)
    {
        switch (txn.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [[Achievements sharedAchievements] addPurchasedProduct:txn.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:txn];
                
                // TODO: Localize me
                SKProduct* product = [self findInAppProduct:txn.payment.productIdentifier];
                if (product != nil)
                {
                    NSString* msg = [NSString stringWithFormat:@"%@ has been added to your game.", product.localizedTitle];
                    [[[UIAlertView alloc] initWithTitle:@"Purchase Complete" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
                break;
                
            }
                
            case SKPaymentTransactionStateRestored:
            {
                SKPaymentTransaction* origTxn = txn.originalTransaction;
                [[Achievements sharedAchievements] addPurchasedProduct:origTxn.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:txn];
                break;
            }
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"TXN Failed: %@", txn.error);
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
}


@end
