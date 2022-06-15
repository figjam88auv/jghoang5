//
//  CompositeFont.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "CompositeFont.h"

@implementation CompositeFont

- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict {
    CGPDFArrayRef widthsArray = nil;
    if (CGPDFDictionaryGetArray(dict, "W", &widthsArray)) {
        [self setWidthsWithArray:widthsArray];
    }
    
    CGPDFInteger defaultWidthValue = 0;
    if (CGPDFDictionaryGetInteger(dict, "DW", &defaultWidthValue)) {
        self.defaultWidth = defaultWidthValue;
    }
}

- (CGFloat)widthOfCharacter:(unichar)character withFontSize:(CGFloat)fontSize {
    NSNumber* width = widthsMap[@(character)];
    
    return (width == nil) ? (self.defaultWidth * fontSize) : [width floatValue] * fontSize;
}

#pragma mark - Private Methods
- (void)setWidthsWithArray:(CGPDFArrayRef)widthsArray {
    NSInteger count = CGPDFArrayGetCount(widthsArray);
    NSInteger index = 0;
    CGPDFObjectRef nextObject = nil;
    
    while (index < count) {
        CGPDFInteger baseCid = 0;
        CGPDFArrayGetInteger(widthsArray, index++, &baseCid);
        
        CGPDFObjectRef integerOrArray = nil;
        CGPDFInteger firstCharacter = 0;
        CGPDFArrayGetObject(widthsArray, index++, &integerOrArray);
        
        if (CGPDFObjectGetType(integerOrArray) == kCGPDFObjectTypeInteger) {
            // [ first last width ]
            CGPDFInteger maxCid = 0;
            CGPDFInteger glyphWidth = 0;
            CGPDFObjectGetValue(integerOrArray, kCGPDFObjectTypeInteger, &maxCid);
            CGPDFArrayGetInteger(widthsArray, index++, &glyphWidth);
            [self setWidthsFrom:baseCid to:maxCid width:glyphWidth];
            
            // If the second item is an array, the sequence
			// defines widths on the form [ first list-of-widths ]
            CGPDFArrayRef characterWidths = nil;
            if (!CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeArray, &characterWidths)) break;
            
            NSInteger widthsCount = CGPDFArrayGetCount(characterWidths);
            for (NSInteger j=0; j<widthsCount; j++) {
                CGPDFInteger width = 0;
                if (CGPDFArrayGetInteger(characterWidths, j, &width)) {
                    [widthsMap setObject:@(width) forKey:@(firstCharacter + j)];
                }
            }
    
        } else {
            // [ first list-of-widths ]
            CGPDFArrayRef glyphWidths = nil;
            CGPDFObjectGetValue(integerOrArray, kCGPDFObjectTypeArray, &glyphWidths);
            [self setWidthsWithBase:baseCid array:glyphWidths];
        }
    }
    
    
    
//	CGPDFInteger firstCharacter = 0;
//    
//	for (int i = 0; i < count; )
//	{
//		// Read two first items from sequence
//		if (!CGPDFArrayGetInteger(widthsArray, i++, &firstCharacter)) break;
//		if (!CGPDFArrayGetObject(widthsArray, i++, &nextObject)) break;
//        
//		CGPDFObjectType type = CGPDFObjectGetType(nextObject);
//        
//		if (type == kCGPDFObjectTypeInteger)
//		{
//			// If the second item is another integer, the sequence
//			// defines a range on the form [ first last width ]
//			CGPDFInteger lastCharacter;
//			CGPDFInteger characterWidth;
//			CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeInteger, &lastCharacter);
//			CGPDFArrayGetInteger(widthsArray, i++, &characterWidth);
//			
//			for (int index = firstCharacter; index <= lastCharacter; index++)
//			{
//				NSNumber *key = [NSNumber numberWithInt:index];
//				NSNumber *val = [NSNumber numberWithInt:characterWidth];
//				[widthsMap setObject:val forKey:key];
//			}
//		}
//		else if (type == kCGPDFObjectTypeArray)
//		{
//			// If the second item is an array, the sequence
//			// defines widths on the form [ first list-of-widths ]
//			CGPDFArrayRef characterWidths;
//			if (!CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeArray, &characterWidths)) break;
//			NSUInteger count = CGPDFArrayGetCount(characterWidths);
//			for (int index = 0; index < count ; index++)
//			{
//				CGPDFInteger width;
//				if (CGPDFArrayGetInteger(characterWidths, index, &width))
//				{
//					NSNumber *key = [NSNumber numberWithInt:firstCharacter+index];
//					NSNumber *val = [NSNumber numberWithInt:width];
//					[widthsMap setObject:val forKey:key];
//				}
//			}
//		}
//		else
//		{
//			break;
//		}
//	}
}

- (void)setWidthsFrom:(CGPDFInteger)cid to:(CGPDFInteger)maxCid width:(CGPDFInteger)width {
    while (cid <= maxCid) {
        [widthsMap setObject:@(width) forKey:@(cid++)];
    }
}

- (void)setWidthsWithBase:(CGPDFInteger)base array:(CGPDFArrayRef)array {
    NSInteger count = CGPDFArrayGetCount(array);
    CGPDFInteger width = 0;
    
    for (NSInteger i=0; i<count; i++) {
        if (CGPDFArrayGetInteger(array, i, &width)) {
            [widthsMap setObject:@(width) forKey:@(base + i)];
        }
    }
}

@end
