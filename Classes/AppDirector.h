//
//  AppDirector.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/7/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

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

