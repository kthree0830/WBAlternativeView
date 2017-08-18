//
//  KFMAlternativeView.h
//  WBAlternativeView
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompletionBlock)(UIButton *);
@interface KFMAlternativeView : UIView
+ (instancetype)alternativeView;
- (void)showCompletion:(CompletionBlock)completion;
- (void)close;
@end
