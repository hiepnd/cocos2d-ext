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

#import "CCSprite+Ext.h"


@implementation CCSprite(Ext)
//- (CGRect) rect{
//	return CGRectMake(0, 0, contentSize_.width, contentSize_.height);
//}

- (CCAction *) animateFrames:(NSArray *) frames 
					duration:(float) duration 
					 reverse:(BOOL) reverse 
					 forever:(BOOL) forever{
	
	NSMutableArray *ar = [NSMutableArray array];
	for (int i = 0; i < [frames count]; i++) {
		[ar addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[frames objectAtIndex:i]]];
	}
	if (reverse) {
		int i = [frames count] - 2;
		for (;i >= 0;i--) {
			[ar addObject:[ar objectAtIndex:i]];
		}
	}
	CCAction *action = [CCAnimation animationWithFrames:ar delay:duration];
	if (forever) {
		action = [CCRepeatForever actionWithAction:(CCActionInterval *)action];
	}
	[self runAction:action];
	
	return action;

}

- (CCAction *) animateFramesWithKey:(NSString *) key 
						 startIndex:(int) start 
						   endIndex:(int) end 
						   duration:(float) duration 
							reverse:(BOOL) reverse 
							forever:(BOOL) forever{
	
	NSMutableArray *frames = [NSMutableArray array];
	BOOL backward = end < start;
	for(int i = start; backward ? i >= end : i <= end; backward ? i-- : i++){
		[frames addObject:[NSString stringWithFormat:@"%@%d.png",key,i]];
	}
	
	return [self animateFrames:frames duration:duration reverse:reverse forever:forever];
}

- (void) setDisplayFrameName:(NSString *) name{
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name]];
}
@end
