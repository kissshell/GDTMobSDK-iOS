//
//  NativeExpressAdViewController.m
//  GDTMobApp
//
//  Created by michaelxing on 2017/4/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "NativeExpressVideoAdViewController.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "GDTAppDelegate.h"
#import "NativeExpressVideoConfigView.h"

@interface NativeExpressVideoAdViewController ()<GDTNativeExpressAdDelegete,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *expressAdViews;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;

@property (weak, nonatomic) IBOutlet UITextField *placementIdTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (assign, nonatomic)  float widthSliderValue;
@property (assign, nonatomic)  float heightSliderValue;
@property (assign, nonatomic)  float adCountSliderValue;
@property (nonatomic) float minVideoDuration;
@property (nonatomic) float maxVideoDuration;
@property (nonatomic) BOOL videoAutoPlay;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic) BOOL videoDetailPageVideoMuted;

//切换广告样式
@property (nonatomic, strong) UIAlertController *advStyleAlertController;

@property (nonatomic, strong) UIButton *changAdvStyleButton;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) BOOL useToken;

@end

@implementation NativeExpressVideoAdViewController

static NSString *ABOVEPH_BLOWTEXT_STR = @"1020922903364636";

static NSString *ABOVETEXT_BLOW_PH_STR = @"1070493363284797";

static NSString *TWOPH_AND_TEXT_STR = @"8070996313484739";

static NSString *ONE_PHOTO_STR = @"1010197333187887";

static NSString *Mediator_STR = @"100015";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多视频配置" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToAnotherView)];
    self.widthSliderValue = [UIScreen mainScreen].bounds.size.width;
    self.heightSliderValue = 50;
    self.adCountSliderValue = 3;
    self.minVideoDuration = 5;
    self.maxVideoDuration = 30;
    self.videoMuted = YES;
    self.videoDetailPageVideoMuted = YES;
    self.videoAutoPlay = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"splitnativeexpresscell"];
    [self refreshButton:nil];
}

- (IBAction)selectADVStyle:(id)sender {
    self.advStyleAlertController = [UIAlertController alertControllerWithTitle:@"请选择需要的广告样式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *advTypeTextArray = @[@"上图下文(图片尺寸1280×720)",
                                   @"上文下图(图片尺寸1280×720)",
                                   @"双图双文(大图尺寸1280×720)",
                                   @"纯图片(图片尺寸1280×720)",
                                  @"流量分配"
    ];
    NSArray *advTypePosIDArray = @[ABOVEPH_BLOWTEXT_STR,
                                   ABOVETEXT_BLOW_PH_STR,
                                   TWOPH_AND_TEXT_STR,
                                   ONE_PHOTO_STR,
                                   Mediator_STR];
    for (NSInteger i = 0; i < advTypeTextArray.count; i++) {
        UIAlertAction *advTypeAction = [UIAlertAction actionWithTitle:advTypeTextArray[i]
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
            self.placementIdTextField.placeholder = advTypePosIDArray[i];
            [self refreshViewWithNewPosID];
        }];
        [self.advStyleAlertController addAction:advTypeAction];
    }
    [self presentViewController:self.advStyleAlertController
                       animated:YES
                     completion:^{
        [self clickBackToMainView];
    }];
}

- (void)clickBackToMainView {
    NSArray *arrayViews = [UIApplication sharedApplication].keyWindow.subviews;
    UIView *backToMainView = [[UIView alloc] init];
    for (int i = 1; i < arrayViews.count; i++) {
        NSString *viewNameStr = [NSString stringWithFormat:@"%s",object_getClassName(arrayViews[i])];
        if ([viewNameStr isEqualToString:@"UITransitionView"]) {
            backToMainView = [arrayViews[i] subviews][0];
            break;
        }
    }
//    UIView *backToMainView = [arrayViews.lastObject subviews][0];
    backToMainView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTap)];
    [backToMainView addGestureRecognizer:backTap];
}

- (void)backTap {
    [self.advStyleAlertController dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshViewWithNewPosID {
    NSString *placementId = self.placementIdTextField.text.length > 0? self.placementIdTextField.text: self.placementIdTextField.placeholder;
    if (self.useToken) {
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId token:self.token
                                                                        adSize:CGSizeMake(self.widthSliderValue, self.heightSliderValue)];
    } else {
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId
                                                                        adSize:CGSizeMake(self.widthSliderValue, self.heightSliderValue)];
    }
    self.nativeExpressAd.delegate = self;
    self.nativeExpressAd.maxVideoDuration = self.maxVideoDuration;
    self.nativeExpressAd.minVideoDuration = self.minVideoDuration;
    self.nativeExpressAd.videoMuted = self.videoMuted;
    self.nativeExpressAd.detailPageVideoMuted = self.videoDetailPageVideoMuted;
    self.nativeExpressAd.videoAutoPlayOnWWAN = self.videoAutoPlay;
    [self.nativeExpressAd loadAd:(NSInteger)self.adCountSliderValue];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}

- (IBAction)refreshButton:(id)sender {
    NSString *placementId = self.placementIdTextField.text.length > 0? self.placementIdTextField.text: self.placementIdTextField.placeholder;
    if (self.useToken) {
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId token:self.token
                                                                        adSize:CGSizeMake(self.widthSliderValue, self.heightSliderValue)];
    } else {
        self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId
                                                                        adSize:CGSizeMake(self.widthSliderValue, self.heightSliderValue)];
    }
    self.nativeExpressAd.delegate = self;
    self.nativeExpressAd.maxVideoDuration = self.maxVideoDuration;
    self.nativeExpressAd.minVideoDuration = self.minVideoDuration;
    self.nativeExpressAd.detailPageVideoMuted = self.videoDetailPageVideoMuted;
    self.nativeExpressAd.videoAutoPlayOnWWAN = self.videoAutoPlay;
    self.nativeExpressAd.videoMuted = self.videoMuted;
    [self.nativeExpressAd loadAd:(NSInteger)self.adCountSliderValue];
}

- (void)jumpToAnotherView{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    NativeExpressVideoConfigView *nativeExpressVideoConfigView = [[NativeExpressVideoConfigView alloc]
                                                                     initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                     minVideoDuration:self.minVideoDuration
                                                                     maxVideoDuration:self.maxVideoDuration
                                                                     videoAutoPlay:self.videoAutoPlay
                                                                     videoMuted:self.videoMuted
                                                                     videoDetailPlageMuted:self.videoDetailPageVideoMuted];
    __weak typeof(self) _weakSelf = self;
    nativeExpressVideoConfigView.placementId = self.placementIdTextField.text.length > 0? self.placementIdTextField.text: self.placementIdTextField.placeholder;
    nativeExpressVideoConfigView.widthSlider.value = self.widthSliderValue;
    nativeExpressVideoConfigView.heightSlider.value = self.heightSliderValue;
    nativeExpressVideoConfigView.adCountSlider.value = self.adCountSliderValue;
    nativeExpressVideoConfigView.useTokenSwitch.on = self.useToken;
    nativeExpressVideoConfigView.tokenLabel.text = self.token;
    nativeExpressVideoConfigView.callBackBlock = ^(float widthSliderValue,
                                                      float heightSliderValue,
                                                      float adCountSliderValue,
                                                      BOOL navigationRightButtonIsenabled,
                                                      float minVideoDuration,
                                                      float maxVideoDuration,
                                                      BOOL videoAutoPlay,
                                                      BOOL videoMuted,
                                                      BOOL videoDetailPageVideoMuted) {
        [self.navigationItem.rightBarButtonItem setEnabled:navigationRightButtonIsenabled];
        _weakSelf.minVideoDuration = minVideoDuration;
        _weakSelf.maxVideoDuration = maxVideoDuration;
        _weakSelf.videoAutoPlay = videoAutoPlay;
        _weakSelf.videoMuted = videoMuted;
        _weakSelf.videoDetailPageVideoMuted = videoDetailPageVideoMuted;
        _weakSelf.widthSliderValue = widthSliderValue;
        _weakSelf.heightSliderValue = heightSliderValue;
        _weakSelf.adCountSliderValue = adCountSliderValue;
    };
    nativeExpressVideoConfigView.tokenBlock = ^(BOOL useToken, NSString * _Nonnull token) {
        _weakSelf.useToken = useToken;
        _weakSelf.token = token;
    };
    [nativeExpressVideoConfigView showInView:self.view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

/**
 * 上报给优量汇服务端在开发者客户端竞价中优量汇的竞价结果，以便于优量汇服务端调整策略提供给开发者更合理的报价
 *
 * 优量汇竞价失败调用 biddingLoss，并填入优量汇竞败原因（必填）、竞胜ADN ID（选填）、竞胜ADN报价（选填）
 * 优量汇竞价胜出调用 biddingWin，并填入开发者期望扣费价格（单位分）
 * 请开发者如实上报相关参数，以保证优量汇服务端能根据相关参数调整策略，使开发者收益最大化
*/

- (void)reportBiddingResult:(GDTNativeExpressAd *)ad {
    NSInteger fakeWinPrice = 100;
    GDTAdBiddingLossReason fakeLossReason = GDTAdBiddingLossReasonLowPrice;
    NSString *fakeAdnId = @"WinAdnId";
    NSNumber *flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"debug_setting_bidding_report"];
    NSInteger reportFlag = flag ? [flag integerValue] : 1;
    if (reportFlag == 1) {
        [ad sendWinNotificationWithPrice:fakeWinPrice];
    } else if (reportFlag == 2) {
        [ad sendLossNotificationWithWinnerPrice:fakeWinPrice lossReason:fakeLossReason winnerAdnID:fakeAdnId];
    }
}

#pragma mark - GDTNativeExpressAdDelegete
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    NSLog(@"%s",__FUNCTION__);
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = self;
            [expressView render];
            NSLog(@"eCPM:%ld eCPMLevel:%@ videoDuration:%lf", [expressView eCPM], [expressView eCPMLevel], [expressView videoDuration]);
        }];
    }
    [self.tableView reloadData];
    
    // 在 bidding 结束之后, 调用对应的竟胜/竟败接口
    if (self.useToken) {
        // 针对本次曝光的媒体期望扣费，常用扣费逻辑包括一价扣费与二价扣费
        // 当采用一价扣费时，胜者出价即为本次扣费价格；当采用二价扣费时，第二名出价为本次扣费价格；
        // 自己根据实际情况设置
        [nativeExpressAd setBidECPM:100];
    } else {
        [self reportBiddingResult:nativeExpressAd];
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    [self.tableView reloadData];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    [self.expressAdViews removeObject:nativeExpressAdView];
    [self.tableView reloadData];
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressAdViewWillDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)nativeExpressAdViewDidDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdView:(GDTNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"view:%@ duration:%@ playtime:%@ status:%@ isVideoAd:%@", nativeExpressAdView,@([nativeExpressAdView videoDuration]), @([nativeExpressAdView videoPlayTime]), @(status), @(nativeExpressAdView.isVideoAd));
}

- (void)nativeExpressAdViewWillPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdViewDidPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}
- (void)nativeExpressAdViewWillDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}
- (void)nativeExpressAdViewDidDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)nativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        UIView *view = [self.expressAdViews objectAtIndex:indexPath.row / 2];
        return view.bounds.size.height;
    }
    else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.expressAdViews.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row % 2 == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        UIView *view = [self.expressAdViews objectAtIndex:indexPath.row / 2];
        view.tag = 1000;
        [cell.contentView addSubview:view];
        cell.accessibilityIdentifier = @"nativeVideoTemp_even_ad";
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"splitnativeexpresscell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
        cell.accessibilityIdentifier = @"nativeVideoTemp_odd_ad";
    }
    return cell;
    
}
@end
