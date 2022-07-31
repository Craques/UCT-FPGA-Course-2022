import Structures::*;

/*************************************************************************
 * DEPENDING ON THE GIVEN ADDRESS THIS MODULE WILL EITHER READ OR WRITE, *
 *          - DURING THE READ PROCESS WE NEED TO SEND A PACKET,          *
 *  - DURING THE WRITE PROCESS WE NEED TO STORE THE DATA IN LOCALMEMORY  *
 *************************************************************************/

 module StreamController(
  input   reg [31:0]    ipReadData,
  input   reg           ipTxReady,
  input   reg           ipReset,
  input   reg           ipClk,
  input   UART_PACKET   ipRxStream, // packet module will generate this

  output  UART_PACKET   opTxStream, // we will be assigning items to send here
  output  reg [7:0]     opAddress,
  output  reg [31:0]    opWriteData,
  output  reg           opWriteEnable  
 );

  reg [3:0] readDataLength =  4'b0100;
  //handle read first
  typedef enum {
    IDLE,
    SEND_READ_ADDRESS,
    READ_DATA, 
    SEND_WRITE_ADDRESS,
    WRITE_DATA
  } State; 

  State state;
  always @(posedge ipClk) begin
    if (ipReset) begin
      state <= IDLE;
      opTxStream.Valid <= 0;
      opWriteEnable <= 0;
    end else begin
      case (state)
        IDLE: begin
          readDataLength <=  4'b0100;
          opWriteEnable <= 0;
          //Read transmit packet setup
          opTxStream.Source <= opTxStream.Destination;
          opTxStream.Destination <= opTxStream.Source;
          opTxStream.Length <= 5;
          opAddress <= ipRxStream.Data;
          readDataLength <= 4;
          // Check address to verify if it is read or write
          if(ipRxStream.Valid && ipRxStream.SoP) begin
            case (ipRxStream.Destination)
              8'h00: state <= SEND_READ_ADDRESS;
              8'h01: state <= WRITE_DATA;
              default: state <= state;
            endcase
          end
        end

        SEND_READ_ADDRESS: begin
          if (ipTxReady) begin
            opTxStream.Data <= opAddress;
            opTxStream.Valid <= 1;
            opTxStream.SoP <= 1;
            state <= READ_DATA;
          end
        end
        
        READ_DATA: begin
          if(ipTxReady) begin
            readDataLength <= readDataLength - 1;
            case (readDataLength)
              4'b0100: begin
                opTxStream.Data <= ipReadData[ (4 * 8)-1 -:8];
              end
              4'b0011: begin
                opTxStream.Data <= ipReadData[ (3 * 8)-1 -:8];
              end
              4'b0010: begin
                opTxStream.Data <= ipReadData[ (2 * 8)-1 -:8];
              end
              4'b0001: begin
                opTxStream.Data <= ipReadData[ (1 * 8)-1 -:8];
                opTxStream.EoP <= 1;
              end
              default:begin
                opTxStream.Valid <=0;
                state <= IDLE;
              end
            endcase
          end

        end

        SEND_WRITE_ADDRESS: begin
          if(ipRxStream.Valid) begin 
            opAddress <= ipRxStream.Data;
            state <= WRITE_DATA;
          end
        end

        WRITE_DATA: begin 
          if (ipRxStream.Valid) begin
            readDataLength <= readDataLength - 1;
            opWriteData <= {ipRxStream.Data, opWriteData[31:8]};
            if(readDataLength == 0) begin
              state <= IDLE;
              opWriteEnable <= 1;
            end
          end
        end
        default:;
      endcase
    end
  end 
 endmodule