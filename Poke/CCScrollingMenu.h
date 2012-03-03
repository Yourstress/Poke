//
//  CCScrollingMenu.h
//  iKout
//
//  Created by Mansour Alsarraf on 4/6/10.
//  Copyright 2010 Diwaniya Labs <http://www.diwaniyalabs.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Standard.h"
#import "CCTargetedTouchMenu.h"

typedef enum {
	ScrollingMenuVertical = 0,
	ScrollingMenuHorizontal = 1,
} ScrollingMenuDirection;

@interface CCScrollingMenu : CCTargetedTouchMenu
{
	int touchState;			// the touch state for this class
	float itemPadding;		// how many pixels separate each two items
	
	// content size
	float rx1;
	float rx2;
	float ry1;
	float ry2;
	
	float heightInPixels;
	
	// scroll direction
	int direction;
	
	// clip tolerance
	float clipTolerance;
}

-(void)setOutwardClipping:(float)x1 :(float)x2 :(float)y1 :(float)y2;
-(void)setInwardClipping:(float)x1 :(float)x2 :(float)y1 :(float)y2 withPixels:(float)pixels;
-(void)setScrollDirection:(ScrollingMenuDirection)dir;
-(void)setClipTolerance:(float)pixels;

-(void)alignItemsInColumnsWithPadding:(float)padding withSpacing:(float)spacing withColumns:(NSNumber *)first, ...;

-(void)updateItems:(CGPoint)position;

//-(CCMenuItem *) itemForTouch: (UITouch *) touch;

@end
