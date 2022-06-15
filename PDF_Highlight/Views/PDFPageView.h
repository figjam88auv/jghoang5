//
//  PDFPageView.h
//  Main
//
//  Created by Fanty on 14-4-7.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AnnotationDrawView;
@class PDFContentCacheView;
@class PDFPageView;
@class PDFSearcher;

//pdf 滚动组合视图
@interface PDFPageView : UIScrollView<UIScrollViewDelegate> {

    //pdf视图
    PDFContentCacheView* contentView;
    //标注视图
    AnnotationDrawView* annotationDrawView;

    //pdf枚举器
    PDFSearcher* searcher;
}

//设置夜间模式
@property(nonatomic,assign) BOOL nightMode;

//设置可视的page
-(void)setPage:(CGPDFPageRef)page;


//更新界面
-(void)updateContentPage;

@end
