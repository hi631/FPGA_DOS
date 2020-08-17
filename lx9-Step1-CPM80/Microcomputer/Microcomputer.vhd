-- This file is copyright by Grant Searle 2014
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Microcomputer is
	port(
		p_reset		: in std_logic;
--		clk_32Mi	: in std_logic;
		clk			: in std_logic;

--		sramData		: inout std_logic_vector(7 downto 0);
--		sramAddress	: out std_logic_vector(15 downto 0);
--		n_sRamWE		: out std_logic;
--		n_sRamCS		: out std_logic;
--		n_sRamOE		: out std_logic;
		
		rxd1			: in std_logic; 
		txd1			: out std_logic;
--		rts1			: out std_logic;
--		rxd2			: in std_logic;
--		txd2			: out std_logic;
--		rts2			: out std_logic;
		
--		videoSync		: out std_logic;
--		video			: out std_logic;

--		videoR0		: out std_logic;
--		videoG0		: out std_logic;
--		videoB0		: out std_logic;
--		videoR1		: out std_logic;
--		videoG1		: out std_logic;
--		videoB1		: out std_logic;
--		hSync			: out std_logic;
--		vSync			: out std_logic;

--		ps2Clk		: inout std_logic;
--		ps2Data		: inout std_logic;

--		sdCS			: out std_logic;
--		sdMOSI		: out std_logic;
--		sdMISO		: in std_logic;
--		sdSCLK		: out std_logic;
		driveLED		: out std_logic :='1'	
	);
end Microcomputer;

architecture struct of Microcomputer is

	signal	sramData		: std_logic_vector(7 downto 0);
	signal	sramAddress	: std_logic_vector(15 downto 0);
	signal	n_sRamWE		: std_logic;
	signal	n_sRamCS		: std_logic;
	signal	n_sRamOE		: std_logic;
	signal	sdCS			: std_logic;
	signal	sdMOSI		: std_logic;
	signal	sdMISO		: std_logic;
	signal	sdSCLK		: std_logic;
--	signal	rxd1			: std_logic;
--	signal	txd1			: std_logic;
	signal	rts1			: std_logic;
	signal	rxd2			: std_logic;
	signal	txd2			: std_logic;
	signal	rts2			: std_logic;
--	signal	clk				: std_logic;
--	signal	videoSync	: std_logic;
--	signal	video			: std_logic;
	signal	videoR0		: std_logic;
	signal	videoG0		: std_logic;
	signal	videoB0		: std_logic;
	signal	videoR1		: std_logic;
	signal	videoG1		: std_logic;
	signal	videoB1		: std_logic;
	signal	hSync			: std_logic;
	signal	vSync			: std_logic;
	signal	ps2Clk		: std_logic;
	signal	ps2Data		: std_logic;

	signal n_WR							: std_logic;
	signal n_RD							: std_logic;
	signal cpuAddress					: std_logic_vector(15 downto 0);
	signal cpuDataOut					: std_logic_vector(7 downto 0);
	signal cpuDataIn					: std_logic_vector(7 downto 0);

	signal basRomData					: std_logic_vector(7 downto 0);
	signal internalRam1DataOut		: std_logic_vector(7 downto 0);
	signal internalRam2DataOut		: std_logic_vector(7 downto 0);
	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal interface2DataOut		: std_logic_vector(7 downto 0);
	signal sdCardDataOut				: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_memRD 					: std_logic :='1';

	signal n_ioWR						: std_logic :='1';
	signal n_ioRD 						: std_logic :='1';
	
	signal n_MREQ						: std_logic :='1';
	signal n_IORQ						: std_logic :='1';	

	signal n_int1						: std_logic :='1';	
	signal n_int2						: std_logic :='1';	
	
	signal n_externalRamCS			: std_logic :='1';
	signal n_internalRam1CS			: std_logic :='1';
	signal n_internalRam2CS			: std_logic :='1';
	signal n_basRomCS					: std_logic :='1';
	signal n_interface1CS			: std_logic :='1';
	signal n_interface2CS			: std_logic :='1';
	signal n_sdCardCS					: std_logic :='1';

	signal serialClkCount			: std_logic_vector(15 downto 0);
	signal cpuClkCount				: std_logic_vector(5 downto 0); 
	signal sdClkCount				: std_logic_vector(5 downto 0); 	
	signal cpuClock					: std_logic;
	signal serialClock				: std_logic;
	signal sdClock					: std_logic;	
	signal n_reset					: std_logic;
	
--component dcmclk
--port(
--  CLK_IN1           : in     std_logic;
--  CLK_50Mo          : out    std_logic
-- );
--end component;

begin
n_reset <= not p_reset;
-- ____________________________________________________________________________________
--inst_dcmclk : dcmclk
--  port map( CLK_IN1 => clk_32Mi, CLK_50Mo => clk);
-- ____________________________________________________________________________________
-- CPU CHOICE GOES HERE
cpu1 : entity work.cpu09
port map(
	clk => not(cpuClock), rst => not n_reset, rw => n_WR,
	addr => cpuAddress,data_in => cpuDataIn,data_out => cpuDataOut,
	halt => '0', hold => '0', irq => '0', firq => '0', nmi => '0'); 
-- ____________________________________________________________________________________
-- ROM GOES HERE	
rom1 : entity work.M6809_EXT_BASIC_ROM -- 8KB BASIC
port map(
	clock => clk,
	address => cpuAddress(12 downto 0), q => basRomData);
-- ____________________________________________________________________________________
-- RAM GOES HERE
ram1: entity work.InternalRam8K
port map(
	clock => clk, wren => not(n_memWR or n_internalRam1CS),
	address => cpuAddress(12 downto 0), data => cpuDataOut,
	q => internalRam1DataOut);
-- ____________________________________________________________________________________
-- INPUT/OUTPUT DEVICES GO HERE	
--io1 : entity work.SBCTextDisplayRGB
--generic map(
--	HORIZ_CHARS => 40, CLOCKS_PER_PIXEL => 6, CLOCKS_PER_SCANLINE => 3200,
--	DISPLAY_TOP_SCANLINE => 37, VERT_SCANLINES => 262, VERT_PIXEL_SCANLINES => 1,
--	VSYNC_SCANLINES => 4, HSYNC_CLOCKS => 235, DISPLAY_LEFT_CLOCK => 850
--)
--port map (
--	n_reset => n_reset,clk => clk,
-- RGB video signals
--	hSync => hSync, vSync => vSync,
--	videoR0 => videoR0, videoR1 => videoR1,
--	videoG0 => videoG0, videoG1 => videoG1,
--	videoB0 => videoB0, videoB1 => videoB1,
-- Monochrome video signals (when using TV timings only)
--	sync => videoSync, video => video,
--	n_wr => n_interface1CS or cpuClock or n_WR, n_rd => n_interface1CS or cpuClock or (not n_WR),
--	n_int => n_int1, regSel => cpuAddress(0),
--	dataIn => cpuDataOut, dataOut => interface1DataOut,
--	ps2Clk => ps2Clk, ps2Data => ps2Data
--);
-----------------------------------------
--io1s : entity work.rs232c_ps2
--port map(
--		rxClock => serialClkCount(15), n_reset => n_reset,
--		rxd => rxd1, txd => txd1,
--		ps2Clk => ps2Clk, ps2Data => ps2Data
--);
-------------------------------------------
io1 : entity work.bufferedUART
	port map(
	clk => clk,
	n_wr => n_interface1CS or cpuClock or n_WR,
	n_rd => n_interface1CS or cpuClock or (not n_WR),
	n_int => n_int1, regSel => cpuAddress(0),
	dataIn => cpuDataOut, dataOut => interface1DataOut,
	rxClock => serialClock, txClock => serialClock,
	rxd => rxd1, txd => txd1, n_cts => '0', n_dcd => '0', n_rts => rts1
	);
-----------------------------------------
-- ____________________________________________________________________________________
-- MEMORY READ/WRITE LOGIC GOES HERE
n_memRD <= not(cpuClock) nand n_WR;
n_memWR <= not(cpuClock) nand (not n_WR);
-- ____________________________________________________________________________________
-- CHIP SELECTS GO HERE
n_basRomCS <= '0' when cpuAddress(15 downto 13) = "111" else '1'; --8K at top of memory
n_interface1CS <= '0' when cpuAddress(15 downto 1) = "111111111101000" else '1'; -- 2 bytes FFD0-FFD1
n_interface2CS <= '0' when cpuAddress(15 downto 1) = "111111111101001" else '1'; -- 2 bytes FFD2-FFD3
n_sdCardCS <= '0' when cpuAddress(15 downto 3) = "1111111111011" else '1'; -- 8 bytes FFD8-FFDF 
n_internalRam1CS <= '0' when cpuAddress(15 downto 13) = "000" else '1';

-- ____________________________________________________________________________________
-- BUS ISOLATION GOES HERE
cpuDataIn <=
interface1DataOut when n_interface1CS = '0' else
interface2DataOut when n_interface2CS = '0' else
sdCardDataOut when n_sdCardCS = '0' else
basRomData when n_basRomCS = '0' else
internalRam1DataOut when n_internalRam1CS= '0' else
sramData when n_externalRamCS= '0' else  x"FF";
-- ____________________________________________________________________________________
-- SYSTEM CLOCKS GO HERE
-- SUB-CIRCUIT CLOCK SIGNALS 
serialClock <= serialClkCount(15);
process (clk)
begin
	if rising_edge(clk) then
		-- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
		if cpuClkCount < 4 then	cpuClkCount <= cpuClkCount + 1;
		else					cpuClkCount <= (others=>'0');
		end if;
			-- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
			if cpuClkCount < 2 then	cpuClock <= '0';
			else					cpuClock <= '1';
			end if; 
	-- 1MHz
	if sdClkCount < 49 then	sdClkCount <= sdClkCount + 1;
	else					sdClkCount <= (others=>'0');
	end if;
		if sdClkCount < 25 then	sdClock <= '0';
		else					sdClock <= '1';
		end if;
-- Serial clock DDS
-- 50MHz master input clock:-- Baud Increment
-- 115200 2416 -- 38400 805 -- 19200 403 -- 9600 201 -- 4800 101 -- 2400 50
	serialClkCount <= serialClkCount + 2416;
	end if;
end process;
end;
