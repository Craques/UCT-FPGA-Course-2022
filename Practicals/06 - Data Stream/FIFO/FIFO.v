module FIFO #(
  param FIFO_DEPTH = 32,
  param DATA_LENGTH = 8
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
  end


  //perform write operation
  always @(posedge ipClk ) begin
    if (count == 32) begin
      opFIFOFull <= 1;
    end else begin
      opFIFOFull <= 0;
    end

    if (reset) begin
      writePointer <= 0
    end else if(ipWriteEnable) begin
      FIFOMemory[writePointer] <= ipWriteData;
      writePointer <= writePointer + 1;
    end
  end


  //set the fifo state depending on count, if empty return 

  always @(posedge ipClk ) begin
    if (reset) begin
      count <= 0;
    end else begin
      case ({ipReadEnable, ipWriteEnable})
        1'b01: begin
          count <= count + 1;  
        end
        1'b10: begin
          count <= count -1;
        end
        default: begin
          count <= count
        end
      endcase
    end
  end
  
endmodule