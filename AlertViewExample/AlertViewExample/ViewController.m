//
//  ViewController.m
//  AlertViewExample
//
//  Created by Andreas de Reggi on 10. 11. 2013.
//  Copyright (c) 2013 Nollie Apps. All rights reserved.
//

#import "ViewController.h"
#import "RAAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)show:(id)sender
{
	RAAlertView *alertView = [[RAAlertView alloc] initWithTitle:@"Alert View"
														message:@"iOS 7 like alert view."
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@[@"More"]
														 action:^(id sender, NSInteger buttonIndex) {
															 if (buttonIndex == [sender cancelButtonIndex])
															 {
																 [sender dismiss];
															 }
															 else
															 {
																 UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 50.0)];
																 [contentView setBackgroundColor:[UIColor grayColor]];
																 
																 [sender setTitle:@"Updated Alert View"
																		  message:@"Loaded with a custom content view"
																	  contentView:contentView
																cancelButtonTitle:@"Dismiss"
																otherButtonTitles:nil
															 singleButtonSegments:NO
																		   action:^(id sender, NSInteger buttonIndex) {
																			   [sender dismiss];
																		   }
																		 animated:YES];
															 }
															 
														 }];
	[alertView showInRootView:self.view];
}

@end
