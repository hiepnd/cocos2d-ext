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

enum {
	kSimpleMenuStaticPause = 1,
	
};

enum  {
	kSimpleMenuDynamicHome = 1,	
	kSimpleMenuDynamicResume,
	kSimpleMenuDynamicRestart,	
};

@class SimpleMenu;

@protocol SimpleMenuDelegate
@optional 
- (void) simpleMenuDidShow:(SimpleMenu *) menu;
- (void) simpleMenuDidHide:(SimpleMenu *) menu;
- (void) simpleMenuWillShow:(SimpleMenu *) menu;
- (void) simpleMenuWillHide:(SimpleMenu *) menu;
- (void) simpleMenu:(SimpleMenu *) menu didActivateItemTag:(int) tag;
@end

@interface SimpleMenu : CCLayer {
	CCMenu *_menu;
	CCMenu *_staticMenu;
	NSObject<SimpleMenuDelegate> *_delegate;
	BOOL _isShown;
	BOOL _isAnimating;
	
	CCActionInterval *_showAnimation, *_hideAnimation;
	id _animationTarget;
}
@property(assign) NSObject<SimpleMenuDelegate> *delegate;
@property(readonly) BOOL isShown;
@property(readonly) CCMenu *dynamicMenu;
@property(readonly) CCMenu *staticMenu;
@property(retain) CCActionInterval *showAnimation;
@property(retain) CCActionInterval *hideAnimation;
@property(assign) id animationTarget;

/** Show and hide with animation and delegate callbacks  */
- (void) show;
- (void) hide;

/** Show and hide with NO animation and NO delegate callbacks  */
- (void) showImmediately;
- (void) hideImmediately;

/** Toggle with animation  */
- (void) toggle;

/** Get the menu item by its tag  */
- (CCMenuItem *) staticMenuItemBytag:(int) tag;
- (CCMenuItem *) dynamicMenuItemBytag:(int) tag;

- (void) addDynamicItem:(CCMenuItem *) item;
- (void) addStaticItem:(CCMenuItem *) item;

@end
