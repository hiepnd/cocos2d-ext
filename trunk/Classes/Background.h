//
//  Background.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Background : CCNode {
	float _speed;
	CCSprite *s1,*s2;
}
@property float speed;

- (id) initWithImage:(NSString *) im1 andImage:(NSString *) im2;
- (void) move:(float) dy;
@end
