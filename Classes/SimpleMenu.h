//
//  SimpleMenu.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

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
