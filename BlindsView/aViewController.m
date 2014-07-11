//
//  aViewController.m
//  BlindsView
//
//  Created by king454 on 14-7-5.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import "aViewController.h"
#import "BlindsView.h"
@interface aViewController ()

@end

@implementation aViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image1 = [UIImage   imageNamed:@"1.jpg"];
    UIImage *image2 = [UIImage   imageNamed:@"2.jpg"];
    BlindsView *bl =[[BlindsView alloc]initWithAboveImage:image1 withUnderImage:image2 withTotalIndex:5 withFrame:CGRectMake(0, 40, 320, 480)];
    bl.swipeActionTime = 1.0f;
    [self.view addSubview:bl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
