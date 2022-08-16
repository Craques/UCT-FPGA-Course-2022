import Structures::*;

module WriteController #(DATA_LENGTH = 4) (
  input                 ipClk,
  input                 ipReset,
  input UART_PACKET     ipRxStream,

  output reg            opTxWrEnable,
  output reg [7:0]      opAddress,
  output reg [31:0]     opWrData
);
  typedef enum { 
    IDLE,
    GET_DATA
  } State;
  //local reset
  reg reset;
  State state;
  reg [3:0] dataLength;
 
  always @(posedge ipClk) begin
    reset <= ipReset;
    /******************************************************************************************************
    * PROCEDURE TO TRANSMIT INVOLVES COLLECTING 4 PACKETS AND STORING THEIR DATA IN THE WRITE REGISTERS. *
    * THE FIRST DATA ON SYNC WILL BE THE ADDRESS. EVERYTHING WILL BE DONE ON VALID, GATE ON OPTXWRENABLE *
    ******************************************************************************************************/
    if (reset) begin
      opWrData <= 32'bz;
      opAddress <= 8'bz;  
      state <= IDLE;
      opTxWrEnable <= 0;
    end else if (ipRxStream.Valid) begin
     case (state)
      IDLE: begin
        dataLength <= DATA_LENGTH;
        opTxWrEnable <=0;
        if(ipRxStream.Source == 8'h01 && ipRxStream.SoP == 1 && ipRxStream.Valid) begin
          opAddress <= ipRxStream.Data;
          state <= GET_DATA;
        end
      end
      GET_DATA: begin
        if(dataLength > 0) begin
          dataLength <= dataLength -1;
          opTxWrEnable <= 1;
          opWrData <= {opWrData, ipRxStream.Data};
          if(ipRxStream.EoP) begin
            state <= IDLE;
          end
        end else begin
          state <= IDLE;
        end
      end
      default: begin
        state <= IDLE;
      end 
     endcase
    end
  end
endmodule //TransmitController