module ReadController_TB;
	reg [31:0] ipReadData = 32'h11112222333344445555666677778888;
	reg opTxReady;
	reg ipClk;
	reg ipReset = 1;
	UART_PACKET ipRxStream;
	UART_PACKET opTxStream;
	output reg opReadAddress;

	initial begin
		//Send Sync and destination for read
		#25 ipReset <= 0;
		ipRxStream.Destination <= 8'h00;
		ipRxStream.Valid <= 1;
		//initial data is address
		ipRxStream.Data <= 8'h02030405;
		ipRxStream.
		opTxReady <= 1;
	end

	always #10 begin
		ipClk <= ~ipClk;
	end


	always @(posedge ipClk) begin
		if (opTxStream.EoP) begin
			opTxReady <= 1;
		end else begin
			opTxReady <= 0;
		end
	end

	ReadController DUT(
		.ipReadData(ipReadData),
		.opTxReady(opTxReady),
		.ipRxStream(ipRxStream),
		.opTxStream(opTxStream),
		.ipReset(ipReset),
		.ipClk(ipClk)
	);
endmodule