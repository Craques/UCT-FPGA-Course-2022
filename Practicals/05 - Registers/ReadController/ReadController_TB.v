`timescale 1ns/1ns

import Structures::*;

module ReadController_TB;
	reg [31:0] ipReadData = 32'h11112222333344445555666677778888;
	reg opTxReady;
	reg ipClk = 0;
	reg ipReset = 1;
	reg [7:0] count = 0;
	UART_PACKET ipRxStream;
	UART_PACKET opTxStream;
	reg [7:0] opReadAddress;

	initial begin
		//Send Sync and destination for read
		#10 ipReset <= 0;
		ipRxStream.Destination <= 8'h00;
		ipRxStream.Valid <= 1;
		//initial data is address
		ipRxStream.Data <= 8'h02030405;
		opTxReady <= 1;
		opTxStream.Valid <= 1;
	end

	always #10 begin
		ipClk <= ~ipClk;
	end


	always @(negedge opTxStream.Valid) begin
		if(opTxStream.Valid) begin
			count <= count + 1;
			ipRxStream.Data <= count;
		end
	end

	ReadController DUT(
		.ipReadData(ipReadData),
		.opTxReady(opTxReady),
		.ipRxStream(ipRxStream),
		.opTxStream(opTxStream),
		.ipReset(ipReset),
		.ipClk(ipClk),
		.opReadAddress(opReadAddress)
	);
endmodule