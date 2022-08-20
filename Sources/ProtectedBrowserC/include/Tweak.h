#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>

@interface WKWebView (Private)
@property (nonatomic,readonly) NSURL * _mainFrameURL;
@end

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface WKUserContentController (Private)
- (void)removeAllContentRuleLists;
- (void)removeAllScriptMessageHandlers;
- (void)_removeAllUserContentFilters;
- (void)_removeAllUserStyleSheetsAssociatedWithContentWorld:(id)arg1 ;
@end
