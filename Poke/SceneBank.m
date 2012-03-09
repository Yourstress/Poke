//
//  SceneBank.m
//  Poke
//
//  Created by Macbook Pro on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SceneBank.h"
#import "LayerPlayers.h"
#import "LayerPopoverTransaction.h"
#import "LayerPopoverTableTransactions.h"
#import "LayerTimeline.h"

@implementation SceneBank

#pragma mark -
#pragma mark Initialization

-(id)init
{
	if ( (self = [super init]) )
	{
		// turn on touches
		self.isTouchEnabled = YES;
//#ifndef DEBUG	
		// show splash then fade out
		CCSprite *spSplash = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		spSplash.anchorPoint = ccp(0,0);
		[self addChild:spSplash z:1000];
		
		// fade out here
		id action = [CCSequence actions:
					 [CCDelayTime actionWithDuration:2.5],
					 [CCFadeOut actionWithDuration:0.7],
					 [CCCallFuncND actionWithTarget:spSplash selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
					 nil];

		[spSplash runAction:action];
//#endif

		// background
		[self initBackground];
		
		// interface
		[self initInterface];
	}
	
	return self;
}

-(void)initBackground
{
	// background
	spBackground = [CCSprite spriteWithFile:@"Background.png"];
	spBackground.anchorPoint = ccp(0,0);
	[self addChild:spBackground z:0];
}

-(void)initInterface
{
	CCMenu *menuButtons = [CCMenu menuWithItems:nil];
	menuButtons.position = ccp(0,0);
	[self addChild:menuButtons z:0];
	
	// bank button
	buttonBank = [CCMenuItemImage itemFromNormalImage:@"IconBank.png" selectedImage:@"IconBankDown.png" target:self selector:@selector(onBank:)];
	buttonBank.position = ccp(111,666);
	buttonBank.tag = ItemTypeBank;
	[menuButtons addChild:buttonBank];
	
	// add player button
	buttonAddPlayer = [CCMenuItemImage itemFromNormalImage:@"IconAddPlayer.png" selectedImage:@"IconAddPlayerDown.png" target:self selector:@selector(onAddPlayer:)];
	buttonAddPlayer.position = ccp(st.size.width-111, 666);
	buttonAddPlayer.tag = ItemTypeDelete;
	[menuButtons addChild:buttonAddPlayer];
	
	// transaction history button
	buttonTransactions = [CCMenuItemImage itemFromNormalImage:@"IconCoin.png" selectedImage:@"IconCoinDown.png" target:self selector:@selector(onTransactions:)];
	buttonTransactions.position = ccp(st.size.width-211, 666);
	[menuButtons addChild:buttonTransactions];
	
	// timeline button
	buttonTimeline = [CCMenuItemImage itemFromNormalImage:@"IconTimeline.png" selectedImage:@"IconTimelineDown.png" disabledImage:@"IconTimelineDown.png" target:self selector:@selector(onTimeline:)];
	buttonTimeline.position = ccp(st.size.width-311, 666);
	[menuButtons addChild:buttonTimeline];
	
	// bank name BUTTON
	labelBankName = [CCLabelStroked labelWithString:@"[No bank selected]" fontName:FontFamilyRegular fontSize:36];
	labelBankName.strokeSize = 3;
//	[self addChild:labelBankName];
	buttonBankName = [CCMenuItemLabel itemWithLabel:labelBankName block:^(id sender)
					  {
						  if (!st.currentBank)
							  return;
						  
						  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Player" message:@"Please enter a new name for this bank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
						  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
						  alert.tag = 'R';

						  UITextField *textField = [alert textFieldAtIndex:0];
						  textField.text = st.currentBank.name;
						  
						  [alert show];
						  [alert release];
						  
						  // play alert sound
						  [[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
					  }];
	buttonBankName.position = ccpAdd(buttonBank.position, ccp(buttonBank.contentSize.width*0.75, 14));
	buttonBankName.anchorPoint = ccp(0,0.5);
	[menuButtons addChild:buttonBankName];
	
	
	// bank balance label
	labelBankBalance = [CCLabelStroked labelWithString:@"0.000 KD" fontName:FontFamilyRegular fontSize:32];
	labelBankBalance.position = ccpAdd(buttonBank.position, ccp(buttonBank.contentSize.width*0.75, -26));
	labelBankBalance.anchorPoint = ccp(0,0.5);
	labelBankBalance.strokeSize = 3;
	[self addChild:labelBankBalance];
	
	// players
	layerPlayers = [LayerPlayers playersLayerWithSize:CGSizeMake(970, 574)];
	layerPlayers.position = ccp(st.size.width/2.0, 24+(574/2));
	layerPlayers.anchorPoint = ccp(0.5,0.5);
	[self addChild:layerPlayers];
	
	// refresh the bank name and balance
	[self refreshBank];
	
	// refresh the players
	[self refreshPlayers];
}

#pragma mark -
#pragma mark Interface Controls

-(void)setBankName:(NSString *)bankName
{
	[labelBankName setString:bankName];
}

-(void)setBankBalance:(float)bankBalance
{
	[labelBankBalance setString:[Bank stringFromAmount:bankBalance]];
}

-(void)setDraggingControls:(BOOL)enabled
{
	if (draggingControlsEnabled == enabled)
		return;
	
	draggingControlsEnabled = enabled;
	
	CCSprite *imageNormal	= [CCSprite spriteWithFile:enabled ? @"IconDelete.png" : @"IconAddPlayer.png"];
	CCSprite *imageDownSel	= [CCSprite spriteWithFile:enabled ? @"IconDeleteDown.png" : @"IconAddPlayerDown.png" ];

	[buttonAddPlayer setNormalImage:imageNormal];
	[buttonAddPlayer setSelectedImage:imageDownSel];
	
	[buttonAddPlayer setIsEnabled:!enabled];
}

-(void)refreshBank
{
	// if a bank is selected
	if (st.currentBank != nil)
	{
		[self setBankName:st.currentBank.name];
		[self setBankBalance:st.currentBank.balance];
	}
	// if no bank is selected
	else
	{
		[self setBankName:@"[No bank selected]"];
		[self setBankBalance:0.0];
	}
}

-(void)refreshPlayers
{
	// remove all previous players
	[layerPlayers removeAllChildrenWithCleanup:YES];
	
	if (!st.currentBank)
		return;
	
	// re-add them
	for (Player *player in st.currentBank.players)
	{
		[layerPlayers addPlayer:player.name repositionPlayers:NO];
	}
	
	[layerPlayers repositionPlayers];
}

-(void)refreshTimeline
{
	if (layerTimeline != nil)
	{
		// update the transactions
		[layerTimeline updateTransactions];
	}
}

-(void)popoverPlayerToBank:(NSString *)playerName atPosition:(CGPoint)position
{
	LayerPopoverTransaction *popover = [LayerPopoverTransaction popoverWithPosition:position];
	
	// set the title
	[popover setTitle:@"Coin In"];
	
	// set the transfer
	[popover setTransferFromPlayer:playerName];
	[popover setTransferToBank];
	[popover setArrowDirection:ArrowDirectionRight];
	
	// confirm button
	[popover setConfirmBlock:^(id data)
	 {
		 [self refreshBank];
		 [self refreshPlayers];
		 if ([layerTimeline isShown])
			 [self refreshTimeline];
	 }];
	
	[self addChild:popover];
	[popover show];
}

-(void)popoverBankToPlayer:(NSString *)playerName atPosition:(CGPoint)position
{
	LayerPopoverTransaction *popover = [LayerPopoverTransaction popoverWithPosition:position];
	
	// set the title
	[popover setTitle:@"Coin Out"];
	
	// set the transfer
	[popover setTransferFromBank];
	[popover setTransferToPlayer:playerName];
	[popover setArrowDirection:ArrowDirectionRight];
	
	// confirm button
	[popover setConfirmBlock:^(id data)
	 {
		 [self refreshBank];
		 [self refreshPlayers];
		 if ([layerTimeline isShown])
			 [self refreshTimeline];
	 }];
	
	[self addChild:popover];
	[popover show];
}

-(void)popoverPlayer:(NSString *)player1Name toPlayer:(NSString *)player2Name atPosition:(CGPoint)position
{
	LayerPopoverTransaction *popover = [LayerPopoverTransaction popoverWithPosition:position];

	// set the title
	[popover setTitle:@"Transfer"];
	
	// set the transfer
	[popover setTransferFromPlayer:player1Name];
	[popover setTransferToPlayer:player2Name];
	[popover setArrowDirection:ArrowDirectionRight];
	
	// confirm button
	[popover setConfirmBlock:^(id data)
	 {
		 [self refreshBank];
		 [self refreshPlayers];
		 if ([layerTimeline isShown])
			 [self refreshTimeline];
	 }];
	
	[self addChild:popover];
	[popover show];
}

#pragma mark -
#pragma mark Event Handling

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 'B')			// ADD BANK
	{
		if (buttonIndex == 0)		// OK
		{
			// get the bank name
			NSString *bankName = [alertView textFieldAtIndex:0].text;
			
			// validate it
			if (![Bank validateString:bankName withOptions:ValidationTypeBankName])
				return;

			// add the bank
			if (![st addBank:bankName])
			{
				[Standard alertViewWithTitle:@"Bank Already Exists" message:@"The bank name you provided already exists. Please choose a different name." cancalButtonTitle:@"OK"];
				return;
			}
			
			// refresh the popover
			LayerPopoverTable *popover = (LayerPopoverTable *)[self getChildByTag:100];
			[popover refreshItems];
		}
	}
	else if (alertView.tag == 'P')	// ADD PLAYER
	{
		if (buttonIndex == 0)		// OK
		{
			// get the player name
			NSString *playerName = [alertView textFieldAtIndex:0].text;
			
			// validate it
			if (![Bank validateString:playerName withOptions:ValidationTypePlayerName])
				return;
			
			// add the player
			if (![st.currentBank addPlayer:playerName])
			{
				[Standard alertViewWithTitle:@"Player Already Exists" message:@"A player with this name already exists within this bank. Please choose another name." cancalButtonTitle:@"OK"];
				return;
			}
			
			// refresh the players
			[self refreshPlayers];
		}
	}
	else if (alertView.tag == 'b')	// DELETE BANK
	{
		if (buttonIndex == 0)		// OK
		{
			// delete the bank
			[st deleteBank:st.currentBank.name];
			
			// refresh everything
			[self refreshBank];
			[self refreshPlayers];
			if (layerTimeline.isShown)	[self refreshTimeline];
		}
	}
	else if (alertView.tag == 'p')	// DELETE PLAYER
	{
		if (buttonIndex == 0)		// OK
		{
			// delete the player
			[st.currentBank deletePlayer:buttonAddPlayer.userData];
			
			// refresh everything
			[self refreshBank];
			[self refreshPlayers];
			if (layerTimeline.isShown)	[self refreshTimeline];
		}
	}
	else if (alertView.tag == 'R')	// RENAME BANK
	{
		if (buttonIndex == 0)		// OK
		{
			// validate new name
			if (![Bank validateString:[alertView textFieldAtIndex:0].text withOptions:ValidationTypeBankName])
				return;
			
			// rename it
			if (![st renameCurrentBankTo:[alertView textFieldAtIndex:0].text])
				NSLog(@"Unable to rename bank.");
			
			// refresh bank
			[self refreshBank];
		}
	}
}

-(void)onBank:(id)sender
{
	// if we're on timeline mode, turn it off
	if (isTimelineOn)
		[self onTimeline:buttonTimeline];
	
	// bank selected
	LayerPopoverTable *popover = [LayerPopoverTable popoverWithPosition:buttonBank.position title:@"Available Banks" items:st.banks block:^(id data)
	 {
		 // get the bank name
		 NSString *bankName = (NSString *)data;
		 
		 // set bank
		 [st setCurrentBank:bankName];
		 
		 // refresh bank and players
		 [self refreshBank];
		 [self refreshPlayers];
		 
		 // upon changing the bank, remove the timeline
		 [layerTimeline removeFromParentAndCleanup:YES];
		 layerTimeline = nil;
		 
		 // close
		 [((LayerPopoverTable *)[self getChildByTag:100]) close];
	 }];
	
	// "plus" button pressed
	[popover addTitleBarButton:ButtonTypeAdd block:^(id data)
	 {
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Bank" message:@"Please enter a name for the new bank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
		 alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		 alert.tag = 'B';
		 
		 [alert show];
		 [alert release];
		 
		 // play alert sound
		 [[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
	 }];
	
	// add the popover
	[self addChild:popover z:100 tag:100];
	
	[popover show];
}

-(void)onTransactions:(id)sender
{
	// if there's no bank selected
	if (!st.currentBank)
	{
		// show an alert
		[Standard alertViewWithTitle:@"No bank selected." message:@"You must first select a bank to view its transactions." cancalButtonTitle:@"OK"];
		
		return;
	}
	
	// show all transactions
	LayerPopoverTableTransactions *popover = [LayerPopoverTableTransactions popoverWithPosition:buttonTransactions.position title:@"All Transactions" items:st.currentBank.transactions block:^(id data)
											  {
												  /*
												   // get the bank name
												   NSString *bankName = (NSString *)data;
												   
												   // set bank
												   [st setCurrentBank:bankName];
												   
												   // refresh bank and players
												   [self refreshBank];
												   [self refreshPlayers];
												   */
												   // close
												   [((LayerPopoverTable *)[self getChildByTag:100]) close];
											  }];
	
	// full detail view
	[popover setFullDetailEnabled:YES];
	
	// add "switch detail view" button
	[popover addTitleBarButton:ButtonTypeDetails block:^(id date)
	 {
		 [popover switchDetailView];
	 }];
	
	// add the popover
	[self addChild:popover z:100 tag:100];
	
	[popover show];
}

-(void)onTimeline:(id)sender
{
	// if there's no bank selected
	if (!st.currentBank)
	{
		// show an alert
		[Standard alertViewWithTitle:@"No bank selected." message:@"You must first select a bank before using the timeline." cancalButtonTitle:@"OK"];
		
		return;
	}
	
	// play sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundTimeline.mp3"];
	
	// disable it for a bit
	[sender setIsEnabled:NO];
	
	// re-enable it
	[sender runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:!isTimelineOn ? 3 : 1]
										two:[CCCallBlock actionWithBlock:^(void)
											 {
												 [sender setIsEnabled:YES];
											 }]]];
	
	// if it's not on, turn it on
	if (!isTimelineOn)
	{
		// create timeline background
		CCSprite *spTimeline = [CCSprite spriteWithFile:@"BackgroundTimeline.png"];
		spTimeline.anchorPoint = ccp(0,0);
		[spBackground addChild:spTimeline];
		[spTimeline runAction:[CCFadeIn actionWithDuration:0.15]];
	}
	// if it's already on, turn it off
	else
	{
		// get timeline
		CCSprite *spTimeline = (CCSprite *)[spBackground.children objectAtIndex:0];
		
		id action = [CCSequence actionOne:[CCFadeOut actionWithDuration:0.15] two:[CCCallBlock actionWithBlock:^(void)
				   {
					   [spTimeline removeFromParentAndCleanup:YES];
				   }]];
		[spTimeline runAction:action];
	}
	
	// show/hide the timeline itself
	[self setTimelineHidden:isTimelineOn];
	
	// switch the boolean
	isTimelineOn = !isTimelineOn;
	
	// remove all other buttons
	for (CCMenuItem *item in buttonTimeline.parent.children)
	{
		// do this to all items except the timeline
		if (item != buttonTimeline && item != buttonBank && item != buttonBankName)
		{
			// hide them if timeline is on
			id action = [CCFadeTo actionWithDuration:0.1 opacity:isTimelineOn ? 0 : 255];
			if (!isTimelineOn)
				action = [CCSequence actionOne:[CCDelayTime actionWithDuration:0.2] two:action];
			[item runAction:action];
			
			// also, disable them if necessary
			[item setIsEnabled:!isTimelineOn];
		}
	}
	
	// move the timeline back OR forward
	id action = [CCMoveBy actionWithDuration:0.3 position:ccp(isTimelineOn ? 200 : -200, 0)];
	action = [CCEaseSineInOut actionWithAction:action];
	[buttonTimeline runAction:action];
}

-(void)onAddPlayer:(id)sender
{
	// if there's no bank selected
	if (!st.currentBank)
	{
		// show an alert
		[Standard alertViewWithTitle:@"No bank selected." message:@"You must first select a bank before adding players." cancalButtonTitle:@"OK"];
		
		return;
	}
	// there's a bank selected, add a player
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Player" message:@"Please enter a name for the new player." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
		alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		alert.tag = 'P';
		
		[alert show];
		[alert release];
		
		// play alert sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
	}
}

#pragma mark -
#pragma mark Touches

-(CCNode *)itemFromPosition:(CGPoint)position
{
	// was it dragged to the bank?
	if ([buttonBank touchInNode:position])
		return buttonBank;
	// was it dragged to the delete button?
	if ([buttonAddPlayer touchInNode:position])
		return buttonAddPlayer;
	// was it dragged to another player?
	else
	{
		// loop over players
		for (CCNode *player in layerPlayers.children)
		{
			CGPoint center = [player centerPointInWorldSpace];
			CGRect rect = CGRectMake(center.x-(player.contentSize.width/2.0), center.y-(player.contentSize.height/2.0), player.contentSize.width, player.contentSize.height);

			if (CGRectContainsPoint(rect, position))
				return player;
		}
	}
	
	return nil;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:NO];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	// see if bank or players got touched
	CCNode *itemTouched = [self itemFromPosition:location];
	
	// if not, ignore move/end touches
	if (itemTouched == nil)
		return NO;
	
	// bank dragged?
	if (itemTouched.tag == ItemTypeBank)
	{
		itemDragged = [CCSprite spriteWithTexture:[((CCSprite *)((CCMenuItemImage *)buttonBank).normalImage) texture]];
		itemDragged.position = [buttonBank centerPointInWorldSpace];
		itemDragged.tag = itemTouched.tag;
	}
	// player dragged?
	else if (itemTouched.tag == ItemTypePlayer)
	{
		CCSprite *sp = (CCSprite *)[((CCMenuItemImage *)itemTouched) normalImage];
		itemDragged = [CCSprite spriteWithTexture:[sp texture]];
		itemDragged.position = [sp centerPointInWorldSpace];
		itemDragged.tag = ItemTypePlayer;
		itemDragged.userData = itemTouched.userData;
	}
	
	// only proceed to move/end touches if an item is being dragged
	if (itemDragged)
	{
		// make barely visible
		[itemDragged setOpacityRecursive:150];
		
		// animate scaling
		id action = [CCSequence actions:
		[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.15 scale:1.8]],
		[CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.35 scale:1.15]], nil];
		[itemDragged runAction:action];
		
		// add it
		[self addChild:itemDragged];
		
		return YES;
	}
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	// ENABLE DRAGGING
	[self setDraggingControls:YES];

	// move the dragged item
	itemDragged.position = location;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	// see if it was dropped into another item
	CCMenuItem *itemDropped = (CCMenuItem *)[self itemFromPosition:location];
	
	// only take action if it was dropped onto another item
	if (itemDropped != nil)
	{
		// PLAYER dropped onto BANK
		if (itemDropped.tag == ItemTypeBank && itemDragged.tag != ItemTypeBank)
		{
			[self popoverPlayerToBank:itemDragged.userData atPosition:[itemDropped centerPointInWorldSpace]];
		}
		// X dropped onto PLAYER
		else if (itemDropped.tag == ItemTypePlayer)
		{
			// turn off player touches
			//layerPlayers.isTouchEnabled = NO;
			
			// BANK onto PLAYER
			if (itemDragged.tag == ItemTypeBank)
			{
				[self popoverBankToPlayer:itemDropped.userData atPosition:[[((CCMenuItemImage *)itemDropped) normalImage] centerPointInWorldSpace]];
			}
			// PLAYER onto PLAYER - A DIFFERENT PLAYER
			else if (itemDragged.tag == ItemTypePlayer && ![((NSString *)itemDragged.userData) isEqualToString:itemDropped.userData])
			{
				[self popoverPlayer:itemDragged.userData toPlayer:itemDropped.userData atPosition:[[((CCMenuItemImage *)itemDropped) normalImage] centerPointInWorldSpace]];
			}
		}
		// X dropped onto DELETE && NOT IN TIMELINE MODE
		else if (itemDropped.tag == ItemTypeDelete && !layerTimeline.isShown)
		{
			// DELETE BANK - make sure it exists
			if (itemDragged.tag == ItemTypeBank && st.currentBank != nil)
			{
				NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete [%@] and all of its players?", [st.currentBank name]];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Bank" message:message delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
				alert.tag = 'b';
				[alert show];
				[alert release];
				
				// play alert sound
				[[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
			}
			// DELETE PLAYER
			else if (itemDragged.tag == ItemTypePlayer)
			{
				NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the player [%@]?", [st.currentBank name]];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Player" message:message delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
				alert.tag = 'p';
				[alert show];
				[alert release];
				
				// play alert sound
				[[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
				
				// SET THE PLAYER NAME FOR LATER
				buttonAddPlayer.userData = itemDragged.userData;
			}
		}
		
		if ([itemDropped respondsToSelector:@selector(unselected)])
			[itemDropped unselected];
	}
	
	// remove dragged item
	[itemDragged removeFromParentAndCleanup:YES];
	itemDragged = nil;
	
	// DISABLE DRAGGING
	[self setDraggingControls:NO];
}

#pragma mark -
#pragma mark Misc.

-(void)setTimelineHidden:(BOOL)hidden
{
	// if not created yet, create it
	if (layerTimeline == nil && !hidden)
	{
		layerTimeline = [LayerTimeline timelineWithLength:436 delegate:layerPlayers];
		layerTimeline.position = ccp(612, 646);
		[layerTimeline setTransactions:st.currentBank.transactions];
		[self addChild:layerTimeline];
	}
	
	// if showing, refresh it
	if (!hidden)
		[self refreshTimeline];
	
	// animave showing/hiding
	[layerTimeline animateShow:!hidden];
}

@end
