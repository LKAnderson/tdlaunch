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
#define DESCRIPTION_COLUMN      (0.275 * [[CCDirector sharedDirector] winSize].width)
#define PRICE_COLUMN            (0.80 * [[CCDirector sharedDirector] winSize].width)

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
                             Tool_Reducer,Tool_Doubler,Tool_Aligner,Tool_Launcher,Tool_GravityReverser,
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
                                             BB_HEIGHT(goBackButton) + BB_HEIGHT(goBackLabel));
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
    model.description = NSLocalizedString(@"AppStore_Slide_Description", @"Description");
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
    
    
    model = [[ProductModel alloc] init];
    model.title = @"Super Starter Pack";
    model.description = @"TOOLS:ddD  bbB  ppss  X";
    model.icon = [CCSprite spriteWithSpriteFrameName:@"ToolBundle.png"];
    model.icon.scale = 0.65;
    [products setObject:model forKey:Product_SuperStartPack];
    
    model = [[ProductModel alloc] init];
    model.title = @"Power Pack";
    model.description = @"TOOLS:ddd  DDD  bbb  BBB\nppp  sss  A a g X";
    model.icon = [CCSprite spriteWithSpriteFrameName:@"ToolBundle.png"];
    model.icon.scale = 0.65;
    [products setObject:model forKey:Product_PowerPack];
    
    model = [[ProductModel alloc] init];
    model.title = @"Developer's Pack";
    model.description = @"TOOLS:ddddd  DDDDD  bbbbb\nBBBBB  ppppp  sssss\nAAA aaa gg XX L";
    model.icon = [CCSprite spriteWithSpriteFrameName:@"ToolBundle.png"];
    model.icon.scale = 0.65;
    [products setObject:model forKey:Product_DevPack];
    
    _productInfo = products;
    
    [self loadProductTable];
    
    // Build the set of product ids and send it off to StoreKit.
    NSSet* productIds = [NSSet setWithObjects:Product_SuperStartPack, Product_PowerPack, Product_DevPack, nil];
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    request.delegate = self;
    [request start];
    
    
    
}


- (SKProduct*) findProductById:(NSString*) productId
{
    for (SKProduct* product in APPCONTROLLER.inAppProducts)
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
    // First, build the product listing table so we know how big to make the scrollview.
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    NSMutableArray* productTable = [NSMutableArray array];
    float tableHeight = 0;
    float tableSpacing = SCRNY(165);
    
    for (NSString* toolId in _toolNamesInOrder)
    {
       
        [productTable addObject:[_productInfo objectForKey:toolId]];
        tableHeight += tableSpacing;
        

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

        NSString* descFont = @"TDFontYellow96.fnt";
        float descScale = 0.5;
        BOOL isPurchasable = NO;
        if ([product.description hasPrefix:@"TOOLS:"])
        {
            isPurchasable = YES;
            descFont = @"ToolFont.fnt";
            descScale = 1.0;
            product.description = [product.description substringFromIndex:6];
        }
        
        CCLabelBMFont* description = [CCLabelBMFont labelWithString:product.description fntFile:descFont];
        description.scale = descScale;

        
        CCNode* titleBox = [CCNode node];
        titleBox.contentSize = CGSizeMake(MAX(title.contentSize.width * title.scale, description.contentSize.width * description.scale),
                                          (title.contentSize.height * title.scale) + (description.contentSize.height * description.scale) + SCRNY(10));
        description.anchorPoint = ccp(0, 0);
        description.position = ccp(0, 0);
        [titleBox addChild:description];
        
        title.anchorPoint = ccp(0,0);
        title.position = ccp(0, BB_TOP(description)+SCRNY(10));
        [titleBox addChild:title];
        
        titleBox.anchorPoint = ccp(0, 0.5);
        titleBox.position = ccp(DESCRIPTION_COLUMN, y);
        [tableView addChild:titleBox];
        
        CCLabelBMFont* price = [CCLabelBMFont labelWithString:@"" fntFile:@"TDFontYellow96.fnt"];
        price.scale = 0.8;
        price.anchorPoint = ccp(0.5, 0.4);
        price.position = ccp(PRICE_COLUMN, y);
        [tableView addChild:price z:100];
        
        if (isPurchasable)
        {
            product.priceLabel = price;
            product.priceBackground = [CCSprite spriteWithSpriteFrameName:@"AppStoreBuy.png"];
            product.priceBackground.scale = 0.8;
            product.priceBackground.anchorPoint = ccp(0.5, 0.5);
            product.priceBackground.position = price.position;
            product.priceBackground.visible = NO;
            [tableView addChild:product.priceBackground z:99];
        }
        
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
    APPCONTROLLER.inAppProducts = response.products;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (SKProduct* product in APPCONTROLLER.inAppProducts)
    {
        ProductModel* model = [_productInfo objectForKey:product.productIdentifier];
        if (model == nil)
            continue;
        
        if (model.priceLabel != nil)
        {
            if ([[Achievements sharedAchievements].purchasedProducts containsObject:product.productIdentifier])
            {
                model.priceLabel.string = @"Loaded";
                model.priceLabel.scale = 0.8;
            }
            else
            {
                [numberFormatter setLocale:product.priceLocale];
                model.priceLabel.string = [numberFormatter stringFromNumber:product.price];
                
                model.priceLabel.isTouchEnabled = YES;
                [model.priceLabel addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
                    AUDIOTIC1;
                    SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product];
                    payment.quantity = 1;
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                }]];
            }
            model.priceBackground.visible = YES;
        }
    }
    
    

}





@end
