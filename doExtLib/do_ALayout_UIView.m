//
//  do_ALayout_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ALayout_UIView.h"

#import "doUIModuleHelper.h"
#import "doUIModule.h"
#import "do_ALayout_UIModel.h"
#import "doInvokeResult.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doEventCenter.h"
#import "doServiceContainer.h"
#import "doIUIModuleFactory.h"
#import "doScriptEngineHelper.h"
#import "doTextHelper.h"
#import "doISourceFS.h"
#import "doIDataFS.h"
#import "doTextHelper.h"
#import "doUIContainer.h"
#import "doIOHelper.h"
#import "doJsonHelper.h"
#import "doIBorder.h"

@interface do_ALayout_UIView()<doIBorder>

@end

@implementation do_ALayout_UIView
{
    NSString *_lastFill;
    BOOL _isLongTouch;
    BOOL _isSingleTouch;
    
    BOOL _isTouchOn;
}
#pragma mark - doIUIModuleView协议方法（必须）
-(void) dealloc
{
    NSLog(@"doalyout view dealloc.........");
}
#pragma mark -
#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        isEnabled = YES;
        self.clipsToBounds = YES;
        _lastFill = @"defaultValue";
        _isSingleTouch = YES;
        _isTouchOn = YES;
    }
    return self;
}

-(void) fireEvent:(NSString*) _event
{
    doInvokeResult* _result = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:_event :_result ];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isSingleTouch) {
        _isSingleTouch = YES;
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self];
    BOOL isPointInsideView = [self pointInside:point withEvent:event];
    if(!_isLongTouch && isPointInsideView)
    {
        [self doALayoutView_fingerTouch];
    }
    [self doALayoutView_fingerTouchUp];
    if (!_isTouchOn) {
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isSingleTouch = YES;
    if (event.allTouches.count>1) {
        _isSingleTouch = NO;
        return;
    }
    _isLongTouch = NO;
    [self doALayoutView_fingerTouchDown];
    [self performSelector:@selector(doALayoutView_fingerLongTouch) withObject:nil afterDelay:.5];
    if (!_isTouchOn) {
        [super touchesBegan:touches withEvent:event];
    }
}
#pragma mark -
#pragma mark - override
- (void)LoadView:(doUIModule *)_doUIModule
{
    model = (do_ALayout_UIModel *)_doUIModule;
    for (int i = 0;i<(int)model.ChildUIModules.count; i++)
    {
        doUIModule* _childUI = model.ChildUIModules[i];
        UIView* _view = (UIView*)_childUI.CurrentUIModuleView;
        if (_view == nil) continue;
        [self addSubview:_view];
    }
}
- (doUIModule *) GetModel
{
    return model;
}
- (void)OnDispose
{
    model = nil;
}
- (void) OnRedraw
{
    [model ComputeZoom];
    [doUIModuleHelper OnRedraw:model];
    for(int i = (int)model.ChildUIModules.count- 1; i >= 0; i--)
    {
        doUIModule* _childUI = model.ChildUIModules[i];
        id<doIUIModuleView> _view = _childUI.CurrentUIModuleView;
        if (_view == nil) continue;
        [_view OnRedraw];
    }
    if (![[model GetPropertyValue:@"bgImage"] isEqualToString:@""]) {
        [self change_bgImageFillType:[model GetPropertyValue:@"bgImageFillType"]];
    }
}
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    [doUIModuleHelper HandleViewProperChanged: self :model : _changedValues ];
}

- (BOOL)InvokeSyncMethod:(NSString *)_methodName :(NSDictionary *)_dictParas :(id<doIScriptEngine>) _scriptEngine :(doInvokeResult *)_invokeResult
{
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dictParas :_scriptEngine :_invokeResult];
}

- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
#pragma mark - 重写该方法，动态选择事件的施行或无效
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    //这里的BOOL值，可以设置为int的标记。从model里获取。
    if([model.EventCenter GetEventCount:@"touch"] <= 0 || isEnabled == NO)
        if(view == self)
            view = nil;
    return view;
}
#pragma mark -
#pragma mark - properties
- (void)change_enabled:(NSString *)newValue
{
    isEnabled = [[doTextHelper Instance] StrToBool:newValue :NO];
}
- (void) change_bgImage:(NSString*) newValue
{
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :newValue];
    UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
    [self changeImage:img : [self getType]];
}
- (void) change_bgImageFillType:(NSString*) newValue
{
    if ([newValue isEqualToString:_lastFill] || ![self sizeValidate]){
        return;
    }
    _lastFill = newValue;
    NSString *imgPath = [model GetPropertyValue:@"bgImage"];
    imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :imgPath];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    [self changeImage:img : newValue];
}
- (NSString *)getType
{
    NSString *type = [model GetPropertyValue:@"bgImageFillType"];
    if (!type || [type isEqualToString:@""]) {
        type = [model GetProperty:@"bgImageFillType"].DefaultValue;
    }
    return type;
}

- (BOOL)sizeValidate
{
    if (CGRectGetHeight(self.frame)<=0 || CGRectGetWidth(self.frame)<=0) {
        return NO;
    }
    return YES;
}
#pragma mark -
#pragma mark - methods
- (void)add:(NSArray *)parms
{
    NSDictionary* _dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scriptEngine = [parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    
    NSString* _viewid = [doJsonHelper GetOneText: _dictParas: @"id" :@""];
    NSString* _viewtemplate = [doJsonHelper GetOneText: _dictParas: @"path" :@""];
    NSString* _targetX = [doJsonHelper GetOneText: _dictParas: @"x" :nil];
    NSString* _targetY = [doJsonHelper GetOneText: _dictParas: @"y" :nil];
    NSString* _result = [model Add:_scriptEngine :_viewtemplate :_targetX :_targetY :_viewid ];
    [_invokeResult SetResultText:_result];
}
-(void) getChildren:(NSArray *)parms
{
    [model getChildren:parms];
}
#pragma mark -
#pragma mark - private
-(void) changeImage:(UIImage*) _img :(NSString*) _type
{
    if (![self sizeValidate]) {
        return;
    }
    if(_img==nil) return;
    if ([_type isEqualToString:@"repeatxy"]) {
        self.layer.contents = nil;
        self.backgroundColor = [UIColor colorWithPatternImage:_img];
    }else{
        CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
        if (colorModel != kCGColorSpaceModelRGB) {
            self.backgroundColor = [doUIModuleHelper GetColorFromString:[model GetPropertyValue:@"bgColor"] : [UIColor clearColor]];
        }
        self.layer.contents = (id)_img.CGImage;
    }
    
    [doUIModuleHelper generateBorder:model :@""];
    
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
    CGColorSpaceModel newModle = CGColorSpaceGetModel(CGColorGetColorSpace(backgroundColor.CGColor));
    if (colorModel == kCGColorSpaceModelPattern && newModle == kCGColorSpaceModelRGB && [_lastFill isEqualToString:@"repeatxy"]) {
    }else
        [super setBackgroundColor:backgroundColor];
}
- (void)doALayoutView_fingerLongTouch
{
    _isLongTouch = YES;
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"longTouch" :_invokeResult];
}
- (void)doALayoutView_fingerTouch
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touch" :_invokeResult];
}
- (void)doALayoutView_fingerTouchUp
{
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchUp" :_invokeResult];
}
- (void)doALayoutView_fingerTouchDown
{
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchDown" :_invokeResult];
}

#pragma mark -
- (int)isResetBorder
{
    int isReset = 0;
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
    if (colorModel == kCGColorSpaceModelPattern || self.layer.contents) {
        isReset = 1;
    }else
        isReset = 2;
    return isReset;
}

- (BOOL)isSupportDiffBorder
{
    return YES;
}


- (void)eventName:(NSString *)event :(NSString *)type
{
    if ([event hasPrefix:@"touch"]) {
        if ([type isEqualToString:@"on"]) {
            _isTouchOn = YES;
        }else
            _isTouchOn = NO;
    }
}

@end
