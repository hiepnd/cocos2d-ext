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

#import <Foundation/Foundation.h>
#import "LoadingContext.h"
#import "HomeContext.h"
#import "OnGameContext.h"
#import "RagdollContext.h"
#import "FollowContext.h"
#import "JointsTestContext.h"
#import "HelloWorldScene.h"

typedef enum {
	kAppStateInvalid,
	kAppStateLoading,
	kAppStateHome,
	kAppStateLevel,
	kAppStateOnGame,
	kAppStateLeaderBoard,
	kAppStateGameIntro,
	kAppStateRagdollTest,
} ApplicationState;

@interface CCDirector(AppDirector)
@property (readonly) int appState;

- (void) prepareLoad32BitsPixelFormat;
- (void) resumeDefaultPixelFormat;

- (CCContext *) runningContext;

//Manage scenes
- (void) jointContext;
- (void) loadingContext;
- (void) homeContext;
- (void) simpleGameContext;
- (void) ragdollContext;
- (void) followContext;
- (void) ropeContext;
@end

