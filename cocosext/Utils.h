//
//  Utils.h
//  Sqlite
//
//  Created by Ngo Duc Hiep on 4/29/10.
//  Copyright 2010 PTT Solution,. JSC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {
	
}
+ (bool) urlExist:(NSString *) url;
+ (NSString *) MD5:(NSString *) str;
+ (NSString *) pathForFileInDocument:(NSString *) file;
+ (NSString *) pathForFileInBundle:(NSString *) file;
+ (NSString *) pathForFile:(NSString *) file inBundle:(NSString *) bundle;
+ (id) obj:(id) obj;
+ (id) obj:(id) obj def:(id)def;
+ (NSString *) ldapHash:(NSString *) pass key:(NSString *) key;
+ (id) readPlist:(NSString *) file;
+ (BOOL) fileExist:(NSString *) path;
+ (BOOL) copyFile:(NSString *) spath to:(NSString *) dpath;
+ (NSData *) encrypt:(NSData *) data withKey:(NSString *) key;
+ (NSData *) decrypt:(NSData *) data withKey:(NSString *) key;
@end
