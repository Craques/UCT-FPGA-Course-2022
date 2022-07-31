import Structures::*;

module Test #(parameter BLOCK_WIDTH = 32) (
  input  ipClk,
  input  ipReset,
  input  ipRx,
  input [3:0] ipButtons,

  output opTx,
  output  [7:0] opLEDs
);

  reg opTxReady;
  reg localReset = ~ipReset;
  reg [7:0] ipAddress;
  reg opTxWrEnable;
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS opWrRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] localWriteMemory;
  reg [BLOCK_WIDTH -1:0] localReadMemory;
  


  StreamController streamController(
    .ipReadData(localReadMemory),
    .ipReset(localReset),
    .ipClk(ipClk),
    .ipRxStream(opRxStream),
    .ipTxReady(opTxReady),

    .opTxStream(ipTxStream), //output will be transmitted
    .opAddress(ipAddress),
    .opWriteData(localWriteMemory),
    .opWriteEnable(opTxWrEnable)
  );
  

  Registers registers(
    .ipClk(ipClk),
    .ipReset(localReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(opWrRegisters),
    .ipAddress(ipAddress),  
    .ipWrData(localWriteMemory),
    .ipWrEnable(opTxWrEnable),
    .opRdData(localReadMemory)
  );

 //may have to use a seperate uart to transmit data
  UART_Packets uartPackets(
    .ipClk(ipClk),
    .ipReset(localReset),
    .ipTxStream(ipTxStream),
    .opTxReady(opTxReady),
    .opTx(opTx),
    .ipRx(ipRx),
    .opRxStream(opRxStream)
  );


  always @(posedge ipClk) begin
    if(ipReset) begin
      readRegisters.ClockTicks <= 0;
    end else begin
      readRegisters.ClockTicks <=  readRegisters.ClockTicks + 1;
    end
  end

  assign readRegisters.Buttons = ~ipButtons;
  assign opLEDs = ~opWrRegisters.LEDs;
endmodule //Test