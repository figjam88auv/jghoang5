//
//  FontFile.m
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "FontFile.h"

const static NSInteger kHeaderLength = 6;
static NSDictionary* characterNameMap = nil;

@implementation FontFile

@synthesize text = _text;

+ (unichar)characterByName:(NSString*)name {
    if (characterNameMap == nil) {
        characterNameMap = @{
                                 @"/ff": @(0xfb00),
                                 @"/fi": @(0xfb01),
                                 @"/fl": @(0xfb02),
                                 @"/ffl": @(0xfb04),
                                 
                                 @"/T": @(0x0054),
                                 @"/a": @(0x0061),
                                 @"/c": @(0x0063),
                                 @"/e": @(0x0065),
                                 @"/h": @(0x0068),
                                 @"/i": @(0x0069),
                                 @"/l": @(0x006c),
                                 @"/n": @(0x006e),
                                 @"/o": @(0x006f),
                                 @"/one": @(0x0031),
                                 @"/period": @(0x002e),
                                 @"/s": @(0x0073),
                                 @"/t": @(0x0074),
                                 @"/u": @(0x0075),
                                 @"/v": @(0x0076),
                                 @"/y": @(0x0079)
                             };
    }
    
    return [characterNameMap[name] integerValue];
}

- (id)initWithData:(NSData*)__data {
    if (__data == nil) return nil;
    
    self = [super init];
    if (self) {
        data = __data;
        
        NSScanner* scanner = [NSScanner scannerWithString:self.text];
        NSCharacterSet* delimiterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSCharacterSet* newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
        
        nameMap = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString* buffer = nil;
        
        while (![scanner isAtEnd]) {
            if (![scanner scanUpToCharactersFromSet:delimiterSet intoString:&buffer]) break;
            
            if ([buffer hasPrefix:@"%"]) {
                [scanner scanUpToCharactersFromSet:newLineCharacterSet intoString:nil];
                continue;
            }
            
            if ([buffer isEqualToString:@"dup"]) {
                NSInteger code = 0;
                NSString* name = nil;
                [scanner scanInt:&code];
                [scanner scanUpToCharactersFromSet:delimiterSet intoString:&name];
                if (name) [nameMap setObject:name forKey:@(code)];
            }
        }
    }
    return self;
}

- (id)initWithContentOfURL:(NSURL*)url {
    return [self initWithData:[NSData dataWithContentsOfURL:url]];
}

- (NSString*)stringWithCode:(NSInteger)code {
    static NSString* singleUnicodeCharFormat = @"%C";
    
    NSString* characterName = nameMap[@(code)];
    unichar unicodeValue = [FontFile characterByName:characterName];
    
    if (!unicodeValue) unicodeValue = code;
    
    return [NSString stringWithFormat:singleUnicodeCharFormat, unicodeValue];
}

- (NSString*)__text {
    if (_text == nil) {
        // ASCII segment length (little endian)
        unsigned char *bytes = (uint8_t *) [data bytes];
        
        if (bytes[0] == 0x80) {
            asciiTextLength =  bytes[2] | bytes[3] << 8 | bytes[4] << 16 | bytes[5] << 24;
            NSData* textData = [[NSData alloc] initWithBytes:bytes+kHeaderLength length:asciiTextLength];
            _text = [[NSString alloc] initWithData:textData encoding:NSASCIIStringEncoding];
            
        } else {
            _text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
    }
    return _text;
}

@end
