//
//  HelloWorldScene.mm
//  verletRopeTestProject
//
//  Created by patrick on 29/10/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
//#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CCMenuItem *item = [CCMenuItemFont itemFromString:@"Home" target:self selector:@selector(home)];
		item.position = ccp(220,140);
		[self addChild:[CCMenu menuWithItems:item,nil]];
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		flags += b2Draw::e_aabbBit;
		flags += b2Draw::e_pairBit;
		flags += b2Draw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		

		// +++ Add anchor body
		b2BodyDef anchorBodyDef;
		anchorBodyDef.position.Set(screenSize.width/PTM_RATIO/2,screenSize.height/PTM_RATIO*0.7f); //center body on screen
		anchorBody = world->CreateBody(&anchorBodyDef);
		// +++ Add rope spritesheet to layer
		ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rope.png" ];
		[self addChild:ropeSpriteSheet];
		// +++ Init array that will hold references to all our ropes
		vRopes = [[NSMutableArray alloc] init];
		
		
		//Set up sprite
		
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( screenSize.width/2, screenSize.height-50);
		
		[self schedule: @selector(tick:)];
	}
	
	
	
	const int32 N = 40;
	b2Vec2 vertices[N];
	float32 masses[N];
	
	for (int32 i = 0; i < N; ++i)
	{
		vertices[i].Set(1.0f, 20.0f - 0.25f * i);
		masses[i] = 1.0f;
	}
	masses[0] = 0.0f;
	masses[1] = 0.0f;
	
	b2RopeDef def;
	def.vertices = vertices;
	def.count = N;
	def.gravity.Set(0.0f, 10.0f);
	def.masses = masses;
	def.damping = 0.1f;
	def.k2 = 1.0f;
	def.k3 = 0.5f;
	
	m_rope.Initialize(&def);
	
	m_angle = 30.0f;
	m_rope.SetAngle(m_angle);
	
	return self;
}

- (void) home{
	[[CCDirector sharedDirector] homeContext];
}

- (void) onEnter{
	[self checkAllArray]; 
	[self schedule:@selector(removePoints:) interval:0.0001f];
	[super onEnter];
}
-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// +++ Update rope sprites
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] updateSprites];
	}
	
	glEnable(GL_LINE_SMOOTH);
	glColor4ub(255, 255, 255, 255); //line color 
	//glLineWidth(2.5f);
	
	
	for(int i = 0; i < [naughtytoucharray count]; i+=2)
	{
		CGPoint start = CGPointFromString([naughtytoucharray objectAtIndex:i]);
		CGPoint end = CGPointFromString([naughtytoucharray objectAtIndex:i+1]);
		ccDrawLine(start, end); // line 1
		ccDrawLine(ccp(start.x-2,start.y-2),ccp(end.x-2,end.y-2));// line 2
		ccDrawLine(ccp(start.x-4,start.y-4),ccp(end.x-4,end.y-4));// line 3
		ccDrawLine(ccp(start.x-6,start.y-6),ccp(end.x-6,end.y-6));// line 4
		ccDrawLine(ccp(start.x-8,start.y-8),ccp(end.x-8,end.y-8));// line 5
		
	}
	
}

-(void)checkAllArray { 
	if (naughtytoucharray==NULL) 
		naughtytoucharray=[[NSMutableArray alloc] init]; 
	else { 
		[naughtytoucharray release]; 
		naughtytoucharray=nil; 
		naughtytoucharray=[[NSMutableArray alloc] init]; 
	} 
}

-(void)removePoints:(ccTime *)tm { 
	if ([naughtytoucharray count]>0) { 
		[naughtytoucharray removeObjectAtIndex:0]; 
	} 

}
-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	// +++ Create box2d joint
	b2RopeJointDef jd;
	jd.bodyA=anchorBody; //define bodies
	jd.bodyB=body;
	jd.localAnchorA = b2Vec2(0,0); //define anchors
	jd.localAnchorB = b2Vec2(0,0);
	jd.maxLength= (body->GetPosition() - anchorBody->GetPosition()).Length(); //define max length of joint = current distance between bodies
	world->CreateJoint(&jd); //create joint
	// +++ Create VRope with two b2bodies and pointer to spritesheet
	VRope *newRope = [[VRope alloc] init:anchorBody body2:body spriteSheet:ropeSpriteSheet];
	[vRopes addObject:newRope];
}

-(void)removeRopes {
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] removeSprites];
		[[vRopes objectAtIndex:i] release];
	}
	[vRopes removeAllObjects];
}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
	
	// +++ Update rope physics
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] update:dt];
	}
	
	m_rope.Step(dt, 1);
	m_rope.Draw(m_debugDraw);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		
//		location = [[CCDirector sharedDirector] convertToGL: location];
//		
//		[self addNewSpriteWithCoords: location];
//	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	CGPoint new_location = [touch locationInView: [touch view]]; 
	new_location = [[CCDirector sharedDirector] convertToGL:new_location];
	
	CGPoint oldTouchLocation = [touch previousLocationInView:touch.view]; 
	oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
	
	[naughtytoucharray addObject:NSStringFromCGPoint(new_location)]; 
	[naughtytoucharray addObject:NSStringFromCGPoint(oldTouchLocation)];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
