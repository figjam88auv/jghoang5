//
//  PDFPageView.m
//  Main
//
//  Created by Fanty on 14-4-7.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import "PDFPageView.h"
#import "PDFContentCacheView.h"
#import "AnnotationDrawView.h"
#import "PDFSearcher.h"

#define OFFSET 15.0f

@interface PDFPageView()
@end

@implementation PDFPageView

- (id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.delaysContentTouches = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 5.0f;
        self.delegate = self;

        contentView=[[PDFContentCacheView alloc] initWithFrame:self.bounds];
        contentView.userInteractionEnabled=YES;
        contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentView];
        searcher = [[PDFSearcher alloc] init];
        

        annotationDrawView=[[AnnotationDrawView alloc] initWithFrame:contentView.bounds];
        annotationDrawView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [contentView addSubview:annotationDrawView];

    }
    return self;
}


-(void)setPage:(CGPDFPageRef)page{
    [contentView setPage:page];
    [searcher loadPage:page];
    annotationDrawView.pdfTransform=[contentView pdfTransform];
    annotationDrawView.pdfRect=[contentView pdfRect];
    annotationDrawView.pdfCharacterModelList=searcher.characterModelList;
    [annotationDrawView.allItemPaths removeAllObjects];
    [contentView setNeedsDisplay];
    [annotationDrawView setNeedsDisplay];
}


-(void)updateContentPage{
    contentView.nightMode=self.nightMode;
    [contentView setNeedsDisplay];
}

#pragma mark - Implement UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView{
    return contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)_scrollView{

    if(_scrollView.zoomScale==1.0f){
        CGRect rect=contentView.frame;
        rect.origin.x = ( _scrollView.bounds.size.width-rect.size.width)*0.5f;
        rect.origin.y=0.0f;
        contentView.frame=rect;

        
    }
    else{

        CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?
            
        (_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
        
        (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
        
        contentView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,
                                         
                                         _scrollView.contentSize.height * 0.5 + offsetY);
        
    }
    
}

@end
