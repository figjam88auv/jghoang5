//
//  FontCollection.m
//  PDFTableTest
//
//  Created by eileen on 13/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "FontCollection.h"
#import "Font.h"

@implementation FontCollection

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
    self = [super init];
    if (self) {
        fontMap = [NSMutableDictionary dictionaryWithCapacity:0];
        
        CGPDFDictionaryApplyFunction(dict, didScanFont, (__bridge void*)fontMap);
    }
    return self;
}

- (Font*)getFontByName:(NSString*)name {
    return fontMap[name];
}

void didScanFont(const char *key, CGPDFObjectRef object, void *info)
{
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) return;
    
	CGPDFDictionaryRef dict = NULL;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
    
    Font* font = [Font fontWithDictionary:dict];
    if (font == nil) return;
    
	NSString* name = [NSString stringWithUTF8String:key];
    
    NSMutableDictionary* collectionMap = (__bridge NSMutableDictionary*)info;
    [collectionMap setObject:font forKey:name];
}

@end
