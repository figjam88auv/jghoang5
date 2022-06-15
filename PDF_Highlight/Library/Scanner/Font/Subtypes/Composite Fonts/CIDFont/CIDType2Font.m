//
//  CIDType2Font.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "CIDType2Font.h"

@implementation CIDType2Font

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
    self = [super initWithFontDictionary:dict];
    
    if (self) {
        CGPDFObjectRef streamOrName = nil;
        if (CGPDFDictionaryGetObject(dict, "CIDToGIDMap", &streamOrName)) {
            CGPDFObjectType type = CGPDFObjectGetType(streamOrName);
            self.isIdentity = (type == kCGPDFObjectTypeName);
            
            if (type == kCGPDFObjectTypeStream) {
                CGPDFStreamRef stream = nil;
                
                if (CGPDFObjectGetValue(streamOrName, kCGPDFObjectTypeStream, &stream)) {
                    cidGidMap = (__bridge NSData*) CGPDFStreamCopyData(stream, nil);
                }
            }
        }
    }
    return self;
}

- (NSString*)unicodeStringWithPDFString:(CGPDFStringRef)pdfString {
    size_t length = CGPDFStringGetLength(pdfString);
    const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);
    NSMutableString* result = [NSMutableString stringWithCapacity:0];

    for (NSInteger i=0; i<length; i+=2) {
        unsigned char unicodeValue1 = cid[i];
		unsigned char unicodeValue2 = cid[i+1];
        
        unichar unicodeValue = (unicodeValue1 << 8) + unicodeValue2;
        [result appendFormat:@"%C", unicodeValue];
    }
    return result;
}

- (NSString*)printPDFString:(CGPDFStringRef)pdfString {
    unichar *characterIDs = (unichar *) CGPDFStringGetBytePtr(pdfString);
	int length = CGPDFStringGetLength(pdfString) / sizeof(unichar);
	int magicalOffset = ([self isIdentity] ? 0 : 30);
	NSMutableString *unicodeString = [NSMutableString string];
	for (int i = 0; i < length; i++)
	{
		unichar unicodeValue = characterIDs[i] + magicalOffset;
		[unicodeString appendFormat:@"%C", unicodeValue];
	}
    
	return unicodeString;
}

@end
