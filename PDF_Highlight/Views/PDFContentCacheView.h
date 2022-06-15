//
//  PDFContentCacheView.h
//  Main
//
//  Created by Fanty on 14-6-16.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import <UIKit/UIKit.h>

//pdf 高亮组件
@interface PDFContentCacheView : UIView

//pdf  页
@property(atomic,readonly) CGPDFPageRef pdfPage;

//夜光模式
@property(nonatomic,assign) BOOL nightMode;

//设置页面
-(void)setPage:(CGPDFPageRef)page;

//pdf 的转换矩阵
-(CGAffineTransform)pdfTransform;

//绘画出来的pdf 所在的位置
- (CGRect)pdfRect;

@end
