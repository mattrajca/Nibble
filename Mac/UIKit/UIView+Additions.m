//
//  UIView+Additions.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "UIView+Additions.h"

#import <objc/runtime.h>

@implementation UIView (Additions)

static char *kUserInfoKey = "mr.userInfo";

@dynamic userInfo;

- (id)userInfo {
	return objc_getAssociatedObject(self, kUserInfoKey);
}

- (void)setUserInfo:(id)userInfo {
	objc_setAssociatedObject(self, kUserInfoKey, userInfo, OBJC_ASSOCIATION_RETAIN);
}

@end
