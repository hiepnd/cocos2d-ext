//
//  CCContext.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/4/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "constant+macro.h"
#import "AppNotification.h"
#import "Global.h"

#if PHYSIC_ENABLED
#import "PhysicContext.h"
#import "PhysicUserData.h"
#import "GLES-Render.h"
#endif

enum  {
	kAppStateWillResignActive			= 1 << 0,
	kAppStateDidBecomeActive			= 1 << 1,
	kAppStateDidReceiveMemoryWarnig		= 1 << 2,
	kAppStateDidEnterBackground			= 1 << 3,
	kAppStateWillEnterForeGround		= 1 << 4,
	kAppStateWillterminate				= 1 << 5,
	kAppStateAll						= 0xFF,
};

//64 bits 
#define SIMPLE_HASH(a,b) ((unsigned int)MIN(a,b) << 16 | (unsigned int)MAX(a,b))
#define _16_LOWER_BITS(x) ((unsigned int)x & 0xFFFF)
#define _16_UPPER_BITS(x) ((unsigned int)x >> 16)

#define SIMPLE_HASH64(a,b) ((long long)a << 32 | (long long)b)
#define _32_LOWER_BITS(x) ((long long)x & 0xFFFFFFFF)
#define _32_UPPER_BITS(x) ((long long)x >> 32)


#define SCROLL_FLAG_NONE	0
#define SCROLL_FLAG_FOLLOW	1
#define SCROLL_FLAG_BOUNCE	2


#define FOLLOW_FLAG_BY_X	1
#define FOLLOW_FLAG_BY_Y	2
#define FOLLOW_FLAG_BY_XY	3


float ff(float dt);

//f(0) = f(1) = 0
float cc_return(float dt);

typedef float (* EaseFunction) (float) ;

@class CCComponent;
@class UIGestureRecognizer;

@interface CCContextScene : CCScene{
	//Layer to place characters
@protected
	CCLayer *_layer;
}
@property (readonly) CCLayer *layer;
@end

#define CC_DEFAULT_GROUP	0
#define CC_MAX_GROUPS		10

@interface CCContext : CCContextScene<UIAccelerometerDelegate, CCStandardTouchDelegate> {
	BOOL _isTouchEnabled;
	BOOL _isAccelerometerEnabled;
	int _interestedStateChanges;
	BOOL _interestShakeEvent;
	
	void *_groups[CC_MAX_GROUPS];
	int _tickCounter;
		
	NSMutableSet *_autoreleaseTextures;
	NSMutableSet *_autoreleaseSpriteFrames;
	
	//Bouncing
	EaseFunction _bounceF;
	int _scrollFlag;
	float _bounceTimeEllapsed;
	CGPoint _bounceDelta;
	CGPoint _bounceSrc;
	float _bounceTime;
	
	/** Scaling & Scrolling  */
	CGRect _boundary;
	float _bL, _bR, _bT, _bB;
	CCNode *_followedNode;
	CGPoint _center;
	int _followFlag; 
	float _maxScale;
	float _minScale;
	
	//
	NSMutableDictionary *_contactListeners;
	NSMutableDictionary *_targetedContactListeners;
		
#if PHYSIC_ENABLED
	PhysicContext *_physicContext;
	BOOL _drawDebugData;
	BOOL _useFixedTimeStep;
	ccTime _timeStep;
	CCArray *_toDestroyed;
	CCArray *_toReleased;
	GLESDebugDraw *_debugDraw;
#endif
}
@property(nonatomic) BOOL isTouchEnabled;
@property(nonatomic) BOOL isAccelerometerEnabled;
@property(nonatomic) int interestedStateChanges;
@property(nonatomic) BOOL interestShakeEvent;
@property(nonatomic) CGRect boundary;
@property float maxScale;
@property float minScale;

#if PHYSIC_ENABLED
@property(readonly) PhysicContext *physicContext;
@property(nonatomic) BOOL useFixedTimeStep;
@property(nonatomic) ccTime timeStep;
@property(nonatomic) BOOL drawDebugData;
#endif

- (void) onEnter;
- (void) onExit;
- (void) tick:(ccTime)dt;

+ (id) context;

#pragma mark Contact Listener
- (void) resolveContacts; //Internal method
- (void) resolveContactsBetweenGroup:(int) g1 andGroup:(int) g2;
- (void) addContactListenerBetweenGroup:(int) g1 andGroup:(int) g2 target:(id) target selector:(SEL) selector;
- (void) removeContactListenerBetweenGroup:(int) g1 andGroup:(int) g2;

- (void) addContactListenerBetweenActor:(CCNode *) node andGroup:(int) gid target:(id) target selector:(SEL) selector;
- (void) removeContactListenerBetweenActor:(int) node andGroup:(int) gid;
- (void) resolveContactsBetweenNode:(CCNode *) node group:(int) gid;

#pragma mark Scaling, Scrolling
- (void) setBoundary:(CGRect) boundary;
- (void) follow:(CCNode *) node;
- (void) followByX:(CCNode *) node;
- (void) followByY:(CCNode *) node;
- (void) unfollow;

- (void) scale:(float) scale;

#pragma mark Sprite batch node
- (void) addBatchNode:(CCSpriteBatchNode *) node;
- (void) addActor:(CCSprite *)actor batch:(CCSpriteBatchNode *) node group:(int) gid;
- (void) addActor:(CCSprite *)actor batch:(CCSpriteBatchNode *) node;

#pragma mark Boucing
- (void) bounceTo:(CGPoint) pos duration:(float) duration withFunction:(EaseFunction) block;
- (void) bounceBy:(CGPoint) pos duration:(float) duration withFunction:(EaseFunction) block;

#pragma mark Memory management
- (void) addAutoreleaseTexture:(NSString *) name;
- (void) addAutoreleaseSpriteFrame:(NSString *) plist;

#pragma mark Actors
- (void) addActor:(CCNode *) actor z:(int) z tag:(int) tag;
- (void) addActor:(CCNode *) actor z:(int) z;
- (void) addActor:(CCNode *) actor;
- (void) removeActor:(CCNode *) actor cleanup:(BOOL) cleanup;
- (void) removeActor:(CCNode *) actor;
- (void) removeAllActorsByTag:(int) tag cleanup:(BOOL) cleanup;
- (void) removeAllActorsByTag:(int) tag;
- (void) removeActorByTag:(int) tag cleanup:(BOOL) cleanup;
- (void) removeActorByTag:(int) tag ;

- (CCNode *) getActorByTag:(int) tag;
- (NSArray *) allActorByTag:(int) tag;
- (CCNode *) getActorAtPoint:(CGPoint) pos;

#pragma mark Actors Group
- (void) addGroup:(int) gid;
- (void) emptyGroup:(int) gid;
- (int) actorCount:(int) gid;
- (NSArray *) getAllActors:(int) gid;

- (void) addActor:(CCNode *) actor group:(int)gid z:(int) z tag:(int) tag;
- (void) addActor:(CCNode *) actor group:(int)gid z:(int) z;
- (void) addActor:(CCNode *) actor group:(int)gid;
- (void) removeActor:(CCNode *) actor group:(int)gid cleanup:(BOOL) cleanup;
- (void) removeActor:(CCNode *) actor group:(int)gid;
- (void) removeAllActorsByTag:(int) tag group:(int)gid cleanup:(BOOL) cleanup;
- (void) removeAllActorsByTag:(int) tag group:(int)gid;
- (void) removeActorByTag:(int) tag group:(int)gid cleanup:(BOOL) cleanup;
- (void) removeActorByTag:(int) tag group:(int)gid;
- (void) removeFromGroup:(int)gid actor:(CCNode *) actor;

- (CCNode *) getActorByTag:(int) tag group:(int)gid;
- (NSArray *) allActorByTag:(int) tag group:(int)gid;
- (CCNode *) getActorAtPoint:(CGPoint) pos group:(int)gid;

#pragma mark Manage children
- (void) addChild:(CCNode *)node z:(int) z tag:(int) tag;
- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup;
- (void) removeChild:(CCNode *)node;
- (CCNode *) getChildByTag:(int) tag;
- (void) removeChildByTag:(int)tag cleanup:(BOOL)cleanup;


#pragma mark Query components
- (NSArray *) allChildsByTag:(int) tag;
- (CCNode *) getChildAtPoint:(CGPoint) pos;
- (CCLayer *) getLayerByTag:(int) tag;

#pragma mark Touch, Acceleromater, Shake Event and Application state change 
- (void) registerWithTouchDispatcher;
- (void) registerWithAccelerometer;
- (void) registerAppStateChangeObserver;
- (void) unregisterAppStateChangeObserver;

- (void) deviceShaked;

- (void) applicationWillResignActive:(NSNotification *) notification;
- (void) applicationDidBecomeActive:(NSNotification *) notification;
- (void) applicationDidReceiveMemoryWarning:(NSNotification *) notification;
- (void) applicationDidEnterBackground:(NSNotification *) notification;
- (void) applicationWillEnterForeground:(NSNotification *) notification;
- (void) applicationWillTerminate:(NSNotification *) notification;

#pragma mark Touch Event helpers
- (CGPoint) pointForTouches:(NSSet *) touches;
- (CGPoint) pointForTouch:(UITouch *) touch;
- (CGPoint) previousPointForTouches:(NSSet *) touches;
- (CGPoint) previousPointForTouch:(UITouch *) touch;

#pragma mark Gesture Recognizer
- (void) addGestureRecognizer:(UIGestureRecognizer *) recognizer action:(SEL) selector;
- (void) removeGestureRecognizer:(UIGestureRecognizer *) recognizer;

#pragma mark Scheduler
- (void) unscheduleAllSelectors;
- (void) pauseScheduler;
- (void) resumeScheduler;

#pragma mark Funny
/** Pause all actions and schedulers of self.layer children - useful to pause/resume game  */
- (void) freezeAllChilden;
- (void) unFreezeAllChilden;
- (void) freezeAllChildenInGroup:(int) gid;
- (void) unFreezeAllChildenInGroup:(int) gid;

/** Useful when you want to move the node based on the touch  */
- (void) moveNode:(CCNode *) node byTouch:(UITouch *) touch;

#pragma mark Physics
#if PHYSIC_ENABLED
- (void) step:(ccTime) dt;
- (void) setDebugDraw:(BOOL) onOrOff flag:(int)flags;
- (void) toDestroyed:(CCComponent *) node;
- (void) toReleased:(CCComponent *) node;

- (b2MouseJoint *) createMouseJoint:(b2Body *) body staticBody:(b2Body *) staticBody position:(CGPoint) position;

- (CCComponent *) queryComponentAtPoint:(CGPoint) position;
- (CCComponent *) queryComponentAtTouch:(UITouch *) touch;
- (b2Body *) queryBodyAtPoint:(CGPoint) position;

- (b2Body *) addCircleAt:(CGPoint) position radius:(float) radius bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addRectangleAt:(CGPoint) position width:(float) width height:(float) height angle:(float) angle bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addStaticEdgeFrom:(CGPoint) from to:(CGPoint) to fixtureDef:(b2FixtureDef *) fdef;

/**
 @param position: position of the fixture relative to the body position
 */
- (b2Fixture *) addCircleTo:(b2Body *) body position:(CGPoint) position radius:(float) radius fixtureDef:(b2FixtureDef *) fdef;
- (b2Fixture *) addRectangleTo:(b2Body *) body position:(CGPoint) position width:(float) width height:(float) height angle:(float) angle fixtureDef:(b2FixtureDef *) fdef;
- (b2Fixture *) addEdgeTo:(b2Body *) body from:(CGPoint) from to:(CGPoint) to fixtureDef:(b2FixtureDef *) fdef;
- (b2Fixture *) addPolyTo:(b2Body *) body poly:(b2PolygonShape *) shape fixtureDef:(b2FixtureDef *) fdef;

/**
 @param position: position of the body
 @param offset: position of the fixture relative to the body position. If not present, CGPointZero is used
 @param radius: radius of the circle. If not present, it is calculated based on the node's size
 All params are measured in GL space, not in Box2D space
 */
- (b2Body *) addCircleComponent:(CCComponent *) node position:(CGPoint) position offset:(CGPoint) offset radius:(float) radius bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addCircleComponent:(CCComponent *) node position:(CGPoint) position radius:(float) radius bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addCircleComponent:(CCComponent *) node position:(CGPoint) position bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;

- (b2Body *) addRectangleComponent:(CCComponent *) node position:(CGPoint) position offset:(CGPoint) offset angle:(float) angle size:(CGSize) size bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addRectangleComponent:(CCComponent *) node position:(CGPoint) position offset:(CGPoint) offset size:(CGSize) size bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addRectangleComponent:(CCComponent *) node position:(CGPoint) position size:(CGSize) size bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;
- (b2Body *) addRectangleComponent:(CCComponent *) node position:(CGPoint) position bodyDef:(b2BodyDef *) bdef fixtureDef:(b2FixtureDef *) fdef;

- (b2Fixture *) addCircleComponent:(CCComponent *) node toParent:(CCComponent *) parent position:(CGPoint) position radius:(float) radius fixtureDef:(b2FixtureDef *) fdef registerPhysic:(BOOL) reg;
- (b2Fixture *) addCircleComponent:(CCComponent *) node toParent:(CCComponent *) parent position:(CGPoint) position fixtureDef:(b2FixtureDef *) fdef registerPhysic:(BOOL) reg;
- (b2Fixture *) addRectangleComponent:(CCComponent *) node toParent:(CCComponent *) parent position:(CGPoint) position size:(CGSize) size angle:(float) angle fixtureDef:(b2FixtureDef *) fdef registerPhysic:(BOOL) reg; 
- (b2Fixture *) addRectangleComponent:(CCComponent *) node toParent:(CCComponent *) parent position:(CGPoint) position angle:(float) angle fixtureDef:(b2FixtureDef *) fdef registerPhysic:(BOOL) reg; 

//Merging
//- (void) mergeCircle:(CCComponent *) node toParent:(CCComponent *) parent;
#endif
@end
