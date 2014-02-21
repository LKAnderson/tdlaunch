//
//  EventManager.h
//  TD Launch
//
//  Created by Kent Anderson on 9/26/13.
//
//

#import <Foundation/Foundation.h>


extern NSString* APP_ACTIVATED;
extern NSString* APP_DEACTIVATED;
extern NSString* GAMECENTER_AVAILABLE;
extern NSString* GAMECENTER_UNAVAILABLE;
extern NSString* ADBANNER_VISIBLE;
extern NSString* ADBANNER_HIDDEN;


@protocol EventListener <NSObject>

// Handle events from the event manager
// Return NO if the event should not be forwarded to any other listeners
- (BOOL) eventOccurred:(NSString*)event data:(id)data;

@end






@interface EventManager : NSObject
{
    NSMutableDictionary* listeners_;
}

// Singleton
+ (EventManager*) sharedManager;


- (void) subscribe:(NSString*) event listener:(id<EventListener>)listener;
- (void) unsubscribe:(NSString*) event listener:(id<EventListener>)listener;

- (void) publish:(NSString*)event data:(id)data;

@end
