//
//  MainMenu.m
//  TD Launch
//
//  Created by Kent Anderson on 8/21/12.
//
//

#import "AppDelegate.h"
#import "MainMenu.h"
#import "LevelMenu.h"

@implementation MainMenu

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MainMenu *layer = [MainMenu node];
	[scene addChild: layer];
	return scene;
}




- (void) onEnter
{
    [super onEnter];
    self.isTouchEnabled = YES;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // This is rudimentary for now....
    
    CCLabelTTF* label = [CCLabelTTF labelWithString:@"TreeDudes Launch" fontName:@"Arial" fontSize:44.0];
    label.position = ccp(winSize.width/2, winSize.height*0.75);
    [self addChild:label];
    
    
    [CCMenuItemFont setFontName:@"Arial"];
    [CCMenuItemFont setFontSize:34];
    CCMenuItemLabel* play = [CCMenuItemFont itemWithString:@"Play" block:^(id sender){
        [[CCDirector sharedDirector] replaceScene: [LevelMenu scene]];
    }];
    
    
    CCMenu *menu = [CCMenu menuWithItems:play, nil];
    [menu alignItemsVertically];
    [menu setPosition:ccp( winSize.width/2, winSize.height*0.33)];
    [self addChild:menu];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
