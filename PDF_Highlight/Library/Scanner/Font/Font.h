//
//  Font.h
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum {
	UnknownEncoding = 0,
	StandardEncoding, // Defined in Type1 font programs
	MacRomanEncoding,
	WinAnsiEncoding,
	PDFDocEncoding,
	MacExpertEncoding,
	
} CharacterEncoding;

static inline NSStringEncoding nativeEncoding(CharacterEncoding encoding)
{
	switch (encoding) {
		case MacRomanEncoding :
			return NSMacOSRomanStringEncoding;
		case WinAnsiEncoding :
			return NSWindowsCP1252StringEncoding;
		default:
			return NSUTF8StringEncoding;
	}
}

static inline BOOL knownEncoding(CharacterEncoding encoding)
{
	return encoding > 0;
}

@class FontDescriptor;
@class CMap;
@class CodingCMap;

@interface Font : NSObject {
    @protected
        NSMutableDictionary* widthsMap;
        NSDictionary* ligatures;
        NSRange widthRange;
        NSString* baseFont;
        NSStringEncoding encoding;
        CodingCMap* codingCMap;
}

@property(nonatomic, strong) CMap* toUnicode;
@property(nonatomic, strong) FontDescriptor* fontDescriptor;

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font*)fontWithDictionary:(CGPDFDictionaryRef)dictionary;

/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Construct a font descriptor given font dictionary */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Import a ToUnicode CMap from a font dictionary */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Given a PDF string, returns a Unicode string */
- (NSString *)unicodeStringWithPDFString:(CGPDFStringRef)pdfString;

/* Given a PDF string, returns a CID string */
- (NSString*)cidWithPDFString:(CGPDFStringRef)pdfString;

/* Given a PDF string, return a Decoded string */
- (NSString*)printPDFString:(CGPDFStringRef)pdfString;

/* Returns the width of a charachter (externionally scaled to some font size) */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize;

@end

