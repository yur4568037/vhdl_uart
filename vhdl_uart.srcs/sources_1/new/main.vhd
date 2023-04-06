----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2023 03:06:38 PM
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( i_CLK100MHZ : in STD_LOGIC;
           i_btn : in STD_LOGIC_VECTOR (3 downto 0);
           i_sw : in STD_LOGIC_VECTOR (3 downto 0);
           o_led0_b : out STD_LOGIC;
           o_led0_g : out STD_LOGIC;
           o_led0_r : out STD_LOGIC;
           o_led : out STD_LOGIC_VECTOR (3 downto 0);
           o_uart_txd : out STD_LOGIC;
           i_uart_rxd : in STD_LOGIC);
end main;

architecture Behavioral of main is
    
    component uart_tx is
        generic(
        g_CLKS_PER_BIT : integer := 115);     -- Needs to be set correctly
        Port (  i_Clk        : in STD_LOGIC;
                i_TX_DV      : in STD_LOGIC;
                i_TX_Byte    : in STD_LOGIC_VECTOR (7 downto 0);
                o_TX_Active  : out STD_LOGIC;
                o_TX_Serial  : out STD_LOGIC;
                o_TX_Done    : out STD_LOGIC);
    end component uart_tx;
    
    component uart_rx is
        generic(
        g_CLKS_PER_BIT : integer := 115);     -- Needs to be set correctly
        Port (  i_Clk       : in STD_LOGIC;
                i_RX_Serial : in STD_LOGIC;
                o_RX_DV     : out STD_LOGIC;
                o_RX_Byte   : out STD_LOGIC_VECTOR (7 downto 0));
    end component uart_rx;
    
    -- Want to interface to 115200 baud UART
    -- 100 MHz / 115200 = 868 Clocks Per Bit.
    constant c_CLKS_PER_BIT : integer := 868;
    constant c_BIT_PERIOD : time := 8680 ns;
    
    -- TX
    signal r_TX_DV     : std_logic                    := '0';
    signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
    signal w_TX_Active : std_logic;
    signal w_TX_SERIAL : std_logic;
    signal w_TX_DONE   : std_logic;
      
    signal r_uart_counter : integer := 0;
     
    type bytes_array is array (63 downto 0)
    of std_logic_vector(7 downto 0);
    
    signal w_TX_STRING : bytes_array := (others => X"00");
    signal r_TX_STRING_lenght : unsigned (7 downto 0) := (others => '0');
    signal r_TX_Byte_Index : integer range 0 to 7 := 1;
    
    -- RX
    signal r_Clk        : STD_LOGIC := '0';
    --signal r_RX_Serial  : STD_LOGIC := '0';
    signal w_RX_DV      : STD_LOGIC;
    signal w_RX_Byte    : STD_LOGIC_VECTOR (7 downto 0);
    
    signal r_uart_rx_counter    : unsigned (7 downto 0) := (others => '0');
    signal r_RX_Buffer          : bytes_array := (others => X"00");
    signal r_RX_Buffer_Index    : integer range 0 to 7 := 0;
    signal r_uart_rx_length     : unsigned (7 downto 0) := (others => '0');
    
    -- other things
    constant c_CNT_HALF : natural := 25_000_000;
    constant c_CNT_FULL : natural := 50_000_000;
    
    signal r_counter : natural range 0 to c_CNT_FULL;
    signal r_out_val : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    
    type int_array is array (3 downto 0) of integer;
	
    constant c_PERIOD : natural := 200_000; -- 500 kHz
    
    signal i_rgb_counter    : int_array := (others => 0);
    signal r_rgb_val        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    signal i_limits         : int_array := (others => 100000);
    signal i_limit_counter  : integer := 0;
    signal i_lim_state      : int_array := (others => 0);
    
begin

    UART_TX_INST : uart_tx
    generic map (
    g_CLKS_PER_BIT => c_CLKS_PER_BIT
    )
    port map (
        i_Clk        => i_CLK100MHZ,
        i_TX_DV      => r_TX_DV,        -- command to start translation
        i_TX_Byte    => r_TX_Byte,
        o_TX_Active  => w_TX_Active,    -- check availability
        o_TX_Serial  => w_TX_Serial,
        o_TX_Done    => w_TX_Done
    );
    
    UART_RX_INST : uart_rx
    generic map (
    g_CLKS_PER_BIT => c_CLKS_PER_BIT
    )
    port map (
        i_Clk       => r_Clk,
        --i_RX_Serial => r_RX_Serial,
        i_RX_Serial => i_uart_rxd,
        o_RX_DV     => w_RX_DV,
        o_RX_Byte   => w_RX_Byte
    );
    
    p_UART_RECEIVER : process (i_CLK100MHZ) is
    begin
        if rising_edge(i_CLK100MHZ) then
            r_uart_rx_counter <= r_uart_rx_counter + 1;
        
            if w_RX_DV = '1' then
                --signal r_uart_rx_counter    : unsigned (7 downto 0) := (others => '0');
                --signal r_RX_Buffer          : bytes_array := (others => X"00");
                --signal r_RX_Buffer_Index    : integer range 0 to 7 := 0;
                --signal r_uart_rx_length     : unsigned (7 downto 0) := (others => '0');
                
                r_uart_rx_counter <= (others => '0');
                
                r_RX_Buffer(r_RX_Buffer_Index) <= w_RX_Byte;
                r_RX_Buffer_Index <= r_RX_Buffer_Index + 1;
                r_uart_rx_length <= r_uart_rx_length + 1;
                
            end if;
            
            -- UART IDLE
            if r_uart_rx_counter >= 10_000 then     -- in 100 us
                
                -- debug
                for ii in 0 to 63 loop
                    w_TX_STRING(ii) <= r_RX_Buffer(ii);
                end loop; --ii
                r_TX_STRING_lenght <= r_uart_rx_length;
                
                r_TX_Byte <= w_TX_STRING(0);
                --r_TX_Byte <= X"54";
                r_TX_DV <= '1';
                -- debug
                
                -- command parsing
                --if r_RX_Buffer(0) /= X"AB" then
                --end if;
                
                r_uart_rx_counter <= (others => '0');
                r_uart_rx_length <= (others => '0');
                r_RX_Buffer_Index <= 0;
                
            end if; -- if r_uart_rx_counter >= 10_000 then
        end if;
    end process;
    
    p_UART_SENDER : process (i_CLK100MHZ) is
    begin
        if rising_edge(i_CLK100MHZ) then
        
            if r_TX_DV = '1' then r_TX_DV <= '0'; end if;
        
            if w_TX_Done = '1' and w_TX_Active = '0' then
                
                r_TX_Byte_Index <= r_TX_Byte_Index + 1;
                
                if r_TX_Byte_Index < r_TX_STRING_lenght then
                    r_TX_Byte <= w_TX_STRING(r_TX_Byte_Index);
                    r_TX_DV <= '1';
                else
                    r_TX_Byte_Index <= 1;
                end if;
            end if;
            
            -- disable counter
            --r_uart_counter <= r_uart_counter +1;
            
            if r_uart_counter >= 100_000_000 and w_TX_Active /= '1' then
            --debug
            --if r_uart_counter >= 3_000_000 and w_TX_Active /= '1' then
            --debug
                r_uart_counter <= 0;
                
                -- write data
                w_TX_STRING(0) <= X"54";
                w_TX_STRING(1) <= X"45";
                w_TX_STRING(2) <= X"53";
                w_TX_STRING(3) <= X"54";
                w_TX_STRING(4) <= X"0A";
                w_TX_STRING(5) <= X"0D";
                r_TX_STRING_lenght <= to_unsigned(6, 8);
                
                -- start
                --r_TX_Byte <= w_TX_STRING(0);
                r_TX_Byte <= X"54";
                r_TX_DV <= '1';
                
                if r_out_val(3) = '1' then
                    r_out_val(3) <= '0';
                else
                    r_out_val(3) <= '1';
                end if;
                
            end if; -- if(r_uart_counter >= 100_000_000 then
        end if; -- if rising_edge(CLK100MHZ) then
    end process p_UART_SENDER;

    p_BLINK : process (i_CLK100MHZ) is
    begin
        if rising_edge(i_CLK100MHZ) then
            
            -- led blink
            
            r_counter <= r_counter + 1;
            
            if r_counter = c_CNT_HALF then
                r_out_val(1) <= '1';
            else
                if r_counter = c_CNT_FULL then
                    r_counter <= 0;
                    r_out_val(1) <= '0';
                end if;
            end if;
            
            
            -- change rgb led state
            
            i_rgb_counter(0) <= i_rgb_counter(0) + 1;
            i_rgb_counter(1) <= i_rgb_counter(1) + 1;
            i_rgb_counter(2) <= i_rgb_counter(2) + 1; 
            
            if i_rgb_counter(0) >= c_PERIOD then    -- 50 Hz
                
                i_rgb_counter(0) <= 0;
                i_rgb_counter(1) <= 0;
                i_rgb_counter(2) <= 0;
                
                if i_sw(0) /= '0' then      r_rgb_val(0) <= '1';
                else                        r_rgb_val(0) <= '0';   
                end if;
                
                if i_sw(1) /= '0' then      r_rgb_val(1) <= '1';
                else                        r_rgb_val(1) <= '0';   
                end if;
                
                if i_sw(2) /= '0' then      r_rgb_val(2) <= '1';
                else                        r_rgb_val(2) <= '0';   
                end if;
            end if;
            
            
            if i_rgb_counter(0) >= i_limits(0) and r_rgb_val(0) = '1' then
                r_rgb_val(0) <= '0';
            end if;
            
            if i_rgb_counter(1) >= i_limits(1) and r_rgb_val(1) = '1' then
                r_rgb_val(1) <= '0';
            end if;
            
            if i_rgb_counter(2) >= i_limits(2) and r_rgb_val(2) = '1' then
                r_rgb_val(2) <= '0';
            end if;  
            
            
            -- change limits with 200 kHz frequency
            
            i_limit_counter <= i_limit_counter + 1;
            
            if(i_limit_counter >= 500) then  -- 200 kHz
            
                i_limit_counter <= 0;
                
                if(i_sw(3) /= '0') then
                    --r_out_val(3) <= '1';
                    
                    if(i_sw(0) /= '0') then
                        -- increment or decrement
                        if(i_lim_state(0) = 0) then
                            if(i_limits(0) < c_PERIOD) then i_limits(0) <= i_limits(0) + 1;
                            else                            i_lim_state(0) <= 1;
                            end if;
                        else
                            if(i_limits(0) > 0) then        i_limits(0) <= i_limits(0) - 1;
                            else                            i_lim_state(0) <= 0;
                            end if;
                        end if;
                    else
                        i_limits(0) <= 100_000;
                    end if; -- if(sw(0) /= '0') then
                    
                    if(i_sw(1) /= '0') then
                        -- increment or decrement
                        if(i_lim_state(1) = 0) then
                            if(i_limits(1) < c_PERIOD) then i_limits(1) <= i_limits(1) + 1;
                            else                            i_lim_state(1) <= 1;
                            end if;
                        else
                            if(i_limits(1) > 0) then        i_limits(1) <= i_limits(1) - 1;
                            else                            i_lim_state(1) <= 0;
                            end if;
                        end if;
                    else
                        i_limits(1) <= 100_000;
                    end if; -- if(sw(1) /= '0') then
                    
                    if(i_sw(2) /= '0') then
                        -- increment or decrement
                        if(i_lim_state(2) = 0) then
                            if(i_limits(2) < c_PERIOD) then i_limits(2) <= i_limits(2) + 1;
                            else                            i_lim_state(2) <= 1;
                            end if;
                        else
                            if(i_limits(2) > 0) then        i_limits(2) <= i_limits(2) - 1;
                            else                            i_lim_state(2) <= 0;
                            end if;
                        end if;
                    else
                        i_limits(2) <= 100_000;
                    end if; -- if(sw(2) /= '0') then
                    
                    
                else    -- if(sw(3) /= '0') then
                    --r_out_val(3) <= '0';
                    
                    i_limits(0) <= 100_000;
                    i_limits(1) <= 100_000;
                    i_limits(2) <= 100_000;
                end if; -- if(sw(3) /= '0') then
            
            end if; -- if(i_limit_counter >= 500) then
            
        end if;
    end process p_BLINK;

    -- assignments
    r_out_val(2) <= '1';
    r_out_val(0) <= i_btn(0);
    o_led <= r_out_val;

    o_led0_b <= r_rgb_val(0);
    o_led0_g <= r_rgb_val(1);
    o_led0_r <= r_rgb_val(2);
    
    o_uart_txd <= w_TX_SERIAL;
    
end Behavioral;
