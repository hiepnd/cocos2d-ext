/*
 * cocos2d+ext for iPhone
 *
 * Copyright (c) 2011 - Ngo Duc Hiep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "RagdollContext.h"
#import "CCJointNode.h"
#import "AppDirector.h"

@implementation RagdollContext

- (id) init{
	self = [super init];
	_isTouchEnabled = YES;
	_mouse = NULL;
	[self addGroup:RAGDOLL_GROUP];
	
	SimpleMenu *menu = [SimpleMenu node];
	[self addChild:menu];
	menu.delegate = self;
	
	[self addAutoreleaseSpriteFrame:@"rbg.plist"];
	
	CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"garden3.png"];
	bg.position = ccp(240,160);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden2.png"];
	bg.position = ccp(720,160);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden4.png"];
	bg.position = ccp(240,480);
	[self addChild:bg];
	
	bg = [CCSprite spriteWithSpriteFrameName:@"garden4.png"];
	bg.position = ccp(720,480);
	[self addChild:bg];
	
	/** Add the walls around iPhone  */
	b2BodyDef bdef;
	
	b2FixtureDef fdef;
	fdef.restitution = 0;
	fdef.density = .5;
	fdef.friction = .4;
	
	[self addRectangleAt:ccp(480,-50) width:960 height:100 angle:0 bodyDef:&bdef fixtureDef:&fdef];
	[self addRectangleAt:ccp(480,690) width:960 height:100 angle:0 bodyDef:&bdef fixtureDef:&fdef];
	[self addRectangleAt:ccp(-50,320) width:100 height:640 angle:0 bodyDef:&bdef fixtureDef:&fdef];
	_static = [self addRectangleAt:ccp(1010,320) width:100 height:640 angle:0 bodyDef:&bdef fixtureDef:&fdef];
	
	bdef.type = b2_dynamicBody;
	doll = [self addRagdollAt:ccp(100,160)];
	
	Ragdoll *d2 = [self addRagdollAt:ccp(380,160)];
	
	b2Body *b1 = [doll getSegment:rdTagLowerArmR];
	b2Body *b2 = [d2 getSegment:rdTagLowerArmL];
	b2DistanceJointDef def;
	def.Initialize(b1, b2, b1->GetWorldCenter(), b2->GetWorldCenter());
	def.dampingRatio = 1;
	def.frequencyHz = 2;
	b2Joint *joint = _physicContext->createJoint(&def);
	CCJointNode *node = [CCJointNode nodeWithJoint:joint];
	node.texture = @"rope.png";
	[self addChild:node z:1];
	
//	Class c = NSClassFromString(@"UIPinchGestureRecognizer");
//	if (c) {
//		UIGestureRecognizer *reg = [[c alloc] init];
//		[self addGestureRecognizer:reg action:@selector(pinch:)];
//		[reg release];
//	}else {
//		NSLog(@"UIGestureRecognizer not supported");
//	}
	
	[self setDebugDraw:YES flag:0x0001 | 0x0002];
	[self follow:doll];
	self.boundary = CGRectMake(0, 0, 960, 640);
	self.maxScale = 2;
	
	//Add slider
	_slider = [CCSlider sliderWithTrackImage:@"slider_track.png" knobImage:@"slider_knob.png" target:self selector:@selector(scaleChanged:)];
	_slider.position = ccp(450,160);
	_slider.rotation = -90;
	_slider.height = 100;
	_slider.horizontalPadding = 50;
	_slider.trackTouchOutsideContent = YES;
	_slider.evaluateFirstTouch = NO;
	_slider.minValue = self.minScale;
	_slider.maxValue = self.maxScale;
	
	_label = [CCLabelTTF labelWithString:@"Scale" fontName:@"Courier" fontSize:18];
	[menu addChild:_label];
	_label.position = ccp(450,30);
	_label.color = ccBLACK;
	[menu addChild:_slider];
	
	return self;
}

- (void) onEnter{
	[self scale:(_minScale + _maxScale)/2];
	_slider.value = _layer.scale;
	[super onEnter];
}

- (void) tick:(ccTime) dt{
	if (_state == rStatePlaying) {
		[self step:dt];
		
		[super tick:dt];
	}
}

- (Ragdoll *) addRagdollAt:(CGPoint) pos{
	RagdollConfig *cf = [RagdollConfig config];
	cf.scale = .3 + (.7 - .3) * CCRANDOM_0_1(); 
	Ragdoll *rd = [Ragdoll ragdollWithPhysicContext:_physicContext config:cf];
	rd.position = pos;
	[self addActor:rd group:RAGDOLL_GROUP];
	return rd;
}

- (void) scaleChanged:(CCSlider *) slider{
	[self scale:_slider.value];
	[_label setString:[NSString stringWithFormat:@"%.2f",_slider.value]];
}

- (void) dealloc{
	NSArray *rs = [self getAllActors:RAGDOLL_GROUP];
	[rs makeObjectsPerformSelector:@selector(releasePhysicAndDestroy:) withObject:[NSNumber numberWithBool:NO]];
	[super dealloc];
}

#pragma mark Touch
- (void) ccTouchesBegan:(NSSet *) touches withEvent:(UIEvent *) event{
	if (_mouseNode != nil) {
		return;
	}
	
	CGPoint pos = [self pointForTouches:touches];
	b2Body *body = [self queryBodyAtPoint:pos];
	
	if (body != NULL) {
		_mouseNode = [CCJointNode nodeWithJoint:[self createMouseJoint:body staticBody:_static position:pos]];
		_mouseNode.physicContext = _physicContext;
		[self addChild:_mouseNode];
	}else {
		//UITouch *t = [touches anyObject];
		//[self bounceTo:[[CCDirector sharedDirector] convertToGL:[t locationInView:t.view]] duration:2 withFunction:ff];
		//[self addRagdollAt:pos];
	}
}

- (void) ccTouchesMoved:(NSSet *) touches withEvent:(UIEvent *) event{
	if (_mouseNode != nil) {
		_mouseNode.position = [self pointForTouches:touches];
	}else {
		
	}
}

- (void) ccTouchesEnded:(NSSet *) touches withEvent:(UIEvent *) event{
	if(_mouseNode != nil){
		//_physicContext->DestroyJoint(_mouse);
		//_mouseNode = nil;
		[_mouseNode removeFromParentAndCleanup:YES];
		_mouseNode = nil;
	}
}

#pragma mark UIGestureRecognizer
- (void) pinch:(UIPinchGestureRecognizer *) reg{
	if (reg.state == UIGestureRecognizerStateBegan) {
		_scale_ = _layer.scale;
	}
	[self scale:_scale_ * reg.scale];	
}

- (void) pause{
	if (_state == rStatePlaying) {
		[self freezeAllChilden];
		_state = rStatePause;
	}
}

- (void) resume{
	if (_state == rStatePause) {
		[self unFreezeAllChilden];
		_state = rStatePlaying;
	}
}


#pragma mark OnGameMenuDelegate
- (void) simpleMenuDidShow:(SimpleMenu *) menu{
	
}

- (void) simpleMenuDidHide:(SimpleMenu *) menu{
	[self resume];
}

- (void) simpleMenuWillShow:(SimpleMenu *) menu{
	[self pause];
}

- (void) simpleMenuWillHide:(SimpleMenu *) menu{
	
}

- (void) simpleMenu:(SimpleMenu *) menu didActivateItemTag:(int) tag{
	switch (tag) {
		case kSimpleMenuDynamicHome:
			[[CCDirector sharedDirector] homeContext];
			break;
			
		case kSimpleMenuDynamicRestart:
			menu.delegate = nil;
			[[CCDirector sharedDirector] followContext];
			break;
			
		case kSimpleMenuDynamicResume:
			[menu hide];
			break;	
	}	
}
@end
