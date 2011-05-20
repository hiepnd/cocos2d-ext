//
//  CCSprite+Ext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/31/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCSprite(Ext)

- (CCAction *) animateFrames:(NSArray *) frames 
			  duration:(float) duration 
			   reverse:(BOOL) reverse 
			   forever:(BOOL) forever;

- (CCAction *) animateFramesWithKey:(NSString *) key 
				   startIndex:(int) start 
					 endIndex:(int) end 
					 duration:(float) duration 
					  reverse:(BOOL) reverse 
					  forever:(BOOL) forever;

- (void) setDisplayFrameName:(NSString *) name;
@end
