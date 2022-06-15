//
//  PDFSearcher.h
//  PDFTableTest
//
//  Created by Fanty on 14-5-12.
//  Copyright (c) 2014年 eileen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class FontCollection;
@class Font;

@interface QInclude : NSObject

@property(nonatomic,strong) NSMutableArray* cmTransforms;

@end



@interface PDFSearcher : NSObject{
    CGPDFOperatorTableRef table;
    FontCollection* fontCollection;
    Font* selectedFont;
    
    float selectedFontSize;

    float Tc;    //字符间隔
    float Tw;    //字间隔
    float textUp;   //文字上升位
    float baseline; //行间隔
    float horizontalScaling;  //垂直缩放值
    
    float lineScaleWidth;   //画线的宽
    float lineScaleHeight;  //画线的高
    
    CGAffineTransform tmTransform;
    
    NSMutableArray* qIncludes;
    
    float customLeft;
    float customTop;
    
    float tdLeft;
    float tdTop;
    
    float left;
    float top;
    
    float lastestTd;
}

@property(nonatomic, strong) NSMutableArray* characterModelList;

-(void)loadPage:(CGPDFPageRef)inPage;

@end
