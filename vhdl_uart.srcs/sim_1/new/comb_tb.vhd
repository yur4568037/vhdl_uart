----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2023 04:32:02 PM
-- Design Name: 
-- Module Name: comb_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity comb_tb is
--  Port ( );
end comb_tb;

architecture Behavioral of comb_tb is

    component main 
        Port ( i_CLK100MHZ : in STD_LOGIC;
               i_btn : in STD_LOGIC_VECTOR (3 downto 0);
               i_sw : in STD_LOGIC_VECTOR (3 downto 0);
               o_led0_b : out STD_LOGIC;
               o_led0_g : out STD_LOGIC;
               o_led0_r : out STD_LOGIC;
               o_led : out STD_LOGIC_VECTOR (3 downto 0);
               o_uart_txd : out STD_LOGIC;
               i_uart_rxd : in STD_LOGIC);
    end component;

    signal r_CLK100MHZ : STD_LOGIC := '0';
    signal r_btn : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal r_sw : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal r_led0_b : STD_LOGIC := '0';
    signal r_led0_g : STD_LOGIC := '0';
    signal r_led0_r : STD_LOGIC := '0';
    signal r_led : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal r_uart_txd_out : STD_LOGIC := '1';
    signal w_uart_rxd_in : STD_LOGIC := '1';

    

begin
    
    r_CLK100MHZ <= not r_CLK100MHZ after 5 ns;
    
    MAIN_INST : main
    port map (
        i_CLK100MHZ => r_CLK100MHZ,
        i_btn => r_btn,
        i_sw => r_sw,
        o_led0_b => r_led0_b,
        o_led0_g => r_led0_g,
        o_led0_r => r_led0_r,
        o_led => r_led,
        o_uart_txd => r_uart_txd_out,
        i_uart_rxd => w_uart_rxd_in
    );
    
    process
    begin
        wait for 100 ns;
        r_sw(0) <= '1';
        
        wait for 50 ms;
        r_sw(3) <= '1';
        
        -- UART test
        
        
        wait for 50 ms;
        r_sw(1) <= '1';        
        
    end process;
    
end Behavioral;
