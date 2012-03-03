//
//  LayerPopover.h
//  Poke
//
//  Created by Macbook Pro on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"

#define PopoverHalfWidth		164
#define PopoverHalfHeight		223

@interface LayerPopover : CCLayer
{
	// layer under the body sprite
	CCLayer *layer;
	
	// title of the popover
	CCLabelStroked *labelTitle;
	
	// put all the buttons on here
	CCMenu *menuButtons;
}

@property (nonatomic, assign, setter=setOpacity:) GLubyte opacity;

+(id)popoverWithPosition:(CGPoint)position;

-(id)initWithPosition:(CGPoint)position;

-(void)setTitle:(NSString *)title;

-(void)show;
-(void)close;

@end
