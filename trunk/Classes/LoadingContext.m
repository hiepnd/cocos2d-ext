//
//  LoadingContext.m
//  save_me2
//
//  Created by Hoang Minh Quan on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingContext.h"
#import "GameSound.h"
#import "Global.h"

@implementation LoadingContext
@synthesize showLogoOnly;

- (id) init{
	self = [super init];	
	
	[self addAutoreleaseTexture:@"ptt-logo.png"];
	[self addAutoreleaseTexture:@"garden4.png"];
	[self addAutoreleaseSpriteFrame:@"xxx.plist"];
	
	logo = [CCSprite spriteWithFile:@"ptt-logo.png"];
	logo.opacity = 0;
	logo.position = CGPointMake(179+63, 320 - 88 - 58);
	[self addChild:logo z:1];
	
	[NSThread detachNewThreadSelector:@selector(loadResources) toTarget:self withObject:nil];
	
	return self;
}

- (void) onEnter{
	if (self.showLogoOnly) {
		[logo runAction:[CCSequence actions:[CCFadeIn actionWithDuration:1],
						 [CCDelayTime actionWithDuration:1],
						 [CCFadeOut actionWithDuration:1],
						 [CCCallFunc actionWithTarget:self selector:@selector(home)],
						 nil
						 ]];
	}else {
		[logo runAction:[CCFadeIn actionWithDuration:1.5]];
	}
	
	[super onEnter];
}

//Load home context here, keep in mind that the Loading context is already in place
- (void) home{
	[[CCDirector sharedDirector] homeContext];
}

- (void) loadDone{
	[logo runAction:[CCSequence actions:
					 [CCFadeOut actionWithDuration:1],
					 [CCCallFunc actionWithTarget:self selector:@selector(home)],nil]];
}

- (void) loadResources{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:.7];
	
	EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
	[EAGLContext setCurrentContext:k_context];
	
	//TODO: Pre load resources here
	//[[GameSound instance] preloadEffect:@""];
	[[GameSound instance] preloadBackgroundMusic:kPathBackgroundOngame];
	[[GameSound instance] preloadEffect:kPathBombExplode];
	[[GameSound instance] preloadEffect:kPathDie];
	[[GameSound instance] preloadEffect:kPathGlassBroken];
	[[GameSound instance] preloadEffect:kPathLionCry];
	
	[self performSelectorOnMainThread:@selector(loadDone) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void) setPercentComplete:(int) percent{
	
}
@end
