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
#import "CCNode+Ext.h"
#import "constant+macro.h"
#import "CCComponent.h"

#if PHYSIC_ENABLED

#import "Box2D.h"
#import "PhysicUserData.h"
#import "PhysicContext.h"

@interface CCJointNode : CCNode<PhysicProtocol> {
	b2Joint *_joint;
	
	float _baseLength;
	float _baseLength2;
	float _baseLength3;
	
	float _lineWidth;
	ccColor4F _lineColor;
	
	//If the _texture is not nil, will draw with texture
	CCTexture2D *_texture;
	
	BOOL _stretchLine;
	
	//Physic
	BOOL _isValid;
	PhysicUserData *_userData;
	PhysicContext *_physicContext;
}
@property float lineWidth;
@property BOOL stretchLine;
@property ccColor4F lineColor;
@property (retain) NSString *texture;
@property (readonly) b2Joint *joint;
@property (assign) PhysicContext *physicContext;

- (id) initWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg;
- (id) initWithJoint:(b2Joint *) joint;
+ (id) nodeWithJoint:(b2Joint *) joint registerPhysic:(BOOL) reg;
+ (id) nodeWithJoint:(b2Joint *) joint;

- (void) drawDistanceJoint:(b2DistanceJoint *) joint;
- (void) drawDistanceJointWithTexture:(b2DistanceJoint *) joint ;

- (void) drawRevoluteJoint:(b2RevoluteJoint *) joint;
- (void) drawRevoluteJointWithTexture:(b2RevoluteJoint *) joint ;

- (void) drawPulleyJoint:(b2PulleyJoint *) joint;
- (void) drawPulleyJointWithTexture:(b2PulleyJoint *) joint ;

- (void) drawPrismaticJoint:(b2PrismaticJoint *) joint;
- (void) drawPrismaticJointWithTexture:(b2PrismaticJoint *) joint ;
/*
- (void) drawLineJoint:(b2LineJoint *) joint;
- (void) drawLineJointWithTexture:(b2LineJoint *) joint ;
 */
@end

#endif