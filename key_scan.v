/************************************************************************************
������ҵ��
FPGA�з�����Ʒ��������Ŀ�з�������ָ������ҵָ������ѵ������
FPGA��ѵ��FPGA��Ƶ����ĩ�ࡢ��ҵ�ࡢ����ࡣ
/************************************************************************************
��������������ƽ̹�˾������ƺ�����������˼·��ο���Ӧ����������Ƶ��
����ϣ��ͨ���淶���Ͻ��Ĵ��룬ʹͬѧ�ǽӴ��������ļ��ɵ�·/FPGA��ơ�
/************************************************************************************
�����������www.mdy-edu.com
�������Ա��꣺https://mdy-edu.taobao.com/
�����ﲩ�ͣ�www.eetop.cn/blog/1467415/spacelist-blog.html  www.eefocus.com/mdykj33/blog
������QQѧϰȺ��97925396
/************************************************************************************
ע�⣺�������˼·��ο���Ӧ����Ƶ��
************************************************************************************/

module  key_scan(
                 clk    ,
                 rst_n  ,
                 key_col,
                 key_row,
                 key_out,
                 key_vld   
               );


    parameter      KEY_W  =         4 ;
    parameter      CHK_COL  =   0 ;
    parameter      CHK_ROW  =   1 ;
    parameter      DELAY    =   2 ;
    parameter      WAIT_END =   3 ;
    parameter      COL_CNT  =   16;
    parameter      TIME_20MS=   1000000;

    //�����źŶ���
    input               clk    ;
    input               rst_n  ;
    input  [3:0]        key_col;

    //����źŶ���
    output              key_vld;
    output[3:0]         key_out;
    output[KEY_W-1:0]   key_row;

    //����ź�reg����
    reg   [3:0]         key_out;
    reg   [KEY_W-1:0]   key_row;
    reg                 key_vld;


    reg [3:0]           key_col_ff0;
    reg [3:0]           key_col_ff1;
    reg [1:0]           key_col_get;
    wire                shake_flag ;
    reg                 shake_flag_ff0;
    reg[3:0]            state_c;
    reg [19:0]          shake_cnt;
    reg[3:0]            state_n;
    reg [1:0]           row_index;
    reg[15:0]           row_cnt;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_col_ff0 <= 4'b1111;
        key_col_ff1 <= 4'b1111;
    end
    else begin
        key_col_ff0 <= key_col    ;
        key_col_ff1 <= key_col_ff0;
    end
end


assign shake_flag = shake_cnt>=TIME_20MS-1;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        shake_cnt <= 0;
    end
    else if(key_col_ff1!=4'hf)begin
        if(shake_flag)
            shake_cnt <= shake_cnt;
        else
            shake_cnt <= shake_cnt + 1;
    end
    else begin
        shake_cnt <= 0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_c <= CHK_COL;
    end
    else begin
        state_c <= state_n;
    end
end

always  @(*)begin
    case(state_c)
        CHK_COL: begin
                     if(shake_flag && shake_flag_ff0==1'b0)begin
                         state_n = CHK_ROW;
                     end
                     else begin
                         state_n = CHK_COL;
                     end
                 end
        CHK_ROW: begin
                     if(row_index==3 && row_cnt==0)begin
                         state_n = DELAY;
                     end
                     else begin
                         state_n = CHK_ROW;
                     end
                 end
        DELAY :  begin
                     if(row_cnt==0)begin
                         state_n = WAIT_END;
                     end
                     else begin
                         state_n = DELAY;
                     end
                 end
        WAIT_END: begin
                     if(key_col_ff1==4'hf)begin
                         state_n = CHK_COL;
                     end
                     else begin
                         state_n = WAIT_END;
                     end
                  end
       default: state_n = CHK_COL;
    endcase
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_row <= 4'b0;
    end
    else if(state_c==CHK_ROW)begin
        key_row <= ~(1'b1 << row_index);
    end
    else begin
        key_row <= 4'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        row_index <= 0;
    end
    else if(state_c==CHK_ROW)begin
       if(row_cnt==0)begin
           if(row_index==3)
               row_index <= 0;
           else
               row_index <= row_index + 1;
       end
    end
    else begin
        row_index <= 0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        row_cnt <= COL_CNT;
    end
    else if(state_c==CHK_ROW || state_c==DELAY) begin
        if(row_cnt==0)begin
            row_cnt <= COL_CNT;
        end
        else begin
            row_cnt <= row_cnt - 1;
        end
    end
    else begin
        row_cnt <= COL_CNT;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        shake_flag_ff0 <= 1'b0;
    end
    else begin
        shake_flag_ff0 <= shake_flag;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_col_get <= 0;
    end
    else if(state_c==CHK_COL && shake_flag==1'b1 && shake_flag_ff0==1'b0) begin
        if(key_col_ff1==4'b1110)
            key_col_get <= 0;
        else if(key_col_ff1==4'b1101)
            key_col_get <= 1;
        else if(key_col_ff1==4'b1011)
            key_col_get <= 2;
        else 
            key_col_get <= 3;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_out <= 0;
    end
    else if(state_c==CHK_ROW && row_cnt==0)begin
        key_out <= {row_index,key_col_get};
    end
    else begin
        key_out <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_vld <= 1'b0;
    end
    else if(state_c==CHK_ROW && row_cnt==0 && key_col_ff1[key_col_get]==1'b0)begin
        key_vld <= 1'b1;
    end
    else begin
        key_vld <= 1'b0;
    end
end

endmodule

