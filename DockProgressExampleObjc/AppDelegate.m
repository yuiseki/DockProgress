//
//  AppDelegate.m
//  DockProgressExampleObjc
//
//  Created by Yui Matsumura on 2018/10/19.
//

#import "AppDelegate.h"
#import <DockProgress/DockProgress-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)borrowIconFrom:(NSString *)app {
	NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:app];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
	icon.size = [NSApp applicationIconImage].size;
	[[NSApplication sharedApplication] setApplicationIconImage:icon];
}

@class DockProgress;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
	[self borrowIconFrom:@"Photos"];
	
	__block NSString *style = @"bar";
	__block double value = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.02
									repeats:YES
									  block:^(NSTimer * _Nonnull timer)
	 {
		 
		 value = value+0.01;
		 [DockProgress setProgressValue:[NSNumber numberWithDouble:value]];
		 if (value>1) {
			 if ([style isEqualToString:@"bar"]) {
				 style = @"circle";
			 }else{
				 style = @"bar";
			 }
			 [DockProgress setProgressStyle:style
									 radius:[NSNumber numberWithInteger:58]
									  color:[NSColor systemPinkColor]];
		 	 value = 0;
		 }
		 
		 
	 }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
