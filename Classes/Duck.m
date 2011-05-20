//
//  Duck.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/8/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Duck.h"


@implementation Duck

- (id) init{
	self = [super initWithFile:@"duck_def.plist"];
	
	return self;
}

- (void) onEnter{
	[self setState:@"idle"];
	//NSLog(@"Duck=%@",NSStringFromCGRect([self rect]));
	[super onEnter];
}

- (CGRect) rect{
	return CGRectMake(6, 6, 46, 30);
}

- (void) getHurt{
	
}

- (void) die{
	[self setState:@"die"];
	[self removeFromParentAndCleanup:YES];
}
@end
