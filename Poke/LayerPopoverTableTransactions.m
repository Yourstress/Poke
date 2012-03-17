//
//  LayerPopoverTableTransactions.m
//  Poke
//
//  Created by Sour on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPopoverTableTransactions.h"
#import "SceneBank.h"		// to refresh stuff

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
	// play sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundButton.mp3"];
	
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
	CellTransaction *cell = [tableView dequeueReusableCellWithIdentifier:iPad ? @"CellTransaction" : @"CellTransactionRetina"];
	if (!cell)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTransaction" owner:self options:nil];
		cell = (CellTransaction *)[nib objectAtIndex:iPad ? 0 : 1];
	}
	
	// apply the transaction to the cell
	[cell setTransaction:transaction withDetailView:currentDetailView fullDetail:fullDetail];
		
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	Transaction *t = transactionSelected = [items objectAtIndex:[items count] - 1 - indexPath.row];
	
	// make a sound!
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundButton.mp3"];
	
	NSString *note = (t.note == nil || t.note.length == 0) ? @"[No note entered]" : [NSString stringWithFormat:@"%@", t.note];
	NSString *message = [NSString stringWithFormat:@"%@ (Other party: %@)\n%@\n%@\n\n%@", t.player.name, t.stringFromOtherParty, [t stringFromTransactionAmount], [t longTimeStamp], note];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Details" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Edit Note", @"Delete Transaction", nil];
	alert.tag = 'T';
	[alert show];
	[alert release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (alertView.tag == 'T')		// Transaction Details
	{
		if (buttonIndex == 1)			// Edit Note
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Transaction Note" message:@"Please enter the note you would like to pin to this transaction." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
			alert.alertViewStyle = UIAlertViewStylePlainTextInput;
			alert.tag = 'E';

			[alert show];
			[alert release];
		}
		else if (buttonIndex == 2)		// Delete Transaction
		{
			// delete the transaction
			[st.currentBank deleteTransaction:transactionSelected];
			
			// refresh
			[self refreshItems];
			
			// refresh main scene too
			SceneBank *sceneBank = (SceneBank *)self.parent;
			[sceneBank refreshBank];
			[sceneBank refreshPlayers];
		}
	}
	else if (alertView.tag == 'E')	// Edit Transaction Note
	{
		if (buttonIndex == 0)			// OK
		{
			// change the note
			transactionSelected.note = [alertView textFieldAtIndex:0].text;
			
			// refresh
			[self refreshItems];
		}
	}
}

@end
