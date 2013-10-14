//
//  ByteShopViewController.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ByteShopViewController.h"

@interface ByteShopViewController ()

- (UIBarButtonItem *)cancelButton;

- (void)loadPrograms;

@end


@implementation ByteShopViewController

@synthesize delegate;

- (id)init {
	return [super initWithStyle:UITableViewStylePlain];
}

- (void)dealloc {
	[_cancelButton release];
	[_programs release];
	
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	
	self.title = NSLocalizedString(@"Byte Shop", nil);
	self.navigationItem.leftBarButtonItem = [self cancelButton];
	self.tableView.rowHeight = 72.0f;
	self.tableView.separatorColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
	
	UIImage *image = [UIImage imageNamed:@"TableBackground.png"];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
	
	[self loadPrograms];
}

- (UIBarButtonItem *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																	  target:self
																	  action:@selector(cancel:)];
	}
	
	return _cancelButton;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_programs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Program";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
		
		UIImage *image = [UIImage imageNamed:@"SelectedRow.png"];
		view.backgroundColor = [UIColor colorWithPatternImage:image];
		
		cell.selectedBackgroundView = view;
		[view release];
		
		cell.textLabel.textColor = [UIColor colorWithRed:78/255.0f
												   green:75/255.0f
													blue:66/255.0f
												   alpha:1.0f];
	}
	
	NSDictionary *program = [_programs objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [program objectForKey:@"name"];
	cell.detailTextLabel.text = [program objectForKey:@"description"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *program = [_programs objectAtIndex:indexPath.row];
	NSString *identifier = [program objectForKey:@"identifier"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:identifier
													 ofType:@"txt"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	[self dismissModalViewControllerAnimated:YES];
	
	if ([delegate respondsToSelector:@selector(byteShopViewController:didLoadData:)]) {
		[delegate byteShopViewController:self didLoadData:data];
	}
}

- (void)loadPrograms {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Directory"
													 ofType:@"json"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	NSArray *programs = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	
	_programs = [programs retain];
}

- (void)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
