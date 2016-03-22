//
//  LDJCycleScrollView.m
//  LDJLoop
//
//  Created by tih on 16/3/16.
//  Copyright © 2016年 TOSHIBA. All rights reserved.
//

//#warning 如果需要从网络加载图片，将下面一行的注释解开
//#define IS_SDWeb

#import "LDJCycleScrollView.h"
#ifdef IS_SDWeb
#import "UIImageView+WebCache.h"
#endif
#define MULTIPLE_COUNT 50

#define sWidth                self.bounds.size.width
#define sHeight               self.bounds.size.height

#define lWidth      [UIScreen mainScreen].bounds.size.width
#define lHeight     [UIScreen mainScreen].bounds.size.height
#pragma mark - cell
@interface LDJCycleCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView      *imageView;
@property (nonatomic, strong) UILabel          *titleLabel;
@end
@implementation LDJCycleCell
static NSString *kCellIdentifier = @"cell";

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        //self.imageView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        [self addSubview:self.imageView];
        
        self.titleLabel                 = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
        self.titleLabel.hidden          = YES;
        self.titleLabel.textColor       = [UIColor whiteColor];
        self.titleLabel.font            = [UIFont systemFontOfSize:13];
        _titleLabel.lineBreakMode       = 0;
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.titleLabel.frame = CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 30);
    self.titleLabel.hidden = self.titleLabel.text.length > 0 ? NO : YES;
}

@end
#pragma mark - 轮播图
@interface LDJCycleScrollView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong ) UIPageControl              *pageControl;
@property (nonatomic, strong) UICollectionView           *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSTimer                    *timer;
@property (nonatomic, assign) NSInteger                  totalPageCount;
@property (nonatomic, assign) NSInteger                  currentPage;
/**
 *  标题们
 */
@property (nonatomic,retain)NSArray * titles;
/**
 *  就是图片们
 */
@property (nonatomic ,retain) NSArray *images;
/**
 *  滚动的时间间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;
/**
 *  点击回传
 */
@property (nonatomic, copy) LDJCycleScrollViewDidSelectItemBlock didSelectItemBlock;

@end

@implementation LDJCycleScrollView
#pragma mark - 初始化
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame
                                 images:(NSArray *)images
                                 titles:(NSArray *)titles
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(LDJCycleScrollViewDidSelectItemBlock)didSelect{
    LDJCycleScrollView *cycleView = [[LDJCycleScrollView alloc] initWithFrame:frame];
    cycleView.titles = titles;
    cycleView.images = images;
    cycleView.timeInterval = timeInterval;
    cycleView.didSelectItemBlock = didSelect;
    
    return cycleView;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.timeInterval = 5.0;
        [self addCollectionView];
    }
    return self;
}
- (void)addCollectionView{
        self.layout = [[UICollectionViewFlowLayout alloc] init];
        //self.layout .estimatedItemSize = CGSizeMake(sWidth, sHeight);
        self.layout.itemSize = self.bounds.size;
        self.layout .minimumLineSpacing = 0;
        self.layout .scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame
                                                 collectionViewLayout:self.layout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        [self.collectionView  registerClass:[LDJCycleCell class]
                 forCellWithReuseIdentifier:kCellIdentifier];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self addSubview:self.collectionView];
        self.collectionView.translatesAutoresizingMaskIntoConstraints=NO;
}
#pragma mark - 给collectionView添加约束
-(void)updateConstraints{
    NSArray *constraints1 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[_collectionView]|"
                             options:0
                             metrics:nil
                             views:NSDictionaryOfVariableBindings(_collectionView)];
    NSArray *constraints2 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|[_collectionView]|"
                             options:0
                             metrics:nil
                             views:NSDictionaryOfVariableBindings(_collectionView)];
    [self addConstraints:constraints1];
    [self addConstraints:constraints2];
    [super updateConstraints];
}
-(void)addPageControlView{
    if (self.pageControl == nil) {
        _pageControl                        = [[UIPageControl alloc] init];
        self.pageControl.hidesForSinglePage = YES;
        [self addSubview:self.pageControl];
        self.pageControl.userInteractionEnabled =NO;
    }
    [self bringSubviewToFront:self.pageControl];
    self.pageControl.numberOfPages      = self.images.count;
    CGSize size                         = [self.pageControl sizeForNumberOfPages:self.images.count];
    self.pageControl.translatesAutoresizingMaskIntoConstraints=NO;
    NSArray *constraints1 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|-[_pageControl]-|"
                             options:NSLayoutFormatAlignAllCenterX
                             metrics:@{@"pageWidth":@(size.width)}
                             views:NSDictionaryOfVariableBindings(_pageControl)];
    NSArray *constraints2 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:[_pageControl(==pageHeight)]-10-|"
                             options:0
                             metrics:@{@"pageHeight":@(size.height)}
                             views:NSDictionaryOfVariableBindings(_pageControl)];
    NSLayoutConstraint *constraints3 = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:constraints3];
    [self addConstraints:constraints1];
    [self addConstraints:constraints2];

}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalPageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    代码会解决一开始不能左划的现象
//    if (indexPath.item == 0) {
//        NSIndexPath* indexPath = [NSIndexPath
//                                  indexPathForItem:self.images.count*0.5* MULTIPLE_COUNT
//                                         inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath
//                                    atScrollPosition:UICollectionViewScrollPositionNone
//                                            animated:NO];
//    }

    LDJCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                        forIndexPath:indexPath];

    NSInteger itemIndex = indexPath.item % self.images.count;
    if (itemIndex < self.images.count) {
        //array里是图片直接放
        if ([self.images[itemIndex] isKindOfClass:[UIImage class]]) {
            cell.imageView.image = self.images[itemIndex];

        }
#ifdef IS_SDWeb
        //array里是网址用SDWebImage加载
        if ([self.images[itemIndex] isKindOfClass:[NSString class]]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.images[itemIndex]] placeholderImage:[UIImage imageNamed:@""]];
        }
#endif
    }
    if (itemIndex<self.titles.count) {
        cell.titleLabel.text = _titles[itemIndex];
    }
    return cell;
}
- (void)setImages:(NSArray *)images {
    if (![images isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (images == nil || images.count == 0) {
        self.collectionView.scrollEnabled = NO;
        [self pauseTimer];
        self.totalPageCount = 0;
        [self.collectionView reloadData];
        return;
    }
    
    if (_images != images) {
        _images = images;
        
        if (images.count > 1) {
            self.totalPageCount = images.count * MULTIPLE_COUNT;

            [self configTimer];
            [self addPageControlView];
            self.collectionView.scrollEnabled = YES;
        }
        
        else {
            [self pauseTimer];
            self.totalPageCount = 1;
            [self addPageControlView];
            self.collectionView.scrollEnabled = NO;
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - 自滚
- (void)pauseTimer {
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)configTimer {
    if (self.images.count <= 1) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                  target:self
                                                selector:@selector(autoScroll)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)autoScroll {
    NSInteger curIndex = (self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5) / self.collectionView.bounds.size.width;

    NSInteger toIndex = curIndex + 1;
    
    NSIndexPath *indexPath = nil;
    
    if (toIndex >= self.totalPageCount) {
        toIndex = self.totalPageCount * 0.5;
        indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    } else {
        indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    }
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self configTimer];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.totalPageCount == 0) {
        return;
    }
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(indexPath.item % self.images.count);
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int itemIndex = (scrollView.contentOffset.x +
                     sWidth * 0.5) / sWidth;
    itemIndex = itemIndex % self.images.count;
    _currentPage = itemIndex;

    _pageControl.currentPage = itemIndex;
}
-(void)rotateReload{
    //如果涉及屏幕旋转,请自行更改以下代码
    //这里是按照轮播图宽度等于屏宽的情况
    self.collectionView.contentOffset = CGPointMake(_currentPage * ((int)self.bounds.size.width==lHeight?lWidth:lHeight), 0);
}
-(void)layoutSubviews{
    self.layout.itemSize = self.bounds.size;
    [super layoutSubviews];
}
@end
