module Test_TB;

  reg ipClk = 0;
  reg ipReset = 0;
  reg ipRx;
  reg [3:0] ipButtons;
  reg [7:0] opLEDs;
  reg [7:0] SYNC = 8'h55;
  reg [7:0] Destination = 8'h00;
  reg [7:0] Source = 8'b10101010;
  reg [7:0] Length = 8'h5;
  reg [7:0] Data = 8'b00001111;


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

  integer n=9;
  always @(posedge opTxBusy) begin
     n <= n - 1;
  end
  
  always @(posedge ipClk) begin
    if(n == -100)begin
      $stop;
    end else if(!opTxBusy) begin
     
      case (n)
        8: begin
          ipTxData <= SYNC;
        end
        7: begin
          ipTxData <= Destination;
        end
        6: begin
          ipTxData <= Source;
        end
        5: begin
          ipTxData <= Length;
        end
        4: begin
          ipTxData <=Data;
        end
        3: begin
          ipTxData <=Data;
        end
        2: begin
          ipTxData <=Data;
        end
        1: begin
          ipTxData <=Data;
        end
        0: begin
          ipTxData <=Data;
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