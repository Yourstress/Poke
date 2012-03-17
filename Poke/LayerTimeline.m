//
//  LayerTimeline.m
//  Poke
//
//  Created by Sour on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayerTimeline.h"

@implementation LayerTimeline

@synthesize isShown;

#pragma mark -
#pragma mark Alloc/Init

+(id)timelineWithLength:(float)l delegate:(id<LayerTimelineDelegate>)d
{
	return [[[self alloc] initTimelineWithLength:l delegate:d] autorelease];
}

-(id)initTimelineWithLength:(float)l delegate:(id<LayerTimelineDelegate>)d
{
	if ( (self = [super init]) )
	{
		// turn touches on
		self.isTouchEnabled = YES;
		
		// set the delegate
		delegate = d;
		
		// store the length
		length = l;
		
		// create timeline
		[self createTimeline];
		
		// create pins
		[self createPins];
		
		// create timestamp displays
		[self createTimestamps];
		
		// create timeline overview
		[self createTimelineOverview];
		
		// by default, it's hidden
		isShown = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark UI Initialization

-(void)createTimeline
{
	// make sure it doesn't already exist
	if (spTimeline != nil)
		[spTimeline removeFromParentAndCleanup:YES];
	
	// load the sprite
	spTimeline = [CCSprite spriteWithFile:@"TimelineBar.png"];
	
	// load borders
	spBorderLeft = [CCSprite spriteWithFile:@"TimelineBarBorder.png"];
	spBorderLeft.position = ccp(-length/2.0, 0);
	spBorderLeft.anchorPoint = ccp(1, 0.5);
	spBorderLeft.scaleX = 2;
	spBorderLeft.opacity = 0;
	[self addChild:spBorderLeft z:1];
	spBorderRight = [CCSprite spriteWithFile:@"TimelineBarBorder.png"];
	spBorderRight.position = ccp(length/2.0, 0);
	spBorderRight.anchorPoint = ccp(0, 0.5);
	spBorderRight.scaleX = 2;
	spBorderRight.opacity = 0;
	[self addChild:spBorderRight z:1];
	
	// size it accordingly
	spTimeline.scaleX = 0;
//	spTimeline.scaleX = length;		// since length is in pixels, and our image width is 1 pixel - straight up scale X
	
	// add it to the layer
	[self addChild:spTimeline z:0];
}

-(void)createPins
{
	// make sure the pins don't already exist
	if (spPinLeft != nil)
		[spPinLeft removeFromParentAndCleanup:YES];
	if (spPinRight != nil)
		[spPinRight removeFromParentAndCleanup:YES];
	
	// load the sprites
	spPinLeft = [CCSprite spriteWithFile:@"TimelinePin.png"];		// the pin image is right pin
	spPinRight = [CCSprite spriteWithFile:@"TimelinePin.png"];		// the pin image is right pin
	
	// flip left pin
	spPinLeft.flipX = YES;
	
	// move left pin half the width, and adjust its anchor
	spPinLeft.position = ccp(0, 0);
	spPinLeft.anchorPoint = ccp(1, 0.5);
	
	// move right pin half the width, and adjust its anchor
	spPinRight.position = ccp(0, 0);
	spPinRight.anchorPoint = ccp(0, 0.5);
	
	// add them to the layer
	[self addChild:spPinLeft z:10];
	[self addChild:spPinRight z:10];
}

-(void)createTimestamps
{
	CCLabelStroked **labels[4] = { &lbDateLeft, &lbDateRight, &lbTimeLeft, &lbTimeRight };
	float height[4] = { 38, 38, 19, 19 };
	
	for (int x = 0; x < 4; x++)
	{
		// make sure it doesn't already exist
		if (*labels[x] != nil)
			[*labels[x] removeFromParentAndCleanup:YES];
		
		// create the label
		*labels[x] = [CCLabelStroked labelWithString:@"[Undefined]" fontName:FontFamilyBold fontSize:Scaled(x <= 1 ? 32 : 16)];
		
		// apply the outline
		[*labels[x] setStrokeSize:Scaled(2)];
		
		// move right OR left HALF THE WIDTH, and adjust its anchor
		float direction = (x%2 == 0 ? -1 : 1);
		[*labels[x] setPosition:ccp(Scaled(direction * length/2.0 + direction*-1 * LabelOffset),
									Scaled(height[x]))];
		[*labels[x] setAnchorPoint:ccp(x%2, 0.5)];

		// hide them initially
		[*labels[x] setOpacity:0];
		
		// add to layer
		[self addChild:*labels[x] z:10];
	}
}

-(void)createTimelineOverview
{
	if (!spOverview)
	{
		// create the overview node
		spOverview = [CCSprite spriteWithFile:@"TimelineOverview.png"];
		
		// position it
		spOverview.position = ccp(0, Scaled(38));
		
		// zero scale
		spOverview.scaleX = 0;
		
		// add to layer
		[self addChild:spOverview];
		
		// create overview shading
		spOverviewShading = [CCSprite spriteWithFile:@"TimelineOverviewShading.png"];
		
		// center it
		spOverviewShading.position = ccp(spOverview.contentSize.width/2.0, spOverview.contentSize.height/2.0);
		
		// zero scale
		spOverviewShading.scaleX = 0;
		
		// add it to overview
		[spOverview addChild:spOverviewShading];
	}
}

-(void)animateShow:(BOOL)show
{
	// update the shown flag
	isShown = show;
	
	// show actual balance when hiding
	if (!show)
	{
		NSTimeInterval start	= [[[transactions objectAtIndex:0] timeStamp] timeIntervalSinceReferenceDate] - 86400;
		NSTimeInterval end	= [[[transactions lastObject] timeStamp] timeIntervalSinceReferenceDate] + 86400;
		
		[delegate timelineChangedToStartDate:start andEndDate:end];
	}
	else
	{
		[delegate timelineChangedToStartDate:dateStart andEndDate:dateEnd];
	}
	
	id action;
	Class easeClass = show ? [CCEaseSineIn class] : [CCEaseExponentialOut class];
	float labelOffset = show ? 0 : LabelOffset;
	
#define duration	1
	
	// animate the pins
	CCSprite *spPins[2] = { spPinLeft, spPinRight };
	for (int x = 0; x < 2; x++)
	{
		float direction = (x == 0 ? -1 : 1);
		CGPoint ptDest = show ? ccp(length/2.0*direction, 0) : ccp(0, 0);
		
		action = [CCMoveTo actionWithDuration:duration position:ptDest];
		action = [easeClass actionWithAction:action];
		action = [CCSpawn actionOne:action two:[CCFadeTo actionWithDuration:duration*0.7 opacity:show ? 255 : 0]];
		[spPins[x] runAction:action];
	}
	
	// animate the bar
	action = [CCScaleTo actionWithDuration:duration scaleX:show ? (iPad ? length : length*2.0) : 0 scaleY:1];
	action = [easeClass actionWithAction:action];
	[spTimeline runAction:action];
	
	// animate the borders
	if (show)
	{
		action = [CCSequence actionOne:
				  [CCDelayTime actionWithDuration:1]
								   two:
				  [CCCallBlock actionWithBlock:^(void)
				   {
					   spBorderLeft.opacity = 255;
					   spBorderRight.opacity = 255;
				   }]];
		[self runAction:action];
	}
	else
	{
		spBorderLeft.opacity = 0;
		spBorderRight.opacity = 0;
	}
	
	// animate the timestamps
	CCLabelStroked *labels[4] = { lbDateLeft, lbDateRight, lbTimeLeft, lbTimeRight };
	for (int x = 0; x < 4; x++)
	{
		float direction = (x%2 == 0 ? -1 : 1);
		float extraOffset = (x >= 2 ? labelOffset*1.35 : 0);
		float timeLabelAlignment = (x >= 2 ? -2 : 0);
		action = [CCMoveTo actionWithDuration:duration*2 position:ccp(direction*(timeLabelAlignment+length/2.0) + direction*-1*(labelOffset+extraOffset), labels[x].position.y)];
		action = [CCEaseExponentialOut actionWithAction:action];
		action = [CCSpawn actionOne:action two:[CCFadeTo actionWithDuration:0.25 opacity:show ? 255 : 0]];
		
		// run the action
		[labels[x] runAction:action];
	}
	
	// animate the transactions
//	float delay = 0.6;
	for (CCSprite *sp in spTransactions.children)
	{
//		id action = [CCScaleTo actionWithDuration:1 scale:show ? 1 : 0];
//		action = [CCEaseBackInOut actionWithAction:action];
//		action = [CCSpawn actionOne:action two:[CCFadeTo actionWithDuration:1 opacity:show ? 255 : 0]];
		id action = [CCScaleTo actionWithDuration:0.4 scale:show ? 2 : 0];
		
		if (show)
		{
			float delay = 0.6 + (sp.tag/60.0);
			
			action = [CCSequence actions:
					  [CCDelayTime actionWithDuration:delay],
					  action,
					  [CCScaleTo actionWithDuration:0.4 scale:1], nil];
		}
		
		[sp runAction:action];
	}
	
	// animate the overview
	CCNode<CCRGBAProtocol> *nodes[2] = { spOverview, spOverviewShading };
	
	// refresh the overview to know what's going on
	[self refreshOverview];
	
	for (int x = 0; x < 2; x++)
	{
		// fade action
		action = [CCFadeTo actionWithDuration:0.25 opacity:show ? 255 : 0];
		
		// scale action (fade the shading FASTER)
		if (x == 1)		// SHADING
		{
			action = [CCSpawn actions:
					  action,
					  [CCScaleTo actionWithDuration:0.25 scaleX:show ? nodes[x].scaleX : 0.0 scaleY:1.0],
					  [CCMoveTo actionWithDuration:0.25 position:nodes[x].position], nil];
		}
		else			// BACK
		{
			action = [CCSpawn actions:
					  action,
					  [CCScaleTo actionWithDuration:0.5 scaleX:show ? 1.0 : 0.0 scaleY:1.0], nil];
		}
		
		[nodes[x] runAction:action];
	}
}

#pragma mark -
#pragma mark Timeline Management

-(void)setEarliestDate:(NSDate *)date
{
	// store the date
	dateEarliest = [date timeIntervalSinceReferenceDate] - 86400;
	
	dateStart = dateEarliest;
	
	// set the start date
	[self setStartTimeInterval:dateEarliest];
	
	// refresh overview
	[self refreshOverview];
}

-(void)setLatestDate:(NSDate *)date
{
	// store the date
	dateLatest = [date timeIntervalSinceReferenceDate] + 86400;
	
	dateEnd = dateLatest;
	
	// set the end date
	[self setEndTimeInterval:dateLatest];
	
	// refresh overview
	[self refreshOverview];
}

-(void)setStartTimeInterval:(NSTimeInterval)interval
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehaviorDefault];
	
	// set date
	[df setDateFormat:@"dd-MM-yy"];
	[lbDateLeft setString:[df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]]];
	
	// set time
	[df setDateFormat:@"hh:mm:ss a"];
	[lbTimeLeft setString:[df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]]];
	
	[df release];
}

-(void)setEndTimeInterval:(NSTimeInterval)interval
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehaviorDefault];
	
	// set date
	[df setDateFormat:@"dd-MM-yy"];
	[lbDateRight setString:[df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]]];
	
	// set time
	[df setDateFormat:@"hh:mm:ss a"];
	[lbTimeRight setString:[df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]]];
	
	[df release];
}

-(void)setStartDateFromXPosition:(float)x
{
	// x ranges from -length/2.0 to length/2.0
	// make it so that it ranges from 0 to length/2.0
	x += length/2.0;
	
	// get the time length
	NSTimeInterval timeLength = dateLatest - dateEarliest;
	
	// get percentage
	double percentage	= x / length;
	
	// set date start
	dateStart = dateEarliest + (timeLength*percentage);
	
	// set the start time
	[self setStartTimeInterval:dateStart];
	
	// refresh overview
	[self refreshOverview];
}

-(void)setEndDateFromXPosition:(float)x
{
	// x ranges from -length/2.0 to length/2.0
	// make it so that it ranges from 0 to length/2.0
	x += length/2.0;
	
	// get the time length
	NSTimeInterval timeLength = dateLatest - dateEarliest;
	
	// get percentage
	double percentage	= x / length;
	
	// set date end
	dateEnd = dateEarliest + (timeLength*percentage);
	
	// set the end time
	[self setEndTimeInterval:dateEnd];
	
	// refresh the overview
	[self refreshOverview];
}

-(void)updateDates
{
	if ([transactions count] < 2)
		return;
	
	// get earliest date
	[self setEarliestDate:[[transactions objectAtIndex:0] timeStamp]];
	
	// get latest date
	[self setLatestDate:[[transactions lastObject] timeStamp]];
}

-(void)updateTransactions
{
	// load the batch sprite
	if (spTransactions == nil)
	{
		// create
		spTransactions = [CCSpriteBatchNode batchNodeWithFile:@"TimelineBarSelectionHighlighted.png" capacity:[transactions count]];
		
		// add to current layer
		[self addChild:spTransactions z:1];
	}
	// remove all children if it already exists
	else
	{
		[spTransactions removeAllChildrenWithCleanup:NO];
	}
	
	CGRect rect = CGRectMake(0, 0, spTransactions.texture.contentSize.width, spTransactions.texture.contentSize.height);
	
	double timeBounds[2] = { dateEarliest, dateLatest };
	double timeLength = timeBounds[1] - timeBounds[0];
	
	// add the transaction sprites
	for (Transaction *transaction in transactions)
	{
		// get the percentage of the bar where the timestamp lies
		float percentage = ([transaction.timeStamp timeIntervalSinceReferenceDate] - timeBounds[0]) / timeLength;
		
		if (percentage < 0.0 || percentage > 1.0)
			continue;
		
		CCSprite *sp = [CCSprite spriteWithBatchNode:spTransactions rect:rect];
		[spTransactions addChild:sp];
		
		// save the percentage to tag
		sp.tag = percentage*100.0;
	
		// position it
		sp.position = ccp(-length/2.0 + percentage*length,0);
		
		// only hide it initially
		if (!isShown)
		{
			sp.scale = 0;
		}
	}
}

-(void)setTransactions:(NSArray *)t
{
	// store transactions
	transactions = t;

	// update the dates
	[self updateDates];
}

-(void)refreshOverview
{
	NSTimeInterval d1 = [[[transactions objectAtIndex:0] timeStamp] timeIntervalSinceReferenceDate] - 86400;
	NSTimeInterval d2 = [[[transactions lastObject] timeStamp] timeIntervalSinceReferenceDate] + 86400;
	
	NSTimeInterval timeDiffTotal	= d2 - d1;
	NSTimeInterval timeDiff			= dateEnd - dateStart;

	float percentage = timeDiff/timeDiffTotal;
	float start	= ((dateStart-d1) / timeDiffTotal) * spOverviewShading.contentSize.width;
	
	spOverviewShading.position = ccp((spOverview.contentSize.width-spOverviewShading.contentSize.width)/2.0 + start, spOverviewShading.position.y);
	spOverviewShading.anchorPoint = ccp(0, 0.5);
	
	// scale the shading
	spOverviewShading.scaleX = MAX(percentage, 1.0/spOverviewShading.contentSize.width);
}

#pragma mark -
#pragma mark Touches

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get touch location
	UITouch *touch = [touches anyObject];	
	CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	// SELF itself is not aligned with parent, so subtract its position
	pt = ccpSub(pt, self.position);
	
	// reset touch state
	touchState = TouchStateNil;
	
	// dragging left pin
	if ([spPinLeft touchInNode:pt])
	{
		touchState = TouchStateDraggingLeftPin;
		
		// reset time?
		if ([touch tapCount] == 2)
		{
			[self setEarliestDate:[[transactions objectAtIndex:0] timeStamp]];
			spPinLeft.color = ccc3(255, 255, 255);
			[self updateTransactions];
			
			// notify the delegate
			[delegate timelineChangedToStartDate:dateStart andEndDate:dateEnd];
		}
	}
	// dragging right pin
	else if ([spPinRight touchInNode:pt])
	{
		touchState = TouchStateDraggingRightPin;
		
		// reset time?
		if ([touch tapCount] == 2)
		{
			[self setLatestDate:[[transactions lastObject] timeStamp]];
			spPinRight.color = ccc3(255, 255, 255);
			[self updateTransactions];
			
			// notify the delegate
			[delegate timelineChangedToStartDate:dateStart andEndDate:dateEnd];
		}
	}
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (touchState == TouchStateNil)
		return;
	
	// get touch location, as well as previous touch
	UITouch *touch = [touches anyObject];
	CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	// SELF itself is not aligned with parent, so subtract its position
	pt = ccpSub(pt, self.position);

	// get the pin we're moving
	switch (touchState)
	{
		case TouchStateNil:
			
			break;
			
		case TouchStateDraggingLeftPin:
			
			spPinLeft.position = ccp(MIN(MAX(pt.x+spPinLeft.contentSize.width/2.0, -length/2.0), length/2.05), spPinLeft.position.y);
			
			// set the date
			[self setStartDateFromXPosition:spPinLeft.position.x];
			
			break;
			
		case TouchStateDraggingRightPin:
			
			spPinRight.position = ccp(MAX(MIN(pt.x-spPinLeft.contentSize.width/2.0, +length/2.0), -length/2.05), spPinRight.position.y);
			
			// set the date
			[self setEndDateFromXPosition:spPinRight.position.x];
			
			break;
	}
	
	// notify the delegate
	[delegate timelineChangedToStartDate:dateStart andEndDate:dateEnd];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// start or end date changed?
	if (touchState == TouchStateDraggingLeftPin && spPinLeft.position.x != -length/2.0)
	{
		// pop the left pin back
		id action = [CCMoveTo actionWithDuration:0.5 position:ccp(-length/2.0, 0)];
		action = [CCEaseSineOut actionWithAction:action];
		[spPinLeft runAction:action];
		
		// and mark it
		spPinLeft.color = ccc3(165, 165, 165);
	}
	else if (touchState == TouchStateDraggingRightPin && spPinRight.position.x != length/2.0)
	{
		// pop the right pin back
		id action = [CCMoveTo actionWithDuration:0.5 position:ccp(length/2.0, 0)];
		action = [CCEaseSineOut actionWithAction:action];
		[spPinRight runAction:action];
		
		// and mark it
		spPinRight.color = ccc3(165, 165, 165);
	}
	else
		return;
	
	// refresh the dates
	dateEarliest = dateStart;
	dateLatest = dateEnd;
	
	// update the transactions
	[self updateTransactions];
	
	// notify the delegate
	[delegate timelineChangedToStartDate:dateStart andEndDate:dateEnd];
}

@end
