//
//  Spaceship.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/6/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Spaceship.h"
#import "OnGameContext.h"

@implementation Spaceship
@synthesize minX = _minX;
@synthesize maxX = _maxX;
@synthesize xSpeed = _xSpeed;

- (id) init{
	self = [super initWithFile:@"spaceship_def.plist"];
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	_minX = 20;
	_maxX = size.width - 20;
	_xSpeed = 2;
	
	_movingFlag = kSpaceshipMovingNone;
	
	return self;
}

- (void) onEnter{
	[self schedule:@selector(tick:)];
	[super onEnter];
}

- (CGRect) rect{
	return CGRectMake(5, 0, 40, 40);
}

- (void) setXSpeed:(float) s{
	_xSpeed = s;
	if (s == 0.0) {
		[self stopTurn];
	}
}

- (void) tick:(ccTime) dt{
	float dx = position_.x;
	switch (_movingFlag) {
		case kSpaceshipMovingLeft:
			dx -= _xSpeed;
			if (dx < _minX) {
				dx = _minX;
				[self stopTurn];
				//[self turnRight];
			}
			break;
			
		case kSpaceshipMovingRight:
			dx += _xSpeed;
			if (dx > _maxX) {
				dx = _maxX;
				[self stopTurn];
				//[self turnLeft];
			}
			break;
			
		default:
			break;
	}
	
	self.position = ccp(dx, position_.y);
}

- (void) fire{
	
}

- (void) die{
	
}

- (void) turnLeft{
	[self setState:@"left"];
	_movingFlag = kSpaceshipMovingLeft;
}

- (void) turnRight{
	[self setState:@"right"];
	_movingFlag = kSpaceshipMovingRight;
	
}

- (void) stopTurn{
	[self setState:@"idle"];
	_movingFlag = kSpaceshipMovingNone;
}

- (void) speedUp{
	
}

@end
