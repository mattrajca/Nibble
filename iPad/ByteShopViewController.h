//
//  ByteShopViewController.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ProgressView.h"

@interface ByteShopViewController : UITableViewController {
  @private
	UIBarButtonItem *_cancelButton;
	ProgressView *_progressView;
	
	NSOperationQueue *_workQueue;
	NSArray *_programs;
}

@property (nonatomic, assign) id delegate;

@end


@interface NSObject (ByteShopViewControllerDelegate)

- (void)byteShopViewController:(ByteShopViewController *)vc didLoadData:(NSData *)data;

@end
