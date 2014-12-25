//
//  LocalizableScanner.m
//  LocalizableScan
//
//  Copyright (c) 2014 Elvin Gao
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "LocalizableScanner.h"
#import "FileScanner.h"
#import <RegexKitLite/RegexKitLite.h>

@interface LocalizableScanner ()
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FileScanner *fileScanner;
@property (nonatomic, strong) NSMutableArray *localizableStrings;
@property (nonatomic, strong) NSMutableArray *missStrings;
@property (nonatomic, assign) NSUInteger matchMethods;
@end

@implementation LocalizableScanner

static LocalizableScanner *_scanner;
+ (instancetype)scanner{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scanner = [[LocalizableScanner alloc] init];
    });
    return _scanner;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.fileScanner = [[FileScanner alloc] init];
    }
    return self;
}


- (void)scanPath:(NSString *)path{
    [self scanPath:path withLocalizableFile:nil withLocalizableMethod:nil];
}

- (void)scanPath:(NSString *)path withLocalizableFile:(NSString *)file{
    [self scanPath:path withLocalizableFile:file withLocalizableMethod:nil];
}
- (void)scanPath:(NSString *)path withLocalizableMethod:(NSString *)method{
    [self scanPath:path withLocalizableFile:nil withLocalizableMethod:method];
}

- (void)scanPath:(NSString *)path withLocalizableFile:(NSString *)file withLocalizableMethod:(NSString *)method{
    if(path == nil){
        path = [[NSFileManager defaultManager] currentDirectoryPath];
    }
    self.path = path;
    printf("Begin scan: %s\n", [path cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if([self isObjectiveCProjectDirectory] == NO){
        printf("[ERROR] Specified path is not a objective c project directory.\n");
        exit(0);
    }
    
    if(file == nil){
        file = [self findDefaultLocalizableStringFile];
    }
    if(file == nil){
        printf("[ERROR] No find Localizable.strings, assign localizable file with -l option.\n");
        return;
    }
    [self loadLocalizableStringsFile:file];
    
    if(method == nil){
        method = @"NSLocalizedString";
    }
    printf("Localizable method: %s\n", [method cStringUsingEncoding:NSUTF8StringEncoding]);
    
    self.matchMethods = 0;
    self.missStrings = [NSMutableArray array];
    __block NSUInteger count = 0;
    NSInteger options = FileScannerOptionsIncludeDescendants;
    [self.fileScanner enumeratorAtPath:path options:options fileFinder:^(NSURL *url, BOOL isDirectory, BOOL *stop) {
        if([url.path.pathExtension isEqualToString:@"m"] == NO) return;
        if([url.pathComponents containsObject:@"Pods"]) return;
        if(self.verbose) printf(".%s\n", [[url.path stringByReplacingOccurrencesOfString:path withString:@""] cStringUsingEncoding:NSUTF8StringEncoding]);
        @autoreleasepool {
            [self scanSingleFile:url withLocalizableMethod:method];
        }
        count++;
        if(self.verbose == NO){
            if(count % 10 == 0){
                printf(".");
            }
            if(count % 100 == 0){
                printf("\n");
            }
        }
    }];
    printf("\n\nMatch Methods: %ld\n", (long)self.matchMethods);
    printf("\n======================== miss string (%ld) =========================\n", (long)self.missStrings.count);
    [self.missStrings enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
        printf("%s\n", [string cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
    printf("\n");
}

- (NSString *)findDefaultLocalizableStringFile{
    if(self.verbose) printf("find default localizable string file: Localizable.strings ...\n");
    __block NSString *path = nil;
    NSInteger options = FileScannerOptionsIncludeDescendants;
    [self.fileScanner enumeratorAtPath:self.path options:options fileFinder:^(NSURL *url, BOOL isDirectory, BOOL *stop) {
        NSString *name = [url.path lastPathComponent];
        if([name isEqualToString:@"Localizable.strings"]){
            path = [url path];
            *stop = YES;
        }
    }];
    return path;
}

- (void)loadLocalizableStringsFile:(NSString *)file{
    self.localizableStrings = [NSMutableArray array];
    
    printf("Load localizable strings file: %s\n", [[file stringByReplacingOccurrencesOfString:self.path withString:@""] cStringUsingEncoding:NSUTF8StringEncoding]);
    
    __block BOOL inComment = NO;
    __block NSUInteger lineNo = 0;
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSString *fileData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [fileData enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        lineNo++;
        if(lineNo == 239){
        }
        @autoreleasepool {
            NSString *clearLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(clearLine.length == 0) return;
            if([clearLine hasPrefix:@"//"]) return;
            if([clearLine hasPrefix:@"/*"] && [clearLine hasSuffix:@"*/"]) return;
            if(inComment && [clearLine hasSuffix:@"*/"]){
                inComment = NO;
                return;
            }
            if([clearLine hasPrefix:@"/*"]){
                inComment = YES;
            }
            if(inComment) return;
            NSArray *array = [line componentsSeparatedByString:@"="];
            if(array.count != 2) return;
            NSString *key = [array[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([key hasPrefix:@"\""] && [key hasSuffix:@"\""] && key.length >= 2){
                [self.localizableStrings addObject:key];
            }
        }
    }];
    if(self.verbose) NSLog(@"\nlocalizable strings:\n%@\n", self.localizableStrings);
}

- (void)scanSingleFile:(NSURL *)url withLocalizableMethod:(NSString *)method{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *fileData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [fileData enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        @autoreleasepool {
            NSString *clearLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(clearLine.length == 0) return;
            if([clearLine hasPrefix:@"//"]) return;
            if([clearLine hasPrefix:@"/*"] && [clearLine hasSuffix:@"*/"]) return;
            
            NSString *regex = [NSString stringWithFormat:@"%@\\(@(\".*?\"),", method];
            [clearLine enumerateStringsMatchedByRegex:regex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                NSString *string = capturedStrings[1];
                if([self.localizableStrings containsObject:string]){
                    if(self.verbose) printf("\tlocalizable string: %s\n", [string cStringUsingEncoding:NSUTF8StringEncoding]);
                }else{
                    if([self.missStrings containsObject:string] == NO){
                        [self.missStrings addObject:string];
                    }
                }
                self.matchMethods++;
            }];
        }
    }];
}

- (BOOL)isObjectiveCProjectDirectory{
    __block BOOL result = NO;
    NSInteger options = FileScannerOptionsFindDirectory;
    [self.fileScanner enumeratorAtPath:self.path options:options fileFinder:^(NSURL *url, BOOL isDirectory, BOOL *stop) {
        result = [url.path.pathExtension isEqualToString:@"xcodeproj"];
        *stop = result;
    }];
    return result;
}


@end
