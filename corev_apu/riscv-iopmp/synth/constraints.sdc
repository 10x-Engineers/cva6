# 0.5 = 2 GHz and Duty Cycle is 0.25 = 50%

# create_clock -name clk -period 0.5 -waveform {0 0.25} [get_ports clk]
create_clock -name clk -period 1 -waveform {0 0.5} [get_ports clk]

# 0.05 clock transition delay at 2 GHz Frequency

# set_clock_transition -rise 0.05 [get_clocks "clk"]
# set_clock_transition -fall 0.05 [get_clocks "clk"]
set_clock_transition -rise 0.1 [get_clocks "clk"]
set_clock_transition -fall 0.1 [get_clocks "clk"]

# clock uncertainity is 0.05 at 2 GHz

# set_clock_uncertainty -setup 0.05 [get_clocks "clk"]
set_clock_uncertainty 0.1 [get_clocks "clk"]


set_input_delay -clock clk -min 0.1 [all_inputs]
set_output_delay -clock clk -min 0.1 [all_outputs]
set_false_path -from [get_ports rst_n]

#set_max_fanout 64
#set_max_delay 0.8 -from [all_inputs] -to [all_outputs]
#set_max_delay 0.8 -from [all_inputs] -to [all_registers]
#set_max_delay 0.8 -from [all_registers] -to [all_registers]
#set_max_delay 0.8 -from [all_registers] -to [all_outputs]