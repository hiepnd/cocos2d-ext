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
