# FPGA-drive-LCD1602
本科小实验，用FPGA驱动LCD1602

有大概的注释，整个思路就是将状态机的功能分成几个小状态机，控制步骤的、控制动作或者说行为的，还有设计到写入数据的小状态机，再利用且的时序逻辑去约束它<br>
测试文件也是随便写了写，只有一个初始的激励，而且仿真时间很短。<br>
图片在master里，上传的时候图片忘了改名称了，自己看吧

![result_display](https://github.com/jhhjkgddss/FPGA-drive-LCD1602.git/result_display.png)
