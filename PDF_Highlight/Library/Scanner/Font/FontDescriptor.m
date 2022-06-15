//
//  FontDescriptor.m
//  PDFTableTest
//
//  Created by eileen on 13/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "FontDescriptor.h"
#import "FontFile.h"

const char *kAscentKey = "Ascent";
const char *kDescentKey = "Descent";
const char *kLeadingKey = "Leading";
const char *kCapHeightKey = "CapHeight";
const char *kXHeightKey = "XHeight";
const char *kAverageWidthKey = "AvgWidth";
const char *kMaxWidthKey = "MaxWidth";
const char *kMissingWidthKey = "MissingWidth";
const char *kFlagsKey = "Flags";
const char *kStemVKey = "StemV";
const char *kStemHKey = "StemH";
const char *kItalicAngleKey = "ItalicAngle";
const char *kFontNameKey = "FontName";
const char *kFontBBoxKey = "FontBBox";
const char *kFontFileKey = "FontFile";

@implementation FontDescriptor

- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict {
    self = [super init];
    if (self) {        
        CGPDFInteger ascentValue = 0L;
		CGPDFInteger descentValue = 0L;
		CGPDFInteger leadingValue = 0L;
		CGPDFInteger capHeightValue = 0L;
		CGPDFInteger xHeightValue = 0L;
		CGPDFInteger averageWidthValue = 0L;
		CGPDFInteger maxWidthValue = 0L;
		CGPDFInteger missingWidthValue = 0L;
		CGPDFInteger flagsValue = 0L;
		CGPDFInteger stemV = 0L;
		CGPDFInteger stemH = 0L;
		CGPDFInteger italicAngleValue = 0L;
		const char *fontNameString = nil;
		CGPDFArrayRef bboxValue = nil;
        
        CGPDFDictionaryGetInteger(dict, kAscentKey, &ascentValue);
        CGPDFDictionaryGetInteger(dict, kDescentKey, &descentValue);
        CGPDFDictionaryGetInteger(dict, kLeadingKey, &leadingValue);
		CGPDFDictionaryGetInteger(dict, kCapHeightKey, &capHeightValue);
		CGPDFDictionaryGetInteger(dict, kXHeightKey, &xHeightValue);
		CGPDFDictionaryGetInteger(dict, kAverageWidthKey, &averageWidthValue);
		CGPDFDictionaryGetInteger(dict, kMaxWidthKey, &maxWidthValue);
		CGPDFDictionaryGetInteger(dict, kMissingWidthKey, &missingWidthValue);
		CGPDFDictionaryGetInteger(dict, kFlagsKey, &flagsValue);
		CGPDFDictionaryGetInteger(dict, kStemVKey, &stemV);
        CGPDFDictionaryGetInteger(dict, kStemHKey, &stemH);
        CGPDFDictionaryGetInteger(dict, kItalicAngleKey, &italicAngleValue);
        CGPDFDictionaryGetName(dict, kFontNameKey, &fontNameString);
		CGPDFDictionaryGetArray(dict, kFontBBoxKey, &bboxValue);
        
        self.ascent = ascentValue;
        self.descent = descentValue;
        self.leading = leadingValue;
		self.capHeight = capHeightValue;
		self.xHeight = xHeightValue;
		self.averageWidth = averageWidthValue;
		self.maxWidth = maxWidthValue;
        self.missingWidth = missingWidthValue;
        self.flags = flagsValue;
        self.verticalStemWidth = stemV;
        self.horizontalStemWidth = stemH;
        self.italicAngle = italicAngleValue;
        self.fontName = [NSString stringWithUTF8String:fontNameString];
        
        if (CGPDFArrayGetCount(bboxValue) == 4)
		{
			CGPDFInteger x = 0, y = 0, width = 0, height = 0;
			CGPDFArrayGetInteger(bboxValue, 0, &x);
			CGPDFArrayGetInteger(bboxValue, 1, &y);
			CGPDFArrayGetInteger(bboxValue, 2, &width);
			CGPDFArrayGetInteger(bboxValue, 3, &height);
            
			self.bounds = CGRectMake(x, y, width, height);
		}
        
        CGPDFStreamRef fontFileStream = nil;
		if (CGPDFDictionaryGetStream(dict, kFontFileKey, &fontFileStream))
		{
			CGPDFDataFormat format = 0;
            CFDataRef dataRef=CGPDFStreamCopyData(fontFileStream, &format);
			NSData *data = (__bridge NSData *) dataRef;
			
	 		NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
			path = [path stringByAppendingPathComponent:@"fontfile"];
			[data writeToFile:path atomically:YES];
			
			self.fontFile = [[FontFile alloc] initWithData:data];
            
            CFRelease(dataRef);
            
		}
    }
    return self;
}

- (BOOL)isSymbolic {
    return ((self.flags & FontSymbolic) > 0) && ((self.flags & FontNonSymbolic) == 0);
}

@end
