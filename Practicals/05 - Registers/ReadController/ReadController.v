import Structures::*;

module ReadController #(
  parameter DATA_LENGTH = 4
) (
  input   reg [31:0]    ipReadData,
  input   reg           ipTxReady,
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
    SET_DATA,
    BUSY
  } State;

  State state;
  always @(posedge ipClk) begin
    reset <= ipReset;
    if(reset) begin
      dataLength <= DATA_LENGTH;
      state <= IDLE;
    end else begin
      
        case (state)
        IDLE: begin
          dataLength <= DATA_LENGTH;
          ipTxStream.Valid <= 0;
          ipTxStream.Source <=  8'hz; // can be anything, not sure if it matters
          ipTxStream.Destination <= 8'hz; // we have to write in the receiver
          ipTxStream.Length <= DATA_LENGTH;
          ipTxStream.SoP <= 0;
          ipTxStream.EoP <= 0;
          if (opRxStream.Destination == 8'h00 && opRxStream.Valid) begin
            opReadAddress <= opRxStream.Data;
            // we have to read 4 bytes here and send them back
            ipTxStream.Valid <= 1;
            state <= SET_DATA;
            ipTxStream.Source <= opRxStream.Destination; // can be anything, not sure if it matters
            ipTxStream.Destination <= opRxStream.Source; // we have to write in the receiver
            ipTxStream.Length <= DATA_LENGTH;
          end
        end
        BUSY: begin
          if(ipTxReady) begin
            dataLength <= dataLength - 1;
            state <= SET_DATA;
          end
        end
        SET_DATA: begin
          
          if (ipTxReady) begin
            case(dataLength)
              4:begin
                ipTxStream.SoP <= 1;
                state <= BUSY;
                ipTxStream.Data <= ipReadData[31:24];
              end
              3: begin
                state <= BUSY;
                ipTxStream.SoP <= 0;
                ipTxStream.Data <= ipReadData[23:16];
              end
              2: begin
                state <= BUSY;
                ipTxStream.Data <= ipReadData[15:8];
              end
              1: begin
                $display("THREE");
                ipTxStream.Data <= ipReadData[7:0];
                ipTxStream.EoP <= 1;
                state <= IDLE;
              end
              default: begin
                state <= IDLE;
              end 
            endcase
          end
          
        end
        default: begin
          state <= IDLE;
        end
      endcase
    
    end
  end
endmodule