--------------------------------------------------------------------------------
--    This file is owned and controlled by Xilinx and must be used solely     --
--    for design, simulation, implementation and creation of design files     --
--    limited to Xilinx devices or technologies. Use with non-Xilinx          --
--    devices or technologies is expressly prohibited and immediately         --
--    terminates your license.                                                --
--                                                                            --
--    XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY    --
--    FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY    --
--    PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE             --
--    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS      --
--    MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY      --
--    CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY       --
--    RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY       --
--    DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE   --
--    IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR          --
--    REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF         --
--    INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A   --
--    PARTICULAR PURPOSE.                                                     --
--                                                                            --
--    Xilinx products are not intended for use in life support appliances,    --
--    devices, or systems.  Use in such applications are expressly            --
--    prohibited.                                                             --
--                                                                            --
--    (c) Copyright 1995-2020 Xilinx, Inc.                                    --
--    All rights reserved.                                                    --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- You must compile the wrapper file rom8k.vhd when simulating
-- the core, rom8k. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY rom8k IS
  PORT (
    a : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END rom8k;

ARCHITECTURE rom8k_a OF rom8k IS
-- synthesis translate_off
COMPONENT wrapped_rom8k
  PORT (
    a : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

-- Configuration specification
  FOR ALL : wrapped_rom8k USE ENTITY XilinxCoreLib.dist_mem_gen_v7_2(behavioral)
    GENERIC MAP (
      c_addr_width => 13,
      c_default_data => "0",
      c_depth => 8192,
      c_family => "spartan6",
      c_has_clk => 0,
      c_has_d => 0,
      c_has_dpo => 0,
      c_has_dpra => 0,
      c_has_i_ce => 0,
      c_has_qdpo => 0,
      c_has_qdpo_ce => 0,
      c_has_qdpo_clk => 0,
      c_has_qdpo_rst => 0,
      c_has_qdpo_srst => 0,
      c_has_qspo => 0,
      c_has_qspo_ce => 0,
      c_has_qspo_rst => 0,
      c_has_qspo_srst => 0,
      c_has_spo => 1,
      c_has_spra => 0,
      c_has_we => 0,
      c_mem_init_file => "rom8k.mif",
      c_mem_type => 0,
      c_parser_type => 1,
      c_pipeline_stages => 0,
      c_qce_joined => 0,
      c_qualify_we => 0,
      c_read_mif => 1,
      c_reg_a_d_inputs => 0,
      c_reg_dpra_input => 0,
      c_sync_enable => 1,
      c_width => 8
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_rom8k
  PORT MAP (
    a => a,
    spo => spo
  );
-- synthesis translate_on

END rom8k_a;
