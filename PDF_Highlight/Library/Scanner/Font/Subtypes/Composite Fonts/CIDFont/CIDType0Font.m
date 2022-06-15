//
//  CIDType0Font.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "CIDType0Font.h"

@implementation CIDType0Font

- (NSString *)unicodeStringWithPDFString:(CGPDFStringRef)pdfString
{
	size_t length = CGPDFStringGetLength(pdfString);
	const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);
    NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < length; i+=2) {
		unichar unicodeValue = cid[i+1];
        [result appendFormat:@"%C", unicodeValue];
	}
    return result;
}

- (NSString*)printPDFString:(CGPDFStringRef)pdfString {
    return [self unicodeStringWithPDFString:pdfString];
}

@end
