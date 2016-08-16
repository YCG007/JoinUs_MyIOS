//
//  CreateFroumStepTwoViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "CreateFroumStepTwoViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "CreateForumStepThreeViewController.h"

@interface CreateFroumStepTwoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;

@end

@implementation CreateFroumStepTwoViewController{
    BOOL _isLogoPicked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isLogoPicked = NO;
    
    self.chooseImageButton.layer.cornerRadius = 5;
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor colorWithRGBValue:0xff0000].CGColor,
                             (id)[UIColor colorWithRGBValue:0x00ff00].CGColor,
                             (id)[UIColor colorWithRGBValue:0x0000ff].CGColor];
    gradientLayer.locations = @[@0.0f, @0.5f, @1.0f];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    //    [self.view.layer addSublayer:gradientLayer];
    
    if (self.forumAdd.iconImage != nil) {
        self.logoImageView.image = self.forumAdd.iconImage;
    } else {
        self.logoImageView.image = [UIImage imageNamed:@"no_logo"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2;
    self.logoImageView.layer.borderWidth = 4;
    self.logoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)chooseimageButtonPressed:(id)sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* takeNewPhotoAlertAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else {
            NSLog(@"NO CAMERA!");
        }
    }];
    
    UIAlertAction* pickFromLibraryAlertAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction* cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Alert Action: Cancel!");
    }];
    
    [alertController addAction:takeNewPhotoAlertAction];
    [alertController addAction:pickFromLibraryAlertAction];
    [alertController addAction:cancelAlertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* pickedImage = info[UIImagePickerControllerEditedImage];
    
    NSLog(@"Image width: %f, height: %f", pickedImage.size.width, pickedImage.size.height);
    
    self.logoImageView.image = pickedImage;
    self.forumAdd.iconImage = pickedImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)nextStepButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"PushThree" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushThree"]) {
        CreateForumStepThreeViewController* createForumStepThreeViewController = segue.destinationViewController;
        createForumStepThreeViewController.forumAdd = self.forumAdd;
    }
}


@end
