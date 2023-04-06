----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2023 02:28:37 PM
-- Design Name: 
-- Module Name: uart_tx - RTL
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

entity uart_tx is
    generic (
    g_CLKS_PER_BIT : integer := 115);     -- Needs to be set correctly
    Port ( i_Clk        : in STD_LOGIC;
           i_TX_DV      : in STD_LOGIC;     -- command to start translation
           i_TX_Byte    : in STD_LOGIC_VECTOR (7 downto 0);
           o_TX_Active  : out STD_LOGIC;
           o_TX_Serial  : out STD_LOGIC;
           o_TX_Done    : out STD_LOGIC);
end uart_tx;

architecture RTL of uart_tx is

    type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                     s_TX_Stop_Bit, s_Cleanup);
    signal r_SM_Main : t_SM_Main := s_Idle;
 
    --signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
    signal r_Clk_Count : unsigned (g_CLKS_PER_BIT-1 downto 0) := (others => '0');
    signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
    --signal r_Bit_Index : unsigned (7 downto 0) := (others => '0');  -- 8 Bits Total
    signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_TX_Done   : std_logic := '0';

begin

  p_UART_TX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case r_SM_Main is
 
        when s_Idle =>
          o_TX_Active <= '0';
          o_TX_Serial <= '1';         -- Drive Line High for Idle
          r_TX_Done   <= '0';
          --r_Clk_Count <= 0;
          r_Clk_Count <= (others => '0');
          --r_Clk_Count <= to_unsigned(0, g_CLKS_PER_BIT-1);
          r_Bit_Index <= 0;
          --r_Bit_Index <= (others => '0');
          --r_Bit_Index <= to_unsigned(0, g_CLKS_PER_BIT-1);
 
          if i_TX_DV = '1' then
            r_TX_Data <= i_TX_Byte;
            r_SM_Main <= s_TX_Start_Bit;
          else
            r_SM_Main <= s_Idle;
          end if;
            
        -- Send out Start Bit. Start bit = 0
        when s_TX_Start_Bit =>
          o_TX_Active <= '1';
          o_TX_Serial <= '0';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Start_Bit;
          else
            --r_Clk_Count <= 0;
            r_Clk_Count <= (others => '0');
            --r_Clk_Count <= to_unsigned(0, g_CLKS_PER_BIT-1);
            r_SM_Main   <= s_TX_Data_Bits;
          end if;
          
        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish
        when s_TX_Data_Bits =>
          o_TX_Serial <= r_TX_Data(r_Bit_Index);
           
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Data_Bits;
          else
            --r_Clk_Count <= 0;
            r_Clk_Count <= (others => '0');
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_TX_Data_Bits;
            else
              r_Bit_Index <= 0;
              --r_Bit_Index <= (others => '0');
              r_SM_Main   <= s_TX_Stop_Bit;
            end if;  
          end if; 
        
        -- Send out Stop bit. Stop bit = 1
        when s_TX_Stop_Bit =>
          o_TX_Serial <= '1';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Stop_Bit;
          else
            r_TX_Done   <= '1';
            --r_Clk_Count <= 0;
            r_Clk_Count <= (others => '0');
            r_SM_Main   <= s_Cleanup;
          end if;
        
        -- Stay here 1 clock
        when s_Cleanup =>
          o_TX_Active <= '0';
          r_TX_Done   <= '1';
          r_SM_Main   <= s_Idle;
          
        when others =>
          r_SM_Main <= s_Idle;
 
      end case;
    end if;
  end process p_UART_TX;
 
  o_TX_Done <= r_TX_Done;
end RTL;
