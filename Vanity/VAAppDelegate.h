//
//  VAAppDelegate.h
//  Vanity
//
//  Created by Jean-Nicolas Jolivet on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
@interface VAAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
    NSMenu *theMenu;
    NSStatusItem *theItem;
    NSTimer *mainTimer;
    int lastCount;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *theMenu;

- (IBAction)configureClicked:(id)sender;
- (IBAction)refreshNow:(id)sender;
@end
