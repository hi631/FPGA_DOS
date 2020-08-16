set_time_format -unit ns -decimal_places 3
create_clock -period 20.000 [get_ports {clk50m}]
derive_pll_clocks
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[1]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[1]}]  -to  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[3]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[4]}]
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[3]}] -to [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[4]}] -to [get_clocks {sys_inst|dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]}]  
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}]  
set_false_path  -from  [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[0]}]  
set_false_path -from [get_clocks {clk50m}] -to [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[3]}]
set_false_path -from [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[3]}] -to [get_clocks {clk50m}]
set_false_path -from [get_clocks {clk50m}] -to [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}]
set_false_path -from [get_clocks {sys_inst|dcm_system|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {clk50m}]

set_false_path -from [get_registers {system:sys_inst|VGA_SC:sc|planarreq}]
set_false_path -from [get_registers {sys_inst|CPUUnit|cpu*}] -through [get_nets {sys_inst|CPUUnit|cpu|ALU16|HINIBBLE~0 sys_inst|CPUUnit|cpu|ALU16|HINIBBLE~1 sys_inst|CPUUnit|cpu|ALU16|HINIBBLE~2 sys_inst|CPUUnit|cpu|ALU16|LONIBBLE~0}] -to [get_cells {sys_inst|cache_ctl|cache_addr*}]
#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from [get_registers {sys_inst|CPUUnit|cpu*}] -setup -start 2
set_multicycle_path -from [get_registers {sys_inst|CPUUnit|cpu*}] -hold -start 1


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



# How to change the PLL frequency after compilation
# 1 - Locate the PLL in the hierarchy, right click and select <Locate Node>/<Locate in Resource Property Editor>
# 2 - Change the desired parameters (the non grayed ones)
# 3 - In the main menu select <Edit>/<Check and Save all Netlist Changes>
# 4 - Wait for Fitter and Assembler