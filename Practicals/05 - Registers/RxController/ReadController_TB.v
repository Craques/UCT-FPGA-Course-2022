module ReadController_TB;
	reg [31:0] ipReadData;
	reg opTxReady;
	UART_PACKET ipRxStream;
	UART_PACKET opTxStream;
	output reg opReadAddress;



	ReadController DUT(
		.ipReadData(ipReadData),
		.opTxReady(opTxReady),
		.ipRxStream(ipRxStream),
		.opTxStream(opTxStream)
	);
endmodule