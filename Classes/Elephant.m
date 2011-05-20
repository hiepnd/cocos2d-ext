//
//  Elephant.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/26/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Elephant.h"
#import "OnGameContext.h"

@implementation Elephant

- (id) init{
	self = [super initWithFile:@"elephant_def.plist"];
	
	return self;
}

- (void) jump{
	[self setState:@"walk"];
}

- (void) goLeft{
	[self setState:@"go"];
	[self setFlipX:NO];
}

- (void) goRight{
	[self setState:@"go"];
	[self setFlipX:YES];
}

- (void) idle{
	[self setState:@"idle"];
}

- (void) physicEntity:(PhysicUserData *) sdata collideWith:(PhysicUserData *) data info:(CollisionInfo) info{
	static CGPoint v = ccp(1,0);
	float cross = ccpDot(v, ccp(info.normal.x,info.normal.y));
	CCNode *node = (CCNode *)data.component;
	if (cross == 0.0 && node.tag != TAG_BB) {
		[self idle];
	}
	
	if (node.tag == TAG_BB) {
		[self jump];
	}
}
@end
