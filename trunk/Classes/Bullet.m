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
