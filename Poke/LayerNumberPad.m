//
//  LayerNumberPad.m
//  Poke
//
//  Created by Sour on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerNumberPad.h"


@implementation LayerNumberPad

@synthesize delegate;

+(id)numberPadWithPosition:(CGPoint)position facingLeft:(BOOL)facingLeft
{
	return [[[self alloc] initWithPosition:position facingLeft:facingLeft] autorelease];
}

-(id)initWithPosition:(CGPoint)position facingLeft:(BOOL)facingLeft
{
	if ( (self = [super init]) )
	{
		self.isTouchEnabled = YES;
		
		// create background
		CCSprite *spBackground = [CCSprite spriteWithFile:@"NumberPad.png"];
		spBackground.anchorPoint = ccp(1,0.5);
		spBackground.position = position;
		spBackground.flipX = !facingLeft;
		[self addChild:spBackground];
		
		// create menu
		menuButtons = [CCTargetedTouchMenu menuWithTouchPriority:INT_MIN withItems:nil];
		menuButtons.position = ccp(spBackground.contentSize.width/2.0+Scaled(6), spBackground.contentSize.height/2.0-Scaled(23));
		[spBackground addChild:menuButtons];
		
		[self addNumpadButtons];
	}
	
	return self;
}

-(void)addNumpadButtons
{
	char cButton[12] = { 'C','0','K','1','2','3','4','5','6','7','8','9' };
	int side[4] = { -1, 0, 1, 2 };
	const float offsetX = Scaled(48.0);
	const float offsetY = Scaled(45.0);
	
	for (int x = 0; x < 3; x++)
	{
		for (int y = 0; y < 4; y++)
		{
			char c = cButton[x+(3*y)];
			NSString *sButtonImage		= [NSString stringWithFormat:@"Number%c.png", c];
			NSString *sButtonImageDown	= [NSString stringWithFormat:@"Number%cDown.png", c];
			
			CCMenuItemImage *menuItem = [CCMenuItemImage itemFromNormalImage:sButtonImage selectedImage:sButtonImageDown target:self selector:@selector(onNumKeyPressed:)];
			
			menuItem.userData = (void *)c;
			
			menuItem.position = ccp(side[x]*offsetX, side[y]*offsetY);

			[menuButtons addChild:menuItem];
		}
	}
}

#pragma mark -
#pragma mark Actions

-(void)onNumKeyPressed:(id)sender
{
	char c = (char)[sender userData];
	if (c == 'C')
		[delegate numberPadCleared];
	else if (c == 'K')
		[delegate numberPadKD];
	else
		[delegate numberPadEnteredNumber:[[NSString stringWithFormat:@"%c", c] intValue]];
	
	// play sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundButton.mp3"];
}

#pragma mark -
#pragma mark Touches

-(void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	if ([menuButtons.parent touchInNode:[menuButtons.parent.parent convertToNodeSpace:location]])
		return YES;
	
	return NO;
}

@end
