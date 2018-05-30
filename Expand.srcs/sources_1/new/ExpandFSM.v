`timescale 1ns / 1ps
`define th 200

   module ExpandFSM(
    input clk,
    input rst,
    input start,
    input queryValid,    
    input dataValid,
    input[8:0] shiftNo,
    input[16:0] dataCounter,
    input[511:0] inQuery,
    input [8:0] LocationQ,
    input [511:0]inDB,
       
    output reg load,
    output reg loadDone,
    output [31:0] outAddress,
    output reg [31:0] locationStart,
    output reg [31:0] locationEnd,
    output reg stop
    );
    
    reg [9:0] shiftNumber;
    reg [511:0] dataSet1;
    reg [511:0] dataSet2;
    reg [31:0] addressCalc;
    reg [1023:0] dataMerged = 1024'b0;
    reg [511:0] dataMatchedQuery;
    reg [511:0] Query;
    reg [2:0] state;
         
    wire [8:0] range1;
    wire [8:0] range2;
    reg [8:0] k1=0;
    reg [8:0] k2=0;
    reg [8:0] i1;
    reg [8:0] i2 = 0;
    integer j;
    wire [8:0] difference; 
    
    localparam IDLE = 2'b00,
               LOAD = 2'b01,
               EXPAND = 2'b10;
    
    assign outAddress = addressCalc;
    assign difference = shiftNumber >= LocationQ ? (shiftNumber - LocationQ) : (LocationQ - shiftNumber);   
    assign  range1 = LocationQ <= `th ? LocationQ : `th;    
    assign  range2 = (512 - (LocationQ + 22)) <= `th ? (512 - (LocationQ + 22)) : `th;   
        
    always @(posedge clk)
    begin
        if(rst)
        begin
            state <= IDLE;
            load = 1'b0;
            stop =  1'b0;
            loadDone = 1'b0;
        end
        else
        begin
            case(state)
                IDLE:begin
                    shiftNumber = shiftNo;  
                    addressCalc = dataCounter * 512 + shiftNumber;
                    i1 <= LocationQ;
                    i2 <= LocationQ + 21;
                    locationStart <= dataCounter * 512 + shiftNumber;
                    locationEnd <= dataCounter * 512 + shiftNumber + 21;
                    if(queryValid)
                        Query <= inQuery;
                    if(start)
                        state <=LOAD;
                end
                LOAD:begin
                    load <= 1'b1;
                    if(dataValid)
                    begin    
                        dataSet1 <= inDB;
                        loadDone <= 1'b1;
                    end    
                    if (shiftNumber > 199 & shiftNumber < 290)
                    begin
                        load = 1'b0;
                    end        
                    else if(shiftNumber < 199)
                    begin
                         loadDone <= 1'b0;
                         addressCalc <= addressCalc - 512; // to take the previous block
                         shiftNumber <= shiftNumber + 512; // 
                         if(dataValid)
                         begin
                            dataSet2 <= inDB;
                            loadDone <= 1'b1;
                         end   
                         dataMerged[511:0] <= dataSet1;
                         dataMerged[1023:512] <= dataSet2;
                         
                    end
                    else if(shiftNumber > 290)
                    begin
                         loadDone = 1'b0;
                         addressCalc <= addressCalc + 512;
                         if(dataValid)
                         begin
                             dataSet2 <= inDB;
                             loadDone <= 1'b1;
                         end                            
                         dataMerged[511:0] <= dataSet2;
                         dataMerged[1023:512] <= dataSet1;
                    end
                    state <= EXPAND;
                end
                EXPAND:begin
                        for(j = 0; j < 512; j = j + 1 )
                        dataMatchedQuery[j] <= dataMerged[j+difference];
                        if(dataMatchedQuery[i1-:2] != Query[i1-:2] & dataMatchedQuery[i2+:2] != Query[i2+:2]) 
                            stop = 1'b1;
                        else if(k1 == range1 & k2 == range2)
                            stop = 1'b1;
                        else 
                        begin
                            if(k1 != range1)
                            begin
                              stop = 1'b0;
                              k1 = k1 + 2;
                              i1 = i1 - 2; 
                              if(dataMatchedQuery[i1-:2] == Query[i1-:2]) 
                                   locationStart <= locationStart - 2;
                            end
                            //else if(k1 == range1)
                            if(k2 != range2)
                            begin
                                stop = 1'b0;
                                k2 <= k2 + 2;
                                i2 <= i2 + 2; 
                                if(dataMatchedQuery[i2+:2] == Query[i2+:2]) 
                                   locationEnd  <= locationEnd + 2;
                            end    
                        end        
                end
            endcase
        end
    end        

    
    endmodule
    