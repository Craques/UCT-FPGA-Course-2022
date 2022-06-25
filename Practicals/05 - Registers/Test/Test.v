import Structures::*;

module Test #(parameter BLOCK_WIDTH = 32) (
  input ipClk,
  input ipReset,
  input ipRx,
  output opTx,
  output [7:0] opLEDs
);

  wire opTxReady;
  wire [7:0] ipAddress;
  wire [7:0] opReadAddress; 
  wire opTxWrEnable;
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS opWrRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] localWriteMemory;
  reg [BLOCK_WIDTH -1:0] localReadMemory;

  WriteController writeController(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opAddress(ipAddress), // this will be input to the Registers module, taken from incoming stream
    .opWrData(localWriteMemory),// data from the packet that will be input to the registers module
    .opTxStream(opRxStream),
    .opTxWrEnable(opTxWrEnable)
  );

  ReadController readController(
    .ipReadData(localReadMemory),
    .ipTxStream(ipTxStream),
    .ipReset(ipReset),
    .ipClk(ipClk),
    .opRxStream(opRxStream),
    .opReadAddress(ipAddress)
  );
  

  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
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
    .ipReset(ipReset),
    .ipTxStream(ipTxStream),
    .opTxReady(opTxReady),
    .opTx(opTx),
    .ipRx(ipRx),
    .opRxStream(opRxStream)
  );
  assign opLEDs = opWrRegisters.LEDs;
endmodule //Test