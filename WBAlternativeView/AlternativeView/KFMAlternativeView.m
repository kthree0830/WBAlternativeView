//
//  KFMAlternativeView.m
//  WBAlternativeView
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 mac. All rights reserved.
//


#import "KFMAlternativeView.h"
#import "KFMAlternativeButton.h"

@interface KFMAlternativeView ()<CAAnimationDelegate>
@property (nonatomic, weak)UIVisualEffectView *backView;//毛玻璃
@property (nonatomic, weak)UIScrollView *scorllView;
@property (nonatomic, weak)UIView *bottomView;//底部返回按钮父视图
@property (nonatomic, weak)UIButton *returnBtn;//返回上一页按钮
@property (nonatomic, weak)UIButton *closeBtn;//关闭按钮

@property (nonatomic, weak)NSLayoutConstraint *closeButtonCenterXCons;
@property (nonatomic, weak)NSLayoutConstraint *returnButtonCenterXCons;

@property (nonatomic, copy) CompletionBlock completion;
@end

@implementation KFMAlternativeView
+ (instancetype)alternativeView {
    return [[self alloc]init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = UIScreen.mainScreen.bounds;
        [self setupUI];
    }
    return self;
}
- (void)showCompletion:(CompletionBlock)completion {
    self.completion = completion;
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    [vc.view addSubview:self];
    
    [self showCurrentView];
}
#pragma mark - events
- (void)clickMore {
    [self.scorllView setContentOffset:CGPointMake(self.scorllView.bounds.size.width, 0) animated:YES];
    
    self.returnBtn.hidden = NO;
    
    CGFloat margin = self.scorllView.bounds.size.width / 6;
    
    self.closeButtonCenterXCons.constant += margin;
    self.returnButtonCenterXCons.constant -= margin;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}
- (void)close {
    [self hideButtons];
}
- (void)clickButton:(KFMAlternativeButton *)selectedButton {
    NSInteger page = self.scorllView.contentOffset.x / self.scorllView.bounds.size.width;
    UIView *v = self.scorllView.subviews[page];
    

    [v.subviews enumerateObjectsUsingBlock:^(__kindof KFMAlternativeButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CGFloat scale = (selectedButton == obj) ? 2 : 0.2;
        scaleAnim.toValue = @(scale);
        
        CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnim.fromValue = @0.2;
        alphaAnim.toValue = @0.5;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[scaleAnim,alphaAnim];
        group.duration = 0.5;
        
        [obj.layer addAnimation:group forKey:nil];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.completion((UIButton *)selectedButton);
    });
    
    
}
- (void)clickReturn {
    [self.scorllView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.closeButtonCenterXCons.constant = 0;
    self.returnButtonCenterXCons.constant = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
        self.returnBtn.alpha = 0;
    } completion:^(BOOL finished) {
        self.returnBtn.hidden = YES;
        self.returnBtn.alpha = 1;
    }];
}
#pragma mark -  Animation
- (void)showCurrentView {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.duration = 0.25;
    [self.layer addAnimation:anim forKey:nil];
    
    [self showButtons];
}
- (void)showButtons {
    UIView *v = self.scorllView.subviews.firstObject;
    for (NSInteger i = 0; i < v.subviews.count; i++) {
        KFMAlternativeButton *btn = v.subviews[i];
        CASpringAnimation *anim = [CASpringAnimation animationWithKeyPath:@"position.y"];
        anim.fromValue = @(btn.center.y + 350);
        anim.toValue = @(btn.center.y);
        anim.mass = 0.25; //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
        anim.stiffness = 40; //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
        anim.damping = 5;//阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
        anim.initialVelocity = 2;
        anim.beginTime = CACurrentMediaTime() + i * 0.025;
        anim.duration = anim.settlingDuration;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [btn.layer addAnimation:anim forKey:nil];
    }
    
}
- (void)hideButtons {
    NSInteger page = self.scorllView.contentOffset.x / self.scorllView.bounds.size.width;
    UIView *v = self.scorllView.subviews[page];
    
    NSInteger count = v.subviews.count;
    
    for (NSInteger index = count; index > 0; index--) {
        KFMAlternativeView *btn = v.subviews[index - 1];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
        anim.fromValue = @(btn.center.y);
        anim.toValue = @(btn.center.y + 350);
        anim.beginTime = CACurrentMediaTime() + (v.subviews.count - index) * 0.025;
        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;
        [btn.layer addAnimation:anim forKey:nil];
    }
    [self hideCurrentView];
    
}
- (void)hideCurrentView {
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
#pragma mark -  UI
- (void)setupUI {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *backView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    backView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.clipsToBounds = NO;
    scrollView.bounces = NO;
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [closeBtn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [returnBtn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_return"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(clickReturn) forControlEvents:UIControlEventTouchUpInside];
    returnBtn.hidden = YES;
    
    [self addSubview:backView];
    [backView addSubview:scrollView];
    [backView addSubview:bottomView];
    [bottomView addSubview:closeBtn];
    [bottomView addSubview:returnBtn];
    
    self.backView = backView;
    self.scorllView = scrollView;
    self.bottomView = bottomView;
    self.closeBtn = closeBtn;
    self.returnBtn = returnBtn;
    
    [self configSubLayout];
    
    [self layoutIfNeeded];
    
    [self setupSubViews];
    
}
- (void)setupSubViews {
    CGRect rect = self.scorllView.bounds;
    CGFloat width = self.scorllView.bounds.size.width;
    //向scrollview上放两个大的view
    NSInteger i = 0;
    while (i < 2) {
        UIView *v = [[UIView alloc]initWithFrame:CGRectOffset(rect, i * width, 0)];
        v.clipsToBounds = NO;
        [self addButtonsWithView:v index:(i * 6)];
        [self.scorllView addSubview:v];
        i++;
    }
    [self.scorllView setContentSize:CGSizeMake(2 * width, 0)];
    self.scorllView.scrollEnabled = NO;
}
- (void)addButtonsWithView:(UIView *)v index:(NSInteger)idx {
    NSInteger count = 6 + idx;
    for (; idx < count; idx++) {
        if (idx >= self.infoList.count) {
            break;
        }
        NSDictionary *dict = self.infoList[idx];
        NSString *imageName = [dict objectForKey:@"imageName"];
        NSString *title = [dict objectForKey:@"title"];
        NSString *actionName = [dict objectForKey:@"actionName"];
        
        KFMAlternativeButton *btn = [KFMAlternativeButton alternativeButtonWithImageName:imageName title:title];
        [v addSubview:btn];
        
        if (actionName.length > 0) {
            [btn addTarget:self action:NSSelectorFromString(actionName) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    CGSize btnSize = CGSizeMake(100, 100);
    CGFloat margin = (v.bounds.size.width - 3 * btnSize.width) / 4;
    
    [v.subviews enumerateObjectsUsingBlock:^(__kindof KFMAlternativeButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat y = idx > 2 ? (v.bounds.size.height - btnSize.height) : 0;
        NSInteger col = idx % 3;
        
        CGFloat x = (col + 1) * margin + col * btnSize.width;
        obj.frame = CGRectMake(x, y, btnSize.width, btnSize.height);
    }];
    
}
- (void)configSubLayout {
    NSLayoutConstraint *backTopC = [NSLayoutConstraint constraintWithItem:_backView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0];
    NSLayoutConstraint *backLeftC = [NSLayoutConstraint constraintWithItem:_backView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0];
    NSLayoutConstraint *backRightC = [NSLayoutConstraint constraintWithItem:_backView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0];
    NSLayoutConstraint *backBottomC = [NSLayoutConstraint constraintWithItem:_backView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0];
    [self addConstraints:@[backTopC,backLeftC,backRightC,backBottomC]];
    
    
    CGFloat bottomViewHight = 44;
    NSLayoutConstraint *bottomViewLeftC = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomView.superview
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:0];
    NSLayoutConstraint *bottomViewRightC = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomView.superview
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    NSLayoutConstraint *bottomViewBottomC = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomView.superview
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:0];
    NSLayoutConstraint *bottomViewHightC = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:bottomViewHight];
    [self.bottomView.superview addConstraints:@[bottomViewLeftC,bottomViewRightC,bottomViewBottomC]];
    [self.bottomView addConstraint:bottomViewHightC];
    
    CGFloat scrollViewHeight = 228;
    NSLayoutConstraint *scrollViewLeftC = [NSLayoutConstraint constraintWithItem:self.scorllView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.scorllView.superview
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:0];
    NSLayoutConstraint *scorllViewRightC = [NSLayoutConstraint constraintWithItem:self.scorllView
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.scorllView.superview
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:0];
    NSLayoutConstraint *scorllViewBottomC = [NSLayoutConstraint constraintWithItem:self.scorllView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:-56];
    NSLayoutConstraint *scorllViewHightC = [NSLayoutConstraint constraintWithItem:self.scorllView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:scrollViewHeight];
    [self.scorllView.superview addConstraints:@[scrollViewLeftC,scorllViewRightC,scorllViewBottomC]];
    [self.scorllView addConstraint:scorllViewHightC];

    NSLayoutConstraint *closeBtnCXC = [NSLayoutConstraint constraintWithItem:self.closeBtn
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.closeBtn.superview
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0];
    NSLayoutConstraint *closeBtnCYC = [NSLayoutConstraint constraintWithItem:self.closeBtn
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.closeBtn.superview
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0];
    [self.bottomView addConstraints:@[closeBtnCXC,closeBtnCYC]];
    self.closeButtonCenterXCons = closeBtnCXC;
    
    NSLayoutConstraint *returnBtnCXC = [NSLayoutConstraint constraintWithItem:self.returnBtn
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.returnBtn.superview
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0];
    NSLayoutConstraint *returnBtnCYC = [NSLayoutConstraint constraintWithItem:self.returnBtn
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.returnBtn.superview
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0];
    [self.bottomView addConstraints:@[returnBtnCXC,returnBtnCYC]];
    self.returnButtonCenterXCons = returnBtnCXC;
    
}
#pragma mark -  lazy
/**
 数据列表
 */
- (NSArray *)infoList {
    return @[@{@"imageName": @"tabbar_compose_idea", @"title": @"文字", @"clsName": @"WBComposeViewController"},
             @{@"imageName": @"tabbar_compose_photo", @"title": @"照片/视频"},
             @{@"imageName": @"tabbar_compose_weibo", @"title": @"长微博"},
             @{@"imageName": @"tabbar_compose_lbs", @"title": @"签到"},
             @{@"imageName": @"tabbar_compose_review", @"title": @"点评"},
             @{@"imageName": @"tabbar_compose_more", @"title": @"更多", @"actionName": @"clickMore"},
             @{@"imageName": @"tabbar_compose_friend", @"title": @"好友圈"},
             @{@"imageName": @"tabbar_compose_wbcamera", @"title": @"微博相机"},
             @{@"imageName": @"tabbar_compose_music", @"title": @"音乐"},
             @{@"imageName": @"tabbar_compose_shooting", @"title": @"拍摄"}];
}

@end
