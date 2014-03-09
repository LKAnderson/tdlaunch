//
//  Achievements.m
//  TD Launch
//
//  Created by Kent Anderson on 9/30/13.
//
//

#import "Achievements.h"
#import "GameLevel.h"
#import "ProductIds.h"
#import <CommonCrypto/CommonDigest.h>

static Achievements* _sharedAchievements;

#define FILENAME ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]\
                  stringByAppendingPathComponent:@"achievements.dat"])


#define FILEVERSION_HASH @"k1"
#define DATAVALUES_HASH @"k2"
#define FILEVERSION @"fv"
#define LEVEL_V1 @"lv"
#define LEVEL_V2 @"pz"
#define TRAMPOLINE @"t"
#define TRAMPOLINE2X @"t2"
#define BLOWER @"b"
#define BLOWER2X @"b2"
#define PLANK @"p"
#define SLIDE @"s"
#define LAUNCHER @"l"
#define ACCEL2X @"a"
#define ACCELHALFX @"h"
#define ANTIGRAVITY @"ag"
#define ALIGNER @"al"
#define BRUCE @"brc"
#define TOBY @"tby"
#define ANGIE @"ang"
#define PURCHASED_PRODUCTS @"pp"


@implementation Achievements

- (id) init
{
    if (self = [super init])
    {
        _level = 1;
        _trampoline = 2;
        _trampoline2x = 0;
        _blower = 2;
        _blower2x = 0;
        _plank = 2;
        _slide = 0;
        _launcher = 0;
        _accel2X = 0;
        _antiGravity = 0;
        _aligner = 0;
        _accelHalfX = 0;
        _hasSteve = YES;
        _hasEmily = YES;
        _hasBruce = NO;
        _hasToby = NO;
        _hasAngie = NO;
        _isTampered = NO;
        _purchasedProducts = [NSMutableSet set];
    }
    return self;
}



- (NSString*) getHashForString:(NSString*)string
{
    const char* cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData* data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* hash = [NSMutableString string];
    for(int i=0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", digest[i]];
    return hash;
}




- (NSString*) getHashForVersion2
{
    int numIntValues = 13;
    int intValues[] = { 2, _level, _trampoline, _trampoline2x, _blower, _blower2x, _plank, _slide, _launcher, _accel2X, _accelHalfX, _antiGravity,          _aligner };
    
    int numBoolValues = 5;
    BOOL boolValues[] = { _hasSteve, _hasEmily, _hasBruce, _hasToby, _hasAngie };
    
    NSMutableString* inputData = [NSMutableString string];
    for (int i=0; i < numIntValues; i++)
        [inputData appendFormat:@"%d", -intValues[i]];
    
    for (int i=0; i < numBoolValues; i++)
        [inputData appendString:(boolValues[i] == YES ? @"A" : @"B")];
    
    return [self getHashForString:inputData];
}


- (NSString*) getHashForVersion3
{
    int numIntValues = 13;
    int intValues[] = { 2, _level, _trampoline, _trampoline2x, _blower, _blower2x, _plank, _slide, _launcher, _accel2X, _accelHalfX, _antiGravity,          _aligner };
    
    int numBoolValues = 5;
    BOOL boolValues[] = { _hasSteve, _hasEmily, _hasBruce, _hasToby, _hasAngie };
    
    NSMutableString* inputData = [NSMutableString string];
    for (int i=0; i < numIntValues; i++)
        [inputData appendFormat:@"%d", -intValues[i]];
    
    for (int i=0; i < numBoolValues; i++)
        [inputData appendString:(boolValues[i] == YES ? @"A" : @"B")];
    
    for (NSString* productId in _purchasedProducts)
    {
        [inputData appendString:productId];
    }
    
    return [self getHashForString:inputData];
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        unsigned int fileVersion = 1;
        if ([aDecoder containsValueForKey:FILEVERSION])
            fileVersion = [aDecoder decodeIntegerForKey:FILEVERSION];
        
        _level = [aDecoder decodeIntForKey:LEVEL_V1];
        if (fileVersion > 1)
            _level = [aDecoder decodeIntForKey:LEVEL_V2];
        
        _trampoline = [aDecoder decodeIntForKey:TRAMPOLINE];
        _trampoline2x = [aDecoder decodeIntForKey:TRAMPOLINE2X];
        _blower = [aDecoder decodeIntForKey:BLOWER];
        _blower2x = [aDecoder decodeIntForKey:BLOWER2X];
        _plank = [aDecoder decodeIntForKey:PLANK];
        _slide = [aDecoder decodeIntForKey:SLIDE];
        _launcher = [aDecoder decodeIntForKey:LAUNCHER];
        _accel2X = [aDecoder decodeIntForKey:ACCEL2X];
        _accelHalfX = [aDecoder decodeIntForKey:ACCELHALFX];
        _antiGravity = [aDecoder decodeIntForKey:ANTIGRAVITY];
        _aligner = [aDecoder decodeIntForKey:ALIGNER];
        
        _hasBruce = [aDecoder decodeBoolForKey:BRUCE];
        _hasToby = [aDecoder decodeBoolForKey:TOBY];
        _hasAngie = [aDecoder decodeBoolForKey:ANGIE];
        
        if (fileVersion == 2)
        {
            NSString* stdVersionHash = [self getHashForString:@"2"];
            NSString* versionHash = [aDecoder decodeObjectForKey:FILEVERSION_HASH];
            if (![versionHash isEqualToString:stdVersionHash])
            {
                _isTampered = YES;
            }
            else
            {
                NSString* stdDataHash = [self getHashForVersion2];
                NSString* dataHash = [aDecoder decodeObjectForKey:DATAVALUES_HASH];
                if (![dataHash isEqualToString:stdDataHash])
                    _isTampered = YES;
            }
            
        }
        
        if (fileVersion == 3)
        {
            _purchasedProducts = [aDecoder decodeObjectForKey:PURCHASED_PRODUCTS];
            
            NSString* stdVersionHash = [self getHashForString:@"3"];
            NSString* versionHash = [aDecoder decodeObjectForKey:FILEVERSION_HASH];
            if (![versionHash isEqualToString:stdVersionHash])
            {
                _isTampered = YES;
            }
            else
            {
                NSString* stdDataHash = [self getHashForVersion3];
                NSString* dataHash = [aDecoder decodeObjectForKey:DATAVALUES_HASH];
                if (![dataHash isEqualToString:stdDataHash])
                    _isTampered = YES;
            }
        }
        
        // else do nothing.  Hopefully none of the 4 people who have downloaded version 1
        // will know enough to be dishonest before version 2 can upgrade their file!
    
        if (! _isTampered && fileVersion < 3)
        {
            [self addPurchasedProduct:Product_SuperStartPack];
        }

    }
    return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder
{
    const unsigned int FileVersion = 3;
    
    [aCoder encodeInt:FileVersion forKey:FILEVERSION];
    [aCoder encodeInt:random() % 0xffffffff forKey:LEVEL_V1];
    [aCoder encodeInt:_level forKey:LEVEL_V2];
    [aCoder encodeInt:_trampoline forKey:TRAMPOLINE];
    [aCoder encodeInt:_trampoline2x forKey:TRAMPOLINE2X];
    [aCoder encodeInt:_blower forKey:BLOWER];
    [aCoder encodeInt:_blower2x forKey:BLOWER2X];
    [aCoder encodeInt:_plank forKey:PLANK];
    [aCoder encodeInt:_slide forKey:SLIDE];
    [aCoder encodeInt:_launcher forKey:LAUNCHER];
    [aCoder encodeInt:_accel2X forKey:ACCEL2X];
    [aCoder encodeInt:_accelHalfX forKey:ACCELHALFX];
    [aCoder encodeInt:_antiGravity forKey:ANTIGRAVITY];
    [aCoder encodeInt:_aligner forKey:ALIGNER];
    
    [aCoder encodeBool:_hasBruce forKey:BRUCE];
    [aCoder encodeBool:_hasToby forKey:TOBY];
    [aCoder encodeBool:_hasAngie forKey:ANGIE];
    
    [aCoder encodeObject:_purchasedProducts forKey:PURCHASED_PRODUCTS];
    
    [aCoder encodeObject:[self getHashForString:@"3"] forKey:FILEVERSION_HASH];
    [aCoder encodeObject:[self getHashForVersion3] forKey:DATAVALUES_HASH];
}




+ (Achievements*) sharedAchievements
{
    if (_sharedAchievements == nil)
    {
        // Read from file, if exists
        NSData* codedData = [[NSData alloc] initWithContentsOfFile:FILENAME];
        if (codedData != nil)
        {
            NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
            _sharedAchievements = [unarchiver decodeObjectForKey:@"achievements"];
        }
        else
        {
            _sharedAchievements = [[Achievements alloc] init];
        }
    }
    return _sharedAchievements;
}



- (void) save
{
    if (_isTampered)
        return;
    
    // Write to file
    
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"achievements"];
    [archiver finishEncoding];
    [data writeToFile:FILENAME atomically:YES];
}


- (void) addPurchasedProduct:(NSString *)productIdentifier
{
    if ([_purchasedProducts containsObject:productIdentifier])
    {
        // Don't want to rack up lots of items accidentally
        return;
    }
    
    NSSet* validProducts = [NSSet setWithObjects:Product_DevPack, Product_PowerPack, Product_SuperStartPack, nil];
    if (! [validProducts containsObject:productIdentifier])
    {
        // this is mostly for my testing environment, since I've played around with
        // different products.
        return;
    }
    
    [_purchasedProducts addObject:productIdentifier];
    
    if ([productIdentifier isEqualToString:Product_SuperStartPack]) //  3.99
    {
        _trampoline += 2;
        _trampoline2x += 1;
        _blower += 2;
        _blower2x += 1;
        _plank += 2;
        _slide += 2;
        _aligner += 1;
    }
    else if ([productIdentifier isEqualToString:Product_PowerPack]) // 5.99
    {
        _trampoline += 3;
        _trampoline2x += 3;
        _blower += 3;
        _blower2x += 3;
        _plank += 3;
        _slide += 3;
        _accel2X += 1;
        _accelHalfX += 1;
        _antiGravity += 1;
        _aligner += 1;
    }
    else if ([productIdentifier isEqualToString:Product_DevPack]) // 9.99
    {
        _trampoline += 5;
        _trampoline2x += 5;
        _blower += 5;
        _blower2x += 5;
        _plank += 5;
        _slide += 5;
        _accel2X += 3;
        _accelHalfX += 3;
        _antiGravity += 2;
        _aligner += 2;
        _launcher += 1;
    }
    
    [self save];
}



- (struct AchievementResult) applyLevelData:(GameLevel*)gameLevel
{
    BOOL isOnTarget = NO;
    BOOL fileUpdated = NO;
    
    struct AchievementResult result = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NO, NO, NO, NO, NO };
    
    for (LogEvent* event in gameLevel.gameData.gameLog)
    {
        switch (event.type)
        {
            case TargetTouched:
                isOnTarget = YES;
                break;
                
            case TargetLeft:
                isOnTarget = NO;
        }
    }
    
    if (!isOnTarget)
        return result;

    if (isOnTarget && gameLevel.ID >= _level)
    {
        _level = gameLevel.ID + 1;
        switch(gameLevel.ID)
        {
            case 1:
                result.trampoline++;
                break;
            case 2:
                result.blower++;
                break;
            case 3:
                result.trampoline2x++;
                break;
            case 4:
                result.blower2x++;
                break;
            case 5:
                result.slide++;
                result.plank++;
                break;
            case 6:
                result.trampoline2x++;
                break;
            case 7:
                result.blower2x++;
                break;
            case 8:
                result.trampoline2x++;
                break;
            case 9:
                result.blower2x++;
                break;
        }
        fileUpdated = YES;
    }
    
    if (isOnTarget && gameLevel.ID == 10 && _launcher == 0)
    {
        result.launcher = 1;
        fileUpdated = YES;
    }
    
    if (gameLevel.gameData.isNewHighScore && gameLevel.gameData.overallStars >= 3)
    {
        fileUpdated = YES;
        
        if (gameLevel.ID == 1) [self level1Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 2) [self level2Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 3) [self level3Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 4) [self level4Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 5) [self level5Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 6) [self level6Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 7) [self level7Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 8) [self level8Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 9) [self level9Awards:gameLevel.gameData.overallStars result:&result];
        else if (gameLevel.ID == 10) [self level10Awards:gameLevel.gameData.overallStars result:&result];
    }
    
    if (fileUpdated)
    {
        _trampoline += result.trampoline;
        _trampoline2x += result.trampoline2x;
        _blower += result.blower;
        _blower2x += result.blower2x;
        _plank += result.plank;
        _slide += result.slide;
        if (result.launcher >= 1) _launcher = 1;
        _accel2X += result.accel2X;
        _accelHalfX += result.accelHalfX;
        _antiGravity += result.antiGravity;
        _aligner += result.aligner;
        if (result.bruce) _hasBruce = YES;
        if (result.toby) _hasToby = YES;
        if (result.angie) _hasAngie = YES;
        [self save];
    }
    
    return result;
}


#define INCREMENT(a, b) if (a <= b) a++; else b++




- (void) level1Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            result->accelHalfX++;
            break;
    }
}

- (void) level2Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->blower, result->trampoline);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            result->accelHalfX++;
            break;
    }
}

- (void) level3Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            result->accel2X++;
            break;
    }
   
}

- (void) level4Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->blower, result->trampoline);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            result->accel2X++;
            break;
    }
    
}

- (void) level5Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            result->antiGravity++;
            break;
    }
    
}

- (void) level6Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->blower, result->trampoline);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else if (!_hasAngie) result->angie = YES;
            INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            INCREMENT(result->antiGravity, result->accel2X);
            break;
    }
    
}



- (void) level7Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else if (!_hasAngie)result->angie = YES;
            else INCREMENT(result->accelHalfX, result->aligner);
            break;
        case 5:
            INCREMENT(result->antiGravity, result->accel2X);
            break;
    }
    
}



- (void) level8Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->blower, result->trampoline);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else if (!_hasAngie) result->angie = YES;
            else INCREMENT(result->blower2x, result->trampoline2x);
            break;
        case 5:
            INCREMENT(result->antiGravity, result->accel2X);
            break;
    }
    
}


- (void) level9Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else if (!_hasAngie) result->angie = YES;
            else INCREMENT(result->accelHalfX, result->aligner);
            break;
        case 5:
            INCREMENT(result->antiGravity, result->accel2X);
            break;
    }
    
}


- (void) level10Awards:(int)stars result:(struct AchievementResult*)result
{
    switch(stars)
    {
        case 3:
            INCREMENT(result->plank, result->slide);
            break;
        case 4:
            if (_launcher < 1) result->launcher = 1;
            if (!_hasBruce) result->bruce = YES;
            else if (!_hasToby) result->toby = YES;
            else if (!_hasAngie) result->angie = YES;
            else INCREMENT(result->trampoline2x, result->aligner);
            break;
        case 5:
            INCREMENT(result->antiGravity, result->accel2X);
            break;
    }
    
}


@end
