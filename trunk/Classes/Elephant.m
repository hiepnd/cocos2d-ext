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
