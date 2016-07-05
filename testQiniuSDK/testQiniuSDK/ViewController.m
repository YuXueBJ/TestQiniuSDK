//
//  ViewController.m
//  testQiniuSDK
//
//  Created by zhuhongwei on 16/6/16.
//  Copyright © 2016年 zhuhongwei. All rights reserved.
//

#import "ViewController.h"
#import "QiniuSDK.h"
#import <SDWebImage/UIImageView+WebCache.h>

#include <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"
#include "base64.h"

@interface ViewController ()

@property (nonatomic,strong)NSString * token ;
//token 生效时间
@property (nonatomic , assign) int expires;
@end

@implementation ViewController


static NSString * bucketName = @"hongzhang";

//
static NSString * MY_ACCESS_KEY = @"iHxIFqTAJtN7HOVttx25sFd_AIkar4SF7ZtG7_Ln";
static NSString * MY_SECRET_KEY = @"gHigIjTUzSMy0wf5FwDGKoz4bg8FGyBxfMHMCamm";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.expires = 0;
    
    self.token = [self makeToken:MY_ACCESS_KEY secretKey:MY_SECRET_KEY];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////////
//下载
- (NSString*)downloadName:(NSString*)key
{

    NSString * code = [NSString stringWithFormat:@"resource/%@",key];
    
    return code;
}
- (NSString*)urlAddTime:(NSString*)hostUrl
{
    time_t deadline;
    time(&deadline);//返回当前系统时间
    //@property (nonatomic , assign) int expires; 怎么定义随你...
    deadline += (self.expires > 0) ? self.expires : 3600; // +3600秒,即默认token保存1小时.
    
    NSNumber * deadlineNumber = [NSNumber numberWithLongLong:deadline];
    
    NSString *  host = hostUrl;

    NSString * url = [NSString stringWithFormat:@"%@?e=%@",host,deadlineNumber];
    
    return url;
}

-(NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength,YES);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    return base64EncodedResult;
}

//生成下载token  对上一步得到的 URL 字符串计算HMAC-SHA1签名（假设 SecretKey 是 MY_SECRET_KEY），并对结果做URL安全的Base64编码：
- (NSString*)downloadToken:(NSString*)url secretKey:(NSString *)secretKey
{
//     const char * secretKeyStr = [secretKey UTF8String];
//    
//    const char * urlKeyStr = [url UTF8String];
    
//    char digestStr[CC_SHA1_DIGEST_LENGTH];
//    
//    bzero(digestStr, 0);
//    
//    CCHmac(kCCHmacAlgSHA1,urlKeyStr,strlen(urlKeyStr),secretKeyStr,strlen(secretKeyStr), digestStr);
//    //    CCHmac(kCCHmacAlgSHA1,secretKeyStr,strlen(secretKeyStr),urlKeyStr,strlen(urlKeyStr), digestStr);
    
//    NSString * encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    
    NSString * encodedDigest = [self hmacsha1:url key:secretKey];
    
    NSString * token = [NSString stringWithFormat:@"%@:%@",MY_ACCESS_KEY,@"FnaQCvNRskl5vDzPgfPPyEdJNb1e"];
    
    return token;
    
}
- (NSString*)downloadImageURL:(NSString*)key
{
    NSString * host = @"http://7xveyg.com1.z0.glb.clouddn.com/";

    NSString * name = [self downloadName:key];
    
    NSString * time = [self urlAddTime:key];
    
    NSString * downloadUrl = [NSString stringWithFormat:@"%@%@",name,time];

    NSString * token = [self downloadToken:downloadUrl secretKey:MY_SECRET_KEY];

    NSString * image = [NSString stringWithFormat:@"%@&token=%@",downloadUrl,token];

    NSString * encodingString = [image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString * imageURL = [NSString stringWithFormat:@"%@%@",host,encodingString];
    
    return imageURL;
    
}

- (IBAction)selectDownloadButton:(id)sender {
    
    
    NSString * qiniuUrl = [self downloadImageURL:@"sss.png"];
    
    [self.dowloadImageView sd_setImageWithURL:[NSURL URLWithString:qiniuUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        NSLog(@"%@",image);
        
    }];
    
}
////////////////////////////////////////////////////////////////////////////////////

// 上传
////////////////////////////////////////////////////////////////////////////////////
- (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey
{
    const char *secretKeyStr = [secretKey UTF8String];
    
    NSString *policy = [self marshal];
    
    NSData * policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *encodedPolicy = [GTMBase64 stringByWebSafeEncodingData:policyData padded:TRUE];
    
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];
    
    char digestStr[CC_SHA1_DIGEST_LENGTH];
    
    bzero(digestStr, 0);
    
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);
    
    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@",  accessKey, encodedDigest, encodedPolicy];
    
    return token;//得到了token
}

- (NSString *)marshal
{
    time_t deadline;
    time(&deadline);//返回当前系统时间
    //@property (nonatomic , assign) int expires; 怎么定义随你...
    deadline += (self.expires > 0) ? self.expires : 3600; // +3600秒,即默认token保存1小时.
    
    NSNumber *deadlineNumber = [NSNumber numberWithLongLong:deadline];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //users是我开辟的公共空间名（即bucket），aaa是文件的key，
    //按七牛“上传策略”的描述：    <bucket>:<key>，表示只允许用户上传指定key的文件。在这种格式下文件默认允许“修改”，若已存在同名资源则会被覆盖。如果只希望上传指定key的文件，并且不允许修改，那么可以将下面的 insertOnly 属性值设为 1。
    //所以如果参数只传users的话，下次上传key还是aaa的文件会提示存在同名文件，不能上传。
    //传users:aaa的话，可以覆盖更新，但实测延迟较长，我上传同名新文件上去，下载下来的还是老文件。
    
    NSString * name = [NSString stringWithFormat:@"%@:%@",bucketName,@"image/aaa.png"];
    
    [dic setObject:name forKey:@"scope"];//根据
    
    [dic setObject:deadlineNumber forKey:@"deadline"];
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * json = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return json;
}


- (IBAction)updata:(id)sender {
    
    //zhwios 空间Token
//    self.token = @"e5n_3lw0d3BtkWLTTvefJavLtCldOTVPJAdem0vp:MOckxDQ4eegvfVMI4XK8hA7l4P8=:eyJzY29wZSI6Inpod2lvczp6aHVob25nd2VpIiwiZGVhZGxpbmUiOjE0NjYxMzU5MTl9";
//    self.token = @"e5n_3lw0d3BtkWLTTvefJavLtCldOTVPJAdem0vp:FWJEaDCVLY0QSZMJosIgHGegsHo=:eyJzY29wZSI6Imhvbmd6aGFuZyIsImRlYWRsaW5lIjoxNDY3NjMyOTc0fQ==";
    
    QNUploadManager *  maneget = [[QNUploadManager alloc] init];
    
    UIImage * image = [UIImage imageNamed:@"meinv.png"];
    NSData * data = UIImageJPEGRepresentation(image, 1);
    [maneget putData:data
                 key:@"image/aaa.png"
               token:self.token
            complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                NSLog(@"%@", info);
                NSLog(@"%@", resp);
                
            } option:nil];
}
////////////////////////////////////////////////////////////////////////////////////

- (NSString*)originbase64:(NSString*)originStr
{
    NSData* originData = [originStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString* encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    //    NSLog(@"encodeResult:%@",encodeResult);
    //
    //    NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:encodeResult options:0];
    //
    //    NSString* decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    
    return encodeResult;
}
@end
