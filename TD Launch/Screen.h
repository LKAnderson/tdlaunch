// This files contains macro definitions that will help work with
// screens of various sizes

extern BOOL isSmallScreen;
extern BOOL isRetinaScreen;


#define SCRNX(x)  (isSmallScreen ? (x/2.0) : x)
#define SCRNY(y)  (isSmallScreen ? (y/2.0) : y)

//#define SCRNX(x)  ([[CCDirector sharedDirector] winSize].width < 1024 ? (x * 0.48675) : x)
//#define SCRNY(y)  ([[CCDirector sharedDirector] winSize].width < 1024 ? (y * 0.416667) : y)
//#define SCRNX(x) (x)
//#define SCRNY(y) (y)

#define SCRN(p)   ( ccp(SCRNX(p.x), SCRNY(p.y)) )
//#define SCRN(p) (p)

// Average the two scale factors.  You can use this to scale down the mass of objects.
#define SCALE(a)  SCRNX(a) 
//#define SCALE(a)  ( [[CCDirector sharedDirector] winSize].width < 1024 ? ( a * ((0.48675 + 0.41667)/2)) : a )
//#define SCALE(a) (a)

// After trial and error, this seems like the right divisor for scaling the forces applied to objects.
#define SCALE_FORCE(f)  (isSmallScreen ? f/4.0 : f)



// Font sizes
#define TDFONT_LARGE(obj)       obj.scale = 1.0
#define TDFONT_MEDIUMLARGE(obj)     obj.scale = 0.75
#define TDFONT_MEDIUM(obj)      obj.scale = 0.5


// this isn't really the right place for this, but this file is included everywhere, so it's easy.
#define AUDIOTIC1 [[SimpleAudioEngine sharedEngine] playEffect:@"Tic.mp3" pitch:1.5 pan:0 gain:1]
#define AUDIOTIC2 [[SimpleAudioEngine sharedEngine] playEffect:@"Tic.mp3" pitch:2.0 pan:0 gain:1]


// Bounding Box Helper, because I really hate how much typing it takes!
#define BB_LEFT(bb)     (bb.origin.x)
#define BB_RIGHT(bb)    (bb.origin.x + bb.size.width)
#define BB_BOTTOM(bb)   (bb.origin.y)
#define BB_TOP(bb)      (bb.origin.y + bb.size.height)