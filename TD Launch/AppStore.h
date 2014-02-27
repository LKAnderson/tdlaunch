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
    NSArray* _storeKitProducts;
    NSDictionary* _productInfo;
    NSArray* _productNamesInOrder;
}

+ (CCScene*) scene;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;

@end


@interface ProductModel : NSObject
@property CCNode* icon;
@property NSString* title;
@property NSString* description;
@property NSString* price;
@property SKProduct* product;
@end
