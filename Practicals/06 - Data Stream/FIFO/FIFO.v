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
  reg [$clog2(DATA_LENGTH) + 2:0]   count = 0;
  reg [$clog2(DATA_LENGTH) + 1:0]   readPointer = 0;
  reg [$clog2(DATA_LENGTH) + 1:0]   writePointer = 0;


  //assign reset on clockedge
  always @(posedge ipClk) begin
    reset <= ipReset;
  end

  //perfom read operation
  always @(posedge ipClk ) begin
    if(count == 0) begin
        opFIFOEmpty <= 1;
    end else begin
      opFIFOEmpty <= 0;
    end

    if (reset) begin
      readPointer <= 0;
    end else if(ipReadEnable) begin
      opReadData <= FIFOMemory[readPointer];
      readPointer <= readPointer + 1;
    end
 
    if (count == 32) begin
      opFIFOFull <= 1;
    end else begin
      opFIFOFull <= 0;
    end

    if (reset) begin
      writePointer <= 0;
    end else if(ipWriteEnable) begin
      FIFOMemory[writePointer] <= ipWriteData;
      writePointer <= writePointer + 1;
    end
 
    if (reset) begin
      count <= 0;
    end else begin
      if (!ipReadEnable && ipWriteEnable) begin
       $display("ADDING");
        count <= count + 1;  
      end else if(ipReadEnable && !ipWriteEnable) begin
        $display("SUBTRACTING");
        count <= count - 1;
      end else begin
        $display("ERROR");
        $display("WRITE ENABLE %d", ipWriteEnable);
        $display("Read ENABLE %d", ipReadEnable);
        count <= count;
      end
    end
  end
  
endmodule