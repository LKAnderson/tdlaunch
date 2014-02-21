//
//  EventManager.m
//  TD Launch
//
//  Created by Kent Anderson on 9/26/13.
//
//

#import "EventManager.h"


NSString* APP_ACTIVATED = @"app_activated";
NSString* APP_DEACTIVATED = @"app_deactivated";
NSString* GAMECENTER_AVAILABLE = @"gamecenter_available";
NSString* GAMECENTER_UNAVAILABLE = @"gamecenter_unavailable";
NSString* ADBANNER_VISIBLE = @"adbanner_visible";
NSString* ADBANNER_HIDDEN = @"adbanner_hidden";



static EventManager* sharedManager_;

@implementation EventManager


- (id) init
{
    if (self = [super init])
    {
        listeners_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}



+ (EventManager*) sharedManager
{
    // should probably use some sort of mutex here, just in case.
    if (sharedManager_ == nil)
        sharedManager_ = [[EventManager alloc] init];
    return sharedManager_;
}


- (void) subscribe:(NSString *)event listener:(id)listener
{
    NSMutableArray* listeners = [listeners_ valueForKey:event];
    if (listeners == nil)
    {
        listeners = [[NSMutableArray alloc] init];
        [listeners_ setObject:listeners forKey:event];
    }
    
    // Don't allow duplicates
    if (![listeners containsObject:listener])
        [listeners addObject:listener];
    
    return;
}


- (void) unsubscribe:(NSString *)event listener:(id)listener
{
    NSMutableArray* listeners = [listeners_ valueForKey:event];
    if (listeners != nil)
    {
        [listeners removeObject:listener];
    }
}



- (void) publish:(NSString *)event data:(id)data
{
    NSMutableArray* listeners = [listeners_ valueForKey:event];
    if (listeners != nil)
    {
        for (id<EventListener> listener in listeners)
        {
            if (! [listener eventOccurred:event data:data])
                break;
        }
    }
    
    return;
}

@end
