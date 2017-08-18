//
//  ViewController.m
//  WBAlternativeView
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "KFMAlternativeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickWriteBtn:(UIButton *)sender {
    KFMAlternativeView *v = [KFMAlternativeView alternativeView];
    [v showCompletion:^(UIButton *a) {
        [v close];
    }];
}

@end
