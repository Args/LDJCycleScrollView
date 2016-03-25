# LDJCycleScrollView
###支持Autolayout
###支持屏幕旋转
###支持自动滚动
###支持无缝滚动
###支持网络加载(需要SDWebImage)
###QAQ~~
#效果如下
![image](https://github.com/Args/LDJCycleScrollView/blob/master/LDJCycleScrollDemo/LDJCycleScrollView/Untitled.gif)   

#使用方法
`pod 'LDJCycleScrollView', '~> 1.0.0'`

###一句代码即可使用,大致如下
    `LDJCycleScrollView * _mainScorllView = [LDJCycleScrollView
                       cycleScrollViewWithFrame:CGRectMake(0, 0, kWidth, 180)
                       images:images
                       titles:titles
                       timeInterval:2
                       didSelect:^(NSInteger atIndex) {
                           NSLog(@"%ld",(long)atIndex);
                       }];`
    
    `[self.view addSubview:_mainScorllView];`
