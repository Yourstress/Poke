//
//  LayerPlayers.h
//  Poke
//
//  Created by Macbook Pro on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"
#import "LayerTimeline.h"
#import "NodePlayer.h"

@interface LayerPlayers : CCMenu <LayerTimelineDelegate>
{
}

#pragma mark Initialization

+(id)playersLayerWithSize:(CGSize)size;

#pragma mark -
#pragma mark Player Management

-(void)addPlayer:(NSString *)playerName repositionPlayers:(BOOL)reposition;

#pragma mark -
#pragma mark Interface

-(void)repositionPlayers;

@end
