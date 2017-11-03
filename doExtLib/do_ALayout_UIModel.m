//
//  do_ALayout_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ALayout_UIModel.h"
#import "doProperty.h"
#import "doTextHelper.h"
#import "do_ALayout_UIView.h"

@implementation do_ALayout_UIModel

#pragma mark - 注册属性（--属性定义--）
/*
[self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];    
    //属性声明
	[self RegistProperty:[[doProperty alloc]init:@"bgImage" :String :@"" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"bgImageFillType" :String :@"fillxy" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"enabled" :Bool :@"true" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"isStretch" :Bool :@"true" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"layoutAlign" :String :@"MiddelCenter" :YES]];

}
-(double)RealX
{
    return super.RealX + workAreaX;
}
-(double)RealY
{
    return super.RealY + workAreaY;
}
-(double)RealWidth
{
    return workAreaWidth;
}

-(double)RealHeight
{
    return workAreaHeight;
}

-(void)ComputeZoom
{
    BOOL _isStretch = [[doTextHelper Instance] StrToBool:[self GetPropertyValue:@"isStretch"] : true];
    NSString* _layoutAlign = [self GetPropertyValue:@"layoutAlign"];
    if (_layoutAlign == nil||_layoutAlign.length<=0)
        _layoutAlign = [self GetProperty:@"layoutAlign"].DefaultValue;
    if (!_isStretch)
    {
        double _zoom = fmin(self.XZoom, self.YZoom);
        
        workAreaWidth = self.Width * _zoom;
        if (_zoom < self.XZoom)
        {
            //九种备选值：TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight
            if ([_layoutAlign hasSuffix:@"Left"])
            {
                workAreaX = 0;
            }
            else if ([_layoutAlign hasSuffix:@"Right"])
            {
                workAreaX = super.RealWidth - self.Width * _zoom;
            }
            else
            {
                //默认Middle
                workAreaX = (super.RealWidth - self.Width * _zoom)/2;
            }
        }
        else
        {
            workAreaX = 0;
        }
        workAreaHeight = self.Height * _zoom;
        if (_zoom < self.YZoom)
        {
            //九种备选值：TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight
            if ([_layoutAlign hasPrefix:@"Top"])
            {
                workAreaY = 0;
            }
            else if ([_layoutAlign hasPrefix:@"Bottom"])
            {
                workAreaY = super.RealHeight - self.Height * _zoom;
            }
            else
            {
                //默认Center
                workAreaY = (super.RealHeight - self.Height * _zoom) / 2;
            }
        }
        else
        {
            workAreaY = 0;
        }
        self.InnerXZoom = _zoom;
        self.InnerYZoom = _zoom;
        
    }
    else
    {
        workAreaX = 0;
        workAreaY = 0;
        workAreaWidth = super.RealWidth;
        workAreaHeight = super.RealHeight;
    }
}
-(void) AddSubview:(doUIModule*) _insertViewModel
{
    UIView* _view = (UIView*)self.CurrentUIModuleView;
    UIView* _insertView = (UIView*) _insertViewModel.CurrentUIModuleView;
    [self.ChildUIModules addObject:_insertViewModel];
    [_view addSubview:_insertView];
}
- (void)eventOn:(NSString *)onEvent
{
    [((do_ALayout_UIView *)self.CurrentUIModuleView) eventName:onEvent :@"on"];
}

- (void)eventOff:(NSString *)offEvent
{
    [((do_ALayout_UIView *)self.CurrentUIModuleView) eventName:offEvent :@"off"];
}
@end