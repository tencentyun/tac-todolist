//
//  ToDoListViewController.m
//  QCloudTACToDoListDemo
//
//  Created by erichmzhang(张恒铭) on 12/06/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "ToDoListViewController.h"
#import "TODOListTableView.h"
#import "ToDoListTableViewCell.h"
#import "ToDoItem.h"
#import "ToDoItemStorage.h"
#import "UIDefine.h"
#import "FloatingButton.h"
#import "ToDoItemDetailViewController.h"
#import "ToDoItemLocalStorage.h"
#import "ToDoItemOnlineStorage.h"
#import "UserDetailViewController.h"
@import TACCore;
#define kFloatingButtonRadius 50
#define kFloatingButtonVerticalSpacingBetweenBottom ([UIScreen mainScreen].bounds.size.height * 0.3 )
@interface ToDoListViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TODOListTableView *tableView;

@property (nonatomic, strong) NSMutableArray<ToDoItem *> * todoItemArray;

@property (nonatomic, strong) FloatingButton *floatingButton;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ToDoListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES];
    self.title = @"To Do List";
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.floatingButton];
        UIBarButtonItem* leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"用户" style:UIBarButtonItemStylePlain target:self action:@selector(onHandleUserButtonClicked:)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)reloadData {
    [ToDoItemOnlineStorage requestOnlineToDoItemWithFinishBlock:^(NSArray *todoItems, NSError *error) {
        [ToDoItemLocalStorage sharedInstance].itemsArray = [todoItems mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
        
    }];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.tableView reloadData];
    [self.refreshControl beginRefreshing];
    [self reloadData];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) onHandleUserButtonClicked:(UIBarButtonItem *)button {
    UserDetailViewController *userDetailViewController = [[UserDetailViewController alloc] init];
    [self.navigationController pushViewController:userDetailViewController animated:YES];
}


- (void)insertToDoItem {
    __block ToDoItem *newItem = [[ToDoItem alloc] init];
    [self.todoItemArray addObject:newItem];
    NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForRow:self.todoItemArray.count - 1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPathToInsert] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [ToDoItemOnlineStorage addItem:newItem withFinishBlock:^(NSDictionary* outputObject,NSError *error) {
        QCloudLogDebug(@"Insert Item fail! error is %@",error);
        if (!error) {
            newItem.uuid = [NSString stringWithFormat:@"%@",outputObject[@"id"]];
        }
    }];
    
    
}

#pragma mark - Button Actions
- (void)onHandleFloatingButtonClicked:(UIButton *)button {
    [self insertToDoItem];
    [self.tableView scrollToBottom];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ToDoListTableViewCell *cell =[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.todoItemArray.count - 1 inSection:0]] ;
        [cell setIsEditting:YES];
    });

}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ToDoItemDetailViewController *vc = [[ToDoItemDetailViewController alloc] init];
    vc.todoItem = self.todoItemArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableView Data Source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.todoItemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* kCellReuseIdentifier = @"kCellReuseIdentifier";
    ToDoListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    cell.title = self.todoItemArray[indexPath.row].title;
    __weak typeof(self) weakSelf = self;
    cell.completeButtonHandler = ^(UIButton *button, UITableViewCell *cell) {
        NSIndexPath *currentIndexPath = [tableView indexPathForCell:cell];
        [weakSelf.todoItemArray removeObjectAtIndex:currentIndexPath.row];
        [tableView deleteRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    };
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kBodyViewHeight+kBodyViewTopSpacing+kBodyViewTopSpacing;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath  {
    return YES;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        ToDoItem *itemToBeDeleted = self.todoItemArray[indexPath.row];
        [self.todoItemArray removeObject:itemToBeDeleted];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [ToDoItemOnlineStorage deleteItem:itemToBeDeleted withFinishBlock:^(NSError *error) {
            NSLog(@"Delte error%@",error);
        }];
    }];
    deleteRowAction.backgroundColor = [UIColor redColor];
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"完成" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        ToDoItem *itemToBeDeleted = self.todoItemArray[indexPath.row];

        [self.todoItemArray removeObject:itemToBeDeleted];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [ToDoItemOnlineStorage deleteItem:itemToBeDeleted withFinishBlock:^(NSError *error) {
            NSLog(@"Delte error%@",error);
        }];
    }];
    topRowAction.backgroundColor = [UIColor colorWithHex:0x9ECDAB];
        return @[deleteRowAction, topRowAction];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.todoItemArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)onHandleRefreshControlTriggered:(UIRefreshControl *)refreshControl {
    [ToDoItemOnlineStorage requestOnlineToDoItemWithFinishBlock:^(NSArray *todoItems, NSError *error) {
        [ToDoItemLocalStorage sharedInstance].itemsArray = [todoItems mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - Getters


- (FloatingButton *)floatingButton {
    if (!_floatingButton) {
        _floatingButton = [[FloatingButton alloc] initWithFrame:CGRectMake(kScreenWidth - kFloatingButtonRadius, kScreenHeight -  kFloatingButtonVerticalSpacingBetweenBottom + kFloatingButtonRadius, kFloatingButtonRadius, kFloatingButtonRadius)];
        [_floatingButton setTitle:@"+" forState:UIControlStateNormal];
        [_floatingButton addTarget:self action:@selector(onHandleFloatingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _floatingButton;
}

- (TODOListTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TODOListTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBodyViewHeight, 0);
        [_tableView addSubview:self.refreshControl];
    }
    return _tableView;
}


- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(onHandleRefreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (NSArray<ToDoItem *> *)todoItemArray {
    return [ToDoItemLocalStorage sharedInstance].itemsArray;
}


@end
