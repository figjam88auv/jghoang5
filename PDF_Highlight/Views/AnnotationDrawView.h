//
//  AnnotationDrawView.h
//  Test
//
//  Created by Fanty on 14-3-7.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnotationItemPath;

//标注容器类
@interface AnnotationDrawView : UIView<NSCoding> {
    CGPoint currentPoint;
    CGPoint lastPoint;
    BOOL didMove;
    
    AnnotationItemPath* currentItemPath;
}


//所有笔画集合
@property(nonatomic,strong) NSMutableArray* allItemPaths;


//选中的颜色
@property(nonatomic,strong) UIColor* selectedColor;


//获取pdf 的矩阵
@property(nonatomic,assign) CGAffineTransform  pdfTransform;

//获取pdf 所在的位置
@property(nonatomic,assign) CGRect pdfRect;

//pdf 的每一个字的路径
@property(nonatomic,strong) NSArray* pdfCharacterModelList;

@end
