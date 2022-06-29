import Structures::*;

module ReadController #(
  parameter DATA_LENGTH = 4
) (
  input   reg [31:0]    ipReadData,
  input   reg           opTxReady,
  input   reg           ipReset,
  input   reg           ipClk,
  input  UART_PACKET   opRxStream, // packet module will generate this
  
  output  UART_PACKET   ipTxStream, // we will be assigning items to send here
  output  reg [7:0]     opReadAddress
);

  reg reset;
  reg [3:0] dataLength = DATA_LENGTH;

  /*********************************************************************************************************************
  * FOR THE READING END WE ONLY RECEIVE THE ADDRESS AS DATA. WE WILL USE THE ADDRESS TO SELECT WHERE TO READ FROM AND *
  *                         SET THE DATA TO THE OUTPUT READ STREAM. WE NEED TO GATE ON VALID                          *
  *********************************************************************************************************************/
  typedef enum { 
    IDLE,
    GET_ADDRESS,
    SET_DATA
  } State;

  State state;
  always @(posedge ipClk) begin
    reset <= ipReset;
    if(reset) begin
      dataLength <= DATA_LENGTH;
      state <= IDLE;
    end else begin
      if (opRxStream.Valid) begin
         case (state)
          IDLE: begin
            dataLength <= DATA_LENGTH;
            ipTxStream.Valid <= 0;
            ipTxStream.Source <=  8'hz; // can be anything, not sure if it matters
            ipTxStream.Destination <= 8'hz; // we have to write in the receiver
            ipTxStream.Length <= DATA_LENGTH;
            ipTxStream.SoP <= 0;
            ipTxStream.EoP <= 0;
            if (opRxStream.Destination == 8'h00) begin
              state <= GET_ADDRESS;
            end
          end
          GET_ADDRESS: begin
            opReadAddress <= opRxStream.Data;
            state <= SET_DATA;
          end
          SET_DATA: begin
          
              // we have to read 4 bytes here and send them back
              ipTxStream.Valid <= 1;
              ipTxStream.Source <= opRxStream.Source; // can be anything, not sure if it matters
              ipTxStream.Destination <= opRxStream.Destination; // we have to write in the receiver
              ipTxStream.Length <= DATA_LENGTH;

              dataLength <= dataLength - 1;
              case(dataLength)
                4:begin
                  ipTxStream.SoP <= 1;
                  ipTxStream.Data <= ipReadData[31:24];
                end
                3: begin
                  ipTxStream.SoP <= 0;
                  ipTxStream.Data <= ipReadData[23:16];
                end
                2: begin
                  ipTxStream.Data <= ipReadData[15:8];
                end
                1: begin
                  ipTxStream.Data <= ipReadData[7:0];
                  ipTxStream.EoP <= 1;
                  state <= IDLE;
                end
                default: begin
                  state <= IDLE;
                end 
              endcase

            end
          
          default: begin
            state <= IDLE;
          end
        endcase
      end
    end
  end
endmodule