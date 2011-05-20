//
//  Spaceship.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/6/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"

@class OnGameContext;

enum {
	kSpaceshipMovingNone = 1,
	kSpaceshipMovingLeft,
	kSpaceshipMovingRight,
};

@interface Spaceship : CCComponent {
	float _minX, _maxX;
	int _movingFlag;
	float _xSpeed;
}
@property float minX;
@property float maxX;
@property float xSpeed;

- (void) fire;
- (void) die;

- (void) turnLeft;
- (void) turnRight;
- (void) stopTurn;

- (void) speedUp;
@end
