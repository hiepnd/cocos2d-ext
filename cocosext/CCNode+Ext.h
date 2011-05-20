//
//  CCNode+Ext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/9/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

inline bool isSeparate(CGPoint v1, CGPoint v2, CGPoint v3, CGPoint *rect);

@interface CCNode(Ext) 
- (CGAffineTransform) nodeToNodeTransform:(CCNode *) node;
- (CGAffineTransform) nodeFromNodeTransform:(CCNode *) node;

/** The collidable rectangle  */
- (CGRect) rect;

- (CGRect) convertRectToNodeSpace:(CGRect) wrect;
- (CGPoint) convertToNodeSpace:(CGPoint) otherpoint otherNode:(CCNode *) node;
- (BOOL) containsPoint:(CGPoint) loc includeChilds:(BOOL) no;
- (BOOL) containsPoint:(CGPoint) loc;
- (BOOL) containsTouch:(UITouch *) touch;

//- (BOOL) nodeRect:(CGRect) lrect intersectWithWorldRect:(CGRect) wrect;
- (BOOL) nodeRect:(CGRect) lrect containsWorldPoint:(CGPoint) wpoint;
//- (BOOL) nodeRect:(CGRect) lrect containsRect:(CGRect) rect ofNode:(CCNode *) node;

/** Check the intersection of caller's and callee's rects  */
- (BOOL) isCollideWithNode:(CCNode *) node;

- (void) mergeNode:(CCNode *) node;

#if NS_BLOCKS_AVAILABLE
- (void) runAction:(CCActionInterval *) action inContext:(NSString *) context withCompletionHandler:(void (^)(CCNode * component, NSString * context)) handler;
#endif

- (void) runAction:(CCActionInterval *) action context:(NSString *) context target:(id) target selector:(SEL) selector;
- (void) runAction:(CCActionInterval *) action target:(id) target selector:(SEL) selector;

- (void) drawLineFrom:(CGPoint) from to:(CGPoint) to width:(float) width color:(ccColor4F) color;
- (void) drawLineFrom:(CGPoint) from to:(CGPoint) to texture:(CCTexture2D *) texture baseLength:(float) base stretch:(BOOL) stretch; 

+ (float) degree:(CGPoint) vect;
@end