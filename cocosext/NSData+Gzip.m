//
//  NSData+Gzip.m
//  Molecules
//
//  The source code for Molecules is available under a BSD license.  See License.txt for details.
//
//  Created by Brad Larson on 7/1/2008.
//
//  This extension is adapted from the examples present at the CocoaDevWiki at http://www.cocoadev.com/index.pl?NSDataCategory

#import "NSData+Gzip.h"
#include <zlib.h>

@implementation NSData (Gzip)

- (id)initWithGzippedData: (NSData *)gzippedData;
{
	[gzippedData retain];
	if ([gzippedData length] == 0) return nil;
	
	unsigned full_length = [gzippedData length];
	unsigned half_length = [gzippedData length] / 2;
	
	NSMutableData *decompressed = [[NSMutableData alloc] initWithLength:(full_length + half_length)];
	BOOL done = NO;
	int status;
	//NSLog(@"Data input: %d",[gzippedData length]);
	z_stream strm;
	strm.next_in = (Bytef *)[gzippedData bytes];
	strm.avail_in = [gzippedData length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) 
	{
		[gzippedData release];
		[decompressed release];
		return nil;
	}
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) 
			done = YES;
		//else if (status == Z_BUF_ERROR){
			//[decompressed increaseLengthBy: half_length];
			//strm.avail_out = [decompressed length] - strm.total_out;
		//}
		else if (status != Z_OK){ 
			NSLog(@"Error here -- %d - avin = %d, avout = %d\nError = %s\nnin = %d",status, strm.avail_in, strm.avail_out, strm.msg,strm.next_in - (Bytef *)[gzippedData bytes]);
			break;
		}
	}
	//inflateSync();
	//strm.next_out = [decompressed mutableBytes] + strm.total_out;
	//strm.avail_out = [decompressed length] - strm.total_out;
	if (inflateEnd (&strm) != Z_OK) 
	{
		[decompressed release];
		return nil;
	}
	
	// Set real length.
	[decompressed setLength: strm.total_out];
	id newObject = [self initWithBytes:[decompressed bytes] length:[decompressed length]];
	[decompressed release];
	[gzippedData release];
	return newObject;
}

- (NSData *)gzipDeflate
{
	if ([self length] == 0) return self;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = [self length];
	
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData:compressed];
}

- (NSData *)gzipInflate
{
	if ([self length] == 0) return self;
	
	unsigned full_length = [self length];
	unsigned half_length = [self length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	else return nil;
}

@end
