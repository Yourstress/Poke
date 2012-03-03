//
//  LayerPopoverTableTransactions.m
//  Poke
//
//  Created by Sour on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPopoverTableTransactions.h"

@implementation LayerPopoverTableTransactions

-(id)init
{
	if ( (self = [super init]) )
	{
		// set the default detail view
		currentDetailView = DetailViewTimeDescription;
		
		// default the detailed parties to no
		fullDetail = NO;
	}
	
	return self;
}

-(void)setFullDetailEnabled:(BOOL)enabled
{
	fullDetail = enabled;
}

-(void)switchDetailView
{
	if (++currentDetailView >= NumDetailViews)
		currentDetailView = 0;
	
	// refresh the table
	[self refreshItems];
}

#pragma mark -
#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Transaction *transaction = [items objectAtIndex:[items count] - 1 - indexPath.row];
	
	// get a cell goin'
	CellTransaction *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTransaction"];
	if (!cell)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTransaction" owner:self options:nil];
		cell = (CellTransaction *)[nib objectAtIndex:0];
	}
	
	// apply the transaction to the cell
	[cell setTransaction:transaction withDetailView:currentDetailView fullDetail:fullDetail];
		
	return cell;
}

@end
