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
#import "cocos2d.h"

/** Does the edge from v1 to v2 separate v3 and rect ?  */
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