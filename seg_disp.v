/************************************************************************************
明德扬业务：
FPGA研发：产品合作、项目研发、技术指导、毕业指导、培训合作。
FPGA培训：FPGA视频、周末班、就业班、网络班。
/************************************************************************************
本代码由明德扬科教公司精心设计和制作，代码思路请参考对应的明德扬视频。
我们希望通过规范、严谨的代码，使同学们接触到纯正的集成电路/FPGA设计。
/************************************************************************************
明德扬官网：www.mdy-edu.com
明德扬淘宝店：https://mdy-edu.taobao.com/
明德扬博客：www.eetop.cn/blog/1467415/spacelist-blog.html  www.eefocus.com/mdykj33/blog
明德扬QQ学习群：97925396
/************************************************************************************
注意：代码设计思路请参考对应的视频。
************************************************************************************/


module  seg_disp(rst_n       ,
                 clk         ,
                 din         ,
                 din_vld     ,
                 seg_sel     ,
                 segment      
             );



parameter  SEG_WID        =       8;
parameter  SEG_NUM        =       8;
parameter  COUNT_WID      =       26;
parameter  TIME_20US      =       20'd1000;

 
parameter  NUM_0          =       8'b1100_0000;
parameter  NUM_1          =       8'b1111_1001;
parameter  NUM_2          =       8'b1010_0100;
parameter  NUM_3          =       8'b1011_0000;
parameter  NUM_4          =       8'b1001_1001;
parameter  NUM_5          =       8'b1001_0010;
parameter  NUM_6          =       8'b1000_0010;
parameter  NUM_7          =       8'b1111_1000;
parameter  NUM_8          =       8'b1000_0000;
parameter  NUM_9          =       8'b1001_0000;
parameter  NUM_ERR        =       8'b1000_0110;


input                             clk;
input                             rst_n;
input  [SEG_NUM*4-1:0]            din;
input  [SEG_NUM-1:0]              din_vld;
output [SEG_NUM-1:0]              seg_sel;
output [SEG_WID-1:0]              segment;

reg    [SEG_NUM-1:0]              seg_sel;
reg    [SEG_WID-1:0]              segment;
reg    [COUNT_WID-1:0]            count_20us;
reg    [SEG_NUM-1:0]              sel_cnt;
reg    [4*SEG_NUM-1:0]            din_ff0;
reg    [        4-1:0]            seg_tmp;
wire                              flag_20us;
integer                           ii;


assign  flag_20us = count_20us==TIME_20US-1;

always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        count_20us<=26'b0;
    end
    else if(flag_20us) begin
        count_20us<=0;
    end
    else begin
        count_20us<=count_20us+1'b1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sel_cnt <= 0;
    end
    else if(flag_20us) begin
        if(sel_cnt==SEG_NUM-1)
            sel_cnt <= 0;
        else
            sel_cnt <= sel_cnt + 1;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        seg_sel <= {SEG_NUM{1'b1}};
    end
    else begin
        seg_sel <= ~(1'b1 << sel_cnt);
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din_ff0 <= 0;
    end
    else begin
        for(ii=0;ii<SEG_NUM;ii=ii+1)begin
            if(din_vld[ii]==1'b1)begin
                din_ff0[(ii+1)*4-1 -:4] <= din[(ii+1)*4-1 -:4];
            end
            else begin
                din_ff0[(ii+1)*4-1 -:4] <= din_ff0[(ii+1)*4-1 -:4];
            end
        end
    end
end

always  @(*)begin
    seg_tmp = din_ff0[(sel_cnt+1)*4-1 -:4]; 
end


always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        segment<=NUM_0;
    end
    else if(seg_tmp==0)begin
          segment<=NUM_0;
    end
    else if(seg_tmp==1)begin
          segment<=NUM_1;
     end
    else if(seg_tmp==2)begin
          segment<=NUM_2;
    end
    else if(seg_tmp==3)begin
          segment<=NUM_3;
    end
    else if(seg_tmp==4)begin
          segment<=NUM_4;
    end
    else if(seg_tmp==5)begin
          segment<=NUM_5;
    end
    else if(seg_tmp==6)begin
          segment<=NUM_6;
    end
    else if(seg_tmp==7)begin
          segment<=NUM_7;
    end
    else if(seg_tmp==8)begin
          segment<=NUM_8;
    end
     else if(seg_tmp==9)begin
          segment<=NUM_9;
    end
    else begin
        segment<=NUM_ERR;    
    end
end

endmodule

