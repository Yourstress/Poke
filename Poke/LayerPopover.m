//
//  LayerPopover.m
//  Poke
//
//  Created by Macbook Pro on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPopover.h"


@implementation LayerPopover
@synthesize opacity;

+(id)popoverWithPosition:(CGPoint)position
{
	return [[[self alloc] initWithPosition:position] autorelease];
}

-(id)initWithPosition:(CGPoint)position
{
	if ( (self = [super init]) )
	{
		// play popover sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"SoundPopover.mp3"];
		
		self.visible = NO;
		
		self.tag = 4224;
		
		BOOL isArrowOnLeft = (position.x <= st.size.width/2.0);
		
		CCSprite *spBody = [CCSprite spriteWithFile:@"PopoverBackground.png"];
		[self addChild:spBody z:1 tag:1];
		
		// layer under the body
		layer = [CCLayer node];
		layer.position = ccp(spBody.contentSize.width/2.0,spBody.contentSize.height/2.0);
		[spBody addChild:layer];
		
		// create the menu on which we'll add buttons
		menuButtons = [CCTargetedTouchMenu menuWithTouchPriority:INT_MIN withItems:nil];
		menuButtons.position = ccp(0,0);
		menuButtons.contentSize = spBody.contentSize;
		[layer addChild:menuButtons];
		
		// only do this on iPad
		if (iPad)
		{
			CCSprite *spArrow = [CCSprite spriteWithFile:@"PopoverArrow.png"];
			spArrow.anchorPoint = ccp(isArrowOnLeft ? 1 : 0, 0.5);
			spArrow.position = ccp(isArrowOnLeft ? -PopoverHalfWidth : PopoverHalfWidth, 0);
			if (!isArrowOnLeft)
				spArrow.flipX = YES;
			[self addChild:spArrow z:0];
		
			// up-reaching?
			if (st.size.height-position.y < spBody.contentSize.height)
				spBody.anchorPoint = ccp(0.5,0.85);
			// down-reaching?
			if (position.y < spBody.contentSize.height)
				spBody.anchorPoint = ccp(0.5,0.15);
			
			// reset the offset and add 60 more for length of arrow
			self.position = ccpAdd(position, isArrowOnLeft ? ccp(PopoverHalfWidth+60,0) : ccp(-PopoverHalfWidth-60,0));
		}
		else
		{
			// center it on non-ipad devices
			self.position = ccp(st.size.width/2.0,st.size.height/2.0);
		}
		
		// enable touches
		self.isTouchEnabled = YES;
	}
	
	return self;
}

-(void)setTitle:(NSString *)title
{
	if (labelTitle)
		[labelTitle removeFromParentAndCleanup:YES];
	
	labelTitle = [CCLabelStroked labelWithString:title fontName:FontFamilyRegular fontSize:Scaled(30)];
	labelTitle.strokeSize = iPad ? 2 : 1.5;
	[layer addChild:labelTitle];
	
	labelTitle.anchorPoint = ccp(0.5,1);
	labelTitle.position = ccp(0, Scaled(PopoverHalfHeight-19));
}

-(void)setOpacity:(GLubyte)o
{
	opacity = o;

	for (CCNode *node in self.children)
		[node setOpacityRecursive:o];
}

-(void)show
{
	// show
	self.visible = YES;
	
	// start fading in
	id action = [CCEaseSineIn actionWithAction:[CCFadeTo actionWithDuration:0.15 opacity:255]];
	[self runAction:action];
}

-(void)close
{
	id action = [CCEaseSineIn actionWithAction:[CCFadeTo actionWithDuration:0.15 opacity:0]];
	action = [CCSequence actionOne:action two:[CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES]];
	
	[self runAction:action];
}

#pragma mark -
#pragma mark Touches

-(void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	CGPoint p;
	
	p = [layer.parent convertToNodeSpace:location];
	CGRect r = CGRectMake(0, 0, layer.parent.contentSize.width, layer.parent.contentSize.height);
	
	// touch outside?
	if (!CGRectContainsPoint(r, p))
	{
		// close
		[self close];
	}
	
	return YES;
}

@end
