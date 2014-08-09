//
//  ViewController.m
//  二维码生成和读取demo
//
//  Created by bb_coder on 14/8/9.
//  Copyright (c) 2014年 bb_coder. All rights reserved.
//

#import "ViewController.h"
#import "NSString+QRImage.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UITextFieldDelegate,AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIImageView *outputImage;
@property (weak, nonatomic) IBOutlet UITextView *outPutTextView;


@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _inputTextField.delegate = self;
    _outPutTextView.editable = NO;
	
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    _outputImage.image = [textField.text createQRCode];
    return YES;
}
- (IBAction)scanning:(id)sender {
    [self readQRCoder];
    
}
#pragma mark - 读取二维码
- (void)readQRCoder
{
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
    
    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 4. 拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    // 4.1 设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // 5.1 设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 5.2 设置preview图层的大小
    [preview setFrame:self.view.bounds];
    // 5.3 将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    self.previewLayer = preview;
    
    // 6. 启动会话
    [session startRunning];
    
    self.session = session;
}

#pragma mark - 输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [self.session stopRunning];
    // 2. 删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    NSLog(@"%@", metadataObjects);
    // 3. 设置界面显示扫描结果
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！
        _outPutTextView.text = obj.stringValue;
    }
}

@end
