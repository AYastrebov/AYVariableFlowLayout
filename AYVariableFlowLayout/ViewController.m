//
//  ViewController.m
//  AYVariableFlowLayout
//
//  Created by Andrey Yastrebov on 16.12.16.
//  Copyright © 2016 Andrey Yastrebov. All rights reserved.
//

#import "ViewController.h"
#import "HeaderView.h"
#import "FooterView.h"
#import "AYVariableFlowLayout.h"

#define ARC4RANDOM_MAX      0x100000000

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, AYVariableDelegateFlowLayout, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<NSValue *> *sizes;

@property (nonatomic, strong) AYVariableFlowLayout *variableLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sizes = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < 32; i++) {
        CGSize size = CGSizeMake(50, 50);
        if (i == 4) {
            size = CGSizeMake(110, 110);
        }
        
        [self.sizes addObject:[NSValue valueWithCGSize:size]];
    }
    
    UICollectionViewLayout *currentLayout = self.collectionView.collectionViewLayout;
    
    if ([currentLayout isKindOfClass:AYVariableFlowLayout.class]) {
        self.variableLayout = (AYVariableFlowLayout *)currentLayout;
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    } else if ([currentLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
        self.flowLayout = (UICollectionViewFlowLayout *)currentLayout;
        self.variableLayout = [[AYVariableFlowLayout alloc] init];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        switch (sender.selectedSegmentIndex) {
                // Custom layout
            case 0:
                [self.collectionView setCollectionViewLayout:self.variableLayout animated:YES];
                break;
                
                // Flow layout
            default:
                [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
                break;
        }
    } completion:nil];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sizes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((double)arc4random() / ARC4RANDOM_MAX) green:((double)arc4random() / ARC4RANDOM_MAX) blue:((double)arc4random() / ARC4RANDOM_MAX) alpha:1.0f];
    UILabel *label = [cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderView *collectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:@"header"
                                                                                 forIndexPath:indexPath];
        collectionHeader.backgroundColor = [UIColor redColor];
        reusableView = collectionHeader;
    } else if (kind == UICollectionElementKindSectionFooter) {
        FooterView *collectionFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                          withReuseIdentifier:@"footer"
                                                                                 forIndexPath:indexPath];
        collectionFooter.backgroundColor = [UIColor blueColor];
        reusableView = collectionFooter;
    }
    
    return reusableView;
}

#pragma mark - AYVariableDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sizes[indexPath.row].CGSizeValue;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44);
}


#pragma mark - UICollectionViewDelegateFlowLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(100, 100);
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
//                        layout:(UICollectionViewLayout*)collectionViewLayout
//        insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(collectionView.bounds.size.width, 44);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake(collectionView.bounds.size.width, 44);
//}

@end
