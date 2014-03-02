//
//  LevelMenu.m
//  TD Launch
//
//  Created by Kent Anderson on 8/22/12.
//
//

#import "AppStore.h"
#import "Screen.h"

#import "GestureRecognizerWithBlock.h"

#import "Settings.h"
#import "AppSettingsDialog.h"
#import "Achievements.h"
#import "LevelMenu.h"
#import "ScrollView.h"
#import "Achievements.h"

#import <SimpleAudioEngine.h>

#import "AppDelegate.h"
#import "ProductIds.h"



#define ICON_COLUMN             (0.15 * [[CCDirector sharedDirector] winSize].width)
#define DESCRIPTION_COLUMN      (0.25 * [[CCDirector sharedDirector] winSize].width)
#define PRICE_COLUMN            (0.90 * [[CCDirector sharedDirector] winSize].width)

@implementation ProductModel
@end


@implementation AppStore

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	AppStore *layer = [AppStore node];
	[scene addChild: layer];
	return scene;
}


- (id) init
{
    if (self = [super init])
    {
        _productNamesInOrder = [NSArray arrayWithObjects:Product_SuperStartPack, Product_PowerPack, Product_DevPack, nil];
        
        NSMutableDictionary* products = [NSMutableDictionary dictionary];

        
        [products setValue:@"LBL:Bundle" forKey:Product_SuperStartPack];
        [products setValue:@"LBL:Bundle" forKey:Product_PowerPack];
        [products setValue:@"LBL:Bundle" forKey:Product_DevPack];
        
        _productInfo = products;
    }
    return self;
}


- (void) onExit
{
    [super onExit];
}



- (void) onEnter
{
    [super onEnter];
    self.isTouchEnabled = YES;
    
    APPCONTROLLER.adsEnabled = NO;
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    CCSprite* background = [CCSprite spriteWithFile:@"AppStore.png"];
    background.anchorPoint = ccp(0.5,0.5);
    background.position = ccp(screen.width/2, screen.height/2);
    [self addChild:background];
    
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tools.plist"] == nil )
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tools.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Menu.plist"];
    }
    
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Tools.png"]];
    [self addChild:[CCSpriteBatchNode batchNodeWithFile:@"Menu.png"]];
    
    CCSprite* goBackButton = [CCSprite spriteWithSpriteFrameName:@"TutorialArrow.png"];
    goBackButton.scale = 0.45;
    goBackButton.rotation = -90.0;
    
    CCLabelBMFont* goBackLabel = [CCLabelBMFont labelWithString:@"Go Back" fntFile:@"TDFontYellow96.fnt"];
    goBackLabel.scale = 0.45;
    
    
    CCNode* goBackContainer = [CCNode node];
    goBackContainer.contentSize = CGSizeMake(MAX(BB_WIDTH(goBackButton), BB_WIDTH(goBackLabel)),
                                             BB_HEIGHT(goBackButton) + BB_HEIGHT(goBackLabel) - SCRNY(20));
    goBackContainer.anchorPoint = ccp(0.5, 0.5);
    goBackContainer.position = ccp(ICON_COLUMN/3, SCRNY(55));
    
    goBackButton.anchorPoint = ccp(0, 1);
    goBackButton.position = ccp((goBackContainer.contentSize.width - BB_WIDTH(goBackButton))/2,
                                goBackContainer.contentSize.height);
    [goBackContainer addChild:goBackButton];
    
    goBackLabel.anchorPoint = ccp(0, 0);
    goBackLabel.position = ccp((goBackContainer.contentSize.width - BB_WIDTH(goBackLabel))/2, 0);
    [goBackContainer addChild:goBackLabel];
    
    [self addChild:goBackContainer z:3];
    
    goBackContainer.isTouchEnabled = YES;

    [goBackContainer addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
        [[CCDirector sharedDirector] replaceScene:[LevelMenu scene]];
    }]];

    
    _loadingLabel = [CCLabelBMFont labelWithString:@"Loading..." fntFile:@"TDFontYellow96.fnt"];
    _loadingLabel.anchorPoint = ccp(0.5,0.5);
    _loadingLabel.position = ccp(screen.width/2, screen.height/2);
    [self addChild:_loadingLabel];
    
    // Build the set of product ids and send it off to StoreKit.
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[_productInfo allKeys]]];
    request.delegate = self;
    [request start];
    
    
    
}


- (SKProduct*) findProductById:(NSString*) productId
{
    for (SKProduct* product in _storeKitProducts)
    {
        if ([product.productIdentifier isEqualToString:productId])
        {
            return product;
        }
    }
    return nil;
}


- (void) loadProductTable
{
    CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
        [self removeChild:_loadingLabel cleanup:NO];
        [self unscheduleUpdate];
    }];
    
    [_loadingLabel runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:0.25] two:cleanup]];
    [self scheduleUpdate];
    
    
    
    // First, build the product listing table so we know how big to make the scrollview.
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    NSMutableArray* productTable = [NSMutableArray array];
    float tableHeight = 0;
    float tableSpacing = SCRNY(165);
    
    for (NSString* productId in _productNamesInOrder)
    {
//        if ([productId isEqualToString:Product_Launcher] && [Achievements sharedAchievements].launcher > 0)
//            continue;
        
        SKProduct* product = [self findProductById:productId];
        if (product == nil)
            continue;
        
        CCNode* toolSprite;
        NSString* spriteName = [_productInfo valueForKey:product.productIdentifier];
        if ([spriteName hasPrefix:@"LBL:"])
        {
            CCLabelBMFont* label = [CCLabelBMFont labelWithString:[spriteName substringFromIndex:4]  fntFile:@"TDFont120.fnt"];
            label.alignment = kCCTextAlignmentCenter;
            label.scale = 0.5;
            toolSprite = label;
            
            //if ([productId isEqualToString:Product_RemoveAds] && [[Achievements sharedAchievements] hasProduct:Product_RemoveAds])
            //    label.opacity = 128;
        }
        else
        {
            toolSprite = [CCSprite spriteWithSpriteFrameName:spriteName];
            //f ([productId isEqualToString:Product_Launcher] && [[Achievements sharedAchievements] hasProduct:Product_Launcher])
            //    ((CCSprite*)toolSprite).opacity = 128;
        }
        
        if ([spriteName isEqual:@"Slide.png"] || [spriteName isEqual:@"Plank.png"] || [spriteName isEqual:@"Drum.png"]
            || [spriteName isEqual:@"Drum2x.png"] || [spriteName isEqual:@"Blower.png"] || [spriteName isEqual:@"Blower2x.png"])
        {
            toolSprite.rotation = -45.0;
        }
        
        
        tableHeight += tableSpacing;
        
        ProductModel* model = [[ProductModel alloc] init];
        model.icon = toolSprite;
        model.title = product.localizedTitle;
        model.description = product.localizedDescription;
        model.product = product;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        model.price = [numberFormatter stringFromNumber:product.price];
        
        [productTable addObject:model];
    }
    
    CCNode* tableView = [CCNode node];
    tableView.contentSize = CGSizeMake(screen.width, tableHeight);
    
    
    float y = tableHeight - (tableSpacing/2);
    
    for (int i=0; i < productTable.count; i++)
    {
        ProductModel* product = [productTable objectAtIndex:i];
        product.icon.anchorPoint = ccp(0.5, 0.5);
        product.icon.position = ccp(ICON_COLUMN, y);
        [tableView addChild:product.icon];
        
        
        
        CCLabelBMFont* title = [CCLabelBMFont labelWithString:product.title fntFile:@"TDFont120.fnt"];
        title.scale = 0.5;
        CCLabelBMFont* description = [CCLabelBMFont labelWithString:product.description fntFile:@"TDFontYellow96.fnt"];
        description.scale = 0.5;
        
        CCNode* titleBox = [CCNode node];
        titleBox.contentSize = CGSizeMake(MAX(title.contentSize.width * title.scale, description.contentSize.width * description.scale),
                                          (title.contentSize.height * title.scale) + (description.contentSize.height * description.scale));
        description.anchorPoint = ccp(0, 0);
        description.position = ccp(0, 0);
        [titleBox addChild:description];
        
        title.anchorPoint = ccp(0,0);
        title.position = ccp(0, BB_TOP(description));
        [titleBox addChild:title];
        
        titleBox.anchorPoint = ccp(0, 0.5);
        titleBox.position = ccp(DESCRIPTION_COLUMN, y);
        [tableView addChild:titleBox];
        
        
        CCLabelBMFont* price = [CCLabelBMFont labelWithString:product.price fntFile:@"TDFontYellow96.fnt"];
        price.scale = 0.7;
        price.anchorPoint = ccp(0.5, 0.5);
        price.position = ccp(PRICE_COLUMN, y);
        [tableView addChild:price];
        price.isTouchEnabled = YES;
        [price addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
            AUDIOTIC1;
            SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product.product];
            payment.quantity = 1;
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }]];
        
        y -= tableSpacing;
    }
    
    ScrollView* scrollView = [ScrollView viewWithContent:tableView];
    scrollView.contentSize = CGSizeMake(screen.width, screen.height);
    scrollView.anchorPoint = ccp(0.5, 0);
    scrollView.position = ccp(screen.width/2, 0);
    [self addChild:scrollView z:2];
    
    scrollView.clipContents = YES;
    scrollView.content.position = ccp(scrollView.content.position.x, scrollView.contentSize.height - scrollView.content.contentSize.height);
}

- (BOOL) eventOccurred:(NSString*)event data:(id)data
{
    return YES;
}


-(void) update:(ccTime) delta
{
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _storeKitProducts = response.products;
    [self loadProductTable];
}





@end
