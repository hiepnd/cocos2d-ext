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

#import "Global.h"
#import "AppController.h"

@implementation Global
+ (AppController *) appDelegate{
	return (AppController *) [[UIApplication sharedApplication] delegate];
}

+ (Config *) config{
	return [Config instanceForFile:[Utils pathForFileInDocument:APP_CONFIG_FILE]];
}

+ (Config *) highscore{
	return [Config instanceForFile:[Utils pathForFileInDocument:APP_HIGHSCORE_FILE]];	
}

+ (void) loadConfig{
	//Copy config file if needed
	NSString *dpath = [Utils pathForFileInDocument:APP_CONFIG_FILE];
	if (![Utils fileExist:dpath]) {
		[Utils copyFile:[Utils pathForFileInBundle:APP_CONFIG_FILE] to:dpath];
	}
	
	//Copy highscore file if needed
	dpath = [Utils pathForFileInDocument:APP_HIGHSCORE_FILE];
	if (![Utils fileExist:dpath]) {
		[Utils copyFile:[Utils pathForFileInBundle:APP_HIGHSCORE_FILE] to:dpath];
	}
}
@end
