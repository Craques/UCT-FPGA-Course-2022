import Structures::*;

module ReadController #(
  parameter DATA_LENGTH = 4
) (
  input   reg [31:0]    ipReadData,
  input   reg           ipTxReady,
  input   reg           ipReset,
  input   reg           ipClk,
  input  UART_PACKET   ipRxStream, // packet module will generate this
  
  output  UART_PACKET   opTxStream, // we will be assigning items to send here
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
    SET_DATA,
    BUSY
  } State;

  State state;

  always @(posedge ipTxReady) begin
    reset <= ipReset;
    if (reset) begin
      dataLength <= DATA_LENGTH;
    end

    if(state == SET_DATA && dataLength > 0) begin
      dataLength <= dataLength -1; 
      case(dataLength)
        4:begin
          opTxStream.SoP <= 1;
          opTxStream.EoP <= 0;
          opTxStream.Data <= 8'h01;
        end
        3: begin
          opTxStream.SoP <= 0;
          opTxStream.Data <=  8'h02;
        end
        2: begin
          opTxStream.Data <=  8'h03;
        end
        1: begin
          opTxStream.Data <=  8'h04;
          opTxStream.EoP <= 1;
        end
        default: begin
        end 
      endcase 
    end else begin
      state <= IDLE;
    end
  end

  always @(posedge ipClk) begin
    
    if(reset) begin
      state <= IDLE;
    end else begin
        case (state)
        IDLE: begin
          opTxStream.Valid <= 0;
          opTxStream.Source <=  8'hz; // can be anything, not sure if it matters
          opTxStream.Destination <= 8'hz; // we have to write in the receiver
          opTxStream.Length <= DATA_LENGTH;
          
          if (ipRxStream.Destination == 8'h00 && ipRxStream.Valid) begin
            opReadAddress <= ipRxStream.Data;
            // we have to read 4 bytes here and send them back
            opTxStream.Valid <= 1;
            state <= SET_DATA;
            opTxStream.Source <= ipRxStream.Destination; // can be anything, not sure if it matters
            opTxStream.Destination <= ipRxStream.Source; // we have to write in the receiver
            opTxStream.Length <= DATA_LENGTH;
          end
        end
       
        SET_DATA: begin
          if (dataLength == 0 && ipTxReady) begin
            opTxStream.Valid <= 0;
          end
        end
        default: begin
          state <= IDLE;
        end
      endcase
    
    end
  end
endmodule