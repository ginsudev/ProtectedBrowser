#import <MobileCoreServices/LSApplicationProxy.h>
#import <UIKit/UIKit.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface LSApplicationProxy (AltList)
+ (id)applicationProxyForIdentifier:(NSString *)arg1 ;
- (BOOL)atl_isUserApplication;
@end
