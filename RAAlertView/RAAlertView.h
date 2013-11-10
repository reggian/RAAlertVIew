//
//  RAAlertView.h
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

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

typedef void (^RAAlertViewActionBlock)(id sender, NSInteger buttonIndex);

@interface RAAlertView : FXBlurView

@property (nonatomic, readonly) NSInteger cancelButtonIndex;
@property (nonatomic, readonly, getter = isVisible) BOOL visible;

- (instancetype)initWithContentView:(UIView *)contentView;

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
				  contentView:(UIView *)contentView;

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSArray *)otherButtonTitles
					   action:(RAAlertViewActionBlock)action;

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
				  contentView:(UIView *)contentView
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSArray *)otherButtonTitles
		 singleButtonSegments:(BOOL)singleButtonSegments
					   action:(RAAlertViewActionBlock)action;

- (RAAlertView *)showInRootView:(UIView *)rootView;
- (RAAlertView *)show;
- (void)dismiss;

- (void)setTitle:(NSString *)title animated:(BOOL)animated;
- (void)setMessage:(NSString *)message animated:(BOOL)animated;
- (void)setContentView:(UIView *)contentView animated:(BOOL)animated;
- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
		   otherButtonTitles:(NSArray *)otherButtonTitles
		singleButtonSegments:(BOOL)singleButtonSegments
					  action:(RAAlertViewActionBlock)action
					animated:(BOOL)animated;

- (void)setTitle:(NSString *)title
		 message:(NSString *)message
	 contentView:(UIView *)contentView
cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
singleButtonSegments:(BOOL)singleButtonSegments
		  action:(RAAlertViewActionBlock)action
		animated:(BOOL)animated;

@end
