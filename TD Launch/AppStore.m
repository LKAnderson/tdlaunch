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



#define ICON_COLUMN             (0.20 * [[CCDirector sharedDirector] winSize].width)
#define DESCRIPTION_COLUMN      (0.35 * [[CCDirector sharedDirector] winSize].width)
#define PRICE_COLUMN            (0.85 * [[CCDirector sharedDirector] winSize].width)

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
        _toolNamesInOrder = [NSArray arrayWithObjects:Tool_Plank,Tool_Slide,Tool_Drums,Tool_Blowers,
                             Tool_Reducer,Tool_Doubler,Tool_Aligner,Tool_Launcher,Tool_GravityReverser, nil];
        
        _productNamesInOrder = [NSArray arrayWithObjects:
                                Product_SuperStartPack, Product_PowerPack, Product_DevPack, nil];
        
//        [products setValue:@"LBL:Bundle" forKey:Product_SuperStartPack];
//        [products setValue:@"LBL:Bundle" forKey:Product_PowerPack];
//        [products setValue:@"LBL:Bundle" forKey:Product_DevPack];

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

    
    NSMutableDictionary* products = [NSMutableDictionary dictionary];
    
    
    ProductModel* model;
    CCSprite *sprite1, *sprite2;
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Plank_Title", @"Plank");
    model.description = NSLocalizedString(@"AppStore_Plank_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"Plank.png"];
    model.icon.rotation = -45.0;
    [products setObject:model forKey:Tool_Plank];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Slide_Title", "Slide");
    model.description = NSLocalizedString(@"Appstore_Slide_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"Slide.png"];
    model.icon.rotation = -45.0;
    [products setObject:model forKey:Tool_Slide];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Drums_Title", @"Drums");
    model.description = NSLocalizedString(@"AppStore_Drums_Description",  @"Description");
    sprite1 = [CCSprite spriteWithSpriteFrameName:@"Drum.png"];
    sprite1.rotation = -45.0;
    sprite1.anchorPoint = ccp(0,0);
    sprite1.position = ccp(0,0);
    sprite2 = [CCSprite spriteWithSpriteFrameName:@"Drum2x.png"];
    sprite2.rotation = -45.0;
    sprite2.anchorPoint = ccp(0,0);
    sprite2.position = ccp(BB_RIGHT(sprite1)*0.67, 0);
    model.icon = [CCNode node];
    model.icon.contentSize = CGSizeMake(BB_RIGHT(sprite2), BB_HEIGHT(sprite2));
    [model.icon addChild:sprite1];
    [model.icon addChild:sprite2];
    [products setObject:model forKey:Tool_Drums];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Blowers_Title", @"Air Blowers");
    model.description = NSLocalizedString(@"AppStore_Blowers_Description", @"Description");
    sprite1 = [CCSprite spriteWithSpriteFrameName:@"Blower.png"];
    sprite1.rotation = 45.0;
    sprite1.anchorPoint = ccp(0,0);
    sprite1.position = ccp(0,0);
    sprite2 = [CCSprite spriteWithSpriteFrameName:@"Blower2x.png"];
    sprite2.rotation = 45.0;
    sprite2.anchorPoint = ccp(0,0);
    sprite2.position = ccp(BB_RIGHT(sprite1)*0.45, 0);
    model.icon = [CCNode node];
    model.icon.contentSize = CGSizeMake(BB_RIGHT(sprite2), BB_HEIGHT(sprite2));
    [model.icon addChild:sprite1];
    [model.icon addChild:sprite2];
    [products setObject:model forKey:Tool_Blowers];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Reducer_Title", @"Force Reducer");
    model.description = NSLocalizedString(@"AppStore_Reducer_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"AcceleratorHalfX.png"];
    [products setObject:model forKey:Tool_Reducer];

    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Doubler_Title", "Force Doubler");
    model.description = NSLocalizedString(@"AppStore_Doubler_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"Accelerator2X.png"];
    [products setObject:model forKey:Tool_Doubler];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Aligner_Title", @"Aligner");
    model.description = NSLocalizedString(@"AppStore_Aligner_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"Aligner.png"];
    [products setObject:model forKey:Tool_Aligner];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_Launcher_Title", @"Launcher");
    model.description = NSLocalizedString(@"AppStore_Launcher_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"Launcher.png"];
    model.icon.rotation = 45.0;
    [products setObject:model forKey:Tool_Launcher];
    
    model = [[ProductModel alloc] init];
    model.title = NSLocalizedString(@"AppStore_GravityReverser_Title", @"Gravity Reverser");
    model.description = NSLocalizedString(@"AppStore_GravityReverser_Description", @"Description");
    model.icon = [CCSprite spriteWithSpriteFrameName:@"AntiGravity.png"];
    [products setObject:model forKey:Tool_GravityReverser];
    
    _productInfo = products;
    
    [self loadProductTable];
    
//    _loadingLabel = [CCLabelBMFont labelWithString:@"Loading..." fntFile:@"TDFontYellow96.fnt"];
//    _loadingLabel.anchorPoint = ccp(0.5,0.5);
//    _loadingLabel.position = ccp(screen.width/2, screen.height/2);
//    [self addChild:_loadingLabel];
    
    // Build the set of product ids and send it off to StoreKit.
//    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[_productInfo allKeys]]];
//    request.delegate = self;
//    [request start];
    
    
    
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
//    CCCallBlock* cleanup = [CCCallBlock actionWithBlock:^(void){
//        [self removeChild:_loadingLabel cleanup:NO];
//        [self unscheduleUpdate];
//    }];
//    
//    [_loadingLabel runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:0.25] two:cleanup]];
//    [self scheduleUpdate];
    
    
    
    // First, build the product listing table so we know how big to make the scrollview.
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    NSMutableArray* productTable = [NSMutableArray array];
    float tableHeight = 0;
    float tableSpacing = SCRNY(165);
    
    for (NSString* toolId in _toolNamesInOrder)
    {
       
        [productTable addObject:[_productInfo objectForKey:toolId]];
        tableHeight += tableSpacing;
        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [numberFormatter setLocale:product.priceLocale];
//        model.price = [numberFormatter stringFromNumber:product.price];
//        
//        [productTable addObject:model];
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
        
        
//        CCLabelBMFont* price = [CCLabelBMFont labelWithString:product.price fntFile:@"TDFontYellow96.fnt"];
//        price.scale = 0.7;
//        price.anchorPoint = ccp(0.5, 0.5);
//        price.position = ccp(PRICE_COLUMN, y);
//        [tableView addChild:price];
//        price.isTouchEnabled = YES;
//        [price addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
//            AUDIOTIC1;
//            SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product.product];
//            payment.quantity = 1;
//            [[SKPaymentQueue defaultQueue] addPayment:payment];
//        }]];
        
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
