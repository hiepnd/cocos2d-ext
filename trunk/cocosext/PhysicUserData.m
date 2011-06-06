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

#import "PhysicUserData.h"

#if PHYSIC_ENABLED

#if DEBUG_INSTANCES_COUNT
static int PHYSIC_USER_DATA_COUNT = 0;
#endif

@implementation PhysicUserData
@synthesize component = _component;
@synthesize key = _key;
@synthesize type = _type;
@synthesize entity = _entity;

- (id) init{
#if DEBUG_INSTANCES_COUNT
	PHYSIC_USER_DATA_COUNT++;
#endif
	self = [super init];
	
	return self;
}

- (void) dealloc{
#if DEBUG_INSTANCES_COUNT
	PHYSIC_USER_DATA_COUNT--;
	NSLog(@"%@ instance count: %d",[self class],PHYSIC_USER_DATA_COUNT);
#endif
	[_key release];
	[super dealloc];
}
@end

#endif
