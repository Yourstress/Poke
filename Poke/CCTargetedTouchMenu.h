//
//  CCTargetedTouchMenu.h
//  iKout
//
//  Created by Mansour Alsarraf on 3/5/10.
//  Copyright 2010 Diwaniya Labs <http://www.diwaniyalabs.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCTargetedTouchMenu : CCMenu
{
	int priority;
}

@property (nonatomic, assign) int priority;

+(id) menuWithTouchPriority:(int)pr withItems: (CCMenuItem*) item, ...;

@end
