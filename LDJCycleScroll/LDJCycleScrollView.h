//
//  LDJCycleScrollView.h
//  LDJLoop
//
//  Created by tih on 16/3/16.
//  Copyright © 2016年 TOSHIBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDJCycleScrollView : UIView
/**
 *  点击某个图片时回调这个
 *
 *  @param atIndex 第几个图片(从零开始)
 */
typedef void (^LDJCycleScrollViewDidSelectItemBlock)(NSInteger atIndex);


-(void)rotateReload;
/**
 *  初始化
 *
 *  @param frame        frame
 *  @param images       图片们，可以传UIImage或者NSString（网址）
 *  @param titles       标题们，没有可以传nil
 *  @param timeInterval 多长时间滚一次
 *  @param didSelect    选中后干什么
 *
 *  @return 返回这个view
 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame
                                 images:(NSArray *)images
                                 titles:(NSArray *)titles
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(LDJCycleScrollViewDidSelectItemBlock)didSelect;
@end
