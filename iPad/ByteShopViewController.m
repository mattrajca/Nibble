//
//  ByteShopViewController.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ByteShopViewController.h"

#import "JSONKit.h"

@interface ByteShopViewController ()

- (ProgressView *)progressView;
- (UIBarButtonItem *)cancelButton;

- (NSOperationQueue *)workQueue;

- (NSString *)cachePathForProgram:(NSString *)identifier;
- (void)handleError;

- (void)loadPrograms;
- (void)loadedProgramData:(NSData *)data;
- (void)loadProgram:(NSString *)identifier;

@end


@implementation ByteShopViewController

#define PROGRAMS_URL @"http://the-byte-shop.appspot.com/apps"
#define SOURCE_URL @"http://the-byte-shop.appspot.com/listSource?identifier=%@"

@synthesize delegate;

- (id)init {
	return [super initWithStyle:UITableViewStylePlain];
}

- (void)dealloc {
	[_cancelButton release];
	[_progressView release];
	[_workQueue release];
	[_programs release];
	
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	
	self.title = NSLocalizedString(@"Byte Shop", nil);
	self.navigationItem.leftBarButtonItem = [self cancelButton];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background.png"]];
	self.tableView.rowHeight = 72.0f;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
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

- (ProgressView *)progressView {
	if (!_progressView) {
		_progressView = [[ProgressView alloc] init];
	}
	
	return _progressView;
}

- (NSOperationQueue *)workQueue {
	if (!_workQueue) {
		_workQueue = [[NSOperationQueue alloc] init];
		[_workQueue setMaxConcurrentOperationCount:1];
		
		[_workQueue addObserver:self forKeyPath:@"operationCount"
						options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
						context:NULL];
	}
	
	return _workQueue;
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
		view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"selected_row.png"]];
		
		cell.selectedBackgroundView = view;
		[view release];
		
		cell.textLabel.textColor = [UIColor colorWithRed:78/255.0f green:75/255.0f blue:66/255.0f alpha:1.0f];
	}
	
	NSDictionary *program = [_programs objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [program objectForKey:@"name"];
	cell.detailTextLabel.text = [program objectForKey:@"description"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *program = [_programs objectAtIndex:indexPath.row];
	[self loadProgram:[program objectForKey:@"identifier"]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		
		BOOL visible = [_workQueue operationCount] > 0;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
		
	}];
}

- (NSString *)cachePathForProgram:(NSString *)identifier {
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	
	if (!path)
		return nil;
	
	return [path stringByAppendingFormat:@"/%@.dat", identifier];
}

- (void)handleError {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		
		if (_progressView) {
			[_progressView dismiss];
		}
		
	}];
}

- (void)loadPrograms {
	if (_programs) {
		[_programs release];
		_programs = nil;
		
		[self.tableView reloadData];
	}
	
	[[self progressView] showInView:self.view];
	
	[[self workQueue] addOperationWithBlock:^{
		
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:PROGRAMS_URL]];
		
		if (!data) {
			NSLog(@"Cannot load program directory");
			[self handleError];
			
			return;
		}
		
		NSArray *programs = [data objectFromJSONData];
		
		if (!programs || ![programs isKindOfClass:[NSArray class]]) {
			NSLog(@"Invalid program directory data");
			[self handleError];
			
			return;
		}
		
		[NSThread sleepForTimeInterval:0.4f];
		
		_programs = [programs retain];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			
			if (_progressView) {
				[_progressView dismiss];
			}
			
			[self.tableView reloadData];
			
		}];
		
	}];
}

- (void)loadedProgramData:(NSData *)data {
	if ([self.delegate respondsToSelector:@selector(byteShopViewController:didLoadData:)]) {
		[self.delegate byteShopViewController:self
								  didLoadData:[[data retain] autorelease]];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)loadProgram:(NSString *)identifier {
	NSData *data = [NSData dataWithContentsOfFile:[self cachePathForProgram:identifier]];
	
	if (data) {
		[self loadedProgramData:data];
		return;
	}
	
	[[self progressView] showInView:self.view];
	
	[[self workQueue] addOperationWithBlock:^{
		
		NSString *strURL = [NSString stringWithFormat:SOURCE_URL, identifier];
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
		
		if (!data) {
			NSLog(@"Cannot load program's source");
			[self handleError];
			
			return;
		}
		
		[data writeToFile:[self cachePathForProgram:identifier] atomically:YES];
		
		[NSThread sleepForTimeInterval:0.4f];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			
			if (_progressView) {
				[_progressView dismiss];
			}
			
			[self performSelector:@selector(loadedProgramData:)
					   withObject:data
					   afterDelay:0.2f];
			
		}];
		
	}];
}

- (void)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
