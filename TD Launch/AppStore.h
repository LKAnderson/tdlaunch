//
//  AppStore.h
//  TD Launch
//
//  Created by Kent Anderson on 2/24/14.
//
//

#import "cocos2d.h"
#import "EventManager.h"
#import <StoreKit/StoreKit.h>


@interface AppStore : CCLayer <EventListener, SKProductsRequestDelegate>
{
    NSDictionary* _productInfo;
    
    NSArray* _toolNamesInOrder;
    NSArray* _productNamesInOrder;
    
    CCLabelBMFont* _loadingLabel;
}

+ (CCScene*) scene;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;

@end


@interface ProductModel : NSObject
@property CCNode* icon;
@property NSString* title;
@property NSString* description;
@property NSString* price;
@property CCLabelBMFont* priceLabel;
@property CCSprite* priceBackground;
@property SKProduct* product;
@end
