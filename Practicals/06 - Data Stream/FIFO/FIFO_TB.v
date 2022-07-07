`timescale 1ns/1ns

module FIFO_TB;
  reg ipClk = 0;
  reg ipReset = 0;
  reg ipReadEnable;
  reg ipWriteEnable;
  reg [7:0] ipWriteData;
  reg opFIFOFull;
  reg [7:0] opReadData;
  reg opFIFOEmpty;

  always #10 begin
    ipClk = ~ipClk;
  end

  initial begin
    ipReset <= 0;
  end

  
  always @(posedge ipClk) begin
    int i; 
    int j;
    if (i < 32 ) begin
      ipReadEnable <= 0;
      ipWriteEnable <= 1;
      i <= i + 1;
      ipWriteData <= i;
      j <= i + 1;
    end else begin
      j <= j - 1;
      ipReadEnable <= 1;
      ipWriteEnable <= 0;
      if (j ==-2) begin
        $stop;
      end
    end
  end


  // always @(posedge ipClk) begin
    
  // end


  FIFO DUT(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipReadEnable(ipReadEnable),
    .opReadData(opReadData),
    .opFIFOEmpty(opFIFOEmpty),
    
    //write params
    .ipWriteEnable(ipWriteEnable),
    .ipWriteData(ipWriteData),
    .opFIFOFull(opFIFOFull)
  ); 
endmodule