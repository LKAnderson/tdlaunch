//
//  Character.m
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import "Character.h"
#import "CollisionTypes.h"
#import "Screen.h"


static CharacterDefinition* Steve;
static CharacterDefinition* Emily;
static CharacterDefinition* Bruce;
static CharacterDefinition* Toby;
static CharacterDefinition* Angie;

@implementation CharacterDefinition

+ (CharacterDefinition*) characterForName:(NSString *)name
{
    if ([name isEqual:@"Steve"]) return [CharacterDefinition Steve];
    if ([name isEqual:@"Emily"]) return [CharacterDefinition Emily];
    if ([name isEqual:@"Bruce"]) return [CharacterDefinition Bruce];
    if ([name isEqual:@"Toby"]) return [CharacterDefinition Toby];
    if ([name isEqual:@"Angie"]) return [CharacterDefinition Angie];
    return nil;
}


+ (CharacterDefinition*) Steve
{
    if (Steve == nil)
    {
        Steve = [[CharacterDefinition alloc] init];
        Steve.mass = SCALE(2.0);
        Steve.maxRotationVelocity = SCALE(10);
        Steve.bodySize = CGSizeMake(SCRNX(30),SCRNY(67));
        Steve.normalSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteve.png"]).displayFrame;
        Steve.happySprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveHappy.png"]).displayFrame;
        Steve.sadSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveSad.png"]).displayFrame;
        Steve.whoaSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveWhoa.png"]).displayFrame;
        Steve.downwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveDownward.png"]).displayFrame;
        Steve.upwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveUpward.png"]).displayFrame;
        Steve.cringeSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallSteveCringe.png"]).displayFrame;
        
        Steve.normalBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Steve.png"]).displayFrame;
        Steve.happyBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SteveHappy.png"]).displayFrame;
        Steve.sadBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SteveSad.png"]).displayFrame;
        Steve.whoaBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SteveWhoa.png"]).displayFrame;
        
        Steve.cringeVelocity = 600;
        Steve.cringeDistance = 300;
        
        Steve.type = Character_Steve;
    }
    
    return Steve;
}


+ (CharacterDefinition*) Emily
{
    if (Emily == nil)
    {
        Emily = [[CharacterDefinition alloc] init];
        Emily.mass = SCALE(1.5);
        Emily.maxRotationVelocity = SCALE(15);
        Emily.bodySize = CGSizeMake(SCRNX(28),SCRNY(65));
        Emily.normalSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmily.png"]).displayFrame;
        Emily.happySprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilyHappy.png"]).displayFrame;
        Emily.sadSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilySad.png"]).displayFrame;
        Emily.whoaSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilyWhoa.png"]).displayFrame;
        Emily.downwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilyDownward.png"]).displayFrame;
        Emily.upwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilyUpward.png"]).displayFrame;
        Emily.cringeSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallEmilyCringe.png"]).displayFrame;
        
        Emily.normalBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Emily.png"]).displayFrame;
        Emily.happyBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"EmilyHappy.png"]).displayFrame;
        Emily.sadBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"EmilySad.png"]).displayFrame;
        Emily.whoaBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"EmilyWhoa.png"]).displayFrame;
        
        Emily.cringeVelocity = 450;
        Emily.cringeDistance = 350;

        Emily.type = Character_Emily;

    }
    
    return Emily;
}



+ (CharacterDefinition*) Bruce
{
    if (Bruce == nil)
    {
        Bruce = [[CharacterDefinition alloc] init];
        Bruce.mass = SCALE(1.7);
        Bruce.maxRotationVelocity = SCALE(8);
        Bruce.bodySize = CGSizeMake(SCRNX(30),SCRNY(77));
        Bruce.normalSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruce.png"]).displayFrame;
        Bruce.happySprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceHappy.png"]).displayFrame;
        Bruce.sadSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceSad.png"]).displayFrame;
        Bruce.whoaSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceWhoa.png"]).displayFrame;
        Bruce.downwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceDownward.png"]).displayFrame;
        Bruce.upwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceUpward.png"]).displayFrame;
        Bruce.cringeSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallBruceCringe.png"]).displayFrame;
        
        Bruce.normalBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Bruce.png"]).displayFrame;
        Bruce.happyBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"BruceHappy.png"]).displayFrame;
        Bruce.sadBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"BruceSad.png"]).displayFrame;
        Bruce.whoaBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"BruceWhoa.png"]).displayFrame;
        
        Bruce.cringeVelocity = 400;
        Bruce.cringeDistance = 300;

        Bruce.type = Character_Bruce;
    }
    
    return Bruce;
}


+ (CharacterDefinition*) Toby
{
    if (Toby == nil)
    {
        Toby = [[CharacterDefinition alloc] init];
        Toby.mass = SCALE(2.5);
        Toby.maxRotationVelocity = SCALE(20);
        Toby.bodySize = CGSizeMake(SCRNX(28),SCRNY(61));
        Toby.normalSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallToby.png"]).displayFrame;
        Toby.happySprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobyHappy.png"]).displayFrame;
        Toby.sadSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobySad.png"]).displayFrame;
        Toby.whoaSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobyWhoa.png"]).displayFrame;
        Toby.downwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobyDownward.png"]).displayFrame;
        Toby.upwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobyUpward.png"]).displayFrame;
        Toby.cringeSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallTobyCringe.png"]).displayFrame;
        
        Toby.normalBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Toby.png"]).displayFrame;
        Toby.happyBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"TobyHappy.png"]).displayFrame;
        Toby.sadBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"TobySad.png"]).displayFrame;
        Toby.whoaBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"TobyWhoa.png"]).displayFrame;
        
        Toby.cringeVelocity = 700;
        Toby.cringeDistance = 250;
        
        Toby.type = Character_Toby;
    }
    
    return Toby;
}


+ (CharacterDefinition*) Angie
{
    if (Angie == nil)
    {
        Angie = [[CharacterDefinition alloc] init];
        Angie.mass = SCALE(1.3);
        Angie.maxRotationVelocity = SCALE(15);
        Angie.bodySize = CGSizeMake(SCRNX(28),SCRNY(63));
        Angie.normalSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngie.png"]).displayFrame;
        Angie.happySprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieHappy.png"]).displayFrame;
        Angie.sadSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieSad.png"]).displayFrame;
        Angie.whoaSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieWhoa.png"]).displayFrame;
        Angie.downwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieDownward.png"]).displayFrame;
        Angie.upwardSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieUpward.png"]).displayFrame;
        Angie.cringeSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"SmallAngieCringe.png"]).displayFrame;
        
        Angie.normalBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"Angie.png"]).displayFrame;
        Angie.happyBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"AngieHappy.png"]).displayFrame;
        Angie.sadBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"AngieSad.png"]).displayFrame;
        Angie.whoaBigSprite = ((CCSprite*)[CCSprite spriteWithSpriteFrameName:@"AngieWhoa.png"]).displayFrame;
        
        Angie.cringeVelocity = 400;
        Angie.cringeDistance = 350;

        Angie.type = Character_Angie;
    }
    
    return Angie;
}



- (ChipmunkBody*) createInSpace:(ChipmunkSpace*)space position:(CGPoint)position angle:(float)angle
{
    cpBB chBodyBox;
    chBodyBox.b = 0 - _bodySize.height/2;
    chBodyBox.l = 0 - _bodySize.width/2;
    chBodyBox.t = _bodySize.height/2;
    chBodyBox.r = _bodySize.width/2;
    
    ChipmunkBody* body = [[ChipmunkBody alloc] initWithMass:SCALE(_mass) andMoment:cpMomentForBox2(SCALE(_mass), chBodyBox)];
    body.pos = position;
    body.angle = angle;
    body.angVelLimit = _maxRotationVelocity;
    [space addBody:body];
    
    ChipmunkShape* character;
    character = [[ChipmunkPolyShape alloc] initBoxWithBody:body bb:chBodyBox];
    character.elasticity = 0.5f;
    character.friction = 0.5f;
    character.collisionType = CT_Character;
    character.group = CT_Character;
    [space add:character];
    
    return body;
}

@end
