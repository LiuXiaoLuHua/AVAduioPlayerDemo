//
//  RingPlayCustomProgressView.m
//  YueWuYou
//
//  Created by XiangTaiMini on 2017/3/22.
//  Copyright © 2017年 HeXiaoBa. All rights reserved.
//

#import "RingPlayCustomProgressView.h"
#import "NSString+Size.h"
#import "UIView+LayoutMethods.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ChooseView.h"

#define PLAYICON_IMAGE [UIImage imageNamed:@"play_open_icon"]
#define STOPICON_IMAGE [UIImage imageNamed:@"play_shut_icon"]
#define PREBTN_ICON [UIImage imageNamed:@"ring_preplay_icon"]
#define NEXTBTN_ICON [UIImage imageNamed:@"ring_nextplay_icon"]

typedef NS_ENUM(NSInteger, PlayType)
{
    PlayTypeOrder = 1, // 顺序播放
    PlayTypeRandom = 2, // 随机播放
    PlayTypeSingleCycle = 3, // 单曲循环
};

@interface RingPlayCustomProgressView ()<ChooseViewDelegate>

@property (nonatomic , weak) UILabel *currentTimeLabel; // 当前播放的时间
@property (nonatomic , weak) UILabel *totalTimeLabel;   // 总的时间数
@property (nonatomic , weak) UILabel *tipsLabel; // 提示语
@property (nonatomic , weak) UIButton *playBtn;  // 播放按钮
@property (nonatomic , weak) UIButton *preBtn;   // 播放前一首按钮
@property (nonatomic , weak) UIButton *nextBtn;  // 播放后一首按钮
@property (nonatomic , weak) UIButton *playOrderBtn; // 选择播放顺序按钮
@property (nonatomic , weak) UISlider *playerSlider; // 播放器拖动条
@property (nonatomic , nullable , strong) AVAudioPlayer *player; // 音频播放器
@property (nonatomic , weak) NSTimer *timer;
@property (nonatomic, nullable, strong) NSArray *musics; // 存放音乐的数组
@property (nonatomic , assign) NSInteger currentMusicIndex; // 当前播放音乐的索引值
@property (nonatomic , assign) PlayType playType; // 播放类型

@end
@implementation RingPlayCustomProgressView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

// 初始化播放器
-(void)initPlayer {
    
    if (self.musics.count <= self.currentMusicIndex) { // 避免数组数量小于当前音乐索引，出现崩溃的情况
        return;
    }
    NSString *currentPlayMusic = self.musics[self.currentMusicIndex];
    if (currentPlayMusic) {
        NSRange range = [currentPlayMusic rangeOfString:@".m"];
        if (range.location != NSNotFound) {
            NSArray *musicNameAndType = [currentPlayMusic componentsSeparatedByString:@".m"];
            if (musicNameAndType.count >= 2) {
                NSString *musicName = musicNameAndType[0];
                NSString *musicType = [NSString stringWithFormat:@".m%@",musicNameAndType[1]];
                
                NSString *path = [[NSBundle mainBundle] pathForResource:musicName ofType:musicType];
                NSURL *url = [NSURL fileURLWithPath:path];
                NSError *error = nil;
                // 初始化音乐播放器
                self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
                if (error) {
                    NSLog(@"error:%@", error);
                }
                // 准备播放
                [self.player prepareToPlay];
                
                NSLog(@"准备播放：%ld", self.currentMusicIndex);

                
                double duration = self.player.duration; // 音乐总长度
                self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration/60, (int)duration%60];
//                self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)self.player.currentTime/60, (int)self.player.currentTime%60];
                
                
                // 设置播放按钮的图片，并且手动调用其点击事件
                [self.playBtn setImage:STOPICON_IMAGE forState:UIControlStateNormal];
                [self playBtnEvent:self.playBtn];
                self.tipsLabel.text = musicName;
            }
        }
    }
    
    
}
// 获取当前播放器的时间
-(void)startTimer {
    //获取当前播放器的时间
    double currentTime = self.player.currentTime;
    
    //设置当前播放时间
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentTime/60, (int)currentTime%60];
    
    //设置播放拖动条的值
    self.playerSlider.value = currentTime/self.player.duration;
    if (currentTime == 0) { // 播放完当前的歌曲 自动切换到下一首
        [self nextBtnEvent:self.nextBtn];
    }
}

#pragma mark - ChooseViewDelegate
-(void)chooseCard:(NSString *)cardStyle {
    
    // 切换播放方式
    [self.playOrderBtn setTitle:cardStyle forState:UIControlStateNormal];
    
    // 把播放顺序先存放到本地，待播放完成之后，再取出这个顺序
    if ([cardStyle isEqualToString:@"顺序播放"]) {
        NSLog(@"顺序播放");
        self.playType = PlayTypeOrder;
    } else if ([cardStyle isEqualToString:@"随机播放"]) {
        NSLog(@"随机播放");
        self.playType = PlayTypeRandom;
    } else {  // 单曲循环
        self.playType = PlayTypeSingleCycle;
    }
}

#pragma mark - Private Method
-(void)playBtnEvent:(UIButton *)playBtn { // 播放按钮
    if ([playBtn.currentImage isEqual:PLAYICON_IMAGE]) {
        
        [playBtn setImage:STOPICON_IMAGE forState:UIControlStateNormal];
        [self.player stop];
    } else {
        
        [playBtn setImage:PLAYICON_IMAGE forState:UIControlStateNormal];
        [self createTimer];
        [self.player play];
        NSLog(@"开始播放：%ld", self.currentMusicIndex);
    }
}

-(void)playOrderBtnEvent:(UIButton *)playOrderBtn {
    
    ChooseView *chooseView = [[ChooseView alloc] init];
    chooseView.contents = @[@"顺序播放",@"随机播放",@"单曲循环"];
    chooseView.targetView = (UIButton *)playOrderBtn;
    chooseView.delegate = self;
    [chooseView show];
}

-(void)preBtnEvent:(UIButton *)preBtn { // 切换到前一首
    self.currentMusicIndex--;
    if (self.currentMusicIndex < 0) {
        self.currentMusicIndex = self.musics.count - 1;
    }
    
    [self initPlayer];
}

-(void)nextBtnEvent:(UIButton *)nextBtn {  // 切换到后一首
    
    [self nextSongIndex];
    
    [self initPlayer];
}

- (void)nextSongIndex
{
    switch (self.playType) {
        case PlayTypeOrder:
            self.currentMusicIndex++;
            self.currentMusicIndex = self.currentMusicIndex % self.musics.count ;
            break;
            
        case PlayTypeRandom:
            self.currentMusicIndex = (arc4random() % self.musics.count);
            break;
            
        case PlayTypeSingleCycle:
            // index不变
            break;
            
        default:
            break;
    }
}

- (NSString *)title
{
    NSString *title = nil;
    switch (self.playType) {
        case PlayTypeOrder:
            title = @"顺序播放";
            break;
            
        case PlayTypeRandom:
            title = @"随机播放";
            break;
            
        case PlayTypeSingleCycle:
            title = @"单曲循环";
            break;
            
        default:
            break;
    }
    
    return title;
}

// 播放器播放进度改变
-(void)playerSliderValueChanged:(UISlider *)sender {
    
    self.player.currentTime = sender.value * self.player.duration;
}

- (void)playerSliderEnd:(UISlider *)sender
{
    if (sender.value == 1) { // 滑动到进度条末端，当前歌曲结束，切换至下一首
        [self nextBtnEvent:self.nextBtn];
    }
}

-(void)setupViews {
    
    self.currentTimeLabel = [self setupLabelWithFontSize:13];
    self.currentTimeLabel.text = @"00:00"; // 要根据当前时间的值计算标签的宽度
    
    self.totalTimeLabel = [self setupLabelWithFontSize:13];
    
    self.tipsLabel = [self setupLabelWithFontSize:16];
    
    // 默认顺序播放
    self.playType = PlayTypeOrder;
    
    UIButton *playOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playOrderBtn.backgroundColor = [UIColor yellowColor];
    [playOrderBtn addTarget:self action:@selector(playOrderBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [playOrderBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [playOrderBtn setTitle:[self title] forState:UIControlStateNormal];
    playOrderBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:playOrderBtn];
    self.playOrderBtn = playOrderBtn;
    
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [preBtn setImage:PREBTN_ICON forState:UIControlStateNormal];
    [preBtn addTarget:self action:@selector(preBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:preBtn];
    self.preBtn = preBtn;
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn addTarget:self action:@selector(playBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    self.playBtn = playBtn;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setImage:NEXTBTN_ICON forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    self.nextBtn = nextBtn;
    
    UISlider *playerSlider = [[UISlider alloc] init];
    playerSlider.tintColor = [UIColor colorWithRed:56 / 255.0 green:208 / 255.0 blue:138 / 255.0 alpha:1];
    [playerSlider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [playerSlider addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [playerSlider addTarget:self action:@selector(playerSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playerSlider];
    self.playerSlider = playerSlider;
    
    [self initPlayer];
}

-(void)createTimer {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
}

-(void)destoryTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)dealloc {
    [self destoryTimer];
}

-(UILabel *)setupLabelWithFontSize:(CGFloat)fontSize {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    return label;
}

- (NSArray *) musics {
    
    if (!_musics) {
        _musics = [[NSArray alloc] initWithObjects:@"G.E.M. 邓紫棋 - 泡沫.mp3",@"李克勤 - 月半小夜曲.mp3",@"张译 - 稳稳的幸福.mp3",@"情非得已.mp3",nil];
    }
    return _musics;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat currentTimeW = [self.currentTimeLabel.text stringSizeWithFontFloat:13].width;
    CGFloat currentTimeH = 20;
    CGFloat currentTimeX = 10;
    CGFloat currentTimeY = self.height - 150;
    self.currentTimeLabel.frame = CGRectMake(currentTimeX, currentTimeY, currentTimeW, currentTimeH);
    
    CGFloat totalTimeW = [self.totalTimeLabel.text stringSizeWithFontFloat:13].width;
    CGFloat totalTimeH = 20;
    CGFloat totalTimeX = SCREEN_WIDTH - totalTimeW - 10;
    CGFloat totalTimeY = self.currentTimeLabel.top;
    self.totalTimeLabel.frame = CGRectMake(totalTimeX, totalTimeY, totalTimeW, totalTimeH);
    
    CGFloat playerSliderW = SCREEN_WIDTH - self.currentTimeLabel.width - self.totalTimeLabel.width - 40;
    CGFloat playerSliderH = 20;
    CGFloat playerSliderX = self.currentTimeLabel.right + 10;
    CGFloat playerSliderY = self.currentTimeLabel.top;
    self.playerSlider.frame = CGRectMake(playerSliderX, playerSliderY, playerSliderW, playerSliderH);
    
    CGFloat tipW = [self.tipsLabel.text stringSizeWithFontFloat:16].width;
    CGFloat tipH = 20;
    CGFloat tipX = (SCREEN_WIDTH - tipW) / 2;
    CGFloat tipY = self.playerSlider.bottom + 10;
    self.tipsLabel.frame = CGRectMake(tipX, tipY, tipW, tipH);
    
    CGFloat playOrderW = 60;
    CGFloat playOrderH = 40;
    CGFloat playOrderX = 20;
    CGFloat playOrderY = self.tipsLabel.bottom + 20;
    self.playOrderBtn.frame = CGRectMake(playOrderX, playOrderY, playOrderW, playOrderH);
    
    CGFloat playW = PLAYICON_IMAGE.size.width;
    CGFloat playH = PLAYICON_IMAGE.size.height;
    CGFloat playX = (SCREEN_WIDTH - playW) / 2;
    CGFloat playY = self.tipsLabel.bottom + 10;
    self.playBtn.frame = CGRectMake(playX, playY, playW, playH);
    
    CGFloat preW = PREBTN_ICON.size.width;
    CGFloat preH = PREBTN_ICON.size.height;
    CGFloat preX = self.playBtn.left - preW - 10;
    CGFloat preY = self.playBtn.center.y - preH / 2;
    self.preBtn.frame = CGRectMake(preX, preY, preW, preH);
    
    CGFloat nextW = NEXTBTN_ICON.size.width;
    CGFloat nextH = NEXTBTN_ICON.size.height;
    CGFloat nextX = self.playBtn.right + 10;
    CGFloat nextY = self.playBtn.center.y - preH / 2;
    self.nextBtn.frame = CGRectMake(nextX, nextY, nextW, nextH);
}

@end
