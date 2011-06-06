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

//TODO: Define config keys here for ease of usage
#define CF_KEY_PLAYER_NAME	@"playername"
#define CF_KEY_LAST_SCORE	@"lastscore"


//TODO: Define macro to get config values, if interests
#define CF_VALUE_PLAYER_NAME	[[Global config] get:CF_KEY_PLAYER_NAME]
#define CF_VALUE_LAST_SCORE		[[Global config] getInt:CF_KEY_LAST_SCORE]

@interface Config : NSObject {
	BOOL dataChanged;
	NSMutableDictionary *config;
	BOOL saveOnChanged;
	NSString *path;
	BOOL encrypted;
	id ekey;
}
@property (nonatomic) BOOL dataChanged;
@property (readwrite) BOOL saveOnChanged;
@property (readonly) NSString *path;

+ (id) instanceForFile:(NSString *) file;
+ (void) removeInstanceForFile:(NSString *) file;
+ (void) removeInstance:(Config *) instance;
+ (void) removeAllInstance;
+ (void) saveAll;
+ (NSMutableDictionary *) readPlistFileAtPath:(NSString *) file;

- (id) initWithFile:(NSString *)path;
- (BOOL) save;
- (BOOL) save:(NSString *) path;
- (void) print;
- (void) deleteFile;

- (void) remove:(NSString *) key;

#pragma mark Setter
- (void) set:(id) value forKey:(NSString *) key ; 
- (void) setInt:(int) value			forKey:(NSString *) key;
- (void) setBool:(BOOL) value		forKey:(NSString *) key;
- (void) setFloat:(float) value		forKey:(NSString *) key;
- (void) setCGPoint:(CGPoint) value forKey:(NSString *) key;
- (void) setCGRect:(CGRect) value	forKey:(NSString *) key;
- (void) setDate:(NSDate *) value	forKey:(NSString *) key;

#pragma mark Getter
- (id) get:(NSString *) key;
- (int) getInt:(NSString *) key;
- (float) getFloat:(NSString *) key;
- (BOOL) getBool:(NSString *) key;
- (CGPoint) getCGPoint:(NSString *) key;
- (CGRect) getCGRect:(NSString *) key;
- (NSDate *) getDate:(NSString *) key;

/** Support encryption */
+ (NSMutableDictionary *) readPlistFileAtPath:(NSString *) file key:(id) key;
+ (id) instanceForFile:(NSString *) file key:(id) key;
- (id) initWithFile:(NSString *)filename key:(id) key;

@end