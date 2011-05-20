//
//  Bullet.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/5/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Bullet.h"
#import "ActorTags.h"
#import "GameSound.h"

static NSArray *_frames_ = [NSArray arrayWithObjects:@"12px-red-arrow.png",@"12px-purple-arrow.png",@"12px-blue-arrow.png",@"12px-red-comet.png",@"12px-purple-comet.png",@"12px-blue-comet.png",nil];

@implementation Bullet

- (id) init{
	self = [super initWithFile:@"bullet_def.plist"];
	int count = [_frames_ count];
	count = ((int)(CCRANDOM_0_1() * count + 1)) % count;
	[self setDisplayFrameName:[_frames_ objectAtIndex:count]];
	_destroyPhysicOnDealloc = YES;
	return self;
}

- (CGRect) rect{
	return CGRectMake(6, 6, 12, 12);
}

- (void) explode{
	[self stopAllActions];
	[self setDisplayFrameName:@"40px-electric.png"];
	self.scale = .2;
	CCActionInterval *action = [CCSpawn actionOne:[CCScaleTo actionWithDuration:.5 scale:1] 
											  two:[CCRotateBy actionWithDuration:.5 angle:360]];
	[self runAction:action context:nil target:self selector:@selector(didExplode:)];
}

- (void) didExplode:(id) context{
	[self removeFromParentAndCleanup:YES];
	//[[GameSound instance] playEffect:kPathBombExplode];
}

- (void) physicEntity:(PhysicUserData *)sdata collideWith:(PhysicUserData *)data info:(CollisionInfo)info{
//	CCComponent *node = (CCComponent *) data.component;
//	if (node.tag == ACTOR_TAG_BRIDGE || node.tag == ACTOR_TAG_BULLET) {
//		self.invalid = YES;
//		[self explode];
//	}
}
@end
