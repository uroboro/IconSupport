#import <Foundation/Foundation.h>

@interface ISIconSupport : NSObject {
    NSMutableSet *extensions;
}
@property (nonatomic, retain) NSMutableDictionary *insertionIcons;

+ (id)sharedInstance;
- (NSString *)extensionString;
- (BOOL)addExtension:(NSString *)extension;
- (BOOL)addIcons:(NSArray *)icons forExtension:(NSString *)extension;
- (BOOL)isBeingUsedByExtensions;
- (void)repairAndReloadIconState;
- (void)repairAndReloadIconState:(NSDictionary *)iconState;
@end

/* vim: set filetype=objcpp sw=4 ts=4 expandtab tw=80 ff=unix: */
