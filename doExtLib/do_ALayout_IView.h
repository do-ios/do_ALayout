//
//  do_ALayout_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_ALayout_IView <NSObject>

@required
//属性方法
- (void)change_bgImage:(NSString *)newValue;
- (void)change_bgImageFillType:(NSString *)newValue;
- (void)change_enabled:(NSString *)newValue;
- (void)change_isStretch:(NSString *)newValue;
- (void)change_layoutAlign:(NSString *)newValue;

//同步或异步方法
- (void)add:(NSArray *)parms;
- (void)getChildren:(NSArray *)parms;


@end