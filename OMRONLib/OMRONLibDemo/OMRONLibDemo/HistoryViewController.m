//
//  HistoryViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "BFHistoryTableViewCell.h"
@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = [NSMutableArray arrayWithArray:self.hisDatas];
    self.tableview.dataSource = (id)self;
    self.tableview.delegate = (id)self;
    [self.tableview reloadData];
    // Do any additional setup after loading the view.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.hisIndex==1)
    {
        BFHistoryTableViewCell *cell = [BFHistoryTableViewCell cellWithTableView:tableView];
        [cell configCell:self.datas[self.datas.count-indexPath.row-1]];
        return cell;
    }
    else
    {
        HistoryTableViewCell *cell = [HistoryTableViewCell cellWithTableView:tableView];
        [cell configCell:self.datas[self.datas.count-indexPath.row-1]];
        return cell;
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
