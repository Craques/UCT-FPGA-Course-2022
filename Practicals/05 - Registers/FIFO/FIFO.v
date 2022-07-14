module FIFO #(
  parameter FIFO_DEPTH = 32,
  parameter DATA_LENGTH = 8
) (
  //fifo params
  input                           ipClk,
  input                           ipReset,

  //read params
  input                           ipReadEnable,
  output reg [DATA_LENGTH - 1:0]  opReadData,
  output reg                      opFIFOEmpty,
  
  //write params
  input                           ipWriteEnable,
  input  reg [DATA_LENGTH - 1:0]  ipWriteData,
  output reg                      opFIFOFull
);

  //local parameters
  reg reset;
  reg [DATA_LENGTH - 1: 0]          FIFOMemory [FIFO_DEPTH-1: 0];
  //will have to figure out how to dynamically set the length of count;
  reg [$clog2(FIFO_DEPTH)  + 2:0]   count = 0;
  reg [$clog2(FIFO_DEPTH) + 1:0]   readPointer = 0;
  reg [$clog2(FIFO_DEPTH) + 1:0]   writePointer = 0;


  //assign reset on clockedge
  always @(posedge ipClk) begin
    reset <= ipReset;
  end

  //perfom read operation
  always @(posedge ipClk ) begin
    // handle external state
    if(count == 0) begin
        opFIFOEmpty <= 1;
    end else if (count == 32) begin
      opFIFOFull <= 1;
    end else begin
      opFIFOFull <= 0;
      opFIFOEmpty <= 0;
    end

    if (reset) begin
      count <= 0;
      writePointer <= 0;
      readPointer <= 0;
    end else begin
      // Write data
      if(ipWriteEnable) begin
        FIFOMemory[writePointer] <= ipWriteData;
        writePointer <= writePointer + 1;
      end

      //read data 
      if(ipReadEnable) begin
        opReadData <= FIFOMemory[readPointer];
        readPointer <= readPointer + 1;
      end

      if (!ipReadEnable && ipWriteEnable) begin
        count <= count + 1;  
      end else if(ipReadEnable && !ipWriteEnable) begin
        count <= count - 1;
      end else begin
        count <= count;
      end
    end
  end
endmodule
