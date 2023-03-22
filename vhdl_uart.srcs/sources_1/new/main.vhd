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
    Port ( CLK100MHZ : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           sw : in STD_LOGIC_VECTOR (3 downto 0);
           led0_b : out STD_LOGIC;
           led0_g : out STD_LOGIC;
           led0_r : out STD_LOGIC;
           led : out STD_LOGIC_VECTOR (3 downto 0);
           uart_txd_in : out STD_LOGIC);
end main;

architecture Behavioral of main is
    
    constant c_CNT_HALF : natural := 25_000_000;
    constant c_CNT_FULL : natural := 50_000_000;
    
    signal r_counter : natural range 0 to c_CNT_FULL;
    signal r_out_val : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    
    type int_array is array (3 downto 0)
	of integer;
	
    constant c_PERIOD : natural := 200_000; -- 500 kHz
    
    signal i_rgb_counter    : int_array := (others => 0);
    signal r_rgb_val        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    signal i_limits         : int_array := (others => 100000);
    signal i_limit_counter  : integer := 0;
    signal i_lim_state      : int_array := (others => 0);
    
begin

    p_BLINK : process (CLK100MHZ) is
    begin
        if rising_edge(CLK100MHZ) then
            
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
            
            if i_rgb_counter(0) >= c_PERIOD then
                
                i_rgb_counter(0) <= 0;
                i_rgb_counter(1) <= 0;
                i_rgb_counter(2) <= 0;
                
                if sw(0) /= '0' then    r_rgb_val(0) <= '1';
                else                    r_rgb_val(0) <= '0';   
                end if;
                
                if sw(1) /= '0' then    r_rgb_val(1) <= '1';
                else                    r_rgb_val(1) <= '0';   
                end if;
                
                if sw(2) /= '0' then    r_rgb_val(2) <= '1';
                else                    r_rgb_val(2) <= '0';   
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
                
                if(sw(3) /= '0') then
                    r_out_val(3) <= '1';
                    
                    if(sw(0) /= '0') then
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
                    
                    if(sw(1) /= '0') then
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
                    
                    if(sw(2) /= '0') then
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
                    r_out_val(3) <= '0';
                    
                    i_limits(0) <= 100_000;
                    i_limits(1) <= 100_000;
                    i_limits(2) <= 100_000;
                end if; -- if(sw(3) /= '0') then
            
            end if; -- if(i_limit_counter >= 500) then
            
        end if;
    end process p_BLINK;

    -- assignments
    r_out_val(2) <= '1';
    r_out_val(0) <= btn(0);
    led <= r_out_val;

    led0_b <= r_rgb_val(0);
    led0_g <= r_rgb_val(1);
    led0_r <= r_rgb_val(2);
    
end Behavioral;
