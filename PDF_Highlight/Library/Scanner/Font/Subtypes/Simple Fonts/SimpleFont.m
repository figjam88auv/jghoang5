//
//  SimpleFont.m
//  PDFTableTest
//
//  Created by eileen on 16/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "SimpleFont.h"
#import "CMap.h"
#import "CodingCMap.h"

@interface SimpleFont ()

/* Set encoding, given a font dictionary */
- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Set encoding with name or dictionary */
- (void)setEncodingWithEncodingObject:(CGPDFObjectRef)object;

@end

@implementation SimpleFont

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
    self = [super initWithFontDictionary:dict];
    
    if (self) {
        [self setEncodingWithFontDictionary:dict];
    }
    return self;
}

- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict {
    CGPDFArrayRef array = nil;
    if (!CGPDFDictionaryGetArray(dict, "Widths", &array)) return;
    
    size_t count = CGPDFArrayGetCount(array);
    CGPDFInteger firstChar = 0, lastChar = 0;
    if (!CGPDFDictionaryGetInteger(dict, "FirstChar", &firstChar)) return;
    if (!CGPDFDictionaryGetInteger(dict, "LastChar", &lastChar)) return;
    widthRange = NSMakeRange(firstChar, lastChar-firstChar);
    
    for (NSInteger i=0; i<count; i++) {
        CGPDFReal width = 0;
        if (!CGPDFArrayGetNumber(array, i, &width)) continue;
        [widthsMap setObject:@(width) forKey:@(firstChar+i)];
    }
}

- (NSString*)printPDFString:(CGPDFStringRef)pdfString {
    const unsigned char *bytes = CGPDFStringGetBytePtr(pdfString);
	NSInteger length = CGPDFStringGetLength(pdfString);
	NSData *rawBytes = [NSData dataWithBytes:bytes length:length];
    
	if (!encoding && codingCMap)
	{
        CFStringRef ref=CGPDFStringCopyTextString(pdfString);
		NSString *str = (__bridge NSString *) ref;
		NSMutableString *unicodeString = [NSMutableString string];
        
		for (int i = 0; i < [str length]; i++)
		{
			unichar cid = [str characterAtIndex:i];
		 	[unicodeString appendFormat:@"%C", [codingCMap unicodeCharacter:cid]];
		}
        CFRelease(ref);
		
		return unicodeString;
	}
	else if (!encoding)
	{
        return [super printPDFString:pdfString];
	}
    return [[NSString alloc] initWithData:rawBytes encoding:encoding];
}

#pragma mark - Private Methods
- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict {
    CGPDFObjectRef encodingObject = nil;
    if (!CGPDFDictionaryGetObject(dict, "Encoding", &encodingObject)) return;
    
    [self setEncodingWithEncodingObject:encodingObject];
}

- (void)setEncodingWithEncodingObject:(CGPDFObjectRef)object {
    CGPDFObjectType type = CGPDFObjectGetType(object);
    
    if (type == kCGPDFObjectTypeDictionary) {
        CGPDFDictionaryRef dict = nil;
        if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
        
        CGPDFObjectRef baseEncoding = nil;
        if (!CGPDFDictionaryGetObject(dict, "BaseEncoding", &baseEncoding)) return;
        [self setEncodingWithEncodingObject:baseEncoding];
        
        return;
    }
    
    if (type != kCGPDFObjectTypeName) return;
    
    const char *name = nil;
    if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &name)) return;
    
    if (strcmp(name, "MacRomanEncoding") == 0) {
        encoding = MacRomanEncoding;
        
    } else if (strcmp(name, "WinAnsiEncoding") == 0) {
        encoding = WinAnsiEncoding;
        
    } else {
        encoding = UnknownEncoding;
    }
}

@end
