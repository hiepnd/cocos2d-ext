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

#import "CCSlider.h"

@interface CCSlider(Private)
- (BOOL) knobTouched:(CGPoint) loc;
- (void) setValueByX:(float) xpos;
@end

@implementation CCSlider(Private)
- (BOOL) knobTouched:(CGPoint) loc{
	if ([self containsPoint:loc]) {
		loc = [self convertToNodeSpace:loc];
		return  fabs(_knob.position.x - loc.x) < _knob.contentSize.width/2;
	}
	
	return NO;
}


- (void) setValueByX:(float) xpos{
	xpos = xpos < -_track.contentSize.width/2 ? -_track.contentSize.width/2 : xpos;
	xpos = xpos > _track.contentSize.width/2 ? _track.contentSize.width/2 : xpos;
	_knob.position = ccp(xpos,_knob.position.y);
	_value = (xpos + _track.contentSize.width/2) / _track.contentSize.width * (_maxValue - _minValue) + _minValue;
	if (_target) {
		[_target performSelector:_selector withObject:self];
	}
}
@end


@implementation CCSlider
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize value = _value;
@synthesize trackTouchOutsideContent = _trackTouchOutsideContent;
@synthesize height = _height;
@synthesize evaluateFirstTouch = _evaluateFirstTouch;
@synthesize enabled = _enabled;

+ (id) sliderWithTrackImage:(NSString *) track knobImage:(NSString *) knob target:(id) target selector:(SEL) selector{
	return [[[self alloc] initWithTrackImage:track knobImage:knob target:target selector:selector] autorelease] ;
}

- (id) initWithTrackImage:(NSString *) track knobImage:(NSString *) knob target:(id) target selector:(SEL) selector{
	self = [super init];
	_track = [CCSprite spriteWithFile:track];
	_knob = [CCSprite spriteWithFile:knob];
	_target = target;
	_selector = selector;
	_minValue = 0;
	_maxValue = 100;
	
	[self addChild:_track];
	[self addChild:_knob];
	
	_width = _track.contentSize.width;
	_height = 45;
	
	_enabled = YES;
	
	return self;
}

- (float) horizontalPadding{
	return (_width - _track.contentSize.width) / 2;
}

- (void) setHorizontalPadding:(float) p{
	_width = _track.contentSize.width + 2 * p;
}

- (void) onEnter{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void) onExit{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL) containsPoint:(CGPoint)loc {
	loc = [self convertToNodeSpace:loc];
	CGRect rect = CGRectMake(-_width/2, -_height/2, _width, _height);
	return CGRectContainsPoint(rect, loc);
}


- (void) setValue:(float) v{
	if (!_enabled) {
		return;
	}
	v = v < _minValue ? _minValue : v;
	v = v > _maxValue ? _maxValue : v;
	
	_value = v;
	float x = (_value - _minValue) / (_maxValue - _minValue) * _track.contentSize.width;
	_knob.position = ccp(x - _track.contentSize.width/2,_knob.position.y);
	if (_target) {
		[_target performSelector:_selector withObject:self];
	}
}

#pragma mark TOUCH
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
	if (!visible_ || !_enabled) {
		return NO;
	}
	CGPoint loc = [touch locationInView:touch.view];
	loc = [[CCDirector sharedDirector] convertToGL:loc];
	
	if ([self containsPoint:loc]) {
		if (_evaluateFirstTouch) {
			[self setValueByX:[self convertToNodeSpace:loc].x];
			_trackingTouch = YES;
			return YES;
		}else {
			_trackingTouch = [self knobTouched:loc];
			return _trackingTouch;
		}
		
	}
	
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
	if (!visible_ || !_enabled) {
		return;
	}
	
	if (_trackingTouch) {
		CGPoint loc = [touch locationInView:touch.view];
		loc = [[CCDirector sharedDirector] convertToGL:loc];
		
		if (_trackTouchOutsideContent) {
			[self setValueByX:[self convertToNodeSpace:loc].x];
		}else {
			if([self containsPoint:loc]){
				[self setValueByX:[self convertToNodeSpace:loc].x];
			}else {
				_trackingTouch = NO;
			}
		}
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
	_trackingTouch = NO;
}
@end
