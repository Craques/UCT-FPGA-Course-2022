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
  reg [1:0] edgeDetector = 0;
  /*********************************************************************************************************************
  * FOR THE READING END WE ONLY RECEIVE THE ADDRESS AS DATA. WE WILL USE THE ADDRESS TO SELECT WHERE TO READ FROM AND *
  *                         SET THE DATA TO THE OUTPUT READ STREAM. WE NEED TO GATE ON VALID                          *
  *********************************************************************************************************************/
  typedef enum { 
    IDLE,
    SET_DATA
  } State;

  State state;


  always @(posedge ipClk) begin
    reset <= ipReset;
    
    if(reset) begin
      state <= IDLE;
      dataLength <= DATA_LENGTH;
    end else begin
        edgeDetector <= {ipTxReady, edgeDetector[1]};


        case (state)
        IDLE: begin
          opTxStream.Valid <= 0;
          opTxStream.Source <=  8'hz; // can be anything, not sure if it matters
          opTxStream.Destination <= 8'hz; // we have to write in the receiver
          opTxStream.Length <= DATA_LENGTH;
          opTxStream.EoP <= 0;
          if (ipRxStream.Destination == 8'h00 && ipRxStream.Valid) begin
            opReadAddress <= ipRxStream.Data;
            // we have to read 4 bytes here and send them back
            state <= SET_DATA;
            opTxStream.Source <= ipRxStream.Destination; // can be anything, not sure if it matters
            opTxStream.Destination <= ipRxStream.Source; // we have to write in the receiver
            opTxStream.Length <= DATA_LENGTH;
          end
        end
       
        SET_DATA: begin
          if (edgeDetector[1] == 1 && edgeDetector[0] == 0) begin
            dataLength <= dataLength - 1;
            opTxStream.Valid <= 1;
          end else begin
            opTxStream.Valid <= 0;
          end

          if (dataLength == 0) begin
            state <= IDLE;
          end else begin
            case(dataLength)
              4:begin
                opTxStream.SoP <= 1;
                opTxStream.Data <=  ipReadData[31:24];
              end
              3: begin
                opTxStream.SoP <= 0;
                opTxStream.Data <=  ipReadData[23:16];
              end
              2: begin
                opTxStream.Data <=  ipReadData[15:8];
              end
              1: begin
                opTxStream.Data <=  ipReadData[7:0];
                opTxStream.EoP <= 1;
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