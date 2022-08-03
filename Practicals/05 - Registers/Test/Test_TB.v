module Test_TB;

  reg ipClk = 0;
  reg ipReset = 0;
  reg ipRx;
  reg [3:0] ipButtons = 4'b1101;
  reg [7:0] opLEDs;
  reg [7:0] SYNC = 8'h55;
  reg [7:0] ReadDestination = 8'h00;
  reg [7:0] WriteDestination = 8'h01;
  reg [7:0] Source = 8'b10101010;
  reg [7:0] Length = 8'h5;
  reg [7:0] Data = 8'b00001111;
  reg [7:0] ReadAddress = 8'h02;
  reg [7:0] WriteAddress = 8'h02;

  // uart data
  reg  [7:0]ipTxData;
  reg       ipTxSend = 1;
  reg      opTxBusy =0;
  reg      opTx;
  reg opRxValid;
  reg [7:0] opRxData;

  always #10 begin
    ipClk = ~ipClk;
  end

  integer n=4;
  integer writeLength = 9;
  integer readEnable = 0;


  always @(posedge opTxBusy) begin
    if(!readEnable) begin
      writeLength <= writeLength - 1;
    end
  end


/**********************************************************
 * THIS SECTION WILL CONTAIN THE LOGIC TO WRITE TO MEMORY *
 **********************************************************/

 always @(posedge ipClk) begin
    if(writeLength == -1)begin
     
    end else if(!opTxBusy) begin
     
      case (writeLength)
        8: begin
          ipTxData <= SYNC;
        end
        7: begin
          ipTxData <= WriteDestination;
        end
        6: begin
          ipTxData <= 8'h01;
        end
        5: begin
          ipTxData <= Length;
        end
        4: begin
          ipTxData <= WriteAddress;
        end
        3: begin
          ipTxData <= 8'h03;
        end
        2: begin
          ipTxData <= 8'h04;
        end
        1: begin
          ipTxData <= 8'h05;
        end
        0: begin
          ipTxData <= 8'h06;
          #50 readEnable <=1;
        end
      endcase
    end
  end

  /**********************************************************
 * THIS SECTION WILL CONTAIN THE LOGIC TO READ FROM MEMORY *
 **********************************************************/
  
  always @(posedge ipClk) begin

    
    if(!opTxBusy && readEnable) begin
       n <= n -1;
      case (n)
        4: begin
          ipTxData <= SYNC;
        end
        3: begin
          ipTxData <= ReadDestination;
        end
        2: begin
          ipTxData <= Source;
        end
        1: begin
          ipTxData <= Length;
        end
        0: begin
          ipTxData <= ReadAddress;
        end 
        default: begin
          $stop;
        end
      endcase
    end
  end

  UART uart(
    .ipClk    (ipClk    ),
    .ipReset  (ipReset  ),
                      
    .ipTxData (ipTxData ),
    .ipTxSend (ipTxSend ),
    .opTxBusy (opTxBusy ),
    .opTx     (ipRx     ),
                 
    .ipRx     (opTx     ),
    .opRxData (opRxData ),
    .opRxValid(opRxValid)
  );


  Test DUT(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRx(ipRx),
    .ipButtons(ipButtons),

    .opTx(opTx),
    .opLEDs(opLEDs)
  );
endmodule