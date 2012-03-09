//
//  Standard.m
//  Poke
//
//  Created by Macbook Pro on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Standard.h"

Standard *st;

@implementation Standard

@synthesize currentBank;
@synthesize banks;
@synthesize size;

-(id)init
{
    if ( (self = [super init]) )
	{
		// save window size
		size = [[CCDirector sharedDirector] winSize];
		
		// load images
		[self loadImages];
		
		// load banks index
		self.banks = [NSMutableArray arrayWithContentsOfFile:[Standard pathForFile:@"Banks.idx"]];
		
		if (!banks)
			banks = [[NSMutableArray alloc] init];
		
		// load bank & players
		[self setCurrentBank:[[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentBank"]];

    }
    
    return self;
}

-(void)dealloc
{
	[super dealloc];
	
	[currentBank release];
	[banks release];
}

#pragma mark -
#pragma mark Standard methods

-(void)loadImages
{
	// define the images
	images[ImageTypeNil]	= nil;
	images[ImageTypeCash]	= [UIImage imageNamed:@"IconCashSm.png"];
	images[ImageTypeCoin]	= [UIImage imageNamed:@"IconCoinSm.png"];
	images[ImageTypeArrowR]	= [UIImage imageNamed:@"IconArrowRSm.png"];
	images[ImageTypeArrowL]	= [UIImage imageNamed:@"IconArrowLSm.png"];
	images[ImageTypePlayer]	= [UIImage imageNamed:@"IconPlayerSm.png"];
	
	// define the images for each transaction
	imageIndex[TransactionTypeCashIn][0]		= ImageTypeCash;
	imageIndex[TransactionTypeCashIn][1]		= ImageTypeArrowR;
	imageIndex[TransactionTypeCashIn][2]		= ImageTypeNil;
	
	imageIndex[TransactionTypeCashOut][0]		= ImageTypeCash;
	imageIndex[TransactionTypeCashOut][1]		= ImageTypeArrowL;
	imageIndex[TransactionTypeCashOut][2]		= ImageTypeNil;
	
	imageIndex[TransactionTypeCoinIn][0]		= ImageTypeCoin;
	imageIndex[TransactionTypeCoinIn][1]		= ImageTypeArrowR;
	imageIndex[TransactionTypeCoinIn][2]		= ImageTypeNil;
	
	imageIndex[TransactionTypeCoinOut][0]		= ImageTypeCoin;
	imageIndex[TransactionTypeCoinOut][1]		= ImageTypeArrowL;
	imageIndex[TransactionTypeCoinOut][2]		= ImageTypeNil;
	
	imageIndex[TransactionTypeCashInCoinOut][0]	= ImageTypeCash;
	imageIndex[TransactionTypeCashInCoinOut][1]	= ImageTypeArrowR;
	imageIndex[TransactionTypeCashInCoinOut][2]	= ImageTypeCoin;
	
	imageIndex[TransactionTypeCoinInCashOut][0]	= ImageTypeCoin;
	imageIndex[TransactionTypeCoinInCashOut][1]	= ImageTypeArrowR;
	imageIndex[TransactionTypeCoinInCashOut][2]	= ImageTypeCash;
	
	imageIndex[TransactionTypeTransferFrom][0]	= ImageTypeNil;
	imageIndex[TransactionTypeTransferFrom][1]	= ImageTypeArrowL;
	imageIndex[TransactionTypeTransferFrom][2]	= ImageTypePlayer;
	
	imageIndex[TransactionTypeTransferTo][0]	= ImageTypeNil;
	imageIndex[TransactionTypeTransferTo][1]	= ImageTypeArrowR;
	imageIndex[TransactionTypeTransferTo][2]	= ImageTypePlayer;
}

-(BOOL)addBank:(NSString *)bankName
{
	if ([self bankExists:bankName])
		return NO;
	
	// add bank name
	[banks addObject:bankName];
	
	// save bank index
	[self saveBanksIndex];
	
	return YES;
}

-(BOOL)deleteBank:(NSString *)bankName
{
	if (![self bankExists:bankName])
		return NO;
	
	// if it's the current bank, deselect it
	if ([st.currentBank.name isEqualToString:bankName])
		st.currentBank = nil;
	
	// remove bank from array
	[banks removeObject:bankName];
	
	// save bank index
	[self saveBanksIndex];
	
	// delete the file
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	[fileMgr removeItemAtPath:[Standard pathForFile:[NSString stringWithFormat:@"Bank%@.data", bankName]] error:nil];
	
	return YES;
}

-(BOOL)renameCurrentBankTo:(NSString *)bankNameNew
{
	// make sure the bank exists
	if (!st.currentBank)
		return NO;
	
	// rename the file
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	[fileMgr moveItemAtPath:[Standard pathForFile:[NSString stringWithFormat:@"Bank%@.data", st.currentBank.name]]
					 toPath:[Standard pathForFile:[NSString stringWithFormat:@"Bank%@.data", bankNameNew]] error:nil];
	
	// rename it in the index
	[banks replaceObjectAtIndex:[banks indexOfObject:st.currentBank.name] withObject:bankNameNew];
	
	// rename it in object
	st.currentBank.name = bankNameNew;
	
	// save bank index
	[self saveBanksIndex];
	
	return YES;
}

-(BOOL)bankExists:(NSString *)bankName
{
	// make sure it exists
	if (bankName == nil || ![banks containsObject:bankName])
		return NO;
	
	return YES;
}

-(BOOL)setCurrentBank:(NSString *)bankName
{
	if (bankName == nil)
		return NO;
	
	// make sure the bank exists
	if (![self bankExists:bankName])
	{
		NSLog(@"The bank '%@' does not exist.", bankName);
		return NO;
	}
	
	// before anything, save the previous bank IF ONE EXISTS
	if (currentBank)
		[self saveBank];
	
	// save it as current
	[[NSUserDefaults standardUserDefaults] setValue:bankName forKey:@"CurrentBank"];

	// load the bank
	[self loadBank:bankName];
	
	return YES;
}

-(BOOL)loadBank:(NSString *)bankName
{
	// get the path first
	NSString *path = [Standard pathForFile:[NSString stringWithFormat:@"Bank%@.data", bankName]];
	
	// file exists? LOAD
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		// read file
		NSData *data = [[NSMutableData alloc] initWithContentsOfFile:path];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		
		// decode object
		self.currentBank = [unarchiver decodeObjectForKey:@"PokeBank"];
		[unarchiver finishDecoding];
	}
	// file doesn't exist? CREATE NEW
	else
	{
		self.currentBank = [[Bank alloc] initWithName:bankName];
	}
	
	return YES;
}

-(BOOL)saveBank
{
	if (currentBank == nil)
		return NO;
	
	// get the path first
	NSString *path = [Standard pathForFile:[NSString stringWithFormat:@"Bank%@.data", currentBank.name]];
	
	// read file
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	// encode object
	[archiver encodeObject:currentBank forKey:@"PokeBank"];
	[archiver finishEncoding];
	
	[data writeToFile:path atomically:YES];
	
	return YES;
}

-(void)saveBanksIndex
{
	[banks writeToFile:[Standard pathForFile:@"Banks.idx"] atomically:YES];
}

-(UIImage *)imageAtIndex:(int)index forType:(TransactionType)type
{
	return images[imageIndex[type][index]];
}

#pragma mark -
#pragma mark Static methods

+(void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancalButtonTitle:(NSString *)cancelButton
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil];
	[alert show];
	
	// play alert sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundAlert.mp3"];
}

+(NSString *)pathForFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

@end
