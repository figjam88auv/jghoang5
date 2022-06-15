//
//  PDFSearcher.m
//  PDFTableTest
//
//  Created by Fanty on 14-5-12.
//  Copyright (c) 2014年 eileen. All rights reserved.
//


//#define OUTPUT_SOURCE

#import "PDFSearcher.h"
#import "FontCollection.h"
#import "Font.h"
#import "PDFCharacterModel.h"

@implementation QInclude

-(id)init{
    self=[super init];
    if(self){
        self.cmTransforms=[[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

@end


@interface PDFSearcher ()

- (void)initOperatorTable;
- (void)reset;
- (void)drawString:(CGPDFStringRef)pdfString;

@end


@implementation PDFSearcher

-(id)init {
    if(self = [super init]){
        qIncludes=[[NSMutableArray alloc] initWithCapacity:3];
        
        [self initOperatorTable];
    }
    return self;
}

-(void)loadPage:(CGPDFPageRef)inPage{
    self.characterModelList = [NSMutableArray arrayWithCapacity:50];
    
    fontCollection=nil;
    CGPDFDictionaryRef dict = CGPDFPageGetDictionary(inPage);
    if (dict != nil) {
        CGPDFDictionaryRef resources = nil;
        if (CGPDFDictionaryGetDictionary(dict, "Resources", &resources)) {
            CGPDFDictionaryRef fonts = nil;
            if (CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) {                
                fontCollection = [[FontCollection alloc] initWithFontDictionary:fonts];
            }
        }
    }
    
    if(fontCollection==nil){
        return;
    }
    
    [qIncludes removeAllObjects];
    QInclude* include=[[QInclude alloc] init];
    [qIncludes addObject:include];
    
    CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(inPage);
    CGPDFScannerRef scanner =  CGPDFScannerCreate(contentStream, table, (__bridge void *)(self));
    CGPDFScannerScan(scanner);
    CGPDFScannerRelease(scanner);
    CGPDFContentStreamRelease(contentStream);
}

#pragma mark - Private Methods
//文本在pdf 的基础定义
//首先定义字体Tf
//然后定义字位置Td
//定义文字Tj
//Tc  设置字符的间隔  例如H  e   之间有10个间隔， 则10 TC
//Tw  设置字的间隔
//Tr  设置文本渲染模式
//Ts 设置文本上升
//TL 设置行间距  //由文字的最低  至  下一行文字的最底  tl减去文字的高， 就是文字的行间距
//T*   意思是移动到下一行   相当于  -0 td
//Tm:  手动定义文本矩阵   <a> <b> <c> <d> <e> <f>
/*
 a   b   0
 c   d   0
 e   f   1
 */
//Tj  显示文字在当前的文字的position
//'   移动到下一行去显示文字    例  abc '   代表在下一行显示abc  等价   abc  Tj  T*
//"  移动到下一行，设置字和字符间距，并显示文字。      例如  2   1 Hello  " 代表在下一行设置字距为2字符间距为1  显示Hello    等价   2 Tw   1  Tc   Hello '
//TJ  显示一个字符串数组，而手动调整字间距。
//Tz  设置垂直scale

//w  10  w 设置10 个像素
//m  306  396 m 移动到306 396的点
//l  306  594 l 画线至306 594 的点
//d  设置笔触虚线样式
//J  设置线帽样式
//j  设置线条连接样式
//M  设置的边角斜接限制
//cm 设置图形的变换矩阵。
//c  <x1> <y1> <x2> <y2> <x3> <y3> c 添国一个贝塞尔曲线
//q   Q   创建一个孤立的图形状态块。 是一对组合来的
//h   关闭路径

//RG  0.1 0.1 0.1 笔触颜色空间更改为RGB和设置笔触颜色。
//rg  0.1 0.1 0.1 填充颜色空间更改为RGB和设置填充颜色。
//K             笔触颜色空间更改为CMYK并设置笔触颜色。
//k             填充颜色空间更改为CMYK，并设置填充颜色。
//S   s       都是关闭路径？
//f   也是差不多是关闭路径？
//B b  也是差不多是关闭路径？

//g  0.5 g    设置灰度  0.5

- (void)initOperatorTable {
    table = CGPDFOperatorTableCreate();
    
    CGPDFOperatorTableSetCallback(table,"BT",tableStart);
    CGPDFOperatorTableSetCallback(table, "Tf", fontInfo);          //获取字体
    CGPDFOperatorTableSetCallback(table, "Td", stringPosition);          //行的改变
    CGPDFOperatorTableSetCallback(table, "Tj", stringCallback);  //获取字符串
    CGPDFOperatorTableSetCallback(table, "Tc", charCallback);  //设置字符的间隔
    CGPDFOperatorTableSetCallback(table, "Tw", strCallback);  //设置字的间隔
    CGPDFOperatorTableSetCallback(table, "Tr", textRenderCallback);  //设置文本渲染模式
    CGPDFOperatorTableSetCallback(table, "Ts", textUpCallback);  //设置文本上升
    CGPDFOperatorTableSetCallback(table, "TL", baselineCallback);  //设置行间距
    CGPDFOperatorTableSetCallback(table, "T*", newLineCallback);  //移动到下一行
    CGPDFOperatorTableSetCallback(table, "Tm", textTransformCallback);  //手动定义文本矩阵
    CGPDFOperatorTableSetCallback(table, "TJ", arrayCallback);  //显示一个字符串数组，而手动调整字间距。
    CGPDFOperatorTableSetCallback(table, "Tz", tzScale);//设置垂直scale
    
    CGPDFOperatorTableSetCallback(table, "\'", moveLineAndText);  //移动到下一行去显示文字。
    CGPDFOperatorTableSetCallback(table, "\"", moveLineAndTextAndchar);  //移动到下一行，设置字和字符间距，并显示文字。
    
    CGPDFOperatorTableSetCallback(table, "TD", moveLineAndLeading);
    CGPDFOperatorTableSetCallback(table, "cm", grapicsTransformCallback);
    CGPDFOperatorTableSetCallback(table,"ET",tableEnd);
    
    CGPDFOperatorTableSetCallback(table,"w",wFunction);
    CGPDFOperatorTableSetCallback(table,"m",mFunction);
    CGPDFOperatorTableSetCallback(table,"l",lFunction);
    CGPDFOperatorTableSetCallback(table,"d",dFunction);
    CGPDFOperatorTableSetCallback(table,"J",JFunction);
    CGPDFOperatorTableSetCallback(table,"j",jFunction);
    CGPDFOperatorTableSetCallback(table,"M",MFunction);
    CGPDFOperatorTableSetCallback(table,"c",cFunction);
    CGPDFOperatorTableSetCallback(table,"q",qFunction);
    CGPDFOperatorTableSetCallback(table,"Q",QFunction);
    CGPDFOperatorTableSetCallback(table,"h",hFunction);
    CGPDFOperatorTableSetCallback(table,"RG",RGFunction);
    CGPDFOperatorTableSetCallback(table,"rg",rgFunction);
    CGPDFOperatorTableSetCallback(table,"K",KFunction);
    CGPDFOperatorTableSetCallback(table,"k",kFunction);
    CGPDFOperatorTableSetCallback(table,"S",SFunction);
    CGPDFOperatorTableSetCallback(table,"s",sFunction);
    CGPDFOperatorTableSetCallback(table,"f",fFunction);
    CGPDFOperatorTableSetCallback(table,"B",BFunction);
    CGPDFOperatorTableSetCallback(table,"b",bFunction);
}

-(void)reset{
    tdTop=0.0f;
    tdLeft=0.0f;
    tmTransform=CGAffineTransformIdentity;
    lineScaleWidth=1.0f;
    lineScaleHeight=1.0f;
    horizontalScaling = 1.0f;
    
    customLeft=0.0f;
    customTop=0.0f;
    left=0.0f;
    top=0.0f;
}

-(void)drawString:(CGPDFStringRef)pdfString{
    NSString *str = [selectedFont cidWithPDFString:pdfString];
//    NSString* printedStr = [selectedFont printPDFString:pdfString];
    NSUInteger length=[str length];
    
//#ifdef OUTPUT_SOURCE
//    printf("[self tj:@\"%s\" ctx:ctx];\n",[str UTF8String]);
//#else
//    printf("tj 文字长度: %d\n",length);
//    NSLog(@"tj 文字内容: %@",printedStr);
//#endif

    if(length>0){
        //trim left
        NSUInteger trimLeftIndex=0;
        for(NSUInteger i=0;i<length;i++){
            unichar ch=[str characterAtIndex:i];
            if(ch!=' ' && ch!=3){
                break;
            }
            float fontWidth = [selectedFont widthOfCharacter:ch withFontSize:selectedFontSize];
            fontWidth /= 1000;
            fontWidth+=Tc;
            if (ch == 32) {
                fontWidth += Tw;
            }
            customLeft+=fontWidth;
            trimLeftIndex++;
        }
        
        //trim right
        NSUInteger trimRightIndex=length;
        for(NSUInteger i=length-1;i!=0;i--){
            unichar ch=[str characterAtIndex:i];
            if(ch!=' ' && ch!=3){
                break;
            }
            trimRightIndex--;
        }
        
        float lineWidth = (lineScaleWidth>0.0f) ? (1.0f/lineScaleWidth) : 1.0f;
        CGAffineTransform transform=CGAffineTransformIdentity;
        for(QInclude* include in qIncludes){
            for(NSValue* value in include.cmTransforms){
                transform=CGAffineTransformConcat([value CGAffineTransformValue],transform);
            }
        }
        
        if(tmTransform.a!=0.0f || tmTransform.b!=0.0f || tmTransform.c!=0.0f || tmTransform.d!=0.0f || tmTransform.tx!=0.0f || tmTransform.ty!=0.0f){
            transform=CGAffineTransformConcat(tmTransform,transform);
        }
        
        for(NSUInteger i=trimLeftIndex;i<trimRightIndex;i++){
            unichar ch=[str characterAtIndex:i];
            
            float fontWidth = [selectedFont widthOfCharacter:ch withFontSize:selectedFontSize];
            fontWidth /= 1000;
            fontWidth+=Tc;
            
            PDFCharacterModel* model = [[PDFCharacterModel alloc] init];
            model.lineWidth = lineWidth;
            model.transform = transform;
            model.rect = CGRectMake((left+customLeft), top+textUp+customTop-selectedFontSize*0.2f, fontWidth, selectedFontSize);
            
            if (ch == 32) {
                customLeft += Tw;
            }
            customLeft+=fontWidth;
            
            [self.characterModelList addObject:model];
        }
    }
}

#pragma mark - Operater Table Callback Methods
void tableStart(CGPDFScannerRef scanner, void *info){
//#ifdef OUTPUT_SOURCE
//    printf("[self reset];\n");
//#else
//    printf("BT   意思是开始\n");
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)info;
    
    //保存一下ctx 的状态
    [objSelf reset];
}

void tableEnd(CGPDFScannerRef scanner, void *userInfo){
//#ifdef OUTPUT_SOURCE
//    printf("[self reset];\n");
//#else
//    printf("ET结束\n");
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    [objSelf reset];
}


void fontInfo(CGPDFScannerRef scanner, void *info){
	CGPDFReal fontSize;
	const char *fontName;
	CGPDFScannerPopNumber(scanner, &fontSize);
	CGPDFScannerPopName(scanner, &fontName);
    
//#ifdef OUTPUT_SOURCE
//    printf("//fontname:%s\n",fontName);
//    printf("selectedFontSize=%f;\n",fontSize);
//#else
//	printf("Tf 获取了字体  fontname:%s  fontsize:%f\n",fontName,fontSize);
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)info;
    objSelf->selectedFont = [objSelf->fontCollection getFontByName:[NSString stringWithUTF8String:fontName]];
    objSelf->selectedFontSize=fontSize;
}

/* Move to start of next line */
void stringPosition(CGPDFScannerRef scanner, void *info){
	CGPDFReal tx = 0, ty = 0;
	CGPDFScannerPopNumber(scanner, &ty);
	CGPDFScannerPopNumber(scanner, &tx);
    
//#ifdef OUTPUT_SOURCE
//    printf("[self Td:%f ty:%f];\n",tx,ty);
//#else
//    printf("Td  从哪个点开始  x:%f y:%f\n",tx,ty);
//#endif
    
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)info;
    
    objSelf->tdTop+=ty;
    objSelf->tdLeft+=tx;
    
    objSelf->customLeft=0.0f;
    objSelf->customTop=0.0f;
    
    objSelf->left=objSelf->tdLeft;
    objSelf->top=objSelf->tdTop;
    
    objSelf->lastestTd=ty;
}

/* Move to start of next line, and set leading */
void moveLineAndLeading(CGPDFScannerRef scanner, void *info){
	CGPDFReal tx, ty;
	CGPDFScannerPopNumber(scanner, &ty);
	CGPDFScannerPopNumber(scanner, &tx);
    
//#ifdef OUTPUT_SOURCE
//    printf("[self TD:%f ty:%f];\n",tx,ty);
//#else
//    printf("TD 从哪个点开始，x:%f y:%f\n",tx,ty);
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)info;
    
    objSelf->tdTop+=ty;
    objSelf->tdLeft+=tx;
    
    objSelf->customLeft=0.0f;
    objSelf->customTop=0.0f;
    
    objSelf->left=objSelf->tdLeft;
    objSelf->top=objSelf->tdTop;
    
    objSelf->lastestTd=ty;
    
}

void newLineCallback(CGPDFScannerRef scanner, void *userInfo){
    
//#ifdef OUTPUT_SOURCE
//    printf("[self TThing];\n");
//#else
//    printf("T*移动到下一行\n");
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    if(objSelf->lastestTd==0.0f){
        objSelf->lastestTd=-objSelf->selectedFontSize*1.5f;
    }
    objSelf->tdTop+=objSelf->lastestTd;
    
    objSelf->customLeft=0.0f;
    objSelf->customTop=0.0f;
    
    objSelf->left=objSelf->tdLeft;
    objSelf->top=objSelf->tdTop;
}


void arrayCallback(CGPDFScannerRef inScanner, void *userInfo) {
    //PDFSearcher * searcher = (__bridge PDFSearcher *)userInfo;
	CGPDFArrayRef array = nil;
	CGPDFScannerPopArray(inScanner, &array);
    size_t count = CGPDFArrayGetCount(array);
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    
	for (int i = 0; i < count; i++){
		CGPDFObjectRef object = nil;
		CGPDFArrayGetObject(array, i, &object);
		CGPDFObjectType type = CGPDFObjectGetType(object);
        switch (type){
            case kCGPDFObjectTypeString:{
                CGPDFStringRef pdfString;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &pdfString)){
                    [objSelf drawString:pdfString];
                }
                break;
            }
            case kCGPDFObjectTypeReal:{
                CGPDFReal tx;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeReal, &tx)){
//#ifdef OUTPUT_SOURCE
//                    printf("[self tj2:%f];\n",tx);
//#else
//                    
//                    NSLog(@"TJ文字%d  space:%f",i,tx);
//#endif
                    objSelf->customLeft-=(tx*0.001f);
                }
                break;
            }
            case kCGPDFObjectTypeInteger:{
                CGPDFInteger tx;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &tx)){
//#ifdef OUTPUT_SOURCE
//                    printf("[self tj2:%ld];\n",tx);
//#else
//                    NSLog(@"TJ文字%d  space:%ld",i,tx);
//#endif
                    objSelf->customLeft-=(tx*0.001f);
                }
                break;
            }
            default:
                NSLog(@"TJ %d   Unsupported type: %d", i,type);
                break;
        }
	}
}

void stringCallback(CGPDFScannerRef inScanner, void *userInfo) {
    CGPDFStringRef pdfString;
    bool success = CGPDFScannerPopString(inScanner, &pdfString);
    
    if(success) {
        PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
        [objSelf drawString:pdfString];
    }
}


void textRenderCallback(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("Tr渲染模式: %f\n",real);
//#endif
}


void charCallback(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
//#ifdef OUTPUT_SOURCE
//    printf("Tc=%f;\n",real);
//    
//#else
//    printf("Tc字符间隔: %f\n",real);
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->Tc=real;
}

void strCallback(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
//#ifdef OUTPUT_SOURCE
//    printf("Tw=%f;\n",real);
//    
//#else
//    printf("Tw字间隔: %f\n",real);
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->Tw=real;
}

void textUpCallback(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
//#ifdef OUTPUT_SOURCE
//    printf("textUp=%f;\n",real);
//    
//#else
//    printf("Ts广本上升位: %f\n",real);
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->textUp=real;
}

void tzScale(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
//    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("tz设置垂直位: %f\n",real);
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->horizontalScaling=real;
    
}

void baselineCallback(CGPDFScannerRef scanner, void *userInfo){
    CGPDFReal real;
	CGPDFScannerPopNumber(scanner, &real);
//#ifdef OUTPUT_SOURCE
//    printf("baseline=%f;\n",real);
//    
//#else
//    printf("TL行间隔: %f\n",real);
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->baseline=real;
}

void textTransformCallback(CGPDFScannerRef scanner, void *userInfo){
	CGPDFReal a, b, c, d, tx, ty;
	CGPDFScannerPopNumber(scanner, &ty);
	CGPDFScannerPopNumber(scanner, &tx);
	CGPDFScannerPopNumber(scanner, &d);
	CGPDFScannerPopNumber(scanner, &c);
	CGPDFScannerPopNumber(scanner, &b);
	CGPDFScannerPopNumber(scanner, &a);
//#ifdef OUTPUT_SOURCE
//    printf("[self Tm:%f b:%f c:%f d:%f tx:%f ty:%f];\n",a,b,c,d,tx,ty);
//    
//#else
//    printf("Tm 文字transform转换a:%f b:%f c:%f d:%f tx:%f ty:%f\n",a,b,c,d,tx,ty);
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    objSelf->tdLeft=0.0f;
    objSelf->tdTop=0.0f;
    objSelf->customLeft=0.0f;
    objSelf->customTop=0.0f;
    objSelf->left=0.0f;
    objSelf->top=0.0f;
    objSelf->lastestTd=0.0f;
    
    objSelf->tmTransform=CGAffineTransformMake(a, b, c, d, tx, ty);
    objSelf->lineScaleWidth=a;
    objSelf->lineScaleHeight=d;
}

void grapicsTransformCallback(CGPDFScannerRef scanner, void *userInfo){
    
    
	CGPDFReal a, b, c, d, tx, ty;
	CGPDFScannerPopNumber(scanner, &ty);
	CGPDFScannerPopNumber(scanner, &tx);
	CGPDFScannerPopNumber(scanner, &d);
	CGPDFScannerPopNumber(scanner, &c);
	CGPDFScannerPopNumber(scanner, &b);
	CGPDFScannerPopNumber(scanner, &a);
//#ifdef OUTPUT_SOURCE
//    printf("[self cm:%f b:%f c:%f d:%f tx:%f ty:%f];\n",a,b,c,d,tx,ty);
//    
//#else
//    printf("cm 页面transform转换a:%f b:%f c:%f d:%f tx:%f ty:%f\n",a,b,c,d,tx,ty);
//#endif
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    CGAffineTransform cmTransform=CGAffineTransformMake(a, b, c, d, tx, ty);
    QInclude* include=[objSelf->qIncludes lastObject];
    [include.cmTransforms addObject:[NSValue valueWithCGAffineTransform:cmTransform]];
    
}

void moveLineAndText(CGPDFScannerRef inScanner, void *info){
    CGPDFStringRef string;
    bool success = CGPDFScannerPopString(inScanner, &string);
    if(success) {
        CFStringRef str=CGPDFStringCopyTextString(string);
//        NSString *data = (__bridge NSString *)str;
        
//        NSLog(@"//'文字换以及移动:%@",data);
        
        CFRelease(str);
        
        
    }
    
}

void moveLineAndTextAndchar(CGPDFScannerRef inScanner, void *info){
    CGPDFStringRef string;
    bool success = CGPDFScannerPopString(inScanner, &string);
    if(success) {
        
        CGPDFReal ch;
        CGPDFReal wh;
        CGPDFScannerPopNumber(inScanner, &ch);
        CGPDFScannerPopNumber(inScanner, &wh);
        
        CFStringRef str=CGPDFStringCopyTextString(string);
//        NSString *data = (__bridge NSString *)str;
//        NSLog(@"//\"文字画以及移动:%@  ch:%f  wh:%f",data,ch,wh);
        CFRelease(str);
    }
}

void wFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal w;
	CGPDFScannerPopNumber(inScanner, &w);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("w设置10个像素:%f\n",w);
//#endif
}

void mFunction(CGPDFScannerRef inScanner, void *info){
    
    CGPDFReal x;
    CGPDFReal y;
    
	CGPDFScannerPopNumber(inScanner, &y);
    CGPDFScannerPopNumber(inScanner, &x);
    
    PDFSearcher* objSelf=(__bridge PDFSearcher*)info;
    objSelf->customLeft=x;
    objSelf->customTop=y;
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("m移动到点:    x:%f        y:%f\n",x,y);
//#endif
}

void lFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal x;
    CGPDFReal y;
    
	CGPDFScannerPopNumber(inScanner, &y);
    CGPDFScannerPopNumber(inScanner, &x);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("l画线:    x:%f        y:%f\n",x,y);
//#endif
}

void dFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal x;
    
    CGPDFScannerPopNumber(inScanner, &x);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("d设置笔触虚线:    x:%f\n",x);
//#endif
}

void JFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal x;
    
    CGPDFScannerPopNumber(inScanner, &x);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("J设置线帽样式:    x:%f\n",x);
//#endif
}

void jFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal x;
    
    CGPDFScannerPopNumber(inScanner, &x);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("j设置线条连接样式:    x:%f\n",x);
//#endif
    
}

void MFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("M边角限制设置\n");
//#endif
}

void cFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("c贝塞尔曲线\n");
//#endif
}

void qFunction(CGPDFScannerRef inScanner, void *userInfo){
//#ifdef OUTPUT_SOURCE
//    printf("[self q];\n");
//    
//#else
//    printf("q路径开始\n");
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    
    QInclude* include=[[QInclude alloc] init];
    
    [objSelf->qIncludes addObject:include];
    
}

void QFunction(CGPDFScannerRef inScanner, void *userInfo){
//#ifdef OUTPUT_SOURCE
//    printf("[self Q];\n");
//    
//#else
//    printf("Q路径关闭与q对应\n");
//#endif
    PDFSearcher* objSelf=(__bridge PDFSearcher*)userInfo;
    if([objSelf->qIncludes count]>0){
        [objSelf->qIncludes removeLastObject];
    }
}

void hFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("h关闭路径\n");
//#endif
}

void RGFunction(CGPDFScannerRef inScanner, void *info){
    
    CGPDFReal r;
    CGPDFReal p;
    CGPDFReal g;
    
    CGPDFScannerPopNumber(inScanner, &g);
    CGPDFScannerPopNumber(inScanner, &p);
    CGPDFScannerPopNumber(inScanner, &r);
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("RG设置颜色    r:%f   p:%f   g:%f\n",r,p,g);
//#endif
}

void rgFunction(CGPDFScannerRef inScanner, void *info){
    CGPDFReal r;
    CGPDFReal p;
    CGPDFReal g;
    
    CGPDFScannerPopNumber(inScanner, &g);
    CGPDFScannerPopNumber(inScanner, &p);
    CGPDFScannerPopNumber(inScanner, &r);
    
    
//#ifdef OUTPUT_SOURCE
//#else
//    printf("rg设置颜色    r:%f   p:%f   g:%f\n",r,p,g);
//#endif
}

void KFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("K颜色填充空间\n");
//#endif
}

void kFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("k颜色填充空间\n");
//#endif
}

void SFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("S关闭路径\n");
//#endif
}

void sFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("s关闭路径\n");
//#endif
}

void fFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("f关闭路径\n");
//#endif
}

void BFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("B关闭路径\n");
//#endif
}

void bFunction(CGPDFScannerRef inScanner, void *info){
//#ifdef OUTPUT_SOURCE
//#else
//    printf("b关闭路径\n");
//#endif
}

@end

