module Test_TB;

  reg ipClk = 0;
  reg ipReset = 0;
  reg ipRx= 0;
  reg [3:0] ipButtons;
  reg opTx;
  reg [7:0] opLEDs;
  reg [7:0] SYNC = 8'b01010101;
  reg [7:0] Destination = 8'b00000001;
  reg [7:0] Source = 8'b10101010;
  reg [7:0] Length = 8'b00000101;
  reg [7:0] DATA = 8'b00001111;
  always #10 begin
    ipClk = ~ipClk;
  end


  reg [63:0] TRANSMIT_DATA ={SYNC, Destination, Source, Length, DATA, DATA, DATA, DATA, DATA};
  integer n=64;
  always @(posedge ipClk) begin
    if(n == 0)begin
      $stop;
    end else begin
      
      n <= n -1;
      ipRx <= TRANSMIT_DATA[n];
    end
  end



  Test DUT(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRx(ipRx),
    .ipButtons(ipButtons),

    .opTx(opTx),
    .opLEDs(opLEDs)
  );
endmodule