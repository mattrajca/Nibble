//
//  ByteShopViewController.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface ByteShopViewController : UITableViewController {
  @private
	UIBarButtonItem *_cancelButton;
	NSArray *_programs;
}

@property (nonatomic, weak) id delegate;

@end


@interface NSObject (ByteShopViewControllerDelegate)

- (void)byteShopViewController:(ByteShopViewController *)vc didLoadData:(NSData *)data;

@end
