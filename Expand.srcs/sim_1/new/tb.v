`timescale 1ns / 1ps
`define Period 10
`define testNum 1024


module tb();

    reg clk;
    reg rst;
    reg start;
    reg queryValid;    
    reg dataValid;
    reg[8:0] shiftNo;
    reg[16:0] dataCounter;
    reg[511:0] inQuery;
    reg [8:0] LocationQ;
    reg [511:0]inDB;
       
    wire load;
    wire loadDone;
    wire [31:0] outAddress;
    wire [31:0] locationStart;
    wire [31:0] locationEnd;
    wire stop;
    
        reg [9:0] shiftNumber;
        reg [511:0] dataSet1;
        reg [511:0] dataSet2;
        reg [31:0] addressCalc;
        reg [1023:0] dataMerged = 1024'b0;
        reg [511:0] dataMatchedQuery;
        reg [511:0] Query;
        reg [2:0] state;
             
        reg [8:0] range1;
        reg [8:0] range2;
        reg [8:0] k1=0;
        reg [8:0] k2=0;
        reg [8:0] i1;
        reg [8:0] i2 = 0;
        integer j;
        reg [8:0] difference;     
initial
begin
    clk = 0;
    forever
    begin
        clk = ~clk;
        #(`Period/2);
    end
end

initial
begin
    rst = 1'b1;
    start = 1'b0;

     #50;
     rst = 1'b0;
     #50
     start = 1'b1;
     @(posedge clk);
     inQuery = 512'hfff;
     queryValid =1'b1;  
     dataValid = 1'b1;
     shiftNo = 9'ha;
     dataCounter = 17'b0 ;
     LocationQ = 9'h28;
     inDB = 512'h0; 
end

always@(posedge clk)
begin
     if(rst)
       begin
        start = 1'b0;
        queryValid =1'b0;
        dataValid = 1'b0;
       end
      else 
      begin
       start = 1'b1;
       queryValid =1'b1;
       dataValid = 1'b1;
      end
end

ExpandFSM exp(
    .clk(clk),
    .rst(rst),
    .start(start),
    .queryValid(queryValid),    
    .dataValid(dataValid),
    .shiftNo(shiftNo),
    .dataCounter(dataCounter),
    .inQuery(inQuery),
    .LocationQ(LocationQ),
    .inDB(inDB),
       
    .load(load),
    .loadDone(loadDone),
    .outAddress(outAddress),
    .locationStart(locationStart),
    .locationEnd(locationEnd),
    .stop(stop)
    );
endmodule