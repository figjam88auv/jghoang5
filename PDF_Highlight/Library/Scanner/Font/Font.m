//
//  Font.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "Font.h"
#import "FontDescriptor.h"
#import "CMap.h"
#import "CodingCMap.h"
#import "Type0Font.h"
#import "Type1Font.h"
#import "Type3Font.h"
#import "CIDType0Font.h"
#import "CIDType2Font.h"
#import "MMType1Font.h"
#import "TrueTypeFont.h"
#import "FontFile.h"

const char *kTypeKey = "Type";
const char *kFontDescriptorKey = "FontDescriptor";
const char *kFontKey = "Font";
const char *kFontSubtypeKey = "Subtype";
const char *kToUnicodeKey = "ToUnicode";
const char *kBaseFontKey = "BaseFont";

// default supported font type
const char *kType0Key = "Type0";
const char *kType1Key = "Type1";
const char *kMMType1Key = "MMType1";
const char *kType3Key = "Type3";
const char *kTrueTypeKey = "TrueType";
const char *kCidFontType0Key = "CIDFontType0";
const char *kCidFontType2Key = "CIDFontType2";

@interface Font ()

// 利用 CMap 解编码
- (NSString *)unicodeStringUsingToUnicode:(id)cmapObj code:(const unsigned char *)codes length:(size_t)length;

// 利用 font file 解编码
- (NSString *)unicodeStringUsingFontFile:(const unsigned char *)codes length:(size_t)length;

// 标准编码解编码
- (NSString *)unicodeStringWithStandardEncoding:(const unsigned char *)codes length:(size_t)length;

// 不明编码解码
- (NSString*)unicodeStringWithUnknowEncoding:(const unsigned char *)codes length:(size_t)length;

@end

@implementation Font

+ (Font*)fontWithDictionary:(CGPDFDictionaryRef)dictionary {
    const char *type = nil;
    CGPDFDictionaryGetName(dictionary, kTypeKey, &type);
    if (!type || strcmp(type, kFontKey) != 0) return nil;
    
    const char *subtype = nil;
    CGPDFDictionaryGetName(dictionary, kFontSubtypeKey, &subtype);
    
    Font* font = nil;
    
    if (!strcmp(subtype, kType0Key)) {
        NSLog(@"Type0"); // demo1
        font = [Type0Font alloc];
        
    } else if (!strcmp(subtype, kType1Key)) {
        NSLog(@"Type1");  // kitten demo
        font = [Type1Font alloc];
        
    } else if (!strcmp(subtype, kMMType1Key)) {
        NSLog(@"MMType1");
        font = [MMType1Font alloc];
        
    } else if (!strcmp(subtype, kType3Key)) {
        NSLog(@"Type3");
        font = [Type3Font alloc];
        
    } else if (!strcmp(subtype, kTrueTypeKey)) {
        NSLog(@"TrueType"); // demo1
        font = [TrueTypeFont alloc];
        
    } else if (!strcmp(subtype, kCidFontType0Key)) {
        NSLog(@"CIDFontType0");
        font = [CIDType0Font alloc];
        
    } else if (!strcmp(subtype, kCidFontType2Key)) {
        NSLog(@"CIDFontType2");
        font = [CIDType2Font alloc];
        
    } else {
        NSLog(@"not support font face %@", [NSString stringWithUTF8String:subtype]);
    }
    font = [font initWithFontDictionary:dictionary];
    
    return font;
}

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
    self = [super init];
    if (self) {
        widthsMap = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [self setWidthsWithFontDictionary:dict];
        [self setFontDescriptorWithFontDictionary:dict];
        [self setToUnicodeWithFontDictionary:dict];
        
        const char *fontName = nil;
        if (CGPDFDictionaryGetName(dict, kBaseFontKey, &fontName)) {
            baseFont = [NSString stringWithCString:fontName encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict {}

- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict {
    CGPDFDictionaryRef descriptor = nil;
    if (!CGPDFDictionaryGetDictionary(dict, kFontDescriptorKey, &descriptor)) return;
    
    const char *type = nil;
	CGPDFDictionaryGetName(descriptor, kTypeKey, &type);
	if (!type || strcmp(type, kFontDescriptorKey) != 0) return;
    
    self.fontDescriptor = [[FontDescriptor alloc] initWithPDFDictionary:descriptor];
}

- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict {
    CGPDFStreamRef stream = nil;
    if (!CGPDFDictionaryGetStream(dict, kToUnicodeKey, &stream)) return;
    
    self.toUnicode = [[CMap alloc] initWithPDFStream:stream];
    codingCMap = [[CodingCMap alloc] initWithPDFStream:stream];
}

- (NSString *)unicodeStringWithPDFString:(CGPDFStringRef)pdfString {
    const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
    size_t length = CGPDFStringGetLength(pdfString);
    NSString* string = nil;
    
    if (self.toUnicode) {
        string = [self unicodeStringUsingToUnicode:self.toUnicode code:characterCodes length:length];
        
    } else if (self.fontDescriptor.fontFile) {
        string = [self unicodeStringUsingFontFile:characterCodes length:length];
        
    } else if (knownEncoding(encoding)) {
        string = [self unicodeStringWithStandardEncoding:characterCodes length:length];
        
    } else {
        string = [self unicodeStringWithUnknowEncoding:characterCodes length:length];
    }
    return string;
}

- (NSString*)cidWithPDFString:(CGPDFStringRef)pdfString {
    CFStringRef ref=CGPDFStringCopyTextString(pdfString);
    NSString* str=(__bridge NSString*) ref;
    CFRelease(ref);
    return str;
}

- (NSString*)printPDFString:(CGPDFStringRef)pdfString {
    const unsigned char *characterCodes = CGPDFStringGetBytePtr(pdfString);
    size_t length = CGPDFStringGetLength(pdfString);
    NSString* string = nil;
    
    if (codingCMap) {
        string = [self unicodeStringUsingToUnicode:codingCMap code:characterCodes length:length];
        
    } else if (self.fontDescriptor.fontFile) {
        string = [self unicodeStringUsingFontFile:characterCodes length:length];
        
    } else if (knownEncoding(encoding)) {
        string = [self unicodeStringWithStandardEncoding:characterCodes length:length];
        
    } else {
        string = [self unicodeStringWithUnknowEncoding:characterCodes length:length];
    }
    return string;
}

- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize {
    float srcFontWidth = [widthsMap[@(characher)] floatValue];
    float desFontWdith = (srcFontWidth > 0) ? srcFontWidth*fontSize : 1000*fontSize;
    
    return desFontWdith;
}

#pragma merk - Private Methods
- (NSString *)unicodeStringUsingToUnicode:(id)cmapObj code:(const unsigned char *)codes length:(size_t)length; {
    NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		unichar value = [cmapObj unicodeCharacter:codes[i]];
		[unicodeString appendFormat:@"%C", value];
	}
	return unicodeString;
}

- (NSString *)unicodeStringUsingFontFile:(const unsigned char *)codes length:(size_t)length {
    FontFile *fontFile = self.fontDescriptor.fontFile;
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		NSString *string = [fontFile stringWithCode:codes[i]];
		[unicodeString appendString:string];
	}
	return unicodeString;
}

- (NSString *)unicodeStringWithStandardEncoding:(const unsigned char *)codes length:(size_t)length {
    NSStringEncoding stringEncoding = nativeEncoding(encoding);
	
	NSString *unicodeString = [[NSString alloc] initWithBytes:codes length:length encoding:stringEncoding];
	return unicodeString;
}

- (NSString*)unicodeStringWithUnknowEncoding:(const unsigned char *)codes length:(size_t)length {
    NSString *unicodeString = [[NSString alloc] initWithBytes:codes length:length encoding:NSUTF8StringEncoding];
    return unicodeString;
}

@end
