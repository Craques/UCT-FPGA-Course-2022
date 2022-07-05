module FIFO #(
  param FIFO_DEPTH = 32,
  param DATA_LENGTH = 8;
) (
  //fifo params
  input                       ipClk,
  input                       ipReset,

  //read params
  input                       ipReadEnable,
  output [DATA_LENGTH - 1:0]  opReadData,
  output [DATA_LENGTH - 1:0]  opFIFOEmpty,
  
  //write params
  input                       ipWriteEnable,
  input                       ipWriteData,
  output                      opFIFOFull
);

//local parameters
  reg reset;
  reg [DATA_LENGTH - 1: 0]  FIFOMemory [FIFO_DEPTH-1: 0];
  //will have to figure out how to dynamically set the length of count;
  reg [6:0]                 count;
  reg [5:0]                 readPointer;
  reg [5:0]                 writePointer;

  //perfom read operation
  always @(posedge ipClk ) begin
    if () begin
      
    end else begin
      
    end
  end


  //perform write operation

  
endmodule