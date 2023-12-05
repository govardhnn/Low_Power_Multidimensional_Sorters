`timescale 10ns / 1ps

module MDSA_FSM(
    input wire START,
    input wire clk,
    input wire rst,
    input wire en,
    output wire [7:0]DIRECTION,
    output wire READY,
    output wire trans,
    output wire output_enable
    );
    
        localparam[3:0] WAIT=4'b0000,PHASE1=4'b0001,PHASE2=4'b0010,
                    PHASE3=4'b0011,PHASE4=4'b0100,PHASE5=4'b0101,
                    PHASE6=4'b0110,
                    DELAY=4'b1000; 
                    reg[2:0] state=WAIT;
		    reg[2:0] prev_state=WAIT;
                    reg [7:0]dir=8'b00000000;
                    reg rdy=1'b1;
                    reg start;
                    
					reg [3:0]count_reg=4'b0000;
                    reg output_enable_reg=1'b0;
                    reg tr=1'b0;
					
					reg[2:0] state_reg=WAIT;
                    reg[2:0] prev_state_reg=WAIT;
					reg flag=1'b0;
					
					wire [3:0]count;
					wire count_delay_tick,count_1_tick,count_2_tick;
					wire FLAG;
					
					//Counter 
                    always@(posedge clk) begin 
                        if(flag | rst) begin 
                            count_reg<=4'b0000;
                        end
                        else begin 
                            count_reg<=count;
                        end
                    end
                    
                    assign count = count_reg + 1;
                    
                    //count ticks
                    assign count_delay_tick=(count_reg==DELAY) ? 1'b1:1'b0;
                    assign count_1_tick=(count_reg==4'b0001) ? 1'b1:1'b0;
                    assign count_2_tick=(count_reg==4'b0010) ? 1'b1:1'b0;
                    
                    //state update
                    always@(posedge clk) begin 
                        if(rst & !flag) begin 
                            prev_state_reg<=WAIT;
                            state_reg<=WAIT;
                        end
                        else if(flag & !rst) begin 
                            prev_state_reg<=prev_state;
                            state_reg<=state;
                        end
                        //else begin 
                            //state_reg<=state;
                        //end
                    end
                    
					//FSM state transition, trans, direction and output_enable generation
                    always @* begin 
                        if((en)&(!rst)) begin
                            case(state_reg)
                                WAIT: begin
                                    if(START) begin 
                                        output_enable_reg<=1'b0;
                                        rdy<=1'b0;
					prev_state<=WAIT;
                                        state<=PHASE1;
                                        dir<=8'b00000000;
                                        tr<=1'b0; flag<=1'b1;
                                    end
                                    else begin 
                                        if(prev_state_reg==PHASE6) begin
                                            if(count_delay_tick) begin 
						prev_state<=WAIT;
                                                state<=WAIT;
                                                output_enable_reg<=1'b1;
                                                rdy<=1'b1;
                                                dir<=8'b00000000;
                                                tr<=1'b1;flag<=1'b1;
                                            end
                                            else begin 
						prev_state<=WAIT;
                                                state<=WAIT;
                                                output_enable_reg<=1'b0;
                                                rdy<=1'b0;
                                                dir<=8'b00000000;
                                                tr<=1'b0;flag<=1'b0;
                                            end
                                        end
                                        else begin 
                                            tr<=1'b0;flag<=1'b0;
					    prev_state<=WAIT;
                                            state<=WAIT;
                                            dir<=8'b00000000;
                                            rdy<=1'b1;
                                            output_enable_reg<=1'b0;                                              
                                        end
                                    end
                                end
                                
                                PHASE1: begin 
                                    if(count_1_tick) begin 
					prev_state<=WAIT;
                                        state<=PHASE1;
                                        tr<=1'b1;flag<=1'b0;
                                        dir<=8'b00000000;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;								
                                    end
                                    else if(count_2_tick) begin 
					prev_state<=WAIT;
                                        state<=PHASE1;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b00000000;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;	
                                    end
                                    else if(count_delay_tick) begin 
					prev_state<=PHASE1;
                                        state<=PHASE2;
                                        tr<=1'b1;flag<=1'b1;
                                        dir<=8'b01010101;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;
                                    end
                                    else begin 
					prev_state<=WAIT;
                                        state<=PHASE1;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b00000000;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;								    
                                    end                                    
                                end 
                                
                                PHASE2: begin 
                                   if(count_delay_tick) begin 
				       prev_state<=PHASE2;
                                       state<=PHASE3;
                                       tr<=1'b1;flag<=1'b1;
                                       dir<=8'b00000000; 
                                       rdy<=1'b0;
                                       output_enable_reg<=1'b0;                                   
                                   end 
                                   else begin 
					prev_state<=PHASE1;
                                        state<=PHASE2;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b01010101;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;
                                   end                                
                                end     
                                            
                                PHASE3: begin 
                                  if(count_delay_tick) begin 
				      prev_state<=PHASE3;
                                      state<=PHASE4;
                                      tr<=1'b1;flag<=1'b1;
                                      dir<=8'b10101010;  
                                      rdy<=1'b0;
                                      output_enable_reg<=1'b0;                                   
                                  end
                                  else begin 
					prev_state<=PHASE2;
                                        state<=PHASE3;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b00000000;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;
                                   end                                   
                                end     
                                    
                                PHASE4: begin 
                                 if(count_delay_tick) begin 
				     prev_state<=PHASE4;
                                     state<=PHASE5;
                                     tr<=1'b1;flag<=1'b1;
                                     dir<=8'b00000000;
                                     rdy<=1'b0;
                                     output_enable_reg<=1'b0;                                   
                                 end
                                 else begin 
					prev_state<=PHASE3;
                                        state<=PHASE4;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b10101010;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;
                                  end                                                                
                                end
                                
                                PHASE5: begin 
                                if(count_delay_tick) begin 
				    prev_state<=PHASE5;
                                    state<=PHASE6;
                                    tr<=1'b1;flag<=1'b1;
                                    dir<=8'b00000000;
                                    rdy<=1'b0;
                                    output_enable_reg<=1'b0;                                    
                                end
                                else begin 
					prev_state<=PHASE4;
                                        state<=PHASE5;
                                        tr<=1'b0;flag<=1'b0;
                                        dir<=8'b00000000;
                                        rdy<=1'b0;
                                        output_enable_reg<=1'b0;
                                end                                                               
                                end  
                                
                                PHASE6: begin 
                                   if(count_delay_tick) begin
				       prev_state<=PHASE6;
                                       state<=WAIT;
                                       tr<=1'b1;flag<=1'b1;
                                       dir<=8'b00000000;
                                       rdy<=1'b0;
                                       output_enable_reg<=1'b0;                                   
                                   end
                                   else begin 
					    prev_state<=PHASE5;
                                            state<=PHASE6;
                                            tr<=1'b0;flag<=1'b0;
                                            dir<=8'b00000000;
                                            rdy<=1'b0;
                                            output_enable_reg<=1'b0;
                                   end                                                             
                               end
                               
                                default: begin 
                                    tr<=1'b0;flag<=1'b0;
				    prev_state<=WAIT;
                                    state<=WAIT;
                                    dir<=8'b00000000;
                                    rdy<=1'b0;
                                    output_enable_reg<=1'b0;   
                                    end
                            endcase    
                    end
                    
                        else if(rst) begin 
                            tr<=1'b0;flag<=1'b0;
			    prev_state<=WAIT;
                            state<=WAIT;
                            dir<=8'b00000000;
                            rdy<=1'b0;
                            output_enable_reg<=1'b0;
                        end
                        
                        else begin 
                            tr<=trans;
                            flag<=FLAG;
			    prev_state<=prev_state_reg;
                            state<=state_reg;
                            dir<=DIRECTION;
                            rdy<=READY;
                            output_enable_reg<=output_enable;
                        end
                    end
                    
                    assign DIRECTION=dir;
                    assign READY=rdy;
                    assign output_enable=output_enable_reg;
                    assign trans=tr;
                    assign FLAG=flag;
endmodule
