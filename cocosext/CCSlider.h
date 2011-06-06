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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNode+Ext.h"

@interface CCSlider : CCNode <CCTargetedTouchDelegate>{
	float _minValue;
	float _maxValue;
	float _value;
	
	SEL _selector;
	id _target;
	
	BOOL _trackingTouch;
	BOOL _trackTouchOutsideContent;
	BOOL _evaluateFirstTouch;
	BOOL _enabled;
	
	float _width;
	float _height;
	
	CCSprite *_track;
	CCSprite *_knob;
}
@property(nonatomic) float minValue;
@property(nonatomic) float maxValue;
@property(nonatomic) float value;
@property(nonatomic) BOOL trackTouchOutsideContent;
@property(nonatomic) float horizontalPadding;
@property(nonatomic) float height;
@property(nonatomic) BOOL evaluateFirstTouch;
@property(nonatomic) BOOL enabled;

- (id) initWithTrackImage:(NSString *) track knobImage:(NSString *) knob target:(id) target selector:(SEL) selector;
+ (id) sliderWithTrackImage:(NSString *) track knobImage:(NSString *) knob target:(id) target selector:(SEL) selector;
@end
