//
//  CCSprite+Ext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/31/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

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
