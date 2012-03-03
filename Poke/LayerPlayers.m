//
//  LayerPlayers.m
//  Poke
//
//  Created by Macbook Pro on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPlayers.h"
#import "LayerPopoverTableTransactions.h"

@implementation LayerPlayers

#pragma mark Initialization

+(id)playersLayerWithSize:(CGSize)size
{
	LayerPlayers *node = [LayerPlayers menuWithItems:nil];

	// set size
	[node setContentSize:size];
	
	// not relative anchor point
	[node setIsRelativeAnchorPoint:YES];
	
	return node;
}

#pragma mark -
#pragma mark Player Management

-(void)addPlayer:(NSString *)playerName repositionPlayers:(BOOL)reposition
{
	NodePlayer *player = [NodePlayer playerWithName:playerName block:^(id sender)
                               {
								   // ONLY DO THIS IF A POPOVER ISN'T ALREADY OPEN
								   if ([self.parent getChildByTag:4224] != nil)
									   return;
								   
								   CCNode *node = sender;
								   Player *pl = [st.currentBank playerFromName:playerName];
								   
                                   CGPoint pos = [node convertToWorldSpace:ccp(node.contentSize.width/2.0,104)];
                                   LayerPopoverTableTransactions *popover = [LayerPopoverTableTransactions popoverWithPosition:pos title:playerName items:pl.transactions block:^(id data)
																 {
																 }];
                                   
								   [popover addTitleBarButton:ButtonTypeDetails block:^(id date)
									{
										[popover switchDetailView];
									}];
                                   [self.parent addChild:popover];
                                   [popover show];
                               }];
	
	// set the player's initial balance
	[player setBalance:[st.currentBank playerFromName:playerName].balance];
	
	// add the node
	[self addChild:player z:0 tag:2/*ItemTypePlayer*/];
	
	// reposition the players
	if (reposition)
		[self repositionPlayers];
}

#pragma mark -
#pragma mark Interface

-(void)repositionPlayers
{
	// get number of columns needed
	int numCols = 6;
	
	// if we have more players than what we can fix in the grid...
	while ([self.children count] > numCols*3)
	{
		// add a column
		numCols++;
	}
	
	float marginY = 26;
	//	float totalXSpacing = self.contentSize.width - marginX*2.0;
	float XSpacing = self.contentSize.width / numCols;
	
	// position every player
	for (int x = 0; x < [self.children count]; x++)
	{
		CCNode *player = [self.children objectAtIndex:x];
		
		int col			= x%numCols;
		int row			= x/numCols;
		
		float posX = XSpacing/2.0;
		float posY = self.contentSize.height-player.contentSize.height/2.0 - marginY;
		
		posX += col * XSpacing;
		posY -= (row * player.contentSize.height*1.30);
		
		player.position = ccp(posX,posY);
	}
}

#pragma mark -
#pragma mark LayerTimelineDelegate

-(void)timelineChangedToStartDate:(NSTimeInterval)dateStart andEndDate:(NSTimeInterval)dateEnd
{
	// go through all players
	for (NodePlayer *playerNode in self.children)
	{
		// get the player's balance within this timeline
		float timelineBalance = [[st.currentBank playerFromName:playerNode.userData] balanceFromDate:dateStart toDate:dateEnd];
		
		// set it
		[playerNode setBalance:timelineBalance];
	}
}

@end
