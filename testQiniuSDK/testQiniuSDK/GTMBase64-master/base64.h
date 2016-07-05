//
//  base64.h
//  testQiniuSDK
//
//  Created by zhuhongwei on 16/7/5.
//  Copyright © 2016年 zhuhongwei. All rights reserved.
//

#import <UIKit/UIKit.h>



extern size_t EstimateBas64EncodedDataSize(size_t inDataSize);
extern size_t EstimateBas64DecodedDataSize(size_t inDataSize);

extern bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize, BOOL wrapped);
extern bool Base64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);