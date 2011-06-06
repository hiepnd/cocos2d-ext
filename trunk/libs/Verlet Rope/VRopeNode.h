//
//  VRopeNode.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/20/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "VPoint.h"
#import "VStick.h"

@interface VRopeNode : CCNode {
	int numPoints;
	NSMutableArray *vPoints;
	NSMutableArray *vSticks;
	NSMutableArray *ropeSprites;
	CCSpriteBatchNode* spriteSheet;
	float antiSagHack;
#ifdef BOX2D_H
	b2Body *bodyA;
	b2Body *bodyB;
#endif
	
}
#ifdef BOX2D_H
-(id)init:(b2Body*)body1 body2:(b2Body*)body2 spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(void)update:(float)dt;
-(void)reset;
#endif
-(id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt;
-(void)debugDraw;
-(void)updateSprites;
-(void)removeSprites;
@end
