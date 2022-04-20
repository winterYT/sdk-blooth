//
//  MeasureGuideViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "MeasureGuideViewController.h"

@interface MeasureGuideViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *guide_image;

@end

@implementation MeasureGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.deviceType) {
        case OMRON_BLOOD_9200T:
        {
            [self.navigationItem setTitle:@"添加9200T"];
            self.guide_image.image = [UIImage imageNamed:@"guide_9200T"];
        }
            break;
        case OMRON_BLOOD_U32J:
        {
            [self.navigationItem setTitle:@"添加U32J"];
            self.guide_image.image = [UIImage imageNamed:@"guide_U32J"];
        }
            break;
        case OMRON_BLOOD_J750:
        {
            [self.navigationItem setTitle:@"添加J750"];
            self.guide_image.image = [UIImage imageNamed:@"guide_J750"];
        }
            break;
        case OMRON_BLOOD_U32K:
        {
            [self.navigationItem setTitle:@"添加U32K"];
            self.guide_image.image = [UIImage imageNamed:@"guide_U32J"];
        }
            break;
        case OMRON_BLOOD_J750L:
        {
            [self.navigationItem setTitle:@"添加J750L"];
            self.guide_image.image = [UIImage imageNamed:@"guide_J750"];
        }
            break;
        case OMRON_BLOOD_J730:
        {
            [self.navigationItem setTitle:@"添加J730"];
            self.guide_image.image = [UIImage imageNamed:@"guide_J730"];
        }
            break;
        case OMRON_BLOOD_J761:
        {
           [self.navigationItem setTitle:@"添加J761"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
           break;
        case OMRON_BLOOD_9200L:
         {
             [self.navigationItem setTitle:@"添加9200L"];
             self.guide_image.image = [UIImage imageNamed:@"guide_9200T"];
         }
             break;
        case OMRON_HBF_219T:
        {
            [self.navigationItem setTitle:@"添加HBF_219T"];
            self.guide_image.image = [UIImage imageNamed:@"guide_219T"];
        }
            break;
        case OMRON_BLOOD_U18:
        {
            [self.navigationItem setTitle:@"添加U18"];
            self.guide_image.image = [UIImage imageNamed:@"guide_U18"];
        }
            break;
        case OMRON_BLOOD_J760:
        {
           [self.navigationItem setTitle:@"添加J760"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_T50:
        {
           [self.navigationItem setTitle:@"添加T50"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_U32:
        {
           [self.navigationItem setTitle:@"添加U32"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_J732:
        {
           [self.navigationItem setTitle:@"添加J732"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_J751:
        {
           [self.navigationItem setTitle:@"添加J751"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_U36J:
        {
           [self.navigationItem setTitle:@"添加U36J"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_BLOOD_U36T:
        {
           [self.navigationItem setTitle:@"添加U36T"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_HEM_6231T:
        {
           [self.navigationItem setTitle:@"添加HEM6231T"];
           self.guide_image.image = [UIImage imageNamed:@"guide_J761"];
        }
            break;
        case OMRON_HBF_229T:
        {
            [self.navigationItem setTitle:@"添加HBF_229T"];
            self.guide_image.image = [UIImage imageNamed:@"guide_219T"];
        }
            break;
        default:
            break;
    }
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)btn_next_click:(id)sender {
    if(self.GuideBlock)
    {
        [self GuideBlock](self.deviceType);
//        [self.navigationController popViewControllerAnimated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
