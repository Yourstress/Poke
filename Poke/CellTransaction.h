//
//  CellTransaction.h
//  Poke
//
//  Created by Sour on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Standard.h"

#define NumDetailViews 3

typedef enum
{
	DetailViewTimeDifference	= 0,
	DetailViewTimeDescription	= 1,
	DetailViewRecipiant			= 2,
}	DetailView;

@class Transaction;
@interface CellTransaction : UITableViewCell
{
	Transaction *transaction;
}

@property (nonatomic, assign) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *amount;
@property (nonatomic, retain) IBOutlet UILabel *detail;

-(void)setTransaction:(Transaction*)t withDetailView:(DetailView)detailView fullDetail:(BOOL)fullDetail;

-(NSString *)timeDifference:(NSDate *)date;
-(NSString *)timeDescription:(NSDate *)date;

@end
