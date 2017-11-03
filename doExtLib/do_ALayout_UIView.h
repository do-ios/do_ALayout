//
//  do_ALayout_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_ALayout_IView.h"
#import "do_ALayout_UIModel.h"
#import "doIUIModuleView.h"

@interface do_ALayout_UIView : UIView<do_ALayout_IView, doIUIModuleView>
//可根据具体实现替换UIView
{
	@private
        BOOL isEnabled;
		__weak do_ALayout_UIModel *model;
}
- (void)eventName:(NSString *)event :(NSString *)type;

@end
