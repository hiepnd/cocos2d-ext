//
//  CCSlider.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

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
