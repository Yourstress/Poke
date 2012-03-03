//
//  LayerTimeline.h
//  Poke
//
//  Created by Sour on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"

#define LabelOffset		55

typedef enum
{
	TouchStateNil,
	TouchStateDraggingLeftPin,
	TouchStateDraggingRightPin,
}	TouchState;

@protocol LayerTimelineDelegate <NSObject>
@required
-(void)timelineChangedToStartDate:(NSTimeInterval)dateStart andEndDate:(NSTimeInterval)dateEnd;
@end


@interface LayerTimeline : CCLayer
{
	// timeline data
	float length;
	
	// UI nodes
	CCSprite *spOverview;
	CCSprite *spOverviewShading;
	CCSprite *spTimeline;
	CCSprite *spPinLeft;
	CCSprite *spPinRight;
	CCSprite *spBorderLeft;
	CCSprite *spBorderRight;
	CCLabelStroked *lbDateLeft;
	CCLabelStroked *lbDateRight;
	CCLabelStroked *lbTimeLeft;
	CCLabelStroked *lbTimeRight;
	CCSpriteBatchNode *spTransactions;
	
	// UI support
	BOOL isShown;
	TouchState touchState;
	
	// date
	NSArray *transactions;
	NSTimeInterval dateEarliest;
	NSTimeInterval dateLatest;
	NSTimeInterval dateStart;
	NSTimeInterval dateEnd;
	
	// the delegate we're notifying
	id<LayerTimelineDelegate> delegate;
}

@property (nonatomic) BOOL isShown;

#pragma mark -
#pragma mark Alloc/Init

+(id)timelineWithLength:(float)l delegate:(id<LayerTimelineDelegate>)d;

-(id)initTimelineWithLength:(float)l delegate:(id<LayerTimelineDelegate>)d;

#pragma mark -
#pragma mark UI Initialization

-(void)createTimeline;

-(void)createPins;

-(void)createTimestamps;

-(void)createTimelineOverview;

-(void)animateShow:(BOOL)show;

#pragma mark -
#pragma mark Timeline Management

-(void)setEarliestDate:(NSDate *)date;

-(void)setLatestDate:(NSDate *)date;

-(void)setStartTimeInterval:(NSTimeInterval)interval;

-(void)setEndTimeInterval:(NSTimeInterval)interval;

-(void)setStartDateFromXPosition:(float)x;

-(void)setEndDateFromXPosition:(float)x;

-(void)updateDates;

-(void)updateTransactions;

-(void)setTransactions:(NSArray *)t;

-(void)refreshOverview;

@end
