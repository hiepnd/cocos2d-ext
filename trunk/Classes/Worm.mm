//
//  Worm.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 5/13/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Worm.h"


@implementation Worm

- (id) init{
	self = [super init];
	trails = [[NSMutableArray alloc] init];
	
	return self;
}

- (void) onEnter{
	for (CCNode *node in trails) {
		[self.parent addChild:node];
	}
	[super onEnter];
}

- (void) onExit{
	for (CCNode *node in trails) {
		[node removeFromParentAndCleanup:YES];
	}
	[super onExit];
}

- (void) dealloc{
	[trails release];
	[super dealloc];
}

- (void) setPosition:(CGPoint) pos{
	if (!CGPointEqualToPoint(pos, position_)) {
		trailPoints.push_front(pos);
		if (trailPoints.size() > [trails count]) {
			trailPoints.pop_back();
		}
		
		//Set position of trails
		CCNode *node;
		for (unsigned int i = 0; i < [trails count]; i++) {
			node = (CCNode *)[trails objectAtIndex:i];
			
		}
	}
	
	[super setPosition:pos];
}

- (void) pushTrail:(CCNode *) node{
	[trails addObject:node];
	if (self.parent != nil) {
		[self.parent addChild:node];
	}
}

- (void) popTrail{
	CCNode *node = (CCNode *) [trails lastObject];
	[node removeFromParentAndCleanup:YES];
	[trails removeLastObject];
}

@end
