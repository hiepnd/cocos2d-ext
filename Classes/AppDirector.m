//
//  AppDirector.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/7/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "AppDirector.h"

static int __appState__ = kAppStateInvalid;

@implementation CCDirector(AppDirector)

- (int) appState{
	return __appState__;
}

- (void) prepareLoad32BitsPixelFormat{
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
}

- (void) resumeDefaultPixelFormat{
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
}

- (CCContext *) runningContext{
	CCScene *scene = [self runningScene];
	if ([scene isKindOfClass:[CCContext class]]) {
		return (CCContext *) scene;
	}
	
	return nil;
}

#pragma mark Scene managements
- (void) loadingContext{
	LoadingContext *context = [LoadingContext context];
	//context.showLogoOnly = YES;
	[self runWithScene:context];
	__appState__ = kAppStateLoading;
}

- (void) homeContext{
	CCScene *home = [HomeContext context];
	[self replaceScene:home];
	__appState__ = kAppStateHome;
}

- (void) simpleGameContext{
	[self replaceScene:[OnGameContext context]];
	__appState__ = kAppStateOnGame;
}

- (void) ragdollContext{
	[self replaceScene:[RagdollContext context]];
	__appState__ = kAppStateRagdollTest;
}

- (void) followContext{
	[self replaceScene:[FollowContext context]];
}

- (void) jointContext{
	[self replaceScene:[JointsTestContext context]];
}

- (void) ropeContext{
	[self replaceScene:[HelloWorld scene]];
}
@end