`timescale 1ns / 1ps

module tb_lcd();

// 输入信号
reg clk;
reg rst_n;

// 输出信号
wire rs;
wire rw;
wire en;
wire [7:0] data;


lcd u_lcd(
    .clk(clk),
    .rst_n(rst_n),
    .rs(rs),
    .rw(rw),
    .en(en),
    .data(data)
);

// 时钟生成
always #10 clk = ~clk;  // 50MHz时钟，周期20ns


initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    
    // 生成复位信号
    #100 rst_n = 1;
    
    // 等待足够长时间观察完整初始化过程
    #5000000;  // 5ms仿真时间
    
    $display("测试完成！");
    $finish;
end




endmodule
