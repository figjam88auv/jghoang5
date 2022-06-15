//
//  PDFContentCacheView.m
//  Main
//
//  Created by Fanty on 14-6-16.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import "PDFContentCacheView.h"
#import <QuartzCore/QuartzCore.h>

@interface PDFContentCacheView()

//画pdf
-(void)drawPDF:(CGContextRef)ctx rect:(CGRect)rect;

//更新状态
-(void)updateEvent;
@end


@implementation PDFContentCacheView

@synthesize pdfPage;

- (void)dealloc {
    CGPDFPageRelease(pdfPage);
}

-(void)setPage:(CGPDFPageRef)page{

    CGPDFPageRelease(pdfPage);
    pdfPage = CGPDFPageRetain(page);
}

-(void)drawRect:(CGRect)rect{
    
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, rect);
    if(self.pdfPage!=nil){
        CGRect pdfRect=CGPDFPageGetBoxRect(self.pdfPage, kCGPDFCropBox);
        
        int rotationAngle = CGPDFPageGetRotationAngle(self.pdfPage);
        CGAffineTransform transform= CGPDFPageGetDrawingTransform(self.pdfPage, kCGPDFCropBox, pdfRect, -rotationAngle, YES);
        
        float scale=rect.size.width/pdfRect.size.width;
        float maxPdfHeight=pdfRect.size.height*scale;
        if(maxPdfHeight>rect.size.height){      //宽自适应没用的话 则尝试高自适应
            scale=rect.size.height/pdfRect.size.height;
        }
        
        float x=(rect.size.width/scale-pdfRect.size.width)*0.5f-pdfRect.origin.x;
        float y=(-rect.size.height/scale-pdfRect.size.height)*0.5f-pdfRect.origin.y;
        transform=CGAffineTransformScale(transform, scale, -scale);
        
        transform=CGAffineTransformTranslate(transform, x, y);
        CGContextConcatCTM(ctx, transform);
        
        CGContextDrawPDFPage(ctx, self.pdfPage);

    }
    
    CGContextRestoreGState(ctx);
    
    //实现黑夜模式
    if(self.nightMode){
        CGContextSetBlendMode(ctx, kCGBlendModeDifference);
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8f] CGColor]);
        CGContextFillRect(ctx, rect);
    }
    
}

-(CGAffineTransform)pdfTransform{
    if(pdfPage==nil)return CGAffineTransformIdentity;

    CGRect rect=self.bounds;
    CGRect pdfRect=CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    
    int rotationAngle = CGPDFPageGetRotationAngle(pdfPage);
    CGAffineTransform _pdfTransform= CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, pdfRect, -rotationAngle, YES);
    
    float scale=rect.size.width/pdfRect.size.width;
    float maxPdfHeight=pdfRect.size.height*scale;
    if(maxPdfHeight>rect.size.height){      //宽自适应没用的话 则尝试高自适应
        scale=rect.size.height/pdfRect.size.height;
    }
    
    float x=(rect.size.width/scale-pdfRect.size.width)*0.5f-pdfRect.origin.x;
    float y=(-rect.size.height/scale-pdfRect.size.height)*0.5f-pdfRect.origin.y;
    _pdfTransform=CGAffineTransformScale(_pdfTransform, scale, -scale);
    
    _pdfTransform=CGAffineTransformTranslate(_pdfTransform, x, y);
    
    return _pdfTransform;
}

- (CGRect)pdfRect {
    if(pdfPage==nil)return CGRectZero;
    CGRect rect=self.bounds;
    CGRect pdfRect=CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    
    float scale=rect.size.width/pdfRect.size.width;
    float maxPdfHeight=pdfRect.size.height*scale;
    if(maxPdfHeight>rect.size.height){      //宽自适应没用的话 则尝试高自适应
        scale=rect.size.height/pdfRect.size.height;
    }
    float x=(rect.size.width/scale-pdfRect.size.width)*0.5f-pdfRect.origin.x;
    float y=(rect.size.height/scale-pdfRect.size.height)*0.5f-pdfRect.origin.y;

    return CGRectMake(x, y, pdfRect.size.width, pdfRect.size.height);
}


@end
