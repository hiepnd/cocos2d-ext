//
//  Utils.m
//  Sqlite
//
//  Created by Ngo Duc Hiep on 4/29/10.
//  Copyright 2010 PTT Solution,. JSC. All rights reserved.
//

#import "Utils.h"
#import "NSData+CommonCrypto.h"
#import "NSData+Base64.h"

@implementation Utils

+(bool) urlExist:(NSString *) url{
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
	NSHTTPURLResponse *response;
	NSError *error;
	
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	int status = [response statusCode];
	[request release];
	//NSLog(@"Status = %d",status);
	return status == 200;
}

+(NSString *) MD5:(NSString *) str{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
	
}

+(id) obj:(id) obj{
	return obj == nil ? @"" : obj;
}

+(id) obj:(id) obj def:(id)def{
	return obj == nil ? def : obj;
}

+(NSString *) pathForFileInDocument:(NSString *) file{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	return [docPath stringByAppendingPathComponent:file];
}

+ (NSString *) pathForFileInBundle:(NSString *) file{
	return [[NSBundle mainBundle] pathForResource:file ofType:nil];
}

+ (NSString *) pathForFile:(NSString *) file inBundle:(NSString *) bundle{
	return [[NSBundle bundleWithIdentifier:bundle] pathForResource:file ofType:nil];
}

/** Compute the LDAP hash - follow the guide of SugarCRM */
+ (NSString *) ldapHash:(NSString *) pass key:(NSString *) key_{
	/*
	 $user_name = 'matt';
	 $user_password = 'mygoodsecret123';
	 $app_name = 'myniceprogram';
	 
	 $key = 'abc123';  // LDAP Key as entered in Sugar
	 $key = substr(md5($key),0,24);
	 $iv = 'password';  // note that this is the word password, not the user's password or hash...
	 $ldap_hash = bin2hex(mcrypt_cbc(MCRYPT_3DES, $key, $user_password, MCRYPT_ENCRYPT, $iv));
	 $soap_client->call('login',array('user_auth'=>array('user_name'=>$user_name, 'password'=>$ldap_hash,'version'=>'.1'), 'application_name'=>$app_name));
	 
	 */
	
	//NSData *iv = [@"password" dataUsingEncoding:NSASCIIStringEncoding];
	//NSData *key = [key_ dataUsingEncoding:NSASCIIStringEncoding];
	NSData *password = [pass dataUsingEncoding:NSUTF8StringEncoding];
	
	CCCryptorStatus status = kCCSuccess;
	
	NSData *encrypted = [password dataEncryptedUsingAlgorithm:kCCAlgorithm3DES
														  key:[[self MD5:key_] substringToIndex:23]
										 initializationVector:@"password"
													  options:kCCOptionPKCS7Padding error:&status];
	
	const unsigned char *result = [encrypted bytes];
	NSString *str = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X",
					 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7]
					 ];
	//NSString *s = [[NSString alloc] initWithData:encrypted encoding:NSASCIIStringEncoding];
	//NSLog(@"Key=%@\nLength=%i\nRet=%@",[[self MD5:key_] substringToIndex:23],[s length],s);
	//NSString *hash = [[NSString alloc] initWithData:encrypted encoding:NSASCIIStringEncoding];
	
	return str;
}

+ (id) readPlist:(NSString *) file{
	NSString *path = [self pathForFileInBundle:file];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSData *data = [manager contentsAtPath:path];
	NSPropertyListFormat f;
		
	return [NSPropertyListSerialization propertyListWithData:data options:0 format:&f error:nil];
}

+ (BOOL) fileExist:(NSString *) path{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL) copyFile:(NSString *) spath to:(NSString *) dpath{
	return [[NSFileManager defaultManager] copyItemAtPath:spath toPath:dpath error:nil];
}

+ (NSData *) encrypt:(NSData *) data withKey:(NSString *) key{
	return [data AES256EncryptedDataUsingKey:key error:nil];
}

+ (NSData *) decrypt:(NSData *) data withKey:(NSString *) key{
	return [data decryptedAES256DataUsingKey:key error:nil];
}
@end
