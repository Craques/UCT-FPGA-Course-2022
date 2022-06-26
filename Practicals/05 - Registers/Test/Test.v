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
  reg [7:0] opWriteAddress;
  reg [7:0] opReadAddress; 
  reg opTxWrEnable;
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS opWrRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] localWriteMemory;
  reg [BLOCK_WIDTH -1:0] localReadMemory;

  always @(posedge ipClk) begin
   readRegisters.Buttons <= ipButtons;
  end
  

  WriteController writeController(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opAddress(opWriteAddress), // this will be input to the Registers module, taken from incoming stream
    .opWrData(localWriteMemory),// data from the packet that will be input to the registers module
    .opRxStream(opRxStream),
    .opTxWrEnable(opTxWrEnable)
  );

  ReadController readController(
    .ipReadData(localReadMemory),
    .ipTxStream(ipTxStream),
    .ipReset(ipReset),
    .ipClk(ipClk),
    .opRxStream(opRxStream),
    .opReadAddress(opReadAddress)
  );
  

  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(opWrRegisters),
    .ipReadAddress(opReadAddress), 
    .ipWriteAddress(opWriteAddress), 
    .ipWrData(localWriteMemory),
    .ipWrEnable(opTxWrEnable),
    .opRdData(localReadMemory)
  );

 //may have to use a seperate uart to transmit data
  UART_Packets uartPackets(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipTxStream(ipTxStream),
    .opTxReady(opTxReady),
    .opTx(opTx),
    .ipRx(ipRx),
    .opRxStream(opRxStream)
  );
  assign opLEDs = opWrRegisters.LEDs;
endmodule //Test