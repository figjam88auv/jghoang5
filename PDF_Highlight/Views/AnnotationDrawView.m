//
//  AnnotationDrawView.m
//  Test
//
//  Created by Fanty on 14-3-7.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import "AnnotationDrawView.h"
#import "PDFCharacterModel.h"
#import "AnnotationItemPath.h"

@interface AnnotationDrawView()

@end


@implementation AnnotationDrawView

@synthesize allItemPaths;

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundColor=[UIColor clearColor];
        self.selectedColor=[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
        self.userInteractionEnabled=YES;
        allItemPaths=[[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"annotation draw view dealloc");
}

- (void)drawRect:(CGRect)rect{
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    
    CGContextSaveGState(ctx);
    
    CGContextConcatCTM(ctx, self.pdfTransform);
    
    NSMutableArray* array=[NSMutableArray arrayWithArray:allItemPaths];
    if(currentItemPath!=nil)
        [array addObject:currentItemPath];

    //画所有的笔画
    for (AnnotationItemPath* itemPath in array) {
        if(itemPath.wantsPDFTransform)
            [itemPath drawRect:ctx];
    }

    
    CGContextSetRGBFillColor(ctx, 0xff/255.0f, 0xff/255.0f, 0.0, 0.4f);

    

    
    CGContextRestoreGState(ctx);
    
    if(currentItemPath!=nil){
        
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:0.7f] CGColor]);
        
        CGContextSetLineWidth(ctx, 1.0f);
        
        CGContextFillRect(ctx, CGRectMake(lastPoint.x, lastPoint.y, currentPoint.x-lastPoint.x, currentPoint.y-lastPoint.y));
        
        CGContextStrokePath(ctx);
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
    currentItemPath=[[AnnotationItemPath alloc] init];
    currentItemPath.wantsPDFTransform=YES;
    currentItemPath.lineWidth=1.0f;
    currentItemPath.selectedColor=self.selectedColor;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
    currentPoint=lastPoint;
    didMove = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self];

    didMove = YES;

    CGRect rect;
    rect.origin=lastPoint;
    rect.size.width=currentPoint.x-lastPoint.x;
    rect.size.height=currentPoint.y-lastPoint.y;
            
    CGRect newRect=CGRectZero;
    BOOL firstDraw=YES;
    [currentItemPath clearPath];
    
    
    for (NSInteger i=0; i<[self.pdfCharacterModelList count]; i++) {
        PDFCharacterModel* textModel = [self.pdfCharacterModelList objectAtIndex:i];
        CGRect characterPDFRect = CGRectApplyAffineTransform(textModel.rect, textModel.transform);
        CGRect trPDFRect = CGRectApplyAffineTransform(characterPDFRect, self.pdfTransform);
        
        // 上下区域
        BOOL noHighlightCondition1 = CGRectGetMaxY(trPDFRect)<CGRectGetMinY(rect) || CGRectGetMinY(trPDFRect)>CGRectGetMaxY(rect);
        
        // 左区域
        BOOL noHighlightCondition2 = CGRectGetMinY(rect)>=CGRectGetMinY(trPDFRect) && CGRectGetMinY(rect)<=CGRectGetMaxY(trPDFRect) && CGRectGetMaxX(trPDFRect)<CGRectGetMinX(rect);
        
        // 右区域
        BOOL noHighlightCondition3 = CGRectGetMaxY(rect)>CGRectGetMinY(trPDFRect) && CGRectGetMaxY(rect)<CGRectGetMaxY(trPDFRect) && CGRectGetMinX(trPDFRect)>CGRectGetMaxX(rect);
        
        BOOL noHighlightCondition = noHighlightCondition1 || noHighlightCondition2 || noHighlightCondition3;
        
        if (CGRectIntersectsRect(rect, trPDFRect) || !noHighlightCondition) {
            if(firstDraw){
                newRect=characterPDFRect;
                firstDraw=NO;
            }
            else{
                if(newRect.origin.y==characterPDFRect.origin.y && newRect.size.height== characterPDFRect.size.height && CGRectGetMaxX(newRect)+characterPDFRect.size.width>=characterPDFRect.origin.x){
                    newRect.size.width=CGRectGetMaxX(characterPDFRect)-newRect.origin.x;
                }
                else{
                    [currentItemPath appendNewRect:newRect];
                    newRect=characterPDFRect;
                }
            }
        }
    }
    if(!firstDraw){
        [currentItemPath appendNewRect:newRect];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self];

    if (didMove) {
        BOOL add=YES;
        if(currentPoint.x-lastPoint.x==0.0f && currentPoint.y-lastPoint.y==0.0f)
            add=NO;
        
        if(add){
            [allItemPaths addObject:currentItemPath];
        }
        
        currentItemPath=nil;
        [self setNeedsDisplay];
    }
    else{
        currentItemPath=nil;
    }
    didMove = NO;
}

@end
