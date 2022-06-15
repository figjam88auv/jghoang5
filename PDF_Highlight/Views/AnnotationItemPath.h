//
//  AnnotationItemPath.h
//  Main
//
//  Created by Fanty on 14-6-17.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@class AnnotationMarkView;
//标注的路径保存点
@interface AnnotationItemPath : NSObject{
    CGMutablePathRef path;

}

//选中的颜色
@property(nonatomic,strong) UIColor* selectedColor;

//线知宽度
@property(nonatomic,assign) float lineWidth;

//转换的矩阵
@property(nonatomic,assign) BOOL wantsPDFTransform;

//绘图
-(void)drawRect:(CGContextRef)context;

//画线
-(void)addlineToPoint:(CGPoint)movePoint currentPoint:(CGPoint)currentPoint refresh:(BOOL)refresh;

//画方框
-(void)addRect:(CGRect)rect;

//判断点是否在框内
-(BOOL)contactPointInRect:(CGPoint)poin;

//获取位置
-(CGRect)frame;

//清空路径
-(void)clearPath;

//添加新的方框
-(void)appendNewRect:(CGRect)rect;

@end
