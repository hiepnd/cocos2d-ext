//
//  ContextDirector.m
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/6/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import "ContextDirector.h"
#import "CCContext.h"
#import "Utils.h"
#import "AppDirector.h"

@implementation ContextDirector
@synthesize stage;

- (id) init{
	self = [super init];
	attached = false;
	_stack = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc{
	[_stack release];
	[super dealloc];
}

- (void) pause{
	[[CCDirector sharedDirector] pause];
}

- (void) resume{
	[[CCDirector sharedDirector] resume];
}

- (void) attachInWindow:(UIWindow *) window{
	NSAssert(!attached,@"");
	[CCDirector setUpInWindow:window];
	attached = true;
}

- (void) attachInView:(UIView *) view{
	NSAssert(!attached,@"");
	[CCDirector setUpInView:view];
	attached = true;
}

- (void) runWithContext:(CCContext *) context{
	//[context onEnter];
	[[CCDirector sharedDirector] runWithScene:[context scene]];
	[_stack addObject:context];
	_runningContext = context;
}

- (void) pushContext:(CCContext *) context{
	[context onEnter];
	[[CCDirector sharedDirector] pushScene:[context scene]];
	[_stack addObject:context];
	_runningContext = context;
}

- (void) popContext{
	if ([_stack count] > 0) {
		CCContext *context = [_stack objectAtIndex:[_stack count] - 1];
		CCScene *scene = [[CCDirector sharedDirector] runningScene];
		if (scene == [context scene]) {
			//[context onExit];
			[_stack removeLastObject];
			if ([_stack count] > 0) {
				_runningContext = (CCContext *) [_stack lastObject];
			}else {
				_runningContext = nil;
			}

			[[CCDirector sharedDirector] popScene];
		}
		else {
			[[CCDirector sharedDirector] popScene];
		}

	}else {
		[[CCDirector sharedDirector] popScene];
	}
}

- (void) replaceContext:(CCContext *) context{
	[[self runningContext] onExit];
	[[CCDirector sharedDirector] replaceScene:context];
	//[context onEnter];
	[_stack removeLastObject];
	[_stack addObject:context];
	_runningContext = context;
}

- (CCContext *) runningContext{
	return _runningContext;
}

#if NS_BLOCKS_AVAILABLE
- (void) pushContext:(CCContext *)context withTransitionBlock:(CCScene * (^)(CCScene * scene)) block{
	//[context onEnter];
	[[CCDirector sharedDirector] pushScene:block(context.scene)];
	[_stack addObject:context];
}

- (void) replaceContext:(CCContext *)context withTransitionBlock:(CCScene * (^)(CCScene * scene)) block{
	//[[self runningContext] onExit];
	[[CCDirector sharedDirector] replaceScene:block(context.scene)];
	//[context onEnter];
	[_stack removeLastObject];
	[_stack addObject:context];
}
#endif
@end
