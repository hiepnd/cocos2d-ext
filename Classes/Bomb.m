//
//  Bomb.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 2/14/11.
//  Copyright © 2011 PTT Solution., JSC . All rights reserved.
//

#import "Bomb.h"


@implementation Bomb

- (id) init{
	self = [super initWithFile:@"bombdef.plist"];
	count = CCRANDOM_0_1() * 5 + 1;
	return self;
}

- (void) onExit{
	[super onExit];
}

- (void) onEnter{
	[self child:@"time"].state = [NSString stringWithFormat:@"%d",count];
	[self schedule:@selector(countdown) interval:1.0];
	[super onEnter];
}

- (void) countdown{
	count --;
	if (count == 0) {
		[self child:@"time"].visible = FALSE;
		[[self child:@"explosion"] setState:@"die" 
									context:nil 
									 target:self
								   selector:@selector(bombDidExplode:)];
		[self unschedule:@selector(countdown)];
	}else 
		[self child:@"time"].state = [NSString stringWithFormat:@"%d",count];
}

- (void) bombDidExplode:(NSString *) context{
	[self removeFromParentAndCleanup:YES];
}

- (void) dealloc{
	[super dealloc];
}
@end
