//
//  AnnotationItemPath.m
//  Main
//
//  Created by Fanty on 14-6-17.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import "AnnotationItemPath.h"



@implementation AnnotationItemPath

-(id)init{
    self=[super init];
    if(self){
        self.lineWidth=7.0f;
        path=CGPathCreateMutable();
    }
    return self;
}


- (void)dealloc{
    CGPathRelease(path);
}


-(void)drawRect:(CGContextRef)context{

    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeDestinationAtop);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextBeginPath(context);


    CGContextSetFillColorWithColor(context, [self.selectedColor CGColor]);

    CGContextAddPath(context, path);


    CGContextFillPath(context);

    
    CGContextRestoreGState(context);
}

-(void)addlineToPoint:(CGPoint)movePoint currentPoint:(CGPoint)currentPoint refresh:(BOOL)refresh{
    if(refresh){
        CGPathRelease(path);
        path=CGPathCreateMutable();
    }
    CGPathMoveToPoint(path, nil, movePoint.x, movePoint.y);
    CGPathAddQuadCurveToPoint(path, NULL, movePoint.x-1.0f, movePoint.y-1.0f, currentPoint.x, currentPoint.y);
    
}

-(void)addRect:(CGRect)rect{
    CGPathRelease(path);
    path=CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
}

-(void)clearPath{
    CGPathRelease(path);
    path=CGPathCreateMutable();

}



-(void)appendNewRect:(CGRect)rect{
        
    CGPathAddRect(path, NULL, rect);
}

-(CGRect)frame{
    CGRect rect=CGPathGetBoundingBox(path);
    rect.origin.x-=20.0f;
    rect.origin.y-=20.0f;
    rect.size.width+=40.0f;
    rect.size.height+=40.0f;
    return rect;
}

-(BOOL)contactPointInRect:(CGPoint)point{
    return CGRectContainsPoint([self frame], point);
}



@end
