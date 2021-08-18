// #region 
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//      Author: ZemZhao                                                         //
//      E-mail: zemzhao@163.com                                                 //
//      Please feel free to contact me if there are BUGs in my program.         //
//      For I know they are everywhere.                                         //
//      I can do nothing but encourage you to debug desperately.                //
//      GOOD LUCK, HAVE FUN!!                                                   //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                              SJTU BCI-Lab 205                                //
//                            All rights reserved                               //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
// adc2fifod.v:
// 该文件是将 ADC-II 部分的数据发送到FIFO_DATA

//////////////////////////////////////////////////////////////////////////////////
// #endregion 
module adc2fifod ( // WRITE DONE

    output [7:0] fifod_txd,
    output fifod_txen,
    input adc_rxen,
    input [7:0] adc_rxd
);

    assign fifod_txd = adc_rxd;
    assign fifod_txen = adc_rxen;
    
endmodule