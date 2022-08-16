`timescale 1ns/1ns

import Structures::*;

module ReadController_TB;
	reg [31:0] ipReadData = 32'b0111_0110_0101_0100_0011_0010_0001_0000;
	reg opTxReady = 0;
	reg ipClk = 0;
	reg ipReset = 1;
	reg [7:0] count = 0;
	UART_PACKET ipTxStream;
	UART_PACKET opRxStream;
	reg [7:0] opReadAddress;

	initial begin
		//Send Sync and destination for read
		#10 ipReset <= 0;
		opRxStream.Destination <= 8'h00;
		opRxStream.Source <= 8'haa;
		opRxStream.Valid <= 1;
		//initial data is address
		opRxStream.Data <= 8'h11;
	
		opRxStream.Valid <= 1;
	end

	always #10 begin
		ipClk <= ~ipClk;
	end

	always #100 begin
			opTxReady <= ~opTxReady;
	end

	always @(posedge opRxStream.EoP) begin
		$stop;
	end

	ReadController DUT(
		.ipReadData(ipReadData),
		.ipTxReady(opTxReady),
		.ipRxStream(opRxStream),
		.opTxStream(ipTxStream),
		.ipReset(ipReset),
		.ipClk(ipClk),
		.opReadAddress(opReadAddress)
	);
endmodule