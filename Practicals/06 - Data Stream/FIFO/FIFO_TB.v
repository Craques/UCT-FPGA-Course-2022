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
  
    
    // for (int i=0; i<32; i++) begin
    //   #10;
    //   ipWriteData <= i;
    // end
    
    // //read data next
    // ipReadEnable <= 0;
    // ipWriteEnable <= 1;

    // for (int i=0; i<32; i++) begin
    //    ipReadEnable <= 1;
    //    #10;
    // end
  end

  
  always @(posedge ipClk) begin
    int i; 
    i <= i + 1;
    ipReadEnable <= 0;
    ipWriteEnable <= 1;
    if (i <32 ) begin
      ipWriteData <= i;
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