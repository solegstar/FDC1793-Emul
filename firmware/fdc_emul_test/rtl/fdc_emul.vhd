library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;  

entity fdc_emul is                    
port(
clk			: in std_logic;
nOE_245		: out std_logic;
DIR_245		: out std_logic;

FDC_nWR		: out std_logic;
FDC_nCS		: out std_logic;
FDC_nRD		: out std_logic;
FDC_A			: out std_logic_vector (1 downto 0);
FDC_DATA		: out std_logic_vector (7 downto 0);
FDC_STEP		: out std_logic;
FDC_DIR		: out std_logic;
FDC_SL		: out std_logic;
FDC_SR		: out std_logic;
FDC_nRES		: out std_logic;
FDC_HRDY		: out std_logic;
FDC_CLK		: in std_logic;
FDC_RSTB		: out std_logic;
FDC_RCLK		: out std_logic;
FDC_nRAWR	: out std_logic;
FDC_HLD		: out std_logic;
FDC_TR43		: out std_logic;
FDC_WG		: out std_logic;
FDC_WR_DATA	: out std_logic;
FDC_RDY		: out std_logic;
FDC_WF_DE	: out std_logic;
FDC_TR00		: out std_logic;
FDC_INDEX	: out std_logic;
FDC_WPRT		: out std_logic;
FDC_nDDEN	: out std_logic;
FDC_DRQ		: out std_logic;
FDC_INTRQ	: out std_logic
);
end fdc_emul;

architecture rtl of fdc_emul is

signal clk_div			: std_logic_vector (7 downto 0);
signal clk_16			: std_logic;

begin

pll : work.pll PORT MAP (
		inclk0	 => clk,
		c0	 => clk_16
	);

process (clk, clk_div)
	begin
		if clk'event and clk = '1' then
			clk_div <= clk_div + 1;
		end if;
end process;

nOE_245		<= clk_div (7);
DIR_245		<= clk_div (7);
FDC_nWR		<= clk_16;
FDC_nCS		<= clk_div (7);
FDC_nRD		<= clk_div (7);
FDC_A			<= clk_div (7 downto 6);
FDC_DATA		<= clk_div (7 downto 0);
FDC_STEP		<= clk_div (7);
FDC_DIR		<= clk_div (7);
FDC_SL		<= clk_div (7);
FDC_SR		<= clk_div (7);
FDC_nRES		<= clk_div (7);
FDC_HRDY		<= clk_div (7);
--FDC_CLK		<= clk_div (7);
FDC_RSTB		<= clk_div (7);
FDC_RCLK		<= clk_div (7);
FDC_nRAWR	<= clk_div (7);
FDC_HLD		<= clk_div (7);
FDC_TR43		<= clk_div (7);
FDC_WG		<= clk_div (7);
FDC_WR_DATA	<= clk_div (7);
FDC_RDY		<= clk_div (7);
FDC_WF_DE	<= clk_div (7);
FDC_TR00		<= clk_div (7);
FDC_INDEX	<= clk_div (7);
FDC_WPRT		<= clk_div (7);
FDC_nDDEN	<= clk_div (7);
FDC_DRQ		<= clk_div (7);
FDC_INTRQ	<= clk_div (7);
	
end rtl;