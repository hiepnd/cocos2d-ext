//
//  HomeContext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/7/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#import "HomeMenu.h"
#import "CCBlade.h"
#import "TouchTrailLayer.h"

@interface HomeContext : CCContext <HomeMenuDelegate>{
	HomeMenu *_mainMenu;
	CCBlade *w;
	
	CCNode *target;
}
@end
