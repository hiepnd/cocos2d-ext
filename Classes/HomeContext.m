//
//  HomeContext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/7/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "HomeContext.h"
#import "GLES-Render.h"
#import "AppDirector.h"
#import "FileContentCache.h"

@implementation HomeContext

- (id) init{
	self = [super init];
	
	_isTouchEnabled = YES;

	_mainMenu = [HomeMenu node];
	_mainMenu.delegate = self;
	
	_layer.anchorPoint = ccp(.5,.5);
	
	[self addChild:_mainMenu];
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	CCNode *bg = [CCSprite spriteWithFile:@"garden4.png"];
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	bg.position = ccp(240,160);
	[self addChild:bg];
	
	target = [CCSprite spriteWithFile:@"rock1-1.png"];
//	[self addChild:target];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"trail3.plist"];
	
	return self;
}

- (void) onEnter{
	[[FileContentCache cache] removeUnusedDef];
	[super onEnter];
}

- (void) homeMenu:(HomeMenu *) menu didActivateItemTag:(int) tag{
	switch (tag) {
		case kHomeMenuJoint:
			[[CCDirector sharedDirector] jointContext];
			break;
			
		case kHomeMenuRagdoll:
			[[CCDirector sharedDirector] ragdollContext];	
			break;

		case kHomeMenuFollow:
			[[CCDirector sharedDirector] followContext];
			break;
			
		case kHomeMenuAllInOne:
			[[CCDirector sharedDirector] simpleGameContext];
			break;
		default:
			break;
	}
}

- (void) ccTouchesBegan:(NSSet *) touches withEvent:(UIEvent *) event{
	
}

- (void) ccTouchesMoved:(NSSet *) touches withEvent:(UIEvent *) event{
	//[self moveNode:target byTouch:[touches anyObject]];
}

- (void) ccTouchesEnded:(NSSet *) touches withEvent:(UIEvent *) event{
	
}
@end
