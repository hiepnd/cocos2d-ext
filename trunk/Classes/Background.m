//
//  Background.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Background.h"


@implementation Background
@synthesize speed = _speed;

- (id) initWithImage:(NSString *) im1 andImage:(NSString *) im2{
	self = [super init];
	s1 = [CCSprite spriteWithFile:im1];
	s2 = [CCSprite spriteWithFile:im2];
	s1.position = ccp(240,160);
	s2.position = ccp(240,480);
	
	_speed = 2;
	
	[self addChild:s1];
	[self addChild:s2];
	
	return self;
}

- (void) move:(float) dy{
	s1.position = ccp(s1.position.x,s1.position.y - dy);
	s2.position = ccp(s2.position.x,s2.position.y - dy);
	
	if (s1.position.y < -160) {
		CCNode *tem = s2;
		s1.position = ccp(240,480);
		s2 = s1;
		s1 = tem;
	}
}
@end
