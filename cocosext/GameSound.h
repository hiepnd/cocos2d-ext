//
//  GameSound.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 11/3/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"


#define APP_KEY				@"__PROJECTNAME___"
#define BACKGROUND_KEY		[NSString stringWithFormat:@"%@/background",APP_KEY]
#define EFFECT_KEY			[NSString stringWithFormat:@"%@/effect",APP_KEY]
#define BACKGROUND_V_KEY	[NSString stringWithFormat:@"%@/backgroundVolume",APP_KEY]
#define EFFECT_V_KEY		[NSString stringWithFormat:@"%@/effectVolume",APP_KEY]
#define DUMMY_KEY			[NSString stringWithFormat:@"%@/dummy",APP_KEY]


/** Define sound paths  */
#define kPathBombExplode	@"bomb.caf"
#define kPathLionCry		@"lion_cry.caf"
#define kPathGlassBroken	@"glass_broken.caf"
#define kPathDie			@"die.caf"

#define kPathBackgroundOngame	@"main_bg.mp4"

@interface GameSound : NSObject {
	BOOL background;
	BOOL effect;
	float backgroundVolume;
	float effectVolume;
	SimpleAudioEngine *engine;
}
@property(nonatomic) BOOL background;
@property(nonatomic) BOOL effect;
@property(nonatomic) float backgroundVolume;
@property(nonatomic) float effectVolume; 

+ (GameSound *) instance;
- (void) preload;
- (void) preloadBackgroundMusic:(NSString *) file;
- (void) preloadEffect:(NSString *) file;
- (void) playEffect:(NSString *) file;
- (void) playBackgroundMusic:(NSString *) file;
- (void) stopBackgroundMusic;
- (void) saveStateToUserDefaults;
- (void) loadStateFromUserDefaults;
@end
