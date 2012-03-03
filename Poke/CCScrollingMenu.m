//
//  CCScrollingMenu.m
//  iKout
//
//  Created by Mansour Alsarraf on 4/6/10.
//  Copyright 2010 Diwaniya Labs <http://www.diwaniyalabs.com>. All rights reserved.
//

#import "CCScrollingMenu.h"

typedef enum {
	TouchStateNone = 0,
	TouchStateGrabbed = 1,
} TouchState;

@implementation CCScrollingMenu

-(id) initWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	if ( (self = [super initWithItems:item vaList:args]) )
	{
		// default scroll direction
		[self setScrollDirection:ScrollingMenuVertical];
		
		// default clip tolerance
		[self setClipTolerance:40];
		
		// default content size
		[self setOutwardClipping:0 :st.size.width :0 :st.size.height];
	}
	
	return self;
}

-(void)setOutwardClipping:(float)x1 :(float)x2 :(float)y1 :(float)y2
{
	rx1 = x1;
	rx2 = x2;
	ry1 = y1;
	ry2 = y2;
}

// note: must set clip tolerance before this
-(void)setInwardClipping:(float)x1 :(float)x2 :(float)y1 :(float)y2 withPixels:(float)pixels
{
	rx1 = x1 + pixels;
	rx2 = x2 - pixels;
	ry1 = y1 + pixels;
	ry2 = y2 - pixels;
}

-(void)setScrollDirection:(ScrollingMenuDirection)dir
{
	direction = dir;
}

-(void)setClipTolerance:(float)pixels
{
	clipTolerance = pixels;
}

// overridden
-(void)alignItemsVerticallyWithPadding:(float)padding
{
	itemPadding = padding;
	
	float ypos = ry2;
	
	for (CCMenuItem *item in children_)
	{
		[item setPosition:ccp(rx1+(rx2-rx1)/2.0, ypos - (item.contentSize.height/2.0))];
		
		ypos -= item.contentSize.height * item.scaleY + padding;
	}
	
	CCMenuItem *itemF	= [children_ objectAtIndex:0];
	CCMenuItem *itemL	= [children_ lastObject];
	
	heightInPixels		= (itemF.position.y + itemF.contentSize.height/2.0) -
						  (itemL.position.y - itemL.contentSize.height/2.0);
	
	// move the whole menu to a neutral position
	self.position = ccp(0,0);
}

// overridden
-(void)alignItemsHorizontallyWithPadding:(float)padding
{
//	itemPadding = padding;
//	
//	CCMenuItem *itemFirst = [children_ objectAtIndex:0];
//	
//	float xpos = 0 - (self.contentSize.width*self.scaleY/2.0);
//	xpos += ((itemFirst.contentSize.width*itemFirst.scale)/2.0) + padding;
//	
//	for(CCMenuItem *item in children_)
//	{
//		[item setPosition:ccp(xpos, 0)];
//		xpos += item.contentSize.width * item.scale + padding;
//	}
}

-(void)alignItemsInColumnsWithPadding:(float)padding withSpacing:(float)spacing withColumns:(NSNumber *)first, ...
{
	va_list args;
	va_start(args, first);
	NSMutableArray *rows = [[NSMutableArray alloc] initWithObjects:first, nil];
	while( (first = va_arg(args, NSNumber *)) )
        [rows addObject:first];
	va_end(args);

	// start aligning items
	itemPadding = padding;
	float ypos = 0;
	int nextChild = 0;
	
	for (int x = 0; x < [rows count]; x++)
	{
		int numColumns = [[rows objectAtIndex:x] intValue];
		
		float maxHeight = 0;
		
		for (int col = 0; col < numColumns; col++)
		{
//			float offset = (-maxWidth/2.0) + ((maxWidth/(numColumns-1))*col);
			float offset = (-spacing*(numColumns-1)/2.0) + (col * spacing);
			
			CCMenuItem *item = [children_ objectAtIndex:nextChild++];
			[item setPosition:ccp(offset, ypos)];
			
			float tempHeight = item.contentSize.height * item.scaleY;
			
			if (tempHeight > maxHeight)
				maxHeight = tempHeight;
		}
		
		// increment y after rows not items
		ypos -= maxHeight + padding;
	}
	
	CCMenuItem *itemFirst = [children_ objectAtIndex:0];
	
	// move up the whole menu
	self.position = ccp(self.position.x, ry2 - (itemFirst.contentSize.height * itemFirst.scaleY)/2.0 - padding);
	
	[rows release];
}

// overridden: not yet!
-(void) alignItemsInColumns: (NSNumber *) columns vaList: (va_list) args
{
	CCLOG(@"alignItemsInColumns not implemented.");
}

// overridden: not yet!
-(void) alignItemsInRows: (NSNumber *) columns vaList: (va_list) args
{
	CCLOG(@"alignItemsInRows not implemented.");
}

// overridden
-(void)setPosition:(CGPoint)position
{
	[super setPosition:position];
	
	// update items
	[self updateItems:position];
}

// overridden
-(void)setParent:(CCNode *)parent
{
	parent_ = parent;
	
	// update items
	[self updateItems:position_];
}

-(void)updateItems:(CGPoint)position
{
	if (!parent_)
		return;

	float itemEdge, offBy;
	float clipFactor = 255 / clipTolerance;

	// TOP CLIPPING
	int x = 0;
	for (; x < [children_ count]; x++)
	{
		CCMenuItemFont *item = [children_ objectAtIndex:x];
		
		// top clipping
		itemEdge	= item.position.y + (item.contentSize.height/2.0);
		offBy		= -(ry2-itemEdge-position.y);
		
		// set opacity based on distance from 0
		if (offBy > 0)
			// clipTolerance is as high as we can go!
			[item setOpacityRecursive:255 - MIN(clipTolerance, offBy) * clipFactor];
		else
			// this is where we stop and the bottom clipping continues
			break;
	}
	
	// CENTER-BOTTOM CLIPPING
	for (x++; x < [children_ count]; x++)
	{
		CCMenuItemFont *item = [children_ objectAtIndex:x];

		// bottom clipping
		itemEdge	= item.position.y - (item.contentSize.height/2.0);
		offBy		= ry1-itemEdge-position.y;

		// set opacity based on distance from 0
		if (offBy > 0)
			// clipTolerance is as high as we can go!
			[item setOpacityRecursive:255 - MIN(clipTolerance, offBy) * clipFactor];
		else
			[item setOpacityRecursive:255];
	}
}

#pragma mark Touches
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	// stop moving the window
	[self stopAllActions];
	
	touchState = TouchStateGrabbed;
	
	// selection
	selectedItem_ = [self performSelector:@selector(itemForTouch:) withObject:touch];
	[selectedItem_ selected];
	
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchState = TouchStateNone;
	
	if (selectedItem_)
	{
		[selectedItem_ unselected];
		[selectedItem_ activate];
		
		return;
	}

	switch (direction)
	{
		case ScrollingMenuHorizontal:
			// TODO: horizontal spring back
			break;
		case ScrollingMenuVertical:
		{
			float contentHeight = ry2-ry1;
			
			// if the menu moved down beyond bounds, spring it back up
			// OR if the menu moved UP but we don't want it sprung up all the way
			if (self.position.y < 0.0 || heightInPixels < contentHeight)
			{
				// spring back up
				[self runAction:[CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.50 position:ccp(0, 0)] rate:3]];
				break;
			}
			
			// if the menu moved up beyond bounds, spring it back down
			float temp = heightInPixels - contentHeight;
			if (self.position.y > 0.0 && self.position.y > temp)
			{
				// spring back down
				[self runAction:[CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.50 position:ccp(0, temp)] rate:3]];
				break;
			}
			
			break;
		}
	}
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchState = TouchStateNone;
	
	if (selectedItem_)
		[selectedItem_ unselected];

//	if (state == kMenuStateTrackingTouch)
//		[super ccTouchCancelled:touch withEvent:event];
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (selectedItem_)
	{
		[selectedItem_ unselected];
		selectedItem_ = nil;
	}
	
	if (touchState == TouchStateGrabbed)
	{
		// get the distance
		CGPoint ptStart	= [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:[touch view]]];
		CGPoint ptEnd	= [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
		
		float moveX = 0;
		float moveY = 0;
		
		switch (direction)
		{
			case ScrollingMenuHorizontal:
				moveX = ptEnd.x-ptStart.x;
				break;
			case ScrollingMenuVertical:
				moveY = ptEnd.y-ptStart.y;
				break;
		}
		
		// move the menu
//		[self runAction:[CCMoveBy actionWithDuration:0.035 position:ccp(moveX, moveY)]];
		self.position = ccp(self.position.x + moveX, self.position.y + moveY);
	}
	
//	if (state == kMenuStateTrackingTouch)
//		[super ccTouchMoved:touch withEvent:event];
}

@end
