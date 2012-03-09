//
//  CellTransaction.m
//  Poke
//
//  Created by Sour on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CellTransaction.h"
#import "Transaction.h"

@implementation CellTransaction

@synthesize image;
@synthesize amount;
@synthesize detail;

-(void)setTransaction:(Transaction*)t withDetailView:(DetailView)detailView fullDetail:(BOOL)fullDetail
{
	// the image
	[image setImage:[UIImage imageNamed:(t.playerOther == nil) ? @"IconBankSm.png" : @"IconPlayerSm.png"]];
	
	// the amount
	amount.text = [t stringFromTransactionAmount];
	amount.textColor = [t colorFromBalance];
	
	// the time
	switch (detailView)
	{
		case DetailViewTimeDescription:
			detail.text = [self timeDescription:t.timeStamp];
			break;
		case DetailViewTimeDifference:
			detail.text = [self timeDifference:t.timeStamp];
			break;
		case DetailViewRecipiant:
			if (fullDetail)
				detail.text = [t stringFromTransactionParties];
			else
				detail.text = [NSString stringWithFormat:@"[%@]", (t.playerOther != nil) ? t.playerOther.name : @"Bank"];
			break;
		case DetailViewNotes:
			detail.text = t.note;
	}
}

-(NSString *)timeDifference:(NSDate *)date
{	
    NSDate *dateNow = [NSDate date];
    double ti = [date timeIntervalSinceDate:dateNow];
    ti *= -1;
	
	if (ti < 1)
		return @"Just now";
	else if (ti < 60)
		return [NSString stringWithFormat:@"%d seconds ago", (int)ti];
    else if (ti < 3600)
        return [NSString stringWithFormat:@"%d minutes ago", (int)round(ti / 60)];
	else if (ti < 86400)
        return [NSString stringWithFormat:@"%d hours ago", (int)round(ti / 60 / 60)];
	else if (ti < 2629743)
        return [NSString stringWithFormat:@"%d days ago", (int)round(ti / 60 / 60 / 24)];
	
	return @"Unknown";
}

-(NSString *)timeDescription:(NSDate *)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehaviorDefault];
    [df setDateFormat:@"EEE dd-MM-yy HH:mm"];
	
	NSString *stringDate = [df stringFromDate:date];
	
    [df release];
	
	return stringDate;
}

-(void)dealloc
{
	[super dealloc];
//	[image release];
	[amount release];
	[detail release];
}

@end
