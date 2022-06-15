//
//  Type0Font.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "Type0Font.h"
#import "CIDType0Font.h"
#import "CIDType2Font.h"
#import "CMap.h"
#import "CodingCMap.h"

@implementation Type0Font

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
    self = [super initWithFontDictionary:dict];
    if (self) {
        descendantFonts = [NSMutableArray arrayWithCapacity:0];
        
        CGPDFArrayRef dFonts = nil;
        if (CGPDFDictionaryGetArray(dict, "DescendantFonts", &dFonts)){
            NSInteger count = CGPDFArrayGetCount(dFonts);
            
            for (NSInteger i=0; i<count; i++) {
                CGPDFDictionaryRef fontDict = nil;
                if (!CGPDFArrayGetDictionary(dFonts, i, &fontDict)) continue;
                const char *subtype = nil;
                if (!CGPDFDictionaryGetName(fontDict, "Subtype", &subtype)) continue;
                
                NSLog(@"Descendant font type %s", subtype);
                
                if (strcmp(subtype, "CIDFontType0") == 0) { // Add descendant font of type 0
                    CIDType0Font* font = [[CIDType0Font alloc] initWithFontDictionary:fontDict];
                    [descendantFonts addObject:font];
                    
                } else if (strcmp(subtype, "CIDFontType2") == 0) {  // Add descendant font of type 2
                    CIDType2Font* font = [[CIDType2Font alloc] initWithFontDictionary:fontDict];
                    [descendantFonts addObject:font];
                }
            }
        }
    }
    return self;
}

- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize {
    for (Font* eachFont in descendantFonts) {
        CGFloat width = [eachFont widthOfCharacter:characher withFontSize:fontSize];
        if (width > 0) return width;
    }
    
    return self.defaultWidth;
}

- (FontDescriptor*)fontDescriptor {
    Font* descendantFont = [descendantFonts lastObject];
    return descendantFont.fontDescriptor;
}

- (NSString*) unicodeStringWithPDFString:(CGPDFStringRef)pdfString {
    NSMutableString* resultStr = [NSMutableString stringWithCapacity:0];
    
    if (self.toUnicode) {
        size_t stringLength = CGPDFStringGetLength(pdfString);
		const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
		
        for (int i = 0; i < stringLength; i+=2) {
			unichar characterCode = characterCodes[i] << 8 | characterCodes[i+1];
			unichar characterSelector = [self.toUnicode unicodeCharacter:characterCode];
            [resultStr appendFormat:@"%C", characterSelector];
		}
        
    } else if (descendantFonts.count > 0) {
        Font *descendantFont = [descendantFonts lastObject];
        resultStr = [[descendantFont unicodeStringWithPDFString: pdfString] mutableCopy];
    }
    
    return resultStr;
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    Font* descendantFont = [descendantFonts lastObject];
    return [descendantFont unicodeStringWithPDFString: pdfString];
}

- (NSString*)printPDFString:(CGPDFStringRef)pdfString {
    if (codingCMap)
	{
		size_t stringLength = CGPDFStringGetLength(pdfString);
		const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
		NSMutableString *unicodeString = [NSMutableString string];
		
        for (int i = 0; i < stringLength; i+=2)
		{
			unichar characterCode = characterCodes[i] << 8 | characterCodes[i+1];
			unichar characterSelector = [codingCMap unicodeCharacter:characterCode];
            [unicodeString appendFormat:@"%C", characterSelector];
		}
		return unicodeString;
	}
	else if ([descendantFonts count] > 0)
	{
		Font *descendantFont = [descendantFonts lastObject];
		return [descendantFont printPDFString:pdfString];
	}
	return @"";
}

@end
