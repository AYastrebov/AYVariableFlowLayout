//
//  AYVariableFlowLayout.h
//  AYVariableFlowLayout
//
//  Created by Andrey Yastrebov on 17.12.16.
//  Copyright © 2016 Andrey Yastrebov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AYVariableDelegateFlowLayout <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForFooterInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout verticalPaddingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout horizontalPaddingForSectionAtIndex:(NSInteger)section;

@end

@interface AYVariableFlowLayout : UICollectionViewLayout

@end
