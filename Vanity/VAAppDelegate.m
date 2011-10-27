//
//  VAAppDelegate.m
//  Vanity
//
//  Created by Jean-Nicolas Jolivet on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VAAppDelegate.h"

@interface VAAppDelegate(Private)
- (void)fetchData;
- (void)timerFireMethod:(NSTimer*)theTimer;
- (void)newSale:(int)newTotal oldTotal:(int)oldTotal;
@end


@implementation VAAppDelegate

@synthesize window = _window;
@synthesize theMenu;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [GrowlApplicationBridge setGrowlDelegate:@""];
    lastCount = -1;
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    theItem.title = @"Updating...";
    [theItem setMenu:theMenu];
    [self fetchData];
    // the timer
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 
                                                 target:self 
                                               selector:@selector(timerFireMethod:) 
                                               userInfo:nil 
                                                repeats:YES];
    
}

- (IBAction)configureClicked:(id)sender
{
    [self.window makeKeyAndOrderFront:sender];
}

- (IBAction)refreshNow:(id)sender
{
    [self fetchData];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    [self fetchData];
}

- (void)newSale:(int)newTotal oldTotal:(int)oldTotal
{
    // do osmething fun
    int dif = lastCount - oldTotal;
    [[NSSound soundNamed:@"cash_register_x.wav"] play];
    [GrowlApplicationBridge notifyWithTitle:@"New Chocolat Sale!" 
                                description:[NSString stringWithFormat:@"%d New Sales! %d happy people now own a license of Chocolat!", dif, lastCount] 
                           notificationName:@"VANewSaleNotification" 
                                   iconData:nil 
                                   priority:0 
                                   isSticky:NO 
                               clickContext:nil];
}


- (void)fetchData
{
    // theItem.title = @"Updating...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *newCount = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://chocolatapp.com/buy/priva291_hasbought.php"] 
                                                      encoding:NSUTF8StringEncoding 
                                                         error:nil];
        // update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            theItem.title = [newCount stringByAppendingString:@" sales"];
            if ([newCount intValue] > lastCount && lastCount != -1) {
                // a new sale!
                [self newSale:[newCount intValue] oldTotal:lastCount];
            }
            lastCount = [newCount intValue];
            
        });
        
    });
}

@end
