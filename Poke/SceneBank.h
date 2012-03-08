//
//  SceneBank.h
//  Poke
//
//  Created by Macbook Pro on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"

@class LayerPlayers;

typedef enum
{
	ItemTypeBank		= 1,
	ItemTypePlayer		= 2,
	ItemTypeDelete		= 3,
}	ItemType;

@class LayerTimeline;
@interface SceneBank : CCLayer
{
	// players layer
	LayerPlayers *layerPlayers;
	
	// the background
	CCSprite *spBackground;
	
	// interface elements
	CCLabelStroked *labelBankName;
	CCLabelStroked *labelBankBalance;
	
	// buttons
    CCMenuItemSprite *buttonBank;
	CCMenuItemSprite *buttonAddPlayer;
	CCMenuItemSprite *buttonTransactions;
	CCMenuItemSprite *buttonTimeline;
	CCMenuItemLabel *buttonBankName;		// for renaming bank
	
	// timeline
	LayerTimeline *layerTimeline;
	
	// dragged item
	BOOL draggingControlsEnabled;
	CCMenuItem *itemDragged;
	
	// timeline mode
	BOOL isTimelineOn;
}

#pragma mark -
#pragma mark Initialization

-(void)initBackground;

-(void)initInterface;

#pragma mark -
#pragma mark Interface Controls

-(void)setBankName:(NSString *)bankName;

-(void)setBankBalance:(float)bankBalance;

-(void)setDraggingControls:(BOOL)enabled;

-(void)refreshBank;

-(void)refreshPlayers;

-(void)refreshTimeline;

-(void)popoverPlayerToBank:(NSString *)playerName atPosition:(CGPoint)position;

-(void)popoverBankToPlayer:(NSString *)playerName atPosition:(CGPoint)position;

-(void)popoverPlayer:(NSString *)player1Name toPlayer:(NSString *)player2Name atPosition:(CGPoint)position;

#pragma mark -
#pragma mark Event Handling

-(void)onBank:(id)sender;

-(void)onTransactions:(id)sender;

-(void)onTimeline:(id)sender;

-(void)onAddPlayer:(id)sender;

#pragma mark -
#pragma mark Misc.

-(void)setTimelineHidden:(BOOL)hidden;

@end
