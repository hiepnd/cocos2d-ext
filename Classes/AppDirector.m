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