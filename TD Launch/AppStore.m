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

#import <SimpleAudioEngine.h>

#import "AppDelegate.h"


typedef struct
{
    char* productId;
    char* spriteName;
}
StoreProduct;

StoreProduct products[] = {

    { "com.kornerstoane.tdlaunch.RemoveAds",    "LBL:Remove Ads" },
    
    { "com.kornerstoane.tdlaunch.Planks",       "Plank.png" },
    { "com.kornerstoane.tdlaunch.Slides",       "Slide.png" },
    { "com.kornerstoane.tdlaunch.Drums",        "Drum.png" },
    { "com.kornerstoane.tdlaunch.Drum2x",       "Drum2x.png" },
    
    { "com.kornerstoane.tdlaunch.Blowers",      "Blower.png" },
    { "com.kornerstoane.tdlaunch.Blower2x",     "Blower2x.png" },
    
    { "com.kornerstoane.tdlaunch.Straightener", "Aligner.png" },
    { "com.kornerstoane.tdlaunch.Reducer",      "AcceleratorHalfX.png" },
    { "com.kornerstoane.tdlaunch.Doubler",      "Accelerator2X.png" },

    { "com.kornerstoane.tdlaunch.Launcher",     "Launcher.png" },
    { "com.kornerstoane.tdlaunch.GravityReverser", "AntiGravity.png" },
    
    { NULL, NULL }
};


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
    
    float iconColumn = screen.width * 0.15;
    float descriptionColumn = screen.width * 0.25;
    float priceColumn = screen.width * 0.90;
    
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
    goBackButton.anchorPoint = ccp(0.5, 0.5);
    goBackButton.position = ccp(iconColumn/3, SCRNY(70));
    
    
    CCLabelBMFont* goBackLabel = [CCLabelBMFont labelWithString:@"Go Back" fntFile:@"TDFontYellow96.fnt"];
    goBackLabel.scale = 0.45;
    goBackLabel.anchorPoint = ccp(0.5, 1.0);
    goBackLabel.position = ccp(goBackButton.position.x, BB_BOTTOM(goBackButton.boundingBox) - SCRNY(10));
    
    
    
    goBackButton.isTouchEnabled = YES;
    goBackLabel.isTouchEnabled = YES;

    [goBackButton addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
        [[CCDirector sharedDirector] replaceScene:[LevelMenu scene]];
    }]];
    
    [goBackLabel addGestureRecognizer:[GestureRecognizerWithBlock recognizer:[[UITapGestureRecognizer alloc] init] block:^(UIGestureRecognizer* r, CCNode* item) {
        [[CCDirector sharedDirector] replaceScene:[LevelMenu scene]];
    }]];

    
    // First, build the product listing table so we know how big to make the scrollview.
    
    NSMutableArray* productTable = [NSMutableArray array];
    float tableHeight = 0;
    float tableSpacing = SCRNY(165);
    
    for (int i=0; products[i].productId != NULL; i++)
    {
        CCNode* toolSprite;
        NSString* spriteName = [[NSString alloc] initWithCString:products[i].spriteName encoding:NSUTF8StringEncoding];
        if ([spriteName hasPrefix:@"LBL:"])
        {
            CCLabelBMFont* label = [CCLabelBMFont labelWithString:[spriteName substringFromIndex:4]  fntFile:@"TDFont120.fnt"];
            label.alignment = kCCTextAlignmentCenter;
            label.scale = 0.5;
            toolSprite = label;
        }
        else
        {
            toolSprite = [CCSprite spriteWithSpriteFrameName:spriteName];
        }
        
        if ([spriteName isEqual:@"Slide.png"] || [spriteName isEqual:@"Plank.png"] || [spriteName isEqual:@"Drum.png"]
            || [spriteName isEqual:@"Drum2x.png"] || [spriteName isEqual:@"Blower.png"] || [spriteName isEqual:@"Blower2x.png"])
        {
            toolSprite.rotation = -45.0;
        }
        
        tableHeight += tableSpacing;
        
        ProductModel* model = [[ProductModel alloc] init];
        model.icon = toolSprite;
        model.title = spriteName; // for now
        model.description = [[NSString alloc] initWithCString:products[i].productId encoding:NSUTF8StringEncoding];
        model.price = @"$0.99";
        [productTable addObject:model];
    }
    
    CCNode* tableView = [CCNode node];
    tableView.contentSize = CGSizeMake(screen.width, tableHeight);
    
    
    float y = tableHeight - (tableSpacing/2);
    
    for (int i=0; i < productTable.count; i++)
    {
        ProductModel* product = [productTable objectAtIndex:i];
        product.icon.anchorPoint = ccp(0.5, 0.5);
        product.icon.position = ccp(iconColumn, y);
        [tableView addChild:product.icon];
        
        
        
        CCLabelBMFont* title = [CCLabelBMFont labelWithString:product.title fntFile:@"TDFont120.fnt"];
        title.scale = 0.6;
        CCLabelBMFont* description = [CCLabelBMFont labelWithString:product.description fntFile:@"TDFontYellow96.fnt"];
        description.scale = 0.6;
        
        CCNode* titleBox = [CCNode node];
        titleBox.contentSize = CGSizeMake(MAX(title.contentSize.width * title.scale, description.contentSize.width * description.scale),
                                      (title.contentSize.height * title.scale) + (description.contentSize.height * description.scale));
        description.anchorPoint = ccp(0, 0);
        description.position = ccp(0, 0);
        [titleBox addChild:description];
        
        title.anchorPoint = ccp(0,0);
        title.position = ccp(0, BB_TOP(description.boundingBox));
        [titleBox addChild:title];
        
        titleBox.anchorPoint = ccp(0, 0.5);
        titleBox.position = ccp(descriptionColumn, y);
        [tableView addChild:titleBox];
        
        
        CCLabelBMFont* price = [CCLabelBMFont labelWithString:@"$0.99" fntFile:@"TDFontYellow96.fnt"];
        price.scale = 0.7;
        price.anchorPoint = ccp(0.5, 0.5);
        price.position = ccp(priceColumn, y);
        [tableView addChild:price];
        
        y -= tableSpacing;
    }
    
    ScrollView* scrollView = [ScrollView viewWithContent:tableView];
    scrollView.contentSize = CGSizeMake(screen.width, screen.height);
    scrollView.anchorPoint = ccp(0.5, 0);
    scrollView.position = ccp(screen.width/2, 0);
    [self addChild:scrollView];
    
    scrollView.clipContents = YES;
    scrollView.content.position = ccp(scrollView.content.position.x, scrollView.contentSize.height - scrollView.content.contentSize.height);
    
    [self addChild:goBackButton]; // Make sure these are on top
    [self addChild:goBackLabel];
}


- (BOOL) eventOccurred:(NSString*)event data:(id)data
{
    
    return YES;
}


-(void) update:(ccTime) delta
{
}








@end
