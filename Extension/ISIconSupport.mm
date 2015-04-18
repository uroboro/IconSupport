#import "ISIconSupport.h"

#include <substrate.h>

NSDictionary * repairIconState(NSDictionary *iconState);

static ISIconSupport *sharedSupport = nil;

@implementation ISIconSupport

+ (id)sharedInstance {
    return sharedSupport;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        extensions = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    [extensions release];
    [super dealloc];
}

- (NSString *)extensionString {
    if ([extensions count] == 0) {
        return @"";
    }

    // Every combination of extensions must produce a unique extension string
    int result = 0;
    for (NSString *extension in extensions) {
        result |= [extension hash];
    }

    return [@"-" stringByAppendingFormat:@"%x", result];
}

- (BOOL)addExtension:(NSString *)extension {
    if (extension == nil || [extensions containsObject:extension]) {
        return NO;
    }

    [extensions addObject:extension];
    return YES;
}

- (BOOL)addIcons:(NSArray *)icons forExtension:(NSString *)extension {
	BOOL r = [self addExtension:extension];
	NSMutableDictionary *dictionary = [self insertionIcons];
	if (!dictionary) {
		dictionary = [NSMutableDictionary new];
		[self setInsertionIcons:dictionary];
	}
	[dictionary setObject:[icons copy] forKey:extension];
	return r;
}

- (BOOL)isBeingUsedByExtensions {
    return ![[self extensionString] isEqualToString:@""];
}

- (void)repairAndReloadIconState {
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_4_0) {
        // iOS 3.x
        return;
    }

    SBIconModel *iconModel = (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_6_0) ?
        [objc_getClass("SBIconModel") sharedInstance] : [[objc_getClass("SBIconController") sharedInstance] model];
    [self repairAndReloadIconState:[iconModel iconState]];
}

- (void)repairAndReloadIconState:(NSDictionary *)iconState {
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_4_0) {
        // iOS 3.x
        return;
    }

    if (iconState == nil) {
        return;
    }

    iconState = repairIconState(iconState);
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_6_0) {
        // iOS 4.x or iOS 5.x
        SBIconModel *iconModel = [objc_getClass("SBIconModel") sharedInstance];
        [iconState writeToFile:[iconModel iconStatePath] atomically:YES];
        [iconModel noteIconStateChangedExternally];
    } else {
        // iOS 6.x+
        [iconState writeToFile:[[[objc_getClass("SBDefaultIconModelStore") sharedInstance] currentIconStateURL] path] atomically:YES];
        [[objc_getClass("SBIconController") sharedInstance] noteIconStateChangedExternally];
    }
}

@end

__attribute__((constructor)) static void initISIconSupport() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // NOTE: This library should only be loaded for SpringBoard
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        sharedSupport = [[ISIconSupport alloc] init];
    }

    [pool release];
}

/* vim: set filetype=objcpp sw=4 ts=4 expandtab tw=80 ff=unix: */
