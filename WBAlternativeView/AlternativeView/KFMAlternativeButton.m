//
//  KFMAlternativeButton.m
//  WBAlternativeView
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMAlternativeButton.h"

@interface KFMAlternativeButton ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation KFMAlternativeButton

+ (instancetype)alternativeButtonWithImageName:(NSString *)imageName title:(NSString *)title {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    KFMAlternativeButton *btn = [nib instantiateWithOwner:nil options:nil][0];
    btn.imageView.image = [UIImage imageNamed:imageName];
    btn.titleLabel.text = title;
    return btn;
}

@end
