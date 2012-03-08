//
//  Standard.h
//  Poke
//
//  Created by Macbook Pro on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeEx.h"
#import "CCLabelStroked.h"
#import "CCTargetedTouchMenu.h"
#import "CCUIViewWrapper.h"
#import "SimpleAudioEngine.h"

#import "Bank.h"

#define iPad	([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define FontFamilyRegular	@"TeluguSangamMN"
#define FontFamilyBold		@"TeluguSangamMN-Bold"

#define PokeWidth			1024.0
#define PokeHeight			768.0

#define ccpScaled(x,y)		(iPad ? ccp(x,y) : ccp(x/2.0,y/2.0))

#define FontSize(size)		(iPad ? size : size/2.0)

#define Scaled(x)			(iPad ? x : x/2.0)

typedef enum
{
	ImageTypeNil	= 0,
	ImageTypeCash	= 1,
	ImageTypeCoin	= 2,
	ImageTypeArrowR	= 3,
	ImageTypeArrowL	= 4,
	ImageTypePlayer	= 5,
}	ImageType;

@interface Standard : NSObject
{
	// variables used for returning icons on demand
	UIImage *images[6];
	int imageIndex[8][3];
}

@property (nonatomic, retain, setter=setCurBank:) Bank *currentBank;
@property (nonatomic, retain) NSMutableArray *banks;
@property (nonatomic, assign) CGSize size;

#pragma mark Standard methods

// load images/icons
-(void)loadImages;

// adding a bank
-(BOOL)addBank:(NSString *)bankName;

// deleting a bank
-(BOOL)deleteBank:(NSString *)bankName;

// renaming current bank
-(BOOL)renameCurrentBankTo:(NSString *)bankNameNew;

// returns YES if bank exists
-(BOOL)bankExists:(NSString *)bankName;

// get bank by name
-(BOOL)setCurrentBank:(NSString *)bankName;

// loads or initializes the bank with no players
-(BOOL)loadBank:(NSString *)bankName;

// saves the bank & players
-(BOOL)saveBank;

// saves the bank index
-(void)saveBanksIndex;

// returns one of three images for a transaction type
-(UIImage *)imageAtIndex:(int)index forType:(TransactionType)type;

#pragma mark -
#pragma mark Static methods

// shows a standard alert view
+(void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancalButtonTitle:(NSString *)cancelButton;

// returns a full path to the given file in the documents directory
+(NSString *)pathForFile:(NSString *)fileName;

@end

extern Standard *st;