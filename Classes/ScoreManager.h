//
//  ScoreManager.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Score.h"
#import "Config.h"

enum {
	kScoreSortedASC,
	kScoreSortedDESC,
};

#define SM_INFINITY 2147483647

#define SM_KEY_SCORES_LIMIT				@"__SCORES_LIMIT__"
#define SM_KEY_SCORES_SORTED			@"__SCORES_SORTED__"

#define SM_KEY_DEFAULT_CATEGORY			@"@^_^___(T_T)___^_^@"

#define SM_KEY_RECENT							@"RECENT"
#define SM_KEY_RECENT_SCORE(category)			[NSString stringWithFormat:@"%@/%@",category]

#define SM_KEY_RECENT_SCORE_NAME(category)		[NSString stringWithFormat:@"%@/%@/NAME",SM_KEY_RECENT,category]
#define SM_KEY_RECENT_SCORE_VALUE(category)		[NSString stringWithFormat:@"%@/%@/VALUE",SM_KEY_RECENT,category]
#define SM_KEY_RECENT_SCORE_RANK(category)		[NSString stringWithFormat:@"%@/%@/RANK",SM_KEY_RECENT,category]
#define SM_KEY_RECENT_SCORE_DATE(category)		[NSString stringWithFormat:@"%@/%@/DATE",SM_KEY_RECENT,category]
#define SM_KEY_RECENT_SCORE_MORE(category)		[NSString stringWithFormat:@"%@/%@/MORE",SM_KEY_RECENT,category]
#define SM_KEY_RECENT_SCORE_CATEGORY(category)	[NSString stringWithFormat:@"%@/%@/CATEGORY",SM_KEY_RECENT,category]

#define SM_KEY_CATEGORIES						@"CATEGORIES"
#define SM_KEY_CATEGORY(category)				[NSString stringWithFormat:@"%@/%@",SM_KEY_CATEGORIES,category]
#define SM_KEY_SCORE(category, rank)			[NSString stringWithFormat:@"%@/%@/%d",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_VALUE(category,rank)		[NSString stringWithFormat:@"%@/%@/%d/SCORE",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_NAME(category,rank)		[NSString stringWithFormat:@"%@/%@/%d/NAME",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_DATE(category,rank)		[NSString stringWithFormat:@"%@/%@/%d/DATE",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_RANK(category,rank)		[NSString stringWithFormat:@"%@/%@/%d/RANK",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_CATEGORY(category,rank)	[NSString stringWithFormat:@"%@/%@/%d/CATEGORY",SM_KEY_CATEGORIES,category,rank]
#define SM_KEY_SCORE_MORE(category,rank)		[NSString stringWithFormat:@"%@/%@/%d/MORE",SM_KEY_CATEGORIES,category,rank]

@interface ScoreManager : NSObject {
	Config	*_data;
	int		_scoreLimit;
	int		_scoreSorted;
}
@property int scoreLimit;
@property int scoreSorted;

- (id) initWithFile:(NSString *) path;
- (id) initWithConfig:(Config *) config;

- (NSArray *) categories;
- (int) numberOfCategories;

- (int) numberOfScoresInCategory:(NSString *) category;

- (BOOL) isScore:(int) score acceptedInCategory:(NSString *) category;
- (int) worstScoreInCategory:(NSString *) category;
- (int) bestScoreInCategory:(NSString *) category;

- (Score *) scoreWithRank:(int) rank inCategory:(NSString *) category;
- (NSArray *) scoresInCategory:(NSString *) category;
- (NSArray *) scoresInCategory:(NSString *) category forUser:(NSString *) name ;
- (NSArray *) scoresInCategory:(NSString *) category fromDate:(NSDate *) from toDate:(NSDate *) to;
- (NSArray *) scoresInCategory:(NSString *) category forDate:(NSDate *) date;
- (Score *) recentScoreIncategory:(NSString *) category;

- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date more:(id) more category:(NSString *) category ;
- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date category:(NSString *) category ;
- (Score *) insertScore:(int) score name:(NSString *) name category:(NSString *) category;

- (void) save;

//Use 2 functions below if you want to store something else in the Config
//BUT be aware with key conflict
- (id) get:(NSString *) key;
- (void) set:(id) value forKey:(NSString *) key;

#pragma mark IF YOUR GAME HAVE ONLY ONE CATEGORY OF SCORES
- (int) numberOfScores;

- (BOOL) isScoreAccepted:(int) score;
- (int) worstScore;
- (int) bestScore;

- (Score *) scoreWithRank:(int) rank ;
- (NSArray *) scores;
- (NSArray *) scoresForUser:(NSString *) name ;
- (NSArray *) scoresFromDate:(NSDate *) from toDate:(NSDate *) to;
- (NSArray *) scoresForDate:(NSDate *) date;
- (Score *) recentScore;

- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date more:(id) more  ;
- (Score *) insertScore:(int) score name:(NSString *) name date:(NSDate *) date ;
- (Score *) insertScore:(int) score name:(NSString *) name;

@end
