//
//  LayerPopoverTableTransactions.h
//  Poke
//
//  Created by Sour on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerPopoverTable.h"
#import "CellTransaction.h"

@interface LayerPopoverTableTransactions : LayerPopoverTable
{
	DetailView currentDetailView;
	
	BOOL fullDetail;
}

-(void)setFullDetailEnabled:(BOOL)enabled;

-(void)switchDetailView;

@end
