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
