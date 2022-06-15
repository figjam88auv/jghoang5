//
//  PDFSelectionViewController.m
//  PDF_Highlight
//
//  Created by Fanty on 14-9-25.
//  Copyright (c) 2014年 Fanty. All rights reserved.
//

#import "PDFSelectionViewController.h"

#import "PDFPageView.h"

@interface PDFSelectionViewController ()

@end

@implementation PDFSelectionViewController{
    CGPDFDocumentRef document;
    NSInteger pageIndex;
    PDFPageView* pageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    document=CGPDFDocumentCreateWithURL((CFURLRef)[[NSBundle mainBundle] URLForResource:@"34816" withExtension:@"pdf"]);
    
    
    
    pageView=[[PDFPageView alloc] initWithFrame:self.view.bounds];
    pageView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:pageView];
    
    
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(btnPrev) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(20.0f, self.view.frame.size.height-100.0f, 100.0f, 50.0f);
    button.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [button setTitle:@"上一页" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(btnNext) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(140.0f, self.view.frame.size.height-100.0f, 100.0f, 50.0f);
    button.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [button setTitle:@"下一页" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    CGPDFPageRef page=CGPDFDocumentGetPage(document, pageIndex+1);
    [pageView setPage:page];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnPrev{
    if(pageIndex>0){
        pageIndex--;
        CGPDFPageRef page=CGPDFDocumentGetPage(document, pageIndex+1);
        [pageView setPage:page];
    }
    
}

-(void)btnNext{
    NSInteger count=CGPDFDocumentGetNumberOfPages(document);
    if(pageIndex<count){
        pageIndex++;
        CGPDFPageRef page=CGPDFDocumentGetPage(document, pageIndex+1);
        [pageView setPage:page];
    }
}

@end
