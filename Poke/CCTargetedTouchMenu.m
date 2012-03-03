//
//  CCTargetedTouchMenu.m
//  iKout
//
//  Created by Mansour Alsarraf on 3/5/10.
//  Copyright 2010 Diwaniya Labs <http://www.diwaniyalabs.com>. All rights reserved.
//

#import "CCTargetedTouchMenu.h"


@implementation CCTargetedTouchMenu

@synthesize priority;

+(id) menuWithTouchPriority:(int)pr withItems: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
	
	CCTargetedTouchMenu *menu = [[self alloc] autorelease];
	
	menu.priority = pr;
	
	[menu initWithItems: item vaList:args];
	
	va_end(args);
	
	return menu;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:priority swallowsTouches:YES];
}

@end
