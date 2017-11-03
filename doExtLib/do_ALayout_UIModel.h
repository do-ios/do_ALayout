//
//  do_ALayout_Model.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//
#import "doUIModuleCollection.h"

@interface do_ALayout_UIModel : doUIModuleCollection
{
@private
    double workAreaX;
    double workAreaY;
    double workAreaWidth;
    double workAreaHeight;
}
-(void) ComputeZoom;
@end
