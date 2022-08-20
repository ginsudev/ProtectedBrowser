#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WKUserContentController (Private)
- (void)removeAllContentRuleLists;
- (void)removeAllScriptMessageHandlers;
- (void)_removeAllUserContentFilters;
- (void)_removeAllUserStyleSheetsAssociatedWithContentWorld:(id)arg1 ;
@end
