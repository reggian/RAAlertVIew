//
//  RAAlertView.m
//
//  Version 0.2, November 10th, 2013
//
//  Created by Andreas de Reggi on 05. 11. 2013.
//  Copyright (c) 2013 Nollie Apps.
//
//  Get the latest version from here:
//
//  https://github.com/Reggian/RAAlertView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "RAAlertView.h"

#define kBUTTON_INDEX_OFFSET	100

@interface EmptyView : NSObject
+ (EmptyView *)empty;
- (void)setAlpha:(CGFloat)alpha;
@end
@implementation EmptyView
+ (EmptyView *)empty{return [[EmptyView alloc] init];}
- (void)setAlpha:(CGFloat)alpha{}
@end

@implementation RAAlertView
{
	UIView *_fadeView;
	
	NSArray *_constraints;
	
	RAAlertViewActionBlock _action;
	
	NSMutableDictionary *_views;
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark - Initialisation & setup
//--------------------------------------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 190.0f)];
    if (self)
	{
        [self setup];
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView
{
    return [self initWithTitle:nil message:nil contentView:contentView cancelButtonTitle:nil otherButtonTitles:nil singleButtonSegments:NO action:NULL];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message contentView:(UIView *)contentView
{
	return [self initWithTitle:title message:message contentView:contentView cancelButtonTitle:nil otherButtonTitles:nil singleButtonSegments:NO action:NULL];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles action:(RAAlertViewActionBlock)action
{
	return [self initWithTitle:title message:message contentView:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles singleButtonSegments:NO action:action];
}

//--------------------------------------------------------------------------------------------------------------

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
				  contentView:(UIView *)contentView
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSArray *)otherButtonTitles
		 singleButtonSegments:(BOOL)singleButtonSegments
					   action:(RAAlertViewActionBlock)action
{
    self = [self init];
    if (self)
	{
		[self setTitle:title
			   message:message
		   contentView:contentView
	 cancelButtonTitle:cancelButtonTitle
	 otherButtonTitles:otherButtonTitles
  singleButtonSegments:singleButtonSegments
				action:action
			  animated:NO];
	}
    return self;
}

//--------------------------------------------------------------------------------------------------------------

- (void)setup
{
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	[self setTintColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
	
	self.layer.cornerRadius = 7.0;
	[self setNeedsDisplay];
	
	_cancelButtonIndex = -1;
	
	_constraints = [NSMutableArray arrayWithCapacity:4];
	
	_views = [NSMutableDictionary dictionaryWithCapacity:4];
	
	_fadeView = [[UIView alloc] initWithFrame:screenBounds];
	[_fadeView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	
	//// Gradient Effect
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
	
	// General Declarations
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	
	// Color Declarations
	UIColor *outColor = [UIColor colorWithWhite:0.95 alpha:0.75];;
	UIColor *inColor = [UIColor colorWithWhite:1.0 alpha:0.8];;
	
	// Gradient Declarations
	NSArray *gradientColors = @[(id)inColor.CGColor,(id)outColor.CGColor];
	CGFloat gradientLocations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
	
	// Rounded Rectangle Drawing
	UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7.0];
	
	CGContextSaveGState(context);
	[roundedRectanglePath addClip];
	CGContextDrawRadialGradient(context, gradient,
								centerPoint, 20,
								centerPoint, 80,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
	
	UIImage *roundedRectangleImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// Cleanup
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	UIGraphicsEndImageContext();
	////
	
	roundedRectangleImage = [roundedRectangleImage resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
																  resizingMode:UIImageResizingModeStretch];
	UIImageView *roundedRectangleImageView = [[UIImageView alloc] initWithImage:roundedRectangleImage];
	[roundedRectangleImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addSubview:roundedRectangleImageView];
	
	
	NSDictionary *viewsDictionary = @{@"view":roundedRectangleImageView};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:viewsDictionary]];
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark - Private
//--------------------------------------------------------------------------------------------------------------

- (void)buttonPressed:(id)sender
{
	if (_action)
	{
		NSInteger index = [sender tag] - kBUTTON_INDEX_OFFSET;
		_action(self,index);
	}
}

//--------------------------------------------------------------------------------------------------------------

- (void)performViewUpdates:(NSDictionary *)updates animated:(BOOL)animated
{
	NSArray *keys = [updates allKeys];
	if (keys.count)
	{
		CGRect frame = [self frameWithUpdatedConstraintsWithUpdates:updates];
		
		if (animated)
		{
			[self setNeedsUpdateConstraints];
			[UIView animateWithDuration:0.2
							 animations:^{
								 for (NSString *key in keys)
								 {
									 [_views[key] setAlpha:0.0];
									 [updates[key] setAlpha:1.0];
								 }
								 [self setFrame:frame];
								 [self layoutIfNeeded];
							 }
							 completion:^(BOOL finished) {
								 for (NSString *key in keys)
								 {
									 [_views[key] removeFromSuperview];
									 if ([updates[key] isKindOfClass:[EmptyView class]])
									 {
										 [_views removeObjectForKey:key];
									 }
									 else
									 {
										 _views[key] = updates[key];
									 }
								 }
							 }];
		}
		else
		{
			for (NSString *key in keys)
			{
				[updates[key] setAlpha:1.0];
				[_views[key] removeFromSuperview];
				if ([updates[key] isKindOfClass:[EmptyView class]])
				{
					[_views removeObjectForKey:key];
				}
				else
				{
					_views[key] = updates[key];
				}
			}
			[self setNeedsUpdateConstraints];
			[self setFrame:frame];
			[self layoutIfNeeded];
		}
	}
}

- (UIView *)getViewForKey:(NSString *)key withUpdates:(NSDictionary *)updates
{
	if ([updates[key] isKindOfClass:[EmptyView class]])
	{
		return nil;
	}
	return updates[key]?:_views[key];
}

- (CGRect)frameWithUpdatedConstraintsWithUpdates:(NSDictionary *)updates
{
	[self removeConstraints:_constraints];
	
	CGFloat totalHeight = 0.0;
	NSMutableString *format = [NSMutableString stringWithString:@"V:|"];
	NSMutableDictionary *views = [NSMutableDictionary dictionary];
	
	UIView *titleView = [self getViewForKey:@"title" withUpdates:updates];
	if (titleView)
	{
		[format appendString:@"-(19)-[title]"];
		[views setObject:titleView forKey:@"title"];
		
		totalHeight += 19 + titleView.bounds.size.height;
	}
	UIView *messageView = [self getViewForKey:@"message" withUpdates:updates];
	if (messageView)
	{
		NSInteger margin = (views.count?0:19);
		[format appendFormat:@"-(%d)-[message]",margin];
		[views setObject:messageView forKey:@"message"];
		
		totalHeight += margin + messageView.bounds.size.height;
	}
	UIView *contentView = [self getViewForKey:@"content" withUpdates:updates];
	if (contentView)
	{
		NSInteger margin = (views.count?10:19);
		[format appendFormat:@"-(%d)-[content]",margin];
		[views setObject:contentView forKey:@"content"];

		totalHeight += margin + contentView.bounds.size.height;
	}
	UIView *buttonView = [self getViewForKey:@"button" withUpdates:updates];
	if (buttonView)
	{
		NSInteger margin = (views.count?13:19);
		[format appendFormat:@"-(%d)-[button]",margin];
		[views setObject:buttonView forKey:@"button"];
		
		totalHeight += margin + buttonView.bounds.size.height;
	}
	
	_constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
	[self addConstraints:_constraints];
	
	CGRect frame = self.frame;
	frame.size.height = totalHeight;
	frame.origin.y = self.center.y - totalHeight/2.0f;
	
	return frame;
}

//--------------------------------------------------------------------------------------------------------------


- (NSDictionary *)setTitle:(NSString *)title animated:(BOOL)animated updateLayouts:(BOOL)updateLayouts
{
	if ([title isEqualToString:[_views[@"title"] text]])
	{
		return nil;
	}
	
	UILabel *titleLabel = nil;
	if (title.length)
	{
		CGRect frame = CGRectMake(0.0, 19.0, self.bounds.size.width, 20.0);
		
		titleLabel = [[UILabel alloc] initWithFrame:frame];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
		[titleLabel setText:title];
		
		[titleLabel setAlpha:0.0];
		[self addSubview:titleLabel];
		
		[titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSDictionary *views = @{@"view":titleLabel};
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[view]-(10)-|" options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(20)]" options:0 metrics:nil views:views]];
	}
	
	NSDictionary *updates = @{@"title": titleLabel?:[EmptyView empty]};
	if (updateLayouts)
	{
		[self performViewUpdates:updates animated:animated];
	}
	return updates;
}

- (NSDictionary *)setMessage:(NSString *)message animated:(BOOL)animated updateLayouts:(BOOL)updateLayouts
{
	if ([message isEqualToString:[_views[@"message"] text]])
	{
		return nil;
	}
	
	UITextView *messageTextView = nil;
	if (message.length)
	{
		CGRect frame = CGRectMake(0.0, (_views[@"title"]?CGRectGetMaxY([_views[@"title"] frame]):19.0), self.bounds.size.width - 20.0, 400.0);
		
		messageTextView = [[UITextView alloc] initWithFrame:frame];
		[messageTextView setUserInteractionEnabled:NO];
		[messageTextView setBackgroundColor:[UIColor clearColor]];
		[messageTextView setTextAlignment:NSTextAlignmentCenter];
		[messageTextView setFont:[UIFont systemFontOfSize:14]];
		[messageTextView setText:message];
		[messageTextView sizeToFit];
		[messageTextView setAlpha:0.0];
		[self addSubview:messageTextView];
		
		[messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSDictionary *views = @{@"view":messageTextView};
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[view]-(10)-|" options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(h)]" options:0 metrics:@{@"h":@(messageTextView.frame.size.height)} views:views]];
	}
	
	NSDictionary *updates = @{@"message": messageTextView?:[EmptyView empty]};
if (updateLayouts)
	{
		[self performViewUpdates:updates animated:animated];
	}
	return updates;
}

- (NSDictionary *)setContentView:(UIView *)contentView animated:(BOOL)animated updateLayouts:(BOOL)updateLayouts
{
	if ([contentView isEqual:_views[@"content"]])
	{
		return nil;
	}
	
	if (contentView != nil)
	{
		[contentView setAlpha:0.0];
		[self addSubview:contentView];
		
		[contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSDictionary *views = @{@"view":contentView};
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(w)]" options:0 metrics:@{@"w":@(contentView.frame.size.width)} views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(h)]" options:0 metrics:@{@"h":@(contentView.frame.size.height)} views:views]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
															toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
		[self setNeedsUpdateConstraints];
		[self layoutIfNeeded];
	}
	
	NSDictionary *updates = @{@"content": contentView?:[EmptyView empty]};
	if (updateLayouts)
	{
		[self performViewUpdates:updates animated:animated];
	}
	return updates;
}

- (NSDictionary *)setCancelButtonTitle:(NSString *)cancelButtonTitle
					 otherButtonTitles:(NSArray *)otherButtonTitles
				  singleButtonSegments:(BOOL)singleButtonSegments
								action:(RAAlertViewActionBlock)action
							  animated:(BOOL)animated
						 updateLayouts:(BOOL)updateLayouts
{
	UIView *buttonView = nil;
	
	if (cancelButtonTitle.length || otherButtonTitles.count)
	{
		CGFloat width = 270.0f;
		
		_action = [action copy];
		
		BOOL twoButtonSegment = (!singleButtonSegments && cancelButtonTitle.length && otherButtonTitles.count == 1);
		CGFloat height = (twoButtonSegment?1:(otherButtonTitles.count + MIN(cancelButtonTitle.length, 1)))*44.0f;
		CGFloat y = (_views[@"message"]?CGRectGetMaxY([_views[@"message"] frame])+13.0:(_views[@"title"]?CGRectGetMaxY([_views[@"title"] frame])+13.0:19.0));
		buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, width, height)];
		
		if (twoButtonSegment)
		{
			UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
			[cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
			[cancelButton setFrame:CGRectMake(0.0f, 0.0f, width/2.0f, 44.0f)];
			[cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
			[cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[cancelButton setTag:0 + kBUTTON_INDEX_OFFSET];
			[buttonView addSubview:cancelButton];
			_cancelButtonIndex = 0;
			
			UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
			[otherButton setTitle:otherButtonTitles[0] forState:UIControlStateNormal];
			[otherButton setFrame:CGRectMake(width/2.0f, 0.0f, width/2.0f, 44.0f)];
			[otherButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
			[otherButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[otherButton setTag:1 + kBUTTON_INDEX_OFFSET];
			[buttonView addSubview:otherButton];
			
			UIView *horisontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.5f)];
			[horisontalLineView setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			[buttonView addSubview:horisontalLineView];
			
			UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(width/2.0f, 0.0f, 0.5f, 44.0f)];
			[verticalLineView setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
			[buttonView addSubview:verticalLineView];
		}
		else
		{
			for (int i = 0; i < otherButtonTitles.count; i++)
			{
				[self addButtonWithTitle:otherButtonTitles[i] index:i toButtonView:buttonView];
			}
			if (cancelButtonTitle.length)
			{
				[self addButtonWithTitle:cancelButtonTitle index:otherButtonTitles.count toButtonView:buttonView];
				[self setCancelButtonIndex:otherButtonTitles.count inButtonView:buttonView];
			}
		}
		
		[self addSubview:buttonView];
		[buttonView setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSDictionary *views = @{@"view":buttonView};
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(h)]" options:0 metrics:@{@"h":@(height)} views:views]];
	}
	else
	{
		_cancelButtonIndex = -1;
		_action = nil;
	}
	
	NSDictionary *updates = @{@"button": buttonView?:[EmptyView empty]};
	if (updateLayouts)
	{
		[self performViewUpdates:updates animated:animated];
	}
	return updates;
}

- (void)addButtonWithTitle:(NSString *)title index:(NSInteger)index toButtonView:(UIView *)buttonView
{
	CGFloat height = index*44.0f;
	UIView *horisontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, height, 270.0, 0.5)];
	[horisontalLineView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0f]];
	[buttonView addSubview:horisontalLineView];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:title forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, height, 270.0, 44.0)];
	[button.titleLabel setFont:[UIFont systemFontOfSize:17]];
	[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[button setTag:index + kBUTTON_INDEX_OFFSET];
	[buttonView addSubview:button];
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex inButtonView:(UIView *)buttonView
{
	_cancelButtonIndex = cancelButtonIndex;
	UIButton *cancelButton = (UIButton *)[buttonView viewWithTag:_cancelButtonIndex + kBUTTON_INDEX_OFFSET];
	[cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark - Public
//--------------------------------------------------------------------------------------------------------------

- (RAAlertView *)show
{
	UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
	return [self showInRootView:rootView];
}

- (RAAlertView *)showInRootView:(UIView *)rootView
{
	_visible = YES;
	
	[self setCenter:rootView.center];
	
	[rootView addSubview:_fadeView];
	[rootView addSubview:self];
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	switch (interfaceOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
			break;
			
		case UIInterfaceOrientationLandscapeRight:
			self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
			break;
			
		default:
			break;
	}
	
	self.layer.opacity = 0.5f;
    self.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
	
    [UIView animateWithDuration:0.2f
					 animations:^{
						 _fadeView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
                         self.layer.opacity = 1.0f;
                         self.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }];
	
	return self;
}

//--------------------------------------------------------------------------------------------------------------

- (void)dismiss
{
	_visible = NO;
	
	self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    self.layer.opacity = 1.0f;
	
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 _fadeView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
                         self.layer.transform = CATransform3DMakeScale(0.6f, 0.6f, 1.0);
                         self.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         [self removeFromSuperview];
						 self.layer.transform = CATransform3DMakeScale(1, 1, 1);
						 self.layer.opacity = 1.0f;
						 
						 [_fadeView removeFromSuperview];
						 
						 [_views enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, BOOL *stop) {
							 [view removeFromSuperview];
						 }];
						 [_views removeAllObjects];
					 }];
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark -
//--------------------------------------------------------------------------------------------------------------

- (void)setTitle:(NSString *)title animated:(BOOL)animated
{
	[self setTitle:title animated:animated updateLayouts:YES];
}

- (void)setMessage:(NSString *)message animated:(BOOL)animated
{
	[self setMessage:message animated:animated updateLayouts:YES];
}

- (void)setContentView:(UIView *)contentView animated:(BOOL)animated
{
	[self setContentView:contentView animated:animated updateLayouts:YES];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
		   otherButtonTitles:(NSArray *)otherButtonTitles
		singleButtonSegments:(BOOL)singleButtonSegments
					  action:(RAAlertViewActionBlock)action
					animated:(BOOL)animated
{
	[self setCancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles singleButtonSegments:singleButtonSegments action:action animated:animated updateLayouts:YES];
}

//--------------------------------------------------------------------------------------------------------------

- (void)setTitle:(NSString *)title
		 message:(NSString *)message
	 contentView:(UIView *)contentView
cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
singleButtonSegments:(BOOL)singleButtonSegments
		  action:(RAAlertViewActionBlock)action
		animated:(BOOL)animated
{
	NSMutableDictionary *updates = [NSMutableDictionary dictionary];
	[updates setValuesForKeysWithDictionary:[self setTitle:title animated:animated updateLayouts:NO]];
	[updates setValuesForKeysWithDictionary:[self setMessage:message animated:animated updateLayouts:NO]];
	[updates setValuesForKeysWithDictionary:[self setContentView:contentView animated:animated updateLayouts:NO]];
	[updates setValuesForKeysWithDictionary:[self setCancelButtonTitle:cancelButtonTitle
													 otherButtonTitles:otherButtonTitles
												  singleButtonSegments:singleButtonSegments
																action:action animated:animated updateLayouts:NO]];
	[self performViewUpdates:updates animated:animated];
}

//--------------------------------------------------------------------------------------------------------------


@end
