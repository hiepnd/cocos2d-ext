//
//  CCNode+Ext.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "CCNode+Ext.h"

#define _SIGN_(p)	((n.x * (p.x-v1.x) + n.y * (p.y - v1.y)) >= 0)

/** Does the edge from v1 to v2 separate v3 and rect ?  */
bool isSeparate(CGPoint v1, CGPoint v2, CGPoint v3, CGPoint *rect){
	CGPoint n = ccpSub(v1, v2);
	n = ccpPerp(n);
	BOOL sign = _SIGN_(v3);
	
	if (_SIGN_(rect[0]) == sign) {
		return NO;
	}
	
	if (_SIGN_(rect[1]) == sign) {
		return NO;
	}
		
	if (_SIGN_(rect[2]) == sign) {
		return NO;
	}
	
	if (_SIGN_(rect[3]) == sign) {
		return NO;
	}
	//NSLog(@"Found(%.2f,%.2f) (%.2f,%.2f)",v1.x,v1.y,v2.x,v2.y);
	return YES;
}

/** Is there any of r1's edges separate the two rectangle ?  */
bool _isSeparate(CGPoint rect1[], CGPoint rect2[]){
	if (isSeparate(rect1[0],rect1[1], rect1[2], rect2)) {
		return YES;
	}
	
	if (isSeparate(rect1[1],rect1[2], rect1[3], rect2)) {
		return YES;
	}
	
	if (isSeparate(rect1[2],rect1[3], rect1[1], rect2)) {
		return YES;
	}
	
	if (isSeparate(rect1[3],rect1[0], rect1[2], rect2)) {
		return YES;
	}
	//
	if (isSeparate(rect2[0],rect2[1], rect2[2], rect1)) {
		return YES;
	}
	
	if (isSeparate(rect2[1],rect2[2], rect2[3], rect1)) {
		return YES;
	}
	
	if (isSeparate(rect2[2],rect2[3], rect2[1], rect1)) {
		return YES;
	}
	
	if (isSeparate(rect2[3],rect2[0], rect2[2], rect1)) {
		return YES;
	}
	
	return NO;
}

@interface CCNode(ExtPrivate)

@end

@implementation CCNode(ExtPrivate)
- (BOOL) _nodeRect:(CGRect) lrect containsRect:(CGRect) rect ofNode:(CCNode *) node{
	CGAffineTransform transform = [node nodeToNodeTransform:self];
	CGPoint p1 = CGPointApplyAffineTransform(ccp(rect.origin.x, rect.origin.y),transform);
	CGPoint p2 = CGPointApplyAffineTransform(ccp(rect.origin.x, rect.origin.y + rect.size.height), transform);
	CGPoint p3 = CGPointApplyAffineTransform(ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), transform);
	CGPoint p4 = CGPointApplyAffineTransform(ccp(rect.origin.x + rect.size.width, rect.origin.y), transform);
	
	float upper = lrect.origin.y + lrect.size.height;
	float lower = lrect.origin.y;
	if (p1.y >= upper && p2.y >= upper && p3.y >= upper && p4.y >= upper) {
		return NO;
	}
	
	if (p1.y <= lower && p2.y <= lower && p3.y <= lower && p4.y <= lower) {
		return NO;
	}
	
	upper = lrect.origin.x + lrect.size.width;
	lower = lrect.origin.x;
	if (p1.x >= upper && p2.x >= upper && p3.x >= upper && p4.x >= upper) {
		return NO;
	}
	
	if (p1.x <= lower && p2.x <= lower && p3.x <= lower && p4.x <= lower) {
		return NO;
	}
	
	return YES;
}
@end


@implementation CCNode(Ext)
- (CGAffineTransform) nodeToNodeTransform:(CCNode *) node{
	CGAffineTransform t1 = [self nodeToWorldTransform];
	CGAffineTransform t2 = [node worldToNodeTransform];
	
	return CGAffineTransformConcat(t1, t2);
}

- (CGAffineTransform) nodeFromNodeTransform:(CCNode *) node{
	return CGAffineTransformInvert([self nodeToNodeTransform:node]);
}

- (CGRect) rect{
	return CGRectMake(0, 0, contentSize_.width, contentSize_.height);
}

- (CGRect) convertRectToNodeSpace:(CGRect) wrect{
	return CGRectApplyAffineTransform(wrect, [self worldToNodeTransform]);
}

- (CGPoint) convertToNodeSpace:(CGPoint) otherpoint otherNode:(CCNode *) node{
	return CGPointApplyAffineTransform(otherpoint, [node nodeToNodeTransform:self]);
}

- (BOOL) containsPoint:(CGPoint) loc includeChilds:(BOOL) no{
	CGPoint pos = [self convertToNodeSpace:loc];
	
	CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	if (CGRectContainsPoint(rect, pos)) {
		return YES;
	}
	if (no) {
		CCNode *node;
		CCARRAY_FOREACH(children_,node){
			if ([node containsPoint:loc]) {
				return YES;
			}
		}
	}
	return FALSE;
}

- (BOOL) containsPoint:(CGPoint) loc{
	return [self containsPoint:loc includeChilds:NO];
}

- (BOOL) containsTouch:(UITouch *) touch{
	return [self containsPoint:
			[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]
			];
}

- (BOOL) nodeRect:(CGRect) lrect intersectWithWorldRect:(CGRect) wrect{
	CGRect rect = [self convertRectToNodeSpace:wrect];
	return CGRectIntersectsRect(rect, lrect);
}

- (BOOL) nodeRect:(CGRect) lrect containsWorldPoint:(CGPoint) wpoint{
	return CGRectContainsPoint(lrect, [self convertToNodeSpace:wpoint]);
}

- (BOOL) nodeRect:(CGRect) lrect containsRect:(CGRect) rect ofNode:(CCNode *) node{
	//return [self _nodeRect:lrect containsRect:rect ofNode:node];
	NSAssert(FALSE,@"Not supported");
	return FALSE;
}

- (BOOL) isCollideWithNode:(CCNode *) node{
	CGPoint r1[4], r2[4];

	CGRect rr = [self rect];
	CGAffineTransform transform = [self nodeToWorldTransform];
	r1[0] = CGPointApplyAffineTransform(ccp(rr.origin.x,rr.origin.y), transform);
	r1[1] = CGPointApplyAffineTransform(ccp(rr.origin.x,rr.origin.y + rr.size.height), transform);
	r1[2] = CGPointApplyAffineTransform(ccp(rr.origin.x + rr.size.width,rr.origin.y + rr.size.height), transform);
	r1[3] = CGPointApplyAffineTransform(ccp(rr.origin.x + rr.size.width,rr.origin.y), transform);
	
	rr = [node rect];
	transform = [node nodeToWorldTransform];
	r2[0] = CGPointApplyAffineTransform(ccp(rr.origin.x,rr.origin.y), transform);
	r2[1] = CGPointApplyAffineTransform(ccp(rr.origin.x,rr.origin.y + rr.size.height), transform);
	r2[2] = CGPointApplyAffineTransform(ccp(rr.origin.x + rr.size.width,rr.origin.y + rr.size.height), transform);
	r2[3] = CGPointApplyAffineTransform(ccp(rr.origin.x + rr.size.width,rr.origin.y), transform);
	
	return !_isSeparate(r1, r2);
}

- (BOOL) _isCollideWithNode:(CCNode *) node{
	if (![self _nodeRect:[self rect] containsRect:[node rect] ofNode:node]) {
		return NO;
	 }
	 
	 if (![node _nodeRect:[node rect] containsRect:[self rect] ofNode:self]) {
		 return NO;
	 }
	 
	 return YES;
}

//Do some fun stuff
- (void) mergeNode:(CCNode *) node{
	CGPoint position = [self convertToNodeSpace:node.position];
	node.position = position;
	node.rotation = - self.rotation + node.rotation;
	//Persist node's size
	node.scale = node.scale / self.scale;
	
	if (node.parent != nil) {
		[node retain];
		[node removeFromParentAndCleanup:NO];
		[node autorelease];
	}
	
	[self addChild:node];
}

#if NS_BLOCKS_AVAILABLE
- (void) runAction:(CCActionInterval *) action inContext:(NSString *) context withCompletionHandler:(void (^)(CCNode * component, NSString * context)) handler{
	//CCCallFuncND *f = [CCCallFuncND actionWithTarget:self selector:@selector(didDoActionInContext:) data:context];
}
#endif

- (void) runAction:(CCActionInterval *) action_ 
		   context:(NSString *) context 
			target:(id) target
		  selector:(SEL) selector{
	
	CCAction *todo = action_;
	if (target && selector) {
		todo = [CCSequence actionOne:action_ 
								 two:[CCCallFuncND actionWithTarget:target selector:selector data:context]];
	}
	[self runAction:todo];
}

- (void) runAction:(CCActionInterval *) action target:(id) target selector:(SEL) selector{
	CCAction *todo = action;
	if (target && selector) {
		todo = [CCSequence actionOne:action
								 two:[CCCallFuncND actionWithTarget:target selector:selector data:self]];
	}
	[self runAction:todo];
}


#pragma mark Drawing
- (void) drawLineFrom:(CGPoint) from 
				   to:(CGPoint) to 
				width:(float) width 
				color:(ccColor4F) color{
	
	glLineWidth(width);
	glColor4f(color.r, color.g, color.b, color.a);
	ccDrawLine(from, to);
}

- (void) drawLineFrom:(CGPoint) from 
				   to:(CGPoint) to 
			  texture:(CCTexture2D *) texture  
		   baseLength:(float) base
			  stretch:(BOOL) stretch{
	
	float length = stretch ? base : ccpDistance(from, to);
	float pwide = texture.pixelsWide;
	float phigh = texture.pixelsHigh/2;
	
	if (stretch) {
		length = ((int) length/pwide) * pwide;
	}
	
	float vertices[] = {0,phigh,
		length,  phigh,
		0,-phigh,
		length, -phigh
	};
	float textCoors[] = {0.,1.,
		length/pwide,
		1.,0.,0.,
		length/pwide,0.};
	
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, [texture name]);

	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textCoors);
	
	glTranslatef(from.x, from.y, 0.0f);
	glRotatef([CCNode degree:ccpSub(to, from)], 0.0f, 0.0f, 1.0f);
	if (stretch) {
		glScalef(ccpDistance(from, to) / length, 1.0f, 1.0f);
	}
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glEnableClientState(GL_COLOR_ARRAY);
	
	glPopMatrix();
}

+ (float) degree:(CGPoint) vect{
	if (vect.x == 0.0 && vect.y == 0.0) {
		return 0;
	}
	
	if (vect.x == 0.0) {
		return vect.y > 0 ? 90 : -90;
	}
	
	if (vect.y == 0.0 && vect.x < 0) {
		return -180;
	}
	
	float angle = atan(vect.y / vect.x) * 180 / M_PI;
	
	return vect.x < 0 ? angle + 180 : angle;
}
@end