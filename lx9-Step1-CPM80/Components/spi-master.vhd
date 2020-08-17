-- SPI bus master for System09 (http://members.optushome.com.au/jekent/system09/index.html)
-- This core implements a SPI master interface.  Transfer size is 4, 8, 12 or
-- 16 bits.  The SPI clock is 0 when idle, sampled on the rising edge of the SPI
-- clock.  The SPI clock is derived from the bus clock input divided 
-- by 2, 4, 8 or 16.
-- clk, reset, cs, rw, addr, data_in, data_out and irq represent the System09
-- bus interface.
-- spi_clk, spi_mosi, spi_miso and spi_cs_n are the standard SPI signals meant
-- to be routed off-chip.
-- The SPI core provides for four register addresses that the CPU can read or
-- write:

-- 0 -> $84 DL: Data LSB
-- 1 -> $85 CS: Command/Status

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi_master is
  port (
    clk, reset, cs, rw : in  std_logic;
    addr               : in  std_logic_vector(1 downto 0);
    data_in            : in  std_logic_vector(7 downto 0);
    data_out           : out std_logic_vector(7 downto 0);
    irq                : out std_logic;
    spi_clk  			: out std_logic;
    spi_cs_n,spi_ds	   : out std_logic;
    spi_res 		   : out std_logic :='1';
    spi_mosi  			: inout std_logic;
    spi_miso           : in  std_logic);
end;

architecture rtl of spi_master is

  type   state_type is (s_idle, s_running, s_done);  -- State type of the SPI transfer state machine
  signal state           : state_type;
  signal shift_reg       : std_logic_vector(15 downto 0);  -- Shift register
  signal spi_data_buf    : std_logic_vector(15 downto 0);  -- Buffer to hold data to be sent
  signal start           : std_logic;  -- Start transmission flag
  signal count           : std_logic_vector(3 downto 0);  -- Number of bits transfered
  signal spi_clk_buf     : std_logic; -- Buffered SPI clock
  signal spi_clk_out     : std_logic;  -- Buffered SPI clock output
  signal prev_spi_clk    : std_logic;  -- Previous SPI clock state
  signal spi_clk_count   : std_logic_vector(2 downto 0);  -- Number of clk cycles-1 in this SPI clock period
  --signal spi_clk_divide  : std_logic_vector(1 downto 0);  -- SPI clock divisor
  --signal transfer_length : std_logic_vector(1 downto 0);  -- SPI transfer length
  -- Flag to indicate that the SPI slave should be deselected after the current
  signal deselect        : std_logic;  -- transfer
  signal irq_enable      : std_logic;  -- Flag to indicate that an IRQ should be generated at the end of a transfer
  signal irqack          : std_logic;  -- Signal to clear IRQ
  signal spi_cs          : std_logic;  -- Internal chip select signal, will be demultiplexed through the cs_mux
  signal spi_addr        : std_logic_vector(2 downto 0);  -- Current SPI device address
  signal spi_mcmd		 : std_logic_vector(3 downto 0);  -- Current SPI device address
  signal spi_mof,spi_moff,spi_ss  : std_logic;
begin

  -- Read CPU bus into internal registers
  cpu_write : process(clk, reset)
  begin
    if reset = '1' then
      deselect <= '0'; irq_enable <= '0'; start <= '0';
      -- xyspi_clk_divide  <= "11"; transfer_length <= "11";
	  spi_ds <= '0'; spi_res <= '1'; spi_data_buf <= (others => '0');
	  spi_mcmd <= "0000"; spi_ss <= '0';
    elsif falling_edge(clk) then
      start  <= '0'; irqack <= '0';
      if cs = '1' and rw = '0' then
        case addr is
          when "00" => spi_data_buf(7 downto 0) <= data_in; start <= '1';
          --when "01" => spi_data_buf(15 downto 8) <= data_in;
          when "01" => 
			spi_mcmd(2 downto 0) <= data_in(2 downto 0); 
			spi_ds <= data_in(3);
			spi_res <= data_in(4);
			spi_ss <= data_in(5);
			spi_mcmd(3) <= data_in(7);
          --when "11" => spi_clk_divide  <= data_in(1 downto 0); transfer_length <= data_in(3 downto 2);
          when others => null;
        end case;
		if spi_cs = '1' then start <= '0'; end if;
      end if;
    end if;
  end process;

  -- Provide data for the CPU to read
  cpu_read : process(shift_reg, addr, state, deselect, start)
  begin
    data_out <= (others => '0');
    case addr is
      when "00" => data_out <= shift_reg(7 downto 0);
      --when "01" => data_out <= shift_reg(15 downto 8);
      when "01" => if state = s_idle then data_out(7) <= '0';
                   else                   data_out(7) <= '1';
                   end if;
                   data_out(0) <= spi_miso;
      when others => null;
    end case;
  end process;

  -- SPI transfer state machine
  spi_proc : process(clk, reset)
  begin
    if reset = '1' then
      count <= (others => '0'); shift_reg <= (others => '0');
      prev_spi_clk <= '0'; spi_clk_out  <= '0'; 
	  spi_cs <= '0'; state <= s_idle; irq <= '0';
    elsif falling_edge(clk) then
      prev_spi_clk <= spi_clk_buf;
      irq          <= '0';
      case state is
        when s_idle =>
          if start = '1' then
            count <= (others => '0'); shift_reg <= spi_data_buf;
            spi_cs <= '1'; state <= s_running;
          else
            spi_cs <= '0';
          end if;
        when s_running =>
          if prev_spi_clk = '1' and spi_clk_buf = '0' then
            spi_clk_out <= '0'; count       <= count + "0001";
            shift_reg   <= shift_reg(14 downto 0) & spi_miso;
            if (count = "0111") then
              spi_cs <= '0';
              --if irq_enable = '1' then irq   <= '1'; state <= s_done; end if;
              state <= s_idle;
            end if;
          elsif prev_spi_clk = '0' and spi_clk_buf = '1' then spi_clk_out <= '1'; end if;
        when s_done => if irqack = '1' then state <= s_idle; end if;
        when others => null;
      end case;
    end if;
  end process;

  -- Generate SPI clock
  spi_clock_gen : process(clk, reset)
  begin
    if reset = '1' then
      spi_clk_count <= (others => '0'); spi_clk_buf   <= '0';
    elsif falling_edge(clk) then
      if state = s_running then
        if (spi_clk_count = "001") then -- "001" 20MHz
          spi_clk_buf <= not spi_clk_buf; spi_clk_count <= (others => '0');
        else
          spi_clk_count <= spi_clk_count + "001";
        end if;
      else
        spi_clk_buf <= '0';
      end if;
    end if;
  end process;

  spi_mosi_mux : process(shift_reg)
  begin
    spi_mof <= shift_reg(7);
  end process;

  spi_mosi <= spi_moff when spi_ss = '0' else 'Z';
  spi_moff <= spi_mof     when spi_mcmd(3) = '0' else spi_mcmd(0); 
  spi_clk  <= spi_clk_out when spi_mcmd(3) = '0' else spi_mcmd(1); 
  spi_cs_n <= not spi_cs  when spi_mcmd(3) = '0' else spi_mcmd(2); 

end rtl;
