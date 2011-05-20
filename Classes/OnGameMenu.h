//
//  OnGameMenu.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleMenu.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"

enum OnGameMenuItemTag {
	kMenuItemDoNotUse = 1,
	kMenuItemResume,
	kMenuItemRestart,
	kMenuItemHome,
	kMenuItemBackgroundMusic,
	kMenuItemSoundFX,
	kMenuItemToggleBackground,
	
	kMenuItemMoveLeft,
	kMenuItemMoveRight,
	kMenuItemJump,
	
	kSimpleMenuDynamicAutoFire = kSimpleMenuDynamicRestart + 1,
	kSimpleMenuDynamicControlMode,
};

@interface OnGameMenu : SimpleMenu {
	CCLabelTTF *_score;	
	SneakyJoystick *_joyStick;
	SneakyButton *_rightButton;
}
@property(readonly) SneakyJoystick *joyStick;
@property(readonly) SneakyButton *rightButton;

- (void) setScore:(int) score;
- (void) hideJoystick:(BOOL) yesorno;
@end
