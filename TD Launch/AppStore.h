//
//  AppStore.h
//  TD Launch
//
//  Created by Kent Anderson on 2/24/14.
//
//

#import "cocos2d.h"
#import "EventManager.h"

@interface AppStore : CCLayer <EventListener>
{

}

+ (CCScene*) scene;
@end


@interface ProductModel : NSObject
@property CCNode* icon;
@property NSString* title;
@property NSString* description;
@property NSString* price;
@end
