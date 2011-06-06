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

#import "GameSound.h"

static GameSound *_instance = nil;

@implementation GameSound
@synthesize effect, background;
@synthesize effectVolume, backgroundVolume;

- (GameSound *) init{
	self = [super init];
	effect = YES;
	background = YES;
	effectVolume = 1.0;
	backgroundVolume = 1.0;
	engine = [SimpleAudioEngine sharedEngine];
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey:DUMMY_KEY] != nil) {
		[self loadStateFromUserDefaults];
	}

	return self;
}

+ (GameSound *) instance{
	if (_instance == nil) {
		_instance = [[self alloc] init];
	}
	
	return _instance;
}

- (void) preload{
	
}

- (void) preloadBackgroundMusic:(NSString *) file{
	[engine preloadBackgroundMusic:file];
}

- (void) preloadEffect:(NSString *) file{
	[engine preloadEffect:file];
}

- (void) playEffect:(NSString *) file{
	if (effect) {
		[engine playEffect:file];
	}
}

- (void) playBackgroundMusic:(NSString *) file{
	if (background) {
		[engine playBackgroundMusic:file];
	}
}

- (void) setBackground:(BOOL) m{
	if (m == background) {
		return;
	}
	background = m;
	if (background) {
		//[self playBackgroundMusic];
	}else {
		[self stopBackgroundMusic];
	}
}

- (void) setEffect:(BOOL) s{
	effect = s;
}

- (void) setBackgroundVolume:(float) v{
	v = v < 0.0 ? 0.0 : v;
	v = v > 1.0 ? 1.0 : v;
	[engine setBackgroundMusicVolume:v];
	backgroundVolume = v;
	if (v == 0.0) {
		background = NO;
	}
}

- (void) setEffectVolume:(float) v{
	v = v < 0.0 ? 0.0 : v;
	v = v > 1.0 ? 1.0 : v;
	[engine setEffectsVolume:v];
	effectVolume = v;
	if (v == 0.0) {
		effect = NO;
	}
}

- (void) stopBackgroundMusic{
	[engine stopBackgroundMusic];
}

- (void) saveStateToUserDefaults{
	[[NSUserDefaults standardUserDefaults] setValue:@"DUMMY"			forKey:DUMMY_KEY];
	[[NSUserDefaults standardUserDefaults] setBool:background			forKey:BACKGROUND_KEY];
	[[NSUserDefaults standardUserDefaults] setBool:effect				forKey:EFFECT_KEY];
	[[NSUserDefaults standardUserDefaults] setFloat:backgroundVolume	forKey:BACKGROUND_V_KEY];
	[[NSUserDefaults standardUserDefaults] setFloat:effectVolume		forKey:EFFECT_V_KEY];
}

- (void) loadStateFromUserDefaults{
	self.background			= [[NSUserDefaults standardUserDefaults] boolForKey:BACKGROUND_KEY];
	self.effect				= [[NSUserDefaults standardUserDefaults] boolForKey:EFFECT_KEY];
	self.backgroundVolume	= [[NSUserDefaults standardUserDefaults] floatForKey:BACKGROUND_V_KEY];
	self.effectVolume		= [[NSUserDefaults standardUserDefaults] floatForKey:EFFECT_V_KEY];
}

- (void) dealloc{
	[self saveStateToUserDefaults];
	[super dealloc];
}	
@end
