//
//  PhysicUserData.m
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/7/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

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
