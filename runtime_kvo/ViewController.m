//
//  ViewController.m
//  runtime_kvo
//
//  Created by caitou on 2022/2/28.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()
@property (nonatomic, strong) Account *acount;
@property (nonatomic, strong) Student *stu;
@property (nonatomic, strong) Teacher *tea;
@property (nonatomic, strong) Person *ps;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.acount = [[Account alloc] init];
    self.stu = [[Student alloc] init];
    self.tea = [[Teacher alloc] init];
    self.ps = [[Person alloc] init];
    [self.acount addObserver:self.stu forKeyPath:@"balance" options:0 context:nil];
    [self.acount addObserver:self.tea forKeyPath:@"balance" options:0 context:nil];
    [self.acount addObserver:self.ps forKeyPath:@"balance" options:0 context:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.acount.balance = 100;
}
@end
