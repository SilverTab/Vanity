//
//  VAAppDelegate.m
//  Vanity
//
//  Created by Jean-Nicolas Jolivet on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define PRESALES 1055

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

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self fetchData];
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
    int dif = newTotal - oldTotal;
    NSSound *yaySound;
    
    yaySound = [NSSound soundNamed:@"cash_register2.wav"];
    
    [yaySound play];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"VAGrowl"] boolValue]) {
        [GrowlApplicationBridge notifyWithTitle:@"New Chocolat Sale!"
                                    description:[NSString stringWithFormat:@"%d New Sales! %d happy people now own a license of Chocolat!", dif, newTotal] 
                               notificationName:@"VANewSaleNotification" 
                                       iconData:nil 
                                       priority:0 
                                       isSticky:NO 
                                   clickContext:nil];
    } else {
        NSUserNotification *notif = [[NSUserNotification alloc] init];
        notif.title = @"New Chocolat Sale!";
        notif.informativeText = [NSString stringWithFormat:@"%d New Sales! %d happy people now own a license of Chocolat!", dif, newTotal];
        notif.hasActionButton = NO;
        notif.deliveryDate = [NSDate date];
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notif];
    }
    
    
}


- (void)fetchData
{
    // theItem.title = @"Updating...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *newCount = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://chocolatapp.com/buy/priva291_hasbought.php"] 
                                                      encoding:NSUTF8StringEncoding 
                                                         error:&error];
        int iNewCount = [newCount intValue];
        iNewCount -= PRESALES;
        if (!error) {
            // update the UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableString *theNewName = [NSMutableString stringWithString:[newCount stringByAppendingString:@" sales"]];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"VAPimpOption"]) {
                    [theNewName appendFormat:@" ($%d)", (PRESALES * 34 + (([newCount intValue] - PRESALES) * 49))];
                }
                theItem.title = theNewName;
                if ([newCount intValue] > lastCount && lastCount != -1) {
                    // a new sale!
                    [self newSale:[newCount intValue] oldTotal:lastCount];
                }
                lastCount = [newCount intValue];
                
            });
        }
        
        
    });
}

@end
