set EXTCLK "clk" ;

set_units -time 1.0ns ;

#set_units -capacitance 1.0pF ;

set EXTCLK_PERIOD 100.0; #10MHz

create_clock -name "$EXTCLK" -period  "$EXTCLK_PERIOD"  -waveform "0 [expr $EXTCLK_PERIOD/2]" [get_ports clk]

# clock skew setting 
#set SKEW 0.50
set SKEW 0.200
set_clock_uncertainty $SKEW [get_clocks $EXTCLK]


# clock latency SR - Source Rise SF - Source Fall
# Number has to be set iteratively by looking at the actual clock network latency 
# the latency would be between 0.8 to 1.5 ns. 3.00 is too much. 
#set SRLATENCY 3.00
#set SFLATENCY 2.95
set SRLATENCY 0.80
set SFLATENCY 0.75 

# clock transition
set MINRISE 0.20
set MAXRISE 0.25
set MINFALL 0.15 
set MAXFALL 0.10 

set_clock_transition -rise -min  $MINRISE [get_clocks $EXTCLK]
set_clock_transition -rise -max  $MAXRISE [get_clocks $EXTCLK]

set_clock_transition -fall -min  $MINFALL [get_clocks $EXTCLK]
set_clock_transition -fall -max  $MAXFALL [get_clocks $EXTCLK]


#
set INPUT_DELAY 0.5 
set OUTPUT_DELAY 0.5


#
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports en]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports start]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports data_in]

set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports rdy]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports output_enable]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports data_out]




