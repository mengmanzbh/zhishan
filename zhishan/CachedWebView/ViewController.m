//
//  ViewController.m
//  CachedWebView
//
//  Created by Robert Napier on 1/29/12.
//  Copyright (c) 2012 Rob Napier.
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "ViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "JSONKit.h"
#import "UIImage+Resize.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface ViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) NSString *funcId;
@property (strong, nonatomic) NSString *callback;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSString *bgcolor;
@property (strong, nonatomic) NSString *center;
@property (strong, nonatomic) NSString *fontcolor;
@property (strong, nonatomic) NSString *fontsize;
@property (strong, nonatomic) NSString *height;
@property (strong, nonatomic) NSString *left;
@property (strong, nonatomic) NSString *leftclick;
@property (strong, nonatomic) NSString *right;
@property (strong, nonatomic) NSString *rightclick;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UILabel *centertitle;
@property (strong, nonatomic) UIButton *leftbtn;
@property (strong, nonatomic) UIButton *rightbtn;
@property (strong, nonatomic) NSDictionary *BottomimageArr;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *firstTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitle;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle;
@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;
@property (weak, nonatomic) IBOutlet UIImageView *fourImage;
@property (weak, nonatomic) IBOutlet NSMutableDictionary *dicdata;
@property (nonatomic, assign) BOOL isEdit;
@property (strong, nonatomic) UIView *statusBarView;
@end

@implementation ViewController
- (void)clearWebCache{
    NSLog(@"clearWebCache");
    //获取缓存大小。。
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    CGFloat fileSize = [self folderSizeAtPath:cachPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",[NSString stringWithFormat:@"%.2fMB",fileSize]);
        
    });
    //缓存大于200M，执行清除
    if (fileSize > 3) {
        [self myClearCacheAction];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 20)];
    self.statusBarView.backgroundColor =  [self getColor:@"00b686"];
    [self.view addSubview:self.statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    
    self.isEdit = NO;
    rootView = self.view;
    self.navigationController.navigationBar.hidden  = YES;
    self.tabBarController.tabBar.hidden  = YES;
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    self.webView2.backgroundColor = [UIColor clearColor];

    self.webView2 = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-20)];
    self.webView2.scrollView.bounces = NO;
    self.webView2.delegate = self;
    [self.view addSubview:self.webView2];
    self.webView2.hidden = YES;
    
    //第一次启动app,引导图显示
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        NSLog(@"第一次启动");
        self.webView2.hidden = YES;
        [self showIntroWithCustomView];
    }else{
        NSLog(@"不是第一次启动");
        NSString *lasturl = [[NSUserDefaults standardUserDefaults] objectForKey:@"lasturl"];
        [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:lasturl]]];
        self.webView2.hidden = NO;
    }

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearWebCache) userInfo:nil repeats:YES];
    
    
    //头部创建
    self.headView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 40)];
    self.centertitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
    self.headView.hidden = YES;
    [self.view addSubview:self.headView];
    //    [self.view insertSubview:self.headView belowSubview:self.intro];
    
    //底部创建
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)- 55, CGRectGetWidth(self.view.bounds), 53);
    //底部线条
    UIView *bottomline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 1)];
    bottomline.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.bottomView addSubview:bottomline];
    
    self.bottomView.backgroundColor = [UIColor whiteColor];
    CGFloat w = CGRectGetWidth(self.view.bounds);
    self.firstTitle.frame = CGRectMake(0, 40, w/4, 12);
    self.firstImage.frame = CGRectMake(0, 40, w/4, 12);
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];
    
    for (NSInteger i = 0; i<1; i++)
    {
        for (NSInteger j = 0; j<4; j++)
        {
            UIButton* numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
            numberButton.frame = CGRectMake(self.view.bounds.size.width/4*j, 0, self.view.bounds.size.width/4 - 1, 50.0f);
            NSInteger numberNum = i*4+j+0;
            [numberButton addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
            numberButton.tag = 1000 + numberNum;
            //红点通知
            UIView *reddot = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(numberButton.bounds) - 39,4, 10, 10)];
            reddot.backgroundColor = [UIColor redColor];
            reddot.tag = 10 + numberNum;
            reddot.hidden = YES;
            reddot.layer.cornerRadius = 5;
            [numberButton addSubview:reddot];
            
            [numberButton setBackgroundColor:[UIColor clearColor]];
            [self.bottomView addSubview:numberButton];
        }
        
    }
    
    NSArray *titleArr = @[@"信息",@"快捷",@"应用",@"个人"];
    for (NSInteger i = 0; i<1; i++)
    {
        for (NSInteger j = 0; j<4; j++)
        {
            UILabel* title = [[UILabel alloc]init];
            title.frame = CGRectMake(self.view.bounds.size.width/4*j, 35, self.view.bounds.size.width/4 - 1, 10.0f);
            NSInteger numberNum = i*4+j+0;
            title.text = [titleArr objectAtIndex:j];
            title.textAlignment = NSTextAlignmentCenter;
            title.font = [UIFont systemFontOfSize:13];
            title.textColor = [self getColor:@"04AC72"];
            title.tag = 100 + numberNum;
//            [self.bottomView addSubview:title];
        }
    }
    
    
}
//底部按钮点击事件
- (void)actionClick:(UIButton *)btn{
    NSArray *imgArr = [self.BottomimageArr objectForKey:@"list"];
    NSString *tagstr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    NSString *tag = [tagstr substringWithRange:NSMakeRange(3, 1)];
    NSString *url = [[imgArr objectAtIndex:[tag intValue]] objectForKey:@"url"];
    [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]]];
    
    if ([tag isEqualToString:@"0"]) {
        //第一个按钮高亮，其他正常
        UIButton *firstbtn = [self.bottomView viewWithTag:1000];
        UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"spic"]]]];
        [firstbtn setImage:img0 forState:UIControlStateNormal];
        [firstbtn setImage:img0 forState:UIControlStateHighlighted];
        
        UIButton *secondbtn = [self.bottomView viewWithTag:1001];
        UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"pic"]]]];
        [secondbtn setImage:img1 forState:UIControlStateNormal];
        [secondbtn setImage:img1 forState:UIControlStateHighlighted];
        
        UIButton *thirdbtn = [self.bottomView viewWithTag:1002];
        UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"pic"]]]];
        [thirdbtn setImage:img2 forState:UIControlStateNormal];
        [thirdbtn setImage:img2 forState:UIControlStateHighlighted];
        
        UIButton *fourbtn = [self.bottomView viewWithTag:1003];
        UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"pic"]]]];
        [fourbtn setImage:img3 forState:UIControlStateNormal];
        [fourbtn setImage:img3 forState:UIControlStateHighlighted];
        
        //设置字体颜色
        UILabel *tilte0 = [self.bottomView viewWithTag:100];
        tilte0.textColor = [UIColor grayColor];
        UILabel *tilte1 = [self.bottomView viewWithTag:101];
        tilte1.textColor = [self getColor:@"04AC72"];
        UILabel *tilte2 = [self.bottomView viewWithTag:102];
        tilte2.textColor = [self getColor:@"04AC72"];
        UILabel *tilte3 = [self.bottomView viewWithTag:103];
        tilte3.textColor =  [self getColor:@"04AC72"];
    }
    
    if ([tag isEqualToString:@"1"]) {
        //第二个按钮高亮，其他正常
        UIButton *firstbtn = [self.bottomView viewWithTag:1000];
        UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"pic"]]]];
        [firstbtn setImage:img0 forState:UIControlStateNormal];
        [firstbtn setImage:img0 forState:UIControlStateHighlighted];
        
        UIButton *secondbtn = [self.bottomView viewWithTag:1001];
        UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"spic"]]]];
        [secondbtn setImage:img1 forState:UIControlStateNormal];
        [secondbtn setImage:img1 forState:UIControlStateHighlighted];
        
        UIButton *thirdbtn = [self.bottomView viewWithTag:1002];
        UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"pic"]]]];
        [thirdbtn setImage:img2 forState:UIControlStateNormal];
        [thirdbtn setImage:img2 forState:UIControlStateHighlighted];
        
        UIButton *fourbtn = [self.bottomView viewWithTag:1003];
        UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"pic"]]]];
        [fourbtn setImage:img3 forState:UIControlStateNormal];
        [fourbtn setImage:img3 forState:UIControlStateHighlighted];
        
        //设置字体颜色
        UILabel *tilte0 = [self.bottomView viewWithTag:100];
        tilte0.textColor = [self getColor:@"04AC72"];
        UILabel *tilte1 = [self.bottomView viewWithTag:101];
        tilte1.textColor = [UIColor grayColor];
        UILabel *tilte2 = [self.bottomView viewWithTag:102];
        tilte2.textColor = [self getColor:@"04AC72"];
        UILabel *tilte3 = [self.bottomView viewWithTag:103];
        tilte3.textColor =  [self getColor:@"04AC72"];
        
    }
    
    if ([tag isEqualToString:@"2"]) {
        //第三个按钮高亮，其他正常
        UIButton *firstbtn = [self.bottomView viewWithTag:1000];
        UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"pic"]]]];
        [firstbtn setImage:img0 forState:UIControlStateNormal];
        [firstbtn setImage:img0 forState:UIControlStateHighlighted];
        
        UIButton *secondbtn = [self.bottomView viewWithTag:1001];
        UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"pic"]]]];
        [secondbtn setImage:img1 forState:UIControlStateNormal];
        [secondbtn setImage:img1 forState:UIControlStateHighlighted];
        
        UIButton *thirdbtn = [self.bottomView viewWithTag:1002];
        UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"spic"]]]];
        [thirdbtn setImage:img2 forState:UIControlStateNormal];
        [thirdbtn setImage:img2 forState:UIControlStateHighlighted];
        
        UIButton *fourbtn = [self.bottomView viewWithTag:1003];
        UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"pic"]]]];
        [fourbtn setImage:img3 forState:UIControlStateNormal];
        [fourbtn setImage:img3 forState:UIControlStateHighlighted];
        
        //设置字体颜色
        UILabel *tilte0 = [self.bottomView viewWithTag:100];
        tilte0.textColor = [self getColor:@"04AC72"];
        UILabel *tilte1 = [self.bottomView viewWithTag:101];
        tilte1.textColor = [self getColor:@"04AC72"];
        UILabel *tilte2 = [self.bottomView viewWithTag:102];
        tilte2.textColor = [UIColor grayColor];
        UILabel *tilte3 = [self.bottomView viewWithTag:103];
        tilte3.textColor =  [self getColor:@"04AC72"];
    }
    
    if ([tag isEqualToString:@"3"]) {
        //第四个按钮高亮，其他正常
        UIButton *firstbtn = [self.bottomView viewWithTag:1000];
        UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"pic"]]]];
        [firstbtn setImage:img0 forState:UIControlStateNormal];
        [firstbtn setImage:img0 forState:UIControlStateHighlighted];
        
        UIButton *secondbtn = [self.bottomView viewWithTag:1001];
        UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"pic"]]]];
        [secondbtn setImage:img1 forState:UIControlStateNormal];
        [secondbtn setImage:img1 forState:UIControlStateHighlighted];
        
        UIButton *thirdbtn = [self.bottomView viewWithTag:1002];
        UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"pic"]]]];
        [thirdbtn setImage:img2 forState:UIControlStateNormal];
        [thirdbtn setImage:img2 forState:UIControlStateHighlighted];
        
        UIButton *fourbtn = [self.bottomView viewWithTag:1003];
        UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"spic"]]]];
        [fourbtn setImage:img3 forState:UIControlStateNormal];
        [fourbtn setImage:img3 forState:UIControlStateHighlighted];
        
        //设置字体颜色
        UILabel *tilte0 = [self.bottomView viewWithTag:100];
        tilte0.textColor = [self getColor:@"04AC72"];
        UILabel *tilte1 = [self.bottomView viewWithTag:101];
        tilte1.textColor = [self getColor:@"04AC72"];
        UILabel *tilte2 = [self.bottomView viewWithTag:102];
        tilte2.textColor = [self getColor:@"04AC72"];
        UILabel *tilte3 = [self.bottomView viewWithTag:103];
        tilte3.textColor =  [UIColor grayColor];
    }
    
}
#pragma mark 调用相机方法
- (void)showCamera{
    
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(300, 300);
    self.imagePicker.delegate = self;
    self.imagePicker.resizeableCropArea = NO;
    
    
    //先判断是否有权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机权限未开启?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;//摄像机
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//相册
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
        
    }];
    [alert addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
# pragma mark GKImagePicker Delegate Methods
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    
    UIImage *reimg = [image resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES];
    NSLog(@"图片大小:%@",NSStringFromCGSize(reimg.size));
    NSData *imageData = UIImageJPEGRepresentation(reimg, 0.1);
    NSString *encodedString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *jsScript = [NSString stringWithFormat:@"iosCallJs('103','%@')",encodedString];
    [self.webView2 stringByEvaluatingJavaScriptFromString:jsScript];
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    
    NSString *url = [NSString stringWithFormat:@"%@",request.URL];
    NSLog(@"打开的链接:%@",url);
    //404页面处理
    static BOOL isRequestWeb = YES;
    if (isRequestWeb) {
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request   returningResponse:&response error:nil];
        if (response.statusCode == 404) {
            NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"nofound" ofType:@"html"];
            [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:htmlPath]]];
            self.headView.hidden = YES;
            return NO;
        }
    }
    

    return YES;
}
//左边文字点击
- (void)lefttitleClick:(UIButton *)btn{
    
    if ([self.leftclick rangeOfString:@"http"].location != NSNotFound) {
        NSLog(@"左边直接跳转");
        NSString *url1 = self.leftclick;
        [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url1]]];
        
    }else{
        NSLog(@"左边JS调用");
        NSString *jsScript = self.leftclick;
        [self.webView2 stringByEvaluatingJavaScriptFromString:jsScript];
    }
}
//右边文字点击
- (void)righttitleClick:(UIButton *)btn{
    
    if ([self.rightclick rangeOfString:@"http"].location != NSNotFound) {
        NSLog(@"右边直接跳转");
        NSString *url1 = self.rightclick;
        [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url1]]];
    }else{
        NSLog(@"右边JS调用");
        NSString *jsScript = self.rightclick;
        [self.webView2 stringByEvaluatingJavaScriptFromString:jsScript];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    //保存最后网址
    NSString *url = [NSString stringWithFormat:@"%@",webView.request.URL];
    [[NSUserDefaults standardUserDefaults]setObject:url forKey:@"lasturl"];
    //底部处理
    if ([url rangeOfString:@"funcId=101"].location != NSNotFound) {
        NSString *jsScript = @"callKeyApp(btm_1)";
        [self.webView2 stringByEvaluatingJavaScriptFromString:jsScript];
    }
    
    JSContext *context = [self.webView2 valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
   //头部
    context[@"jsCallIos100"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSString *result = jsVal.toString;
            NSDictionary *params = [result objectFromJSONString];
            self.bgcolor = [params objectForKey:@"bgcolor"];
            self.center = [params objectForKey:@"center"];
            self.fontcolor = [params objectForKey:@"fontcolor"];
            self.fontsize = [params objectForKey:@"fontsize"];
            self.height = [params objectForKey:@"height"];
            self.left = [params objectForKey:@"left"];
            self.leftclick = [params objectForKey:@"leftclick"];
            self.right = [params objectForKey:@"right"];
            self.rightclick = [params objectForKey:@"rightclick"];
            
            //高度修改
            CGFloat height = [self.height floatValue];
            self.headView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), height);
            
            self.webView2.frame = CGRectMake(0, height+20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-height-20);
            
            self.headView.backgroundColor = [self getColor:self.bgcolor];
            self.statusBarView.backgroundColor =  [self getColor:self.bgcolor];
            //中间文字
            self.centertitle.text = self.center;
            self.centertitle.font = [UIFont boldSystemFontOfSize:[self.fontsize floatValue]];
            self.centertitle.textColor = [self getColor:self.fontcolor];
            self.centertitle.textAlignment = NSTextAlignmentCenter;
            [self.headView addSubview:self.centertitle];
            
            //左边
            if ([self.left rangeOfString:@"http"].location != NSNotFound) {
                NSLog(@"图片的情况");
                [self.leftbtn removeFromSuperview];
                self.leftbtn = [[UIButton alloc]initWithFrame:CGRectMake(3, 2, 50, 40)];
                self.leftbtn.imageEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 10);
                NSURL *url = [NSURL URLWithString:self.left];
                [self.leftbtn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] forState:UIControlStateNormal];
                [self.leftbtn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] forState:UIControlStateHighlighted];
                [self.leftbtn addTarget:self action:@selector(lefttitleClick:) forControlEvents:UIControlEventTouchUpInside];
                self.leftbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [self.headView addSubview:self.leftbtn];
            }else{
                NSLog(@"文字");
                [self.leftbtn removeFromSuperview];
                self.leftbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 100, height)];
                [self.leftbtn setTitle:self.left forState:UIControlStateNormal];
                [self.leftbtn setTitleColor:[self getColor:self.fontcolor] forState:UIControlStateNormal];
                self.leftbtn.titleLabel.font = [UIFont boldSystemFontOfSize:[self.fontsize floatValue]];
                [self.leftbtn addTarget:self action:@selector(lefttitleClick:) forControlEvents:UIControlEventTouchUpInside];
                self.leftbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [self.headView addSubview:self.leftbtn];
            }
            
            //右边
            if ([self.right rangeOfString:@"http"].location != NSNotFound) {
                NSLog(@"图片的情况");
                [self.rightbtn removeFromSuperview];
                self.rightbtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 23, 13, 18, 17)];
                NSURL *url = [NSURL URLWithString:self.right];
                [self.rightbtn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] forState:UIControlStateNormal];
                [self.rightbtn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] forState:UIControlStateHighlighted];
                [self.rightbtn addTarget:self action:@selector(righttitleClick:) forControlEvents:UIControlEventTouchUpInside];
                self.rightbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [self.headView addSubview:self.rightbtn];
            }else{
                NSLog(@"文字");
                [self.rightbtn removeFromSuperview];
                self.rightbtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 100, 0, 90, height)];
                [self.rightbtn setTitle:self.right forState:UIControlStateNormal];
                [self.rightbtn setTitleColor:[self getColor:self.fontcolor] forState:UIControlStateNormal];
                self.rightbtn.titleLabel.font = [UIFont boldSystemFontOfSize:[self.fontsize floatValue]];
                [self.rightbtn addTarget:self action:@selector(righttitleClick:) forControlEvents:UIControlEventTouchUpInside];
                self.rightbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [self.headView addSubview:self.rightbtn];
            }
            self.headView.hidden = NO;
        }
        
    };
    //头部隐藏
    context[@"jsCallIos107"] = ^() {
        self.headView.hidden = YES;
        self.webView2.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-20 - 50);
    };
    //底部
    context[@"jsCallIos101"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSString *result = jsVal.toString;
            self.BottomimageArr = [result objectFromJSONString];
            NSDictionary *bottomold = [[NSUserDefaults standardUserDefaults] objectForKey:@"BottomimageArr"];//取缓存数据
            if(!bottomold){
                [[NSUserDefaults standardUserDefaults] setObject:self.BottomimageArr forKey:@"BottomimageArr"];//缓存本地
            }
            
            NSDictionary *bottomArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"BottomimageArr"];//取缓存数据
            
            NSArray *imgArr = [bottomArr objectForKey:@"list"];
            CGFloat h = [[bottomArr objectForKey:@"height"] floatValue];
            self.bottomView.backgroundColor = [self getColor:[bottomArr objectForKey:@"bgcolor"]];
            self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)- h, CGRectGetWidth(self.view.bounds),h);
            self.webView2.frame = CGRectMake(0, 44+20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-44-20-h);
            CGFloat top = 3;
            CGFloat left = 28;
            CGFloat bottom = 2;
            CGFloat right = 28;
            //设置图片
            UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"pic"]]]];
            UIButton *firstbtn = [self.bottomView viewWithTag:1000];
            firstbtn.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            [firstbtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [firstbtn setImage:img0 forState:UIControlStateNormal];
            [firstbtn setImage:img0 forState:UIControlStateHighlighted];
            
            UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"pic"]]]];
            UIButton *secondbtn = [self.bottomView viewWithTag:1001];
            secondbtn.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            [secondbtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [secondbtn setImage:img1 forState:UIControlStateNormal];
            [secondbtn setImage:img1 forState:UIControlStateHighlighted];
            
            UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"pic"]]]];
            UIButton *thirddbtn = [self.bottomView viewWithTag:1002];
            thirddbtn.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            [thirddbtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [thirddbtn setImage:img2 forState:UIControlStateNormal];
            [thirddbtn setImage:img2 forState:UIControlStateHighlighted];
            
            UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"pic"]]]];
            UIButton *fourdbtn = [self.bottomView viewWithTag:1003];
            fourdbtn.imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            [fourdbtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [fourdbtn setImage:img3 forState:UIControlStateNormal];
            [fourdbtn setImage:img3 forState:UIControlStateHighlighted];
            
            //高亮图片
            if([[self.BottomimageArr objectForKey:@"index"] integerValue] == 0){
                UIImage *img0 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:0] objectForKey:@"spic"]]]];
                [firstbtn setImage:img0 forState:UIControlStateNormal];
                [firstbtn setImage:img0 forState:UIControlStateHighlighted];
                //设置字体颜色
                UILabel *tilte0 = [self.bottomView viewWithTag:100];
                tilte0.textColor = [UIColor grayColor];
                UILabel *tilte1 = [self.bottomView viewWithTag:101];
                tilte1.textColor = [self getColor:@"04AC72"];
                UILabel *tilte2 = [self.bottomView viewWithTag:102];
                tilte2.textColor = [self getColor:@"04AC72"];
                UILabel *tilte3 = [self.bottomView viewWithTag:103];
                tilte3.textColor =  [self getColor:@"04AC72"];
            }
            if([[self.BottomimageArr objectForKey:@"index"] integerValue] == 1){
                UIImage *img1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:1] objectForKey:@"spic"]]]];
                [secondbtn setImage:img1 forState:UIControlStateNormal];
                [secondbtn setImage:img1 forState:UIControlStateHighlighted];
                //设置字体颜色
                UILabel *tilte0 = [self.bottomView viewWithTag:100];
                tilte0.textColor = [self getColor:@"04AC72"];
                UILabel *tilte1 = [self.bottomView viewWithTag:101];
                tilte1.textColor =  [UIColor grayColor];
                UILabel *tilte2 = [self.bottomView viewWithTag:102];
                tilte2.textColor = [self getColor:@"04AC72"];
                UILabel *tilte3 = [self.bottomView viewWithTag:103];
                tilte3.textColor =  [self getColor:@"04AC72"];
            }
            if([[self.BottomimageArr objectForKey:@"index"] integerValue] == 2){
                UIImage *img2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:2] objectForKey:@"spic"]]]];
                [thirddbtn setImage:img2 forState:UIControlStateNormal];
                [thirddbtn setImage:img2 forState:UIControlStateHighlighted];
                //设置字体颜色
                UILabel *tilte0 = [self.bottomView viewWithTag:100];
                tilte0.textColor = [self getColor:@"04AC72"];
                UILabel *tilte1 = [self.bottomView viewWithTag:101];
                tilte1.textColor = [self getColor:@"04AC72"];
                UILabel *tilte2 = [self.bottomView viewWithTag:102];
                tilte2.textColor = [UIColor grayColor];
                UILabel *tilte3 = [self.bottomView viewWithTag:103];
                tilte3.textColor =  [self getColor:@"04AC72"];
            }
            if([[self.BottomimageArr objectForKey:@"index"] integerValue] == 3){
                UIImage *img3 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imgArr objectAtIndex:3] objectForKey:@"spic"]]]];
                [fourdbtn setImage:img3 forState:UIControlStateNormal];
                [fourdbtn setImage:img3 forState:UIControlStateHighlighted];
                //设置字体颜色
                UILabel *tilte0 = [self.bottomView viewWithTag:100];
                tilte0.textColor = [self getColor:@"04AC72"];
                UILabel *tilte1 = [self.bottomView viewWithTag:101];
                tilte1.textColor = [self getColor:@"04AC72"];
                UILabel *tilte2 = [self.bottomView viewWithTag:102];
                tilte2.textColor = [self getColor:@"04AC72"];
                UILabel *tilte3 = [self.bottomView viewWithTag:103];
                tilte3.textColor =  [UIColor grayColor];
            }
            
            self.bottomView.hidden = NO;
            

        }
    };
    //底部隐藏
    context[@"jsCallIos102"] = ^() {
        self.bottomView.hidden = YES;
    };
    //调用摄像机
    context[@"jsCallIos103"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSString *result = jsVal.toString;
            NSDictionary *params = [result objectFromJSONString];
            self.funcId = [params valueForKey:@"funcId"];
            self.callback = [params valueForKey:@"callback"];
            [self showCamera];//调用相机
        }
    };
    context[@"jsCallIos104"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSString *msg = jsVal.toString;
            //关闭全部红点
            if ([msg isEqualToString:@""]) {
                UIView *firstRedhot = [self.bottomView viewWithTag:10];
                firstRedhot.hidden = YES;
                UIView *secondRedhot = [self.bottomView viewWithTag:11];
                secondRedhot.hidden = YES;
                UIView *thirdRedhot = [self.bottomView viewWithTag:12];
                thirdRedhot.hidden = YES;
                UIView *fourRedhot = [self.bottomView viewWithTag:13];
                fourRedhot.hidden = YES;
            }
            
            if([msg rangeOfString:@"0"].location != NSNotFound){
                UIView *firstRedhot = [self.bottomView viewWithTag:10];
                firstRedhot.hidden = NO;
            }else{
                UIView *firstRedhot = [self.bottomView viewWithTag:10];
                firstRedhot.hidden = YES;
            }
            
            if([msg rangeOfString:@"1"].location != NSNotFound){
                UIView *secondRedhot = [self.bottomView viewWithTag:11];
                secondRedhot.hidden = NO;
            }else{
                UIView *secondRedhot = [self.bottomView viewWithTag:11];
                secondRedhot.hidden = YES;
            }
            
            if([msg rangeOfString:@"2"].location != NSNotFound){
                UIView *thirdRedhot = [self.bottomView viewWithTag:12];
                thirdRedhot.hidden = NO;
            }else{
                UIView *thirdRedhot = [self.bottomView viewWithTag:12];
                thirdRedhot.hidden = YES;
            }
            
            if([msg rangeOfString:@"3"].location != NSNotFound){
                UIView *fourRedhot = [self.bottomView viewWithTag:13];
                fourRedhot.hidden = NO;
            }else{
                UIView *fourRedhot = [self.bottomView viewWithTag:13];
                fourRedhot.hidden = YES;
            }
        }
    };
    //登录处理
    context[@"jsCallIos105"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSString *result = jsVal.toString;
            self.dicdata = [result objectFromJSONString];
            [[NSUserDefaults standardUserDefaults] setObject:self.dicdata forKey:@"tsdata"];
        }
    };
    context[@"jsCallIos106"] = ^() {
        self.dicdata = nil;
        [[NSUserDefaults standardUserDefaults] setObject:self.dicdata forKey:@"tsdata"];
    };
  
    //调JS
    //        JSContext *context = [self.webView2 valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //        NSString *textJS = @"iosCallJs('100','OK')";
    //        [context evaluateScript:textJS];
    
}
- (void)loadErrorWebView:(BOOL)isshow{
    if (isshow) {
        NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"nofound" ofType:@"html"];
        NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
        NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
        [self.webView2 loadHTMLString:appHtml baseURL:baseURL];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    
    NSLog(@"%@",error);
    //    [self loadErrorWebView:YES];
    
}
#pragma  mark 引导图
- (void)showIntroWithCustomView {
    
    UIImageView *image1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide01.png"]];
    image1.frame = rootView.bounds;
    EAIntroPage *page1 = [EAIntroPage pageWithCustomView:image1];
    
    UIImageView *image2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide02.png"]];
    image2.frame = rootView.bounds;
    EAIntroPage *page2 = [EAIntroPage pageWithCustomView:image2];
    
    CGFloat w = CGRectGetWidth(self.view.bounds);
    UIButton *lastguidebtn = [[UIButton alloc]initWithFrame:CGRectMake((w - 150)/2, rootView.bounds.size.height - 150, 150, 40)];
    [lastguidebtn setImage:[UIImage imageNamed:@"lastguidebtn.png"] forState:UIControlStateNormal];
    [lastguidebtn addTarget:self action:@selector(gotoMain:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *image3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide03.png"]];
    image3.frame = rootView.bounds;
    image3.userInteractionEnabled = YES;
    [image3 addSubview:lastguidebtn];
    EAIntroPage *page3 = [EAIntroPage pageWithCustomView:image3];
    
    UIImageView *image4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide03.png"]];
    image4.frame = rootView.bounds;
    EAIntroPage *page4 = [EAIntroPage pageWithCustomView:image4];
    self.intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3]];
    [self.intro.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    [self.intro setDelegate:self];
    [self.intro showInView:rootView animateDuration:0.3];
}
-(void)gotoMain:(UIButton *)btn{
    [self.intro hideWithFadeOutDuration:0.3];
    NSLog(@"引导结束");
    self.navigationController.navigationBar.hidden  = NO;
    self.tabBarController.tabBar.hidden  = NO;
    NSString *url1 = @"http://www.attop.com/app/index.htm";
    [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url1]]];
    self.webView2.hidden = NO;
    
}
- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"引导结束");
    self.navigationController.navigationBar.hidden  = NO;
    self.tabBarController.tabBar.hidden  = NO;
    NSString *url1 = @"http://www.attop.com/app/index.htm";
    [self.webView2 loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url1]]];
    self.webView2.hidden = NO;
}
#pragma mark === 暂时不用清除缓存=====
-(void)myClearCacheAction{
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       NSLog(@"files :%lu",(unsigned long)[files count]);
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
}
-(void)clearCacheSuccess
{
    NSLog(@"清理成功");
    //获取缓存大小。。
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    CGFloat fileSize = [self folderSizeAtPath:cachPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",[NSString stringWithFormat:@"%.2fMB",fileSize]);
        
    });
    
}
- (CGFloat)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString *fileName = nil;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
    
}
- (UIColor *)getColor:(NSString*)hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}
@end
