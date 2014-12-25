//
//  main.m
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

#import <Foundation/Foundation.h>
#import "LocalizableScanner.h"

void printHelp();

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *paramNames = @[@"-p", @"-m", @"-l"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        for (int i=1; i<argc; i++) {
            NSString *param = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
            NSArray *ps = [param componentsSeparatedByString:@"="];
            if(ps.count == 1 && [ps[0] isEqualToString:@"-v"]){
                [LocalizableScanner scanner].verbose = YES;
                continue;
            }
            if(ps.count == 1 && [ps[0] isEqualToString:@"-h"]){
                printHelp();
                return 0;
            }
            if(ps.count != 2){
                printf("Unrecognized option:%s", argv[i]);
                printHelp();
                return 0;
            }
            if([paramNames containsObject:ps[0]] == NO){
                printf("Unrecognized option:%s", argv[i]);
                printHelp();
                return 0;
            }
            [params setObject:ps[1] forKey:ps[0]];
        }
        
        NSString *path = [params objectForKey:paramNames[0]];
        NSString *method = [params objectForKey:paramNames[1]];
        NSString *localizableStringFile = [params objectForKey:paramNames[2]];
        
        printf("============ Localizable Strings Scan ===========\n");
        [[LocalizableScanner scanner] scanPath:path withLocalizableFile:localizableStringFile withLocalizableMethod:method];
    }
    return 0;
}

void printHelp(){
    printf("\n");
    printf("Useage:\n");
    printf("\n");
    printf("\t$ LocalizableStringsScanner [-p=<dir>] [-m=<method>] [-l=<path>] [-v]\n");
    printf("\n");
    printf("\t-p=<dir>      scan dir\n");
    printf("\t-m=<method>   localizable string method used in code,\n");
    printf("\t              default is \"NSLocalizedString\".\n");
    printf("\t-l=<path>     localizable string file path,\n");
    printf("\t              default to search Localizable.strings file in scan dir.\n");
    printf("\t-v            verbose mode.\n");
    printf("\n");
}


