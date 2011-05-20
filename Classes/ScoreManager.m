//
//  ScoreManager.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "ScoreManager.h"

@interface ScoreManager(Private)
- (void) createCategoryIfNeeded:(NSString *) category;
- (void) cleanCategory:(NSString *) category fromRank:(int) rank;
- (void) validateValueScoresForCategory:(NSString *) category;
@end

@implementation ScoreManager(Private)
- (void) createCategoryIfNeeded:(NSString *) category{
	if ([_data get:SM_KEY_CATEGORY(category)] == nil) {
		[_data set:[NSMutableDictionary dictionary] forKey:SM_KEY_CATEGORY(category)];
	}
}

- (void) cleanCategory:(NSString *) category fromRank:(int) rank{
	int count = [self numberOfScoresInCategory:category];
	for (int r = rank; r <= count; r++) {
		[_data remove:SM_KEY_SCORE(category, r)];
	}
}

- (void) validateValueScoresForCategory:(NSString *) category{
	int num = [self numberOfScoresInCategory:category];
	for (int i = 1; i < num; i ++) {
		if (_scoreSorted == kScoreSortedDESC) {
			NSAssert([_data getInt:SM_KEY_SCORE_VALUE(category,i)] >= [_data getInt:SM_KEY_SCORE_VALUE(category,i+1)],@"FAIL" );
		}else {
			NSAssert([_data getInt:SM_KEY_SCORE_VALUE(category,i)] <= [_data getInt:SM_KEY_SCORE_VALUE(category,i+1)],@"FAIL" );
		}
	}
	
	NSLog(@"VALIDATION PASSED for category: %@",category);
}
@end


@implementation ScoreManager
@synthesize scoreLimit = _scoreLimit;
@synthesize scoreSorted = _scoreSorted;

- (id) initWithFile:(NSString *) path{
	self = [super init];
	_scoreLimit = 50;
	_scoreSorted = kScoreSortedDESC;
	_data = [[Config alloc] initWithFile:path];
	
	if (!_data) {
		NSLog(@"ScoreManager: Cannot find data file. Return NOTHING");
		[self autorelease];
		return nil;
	}
	
	if ([_data get:SM_KEY_SCORES_LIMIT] == nil) {
		[_data setInt:_scoreLimit forKey:SM_KEY_SCORES_LIMIT];
	}else {
		_scoreLimit = [_data getInt:SM_KEY_SCORES_LIMIT];
	}
	
	if ([_data get:SM_KEY_SCORES_SORTED] == nil) {
		[_data setInt:_scoreSorted forKey:SM_KEY_SCORES_SORTED];
	}else {
		_scoreSorted = [_data getInt:SM_KEY_SCORES_SORTED];
	}
	
	return self;
}

- (id) initWithConfig:(Config *) config{
	self = [super init];
	_scoreLimit = 50;
	_scoreSorted = kScoreSortedDESC;
	_data = [config retain];
	
	if ([_data get:SM_KEY_SCORES_LIMIT] == nil) {
		[_data setInt:_scoreLimit forKey:SM_KEY_SCORES_LIMIT];
	}else {
		_scoreLimit = [_data getInt:SM_KEY_SCORES_LIMIT];
	}
	
	if ([_data get:SM_KEY_SCORES_SORTED] == nil) {
		[_data setInt:_scoreSorted forKey:SM_KEY_SCORES_SORTED];
	}else {
		_scoreSorted = [_data getInt:SM_KEY_SCORES_SORTED];
	}
	
	return self;
}

- (void) save{
	[_data save];
}

- (id) get:(NSString *) key{
	return [_data get:key];
}

- (void) set:(id) value forKey:(NSString *) key{
	[_data set:value forKey:key];
}

- (void) dealloc{
	[_data save];
	[_data release];
	[super dealloc];
}

- (void) setScoreLimit:(int) limit{
	if (limit < 1 || limit > 1000 || limit == _scoreLimit) {
		return;
	}
	//Remove un needed ranks
	if (limit < _scoreLimit ) {
		NSArray *categories = [self categories];
		for (NSString *category in categories) {
			[self cleanCategory:category fromRank:limit + 1];
		}
	}
	
	_scoreLimit = limit;
	[_data setInt:limit forKey:SM_KEY_SCORES_LIMIT];
}

- (void) setScoreSorted:(int) sorted{
	if ((sorted != kScoreSortedDESC && sorted != kScoreSortedASC) || sorted == _scoreSorted) {
		return;
	}
	_scoreSorted = sorted;
	[_data setInt:sorted forKey:SM_KEY_SCORES_SORTED];
	
	NSArray *cats = [self categories];
	for (NSString *category in cats) {
		int num = [self numberOfScoresInCategory:category];
		for(int i = 1, k = num; i < k; i++,k--) {
			//Swap
			id temp = [[_data get:SM_KEY_SCORE(category,k)] retain];
			[_data set:[_data get:SM_KEY_SCORE(category,i)] forKey:SM_KEY_SCORE(category,k)];
			[_data set:temp forKey:SM_KEY_SCORE(category,i)];
			[temp release];
		}
	}
}

- (NSArray *) categories{
	return [[_data get:SM_KEY_CATEGORIES] allKeys];
}

- (int) numberOfCategories{
	return [[self categories] count];
}

- (int) numberOfScoresInCategory:(NSString *) category{
	return [[_data get:SM_KEY_CATEGORY(category)] count];
}

- (NSArray *) scoresInCategory:(NSString *) category{
	int count = [self numberOfScoresInCategory:category];
	if (count == 0) {
		return nil;
	}
	
	NSMutableArray *scores = [NSMutableArray arrayWithCapacity:count];
	for (int i = 1; i <= count; i++) {
		[scores addObject:[self scoreWithRank:i inCategory:category]];
	}
	
	return scores;
}

- (NSArray *) scoresInCategory:(NSString *) category forUser:(NSString *) name {
	NSMutableArray *scores = [NSMutableArray array];
	int num = [self numberOfScoresInCategory:category];
	for (int i = 1; i <= num; i++) {
		if ([[_data get:SM_KEY_SCORE_NAME(category,i)] isEqualToString:name]) {
			[scores addObject:[self scoreWithRank:i inCategory:category]];
		}
	}
	
	return scores;
}

- (NSArray *) scoresInCategory:(NSString *) category fromDate:(NSDate *) from toDate:(NSDate *) to{
	NSMutableArray *scores = [NSMutableArray array];
	int num = [self numberOfScoresInCategory:category];
	for (int i = 1; i <= num; i++) {
		NSDate *date = [_data getDate:SM_KEY_SCORE_DATE(category,i)];
		if ([date compare:from] != NSOrderedAscending && [date compare:to] != NSOrderedDescending) {
			[scores addObject:[self scoreWithRank:i inCategory:category]];
		}
	}
	
	return scores;
}

- (NSArray *) scoresInCategory:(NSString *) category forDate:(NSDate *) date{
	NSMutableArray *scores = [NSMutableArray array];
	NSAssert(FALSE,@"Not yet implemented");
	return scores;
}

- (Score *) scoreWithRank:(int) rank inCategory:(NSString *) category{
	if (rank <= 0 || rank > [self numberOfScoresInCategory:category]) {
		return nil;
	}
	
	Score *score = [Score score];
	score.rank = rank;
	score.name = [_data get:SM_KEY_SCORE_NAME(category,rank)];
	score.value = [_data getInt:SM_KEY_SCORE_VALUE(category,rank)];
	score.category = category;
	score.date = [_data getDate:SM_KEY_SCORE_DATE(category,rank)];
	score.more = [_data get:SM_KEY_SCORE_MORE(category,rank)];
	
	return score;
}

- (Score *) recentScoreIncategory:(NSString *) category{
	if ([_data get:SM_KEY_RECENT_SCORE(category)]) {
		Score *score = [Score score];
		score.category = category;
		score.name = [_data get:SM_KEY_RECENT_SCORE_NAME(category)];
		score.value = [_data getInt:SM_KEY_RECENT_SCORE_VALUE(category)];
		score.rank = [_data getInt:SM_KEY_RECENT_SCORE_RANK(category)];
		score.more = [_data get:SM_KEY_RECENT_SCORE_MORE(category)];
		score.date = [_data getDate:SM_KEY_RECENT_SCORE_DATE(category)];
		
		return score;
	}
	
	return nil;
}

- (BOOL) isScore:(int) score acceptedInCategory:(NSString *) category{
	int num = [self numberOfScoresInCategory:category];
	if (_scoreSorted == kScoreSortedDESC) {
		if(num < _scoreLimit || 
		   (num >= _scoreLimit && score > [self worstScoreInCategory:category])){
			return YES;
		}
	}else {
		if(num < _scoreLimit || 
		   (num >= _scoreLimit && score < [self worstScoreInCategory:category])){
			return YES;
		}
	}

	return NO;
}

- (int) worstScoreInCategory:(NSString *) category{
	int num = [self numberOfScoresInCategory:category];
	if (num == 0) {
		if (_scoreSorted == kScoreSortedDESC) {
			return -SM_INFINITY;
		}else {
			return SM_INFINITY;
		}
	}
	
	return [_data getInt:SM_KEY_SCORE_VALUE(category, num)];
}

- (int) bestScoreInCategory:(NSString *) category{
	return [_data getInt:SM_KEY_SCORE_VALUE(category, 1)];			
}

- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date category:(NSString *) category {
	return [self insertScore:score 
						name:name 
						date:date 
						more:nil
					category:category];
}

- (Score *) insertScore:(int) score name:(NSString *) name category:(NSString *) category{
	return [self insertScore:score 
						name:name  
						date:[NSDate date] 
						more:nil
					category:category];
}


- (Score *) insertScore:(int) score 
				   name:(NSString *) name  
				   date:(NSDate *) date 
				   more:(id) more
			   category:(NSString *) category{

	if (![self isScore:score acceptedInCategory:category]) {
		return nil;
	}	
	
	if (more == nil) {
		more = @"";
	}
	
	Score *_score = [Score score];
	_score.name = name;
	_score.value = score;
	_score.category = category;
	_score.more = more;
	
	int count = [self numberOfScoresInCategory:category];
	int tarGetRank = 1;
	
	/** Find the rank for the new score  */
	for (int i = 1; i <= count ;i++ ) {
		int s = [_data getInt:SM_KEY_SCORE_VALUE(category,i)];
		if (_scoreSorted == kScoreSortedDESC) {
			if (score > s) {
				tarGetRank = i;
				break;
			}else {
				tarGetRank = i + 1;
			}
		}else {
			if (score < s) {
				tarGetRank = i;
				break;
			}else {
				tarGetRank = i + 1;
			}
		}
	}
	
	_score.rank = tarGetRank;
	
	//Shift all scores greater than targetRank down a row
	//Only shif if the targetRank is not at _scoreLimit
	if (tarGetRank != _scoreLimit) {
		//If the _scoreLimit exceeds, the last row is sliced out
		int endIndex = count + 1 <= _scoreLimit ? count + 1 : _scoreLimit;
		for (int i = endIndex; i > tarGetRank; i --) {
			NSDictionary *s1 = [_data get:SM_KEY_SCORE(category,i-1)];
			[_data set:s1 forKey:SM_KEY_SCORE(category,i)];
		}
	}
		
	[_data set:name				forKey:SM_KEY_SCORE_NAME(category,tarGetRank)];
	[_data set:more				forKey:SM_KEY_SCORE_MORE(category,tarGetRank)];
	[_data setDate:date			forKey:SM_KEY_SCORE_DATE(category,tarGetRank)];
	[_data setInt:score			forKey:SM_KEY_SCORE_VALUE(category,tarGetRank)];
	[_data setInt:tarGetRank	forKey:SM_KEY_SCORE_RANK(category,tarGetRank)];
	
	[_data set:name				forKey:SM_KEY_RECENT_SCORE_NAME(category)];
	[_data set:more				forKey:SM_KEY_RECENT_SCORE_MORE(category)];
	[_data setDate:date			forKey:SM_KEY_RECENT_SCORE_DATE(category)];
	[_data setInt:score			forKey:SM_KEY_RECENT_SCORE_VALUE(category)];
	[_data setInt:tarGetRank	forKey:SM_KEY_RECENT_SCORE_RANK(category)];
	
	
	return _score;
}

#pragma mark IF YOUR GAME HAVE ONLY ONE CATEGORY OF SCORES
- (int) numberOfScores{
	return [self numberOfScoresInCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (BOOL) isScoreAccepted:(int) score{
	return [self isScore:score acceptedInCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (int) worstScore{
	return [self worstScoreInCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (int) bestScore{
	return [self bestScoreInCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (Score *) scoreWithRank:(int) rank{
	return [self scoreWithRank:rank inCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (Score *) recentScore{
	return [self recentScoreIncategory:SM_KEY_DEFAULT_CATEGORY];
}

- (NSArray *) scores{
	return [self scoresInCategory:SM_KEY_DEFAULT_CATEGORY];
}

- (NSArray *) scoresForUser:(NSString *) name{
	return [self scoresInCategory:SM_KEY_DEFAULT_CATEGORY forUser:name];
}

- (NSArray *) scoresFromDate:(NSDate *) from toDate:(NSDate *) to{
	return [self scoresInCategory:SM_KEY_DEFAULT_CATEGORY fromDate:from toDate:to];
}

- (NSArray *) scoresForDate:(NSDate *) date{
	return [self scoresInCategory:SM_KEY_DEFAULT_CATEGORY forDate:date];
}

- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date more:(id) more{
	return [self insertScore:score name:name date:date more:more category:SM_KEY_DEFAULT_CATEGORY];
}

- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date{
	return [self insertScore:score name:name date:date more:nil category:SM_KEY_DEFAULT_CATEGORY];
}

- (Score *) insertScore:(int) score name:(NSString *) name{
	return [self insertScore:score name:name date:[NSDate date] more:nil category:SM_KEY_DEFAULT_CATEGORY];
}

@end
