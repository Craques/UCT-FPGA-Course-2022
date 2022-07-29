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
  output reg [31:0]     opWriteData 
 );

  reg [2:0] readDataLength = 5;
 //handle read first
  typedef struct {
    IDLE,
    SEND_READ_ADDRESS,
    SEND_DATA
  } State; 

  State state;
  always @(posedge ipClk) begin
    if (ipReset) begin
      state <= IDLE;
      reg [2:0] readDataLength <= 5;
      opTxStream.Valid <= 0;
    end else begin
      case (state)
        IDLE: begin
          //Read transmit packet setup
          opTxStream.Source <= opTxStream.Destination;
          opTxStream.Destination <= opTxStream.Source;
          opAddress <= ipRxStream.Data;

          // Check address to verify if it is read or write
          if(ipRxStream.Valid && ipRxStream.Sop) begin
            case (ipRxStream.Destination)
              8'h00: state <= SEND_READ_ADDRESS;
              8'h01:;
              default:;
            endcase
          end
        end

        SEND_READ_ADDRESS: begin
          if (ipTxReady) begin
            opTxStream.Data <= opAddress;
            ipTxStream.Valid <= 1;
            ipTxStream.SoP <= 1;
          end
        end
        default:;
      endcase
    end
  end 
 endmodule