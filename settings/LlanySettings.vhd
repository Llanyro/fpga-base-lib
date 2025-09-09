library ieee;

use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

package LlanySettings is

	subtype SL			is std_logic;
	subtype SLV			is std_logic_vector;
	subtype NAT			is natural;
	subtype INT			is integer;
	subtype	FLOAT		is real;
--	subtype	BOOL		is boolean;

	subtype u8			is unsigned (7		downto	0);
	subtype u16			is unsigned (15		downto	0);
	subtype u32			is unsigned (31		downto	0);
	subtype u64			is unsigned (63		downto	0);
	subtype u128		is unsigned (127	downto	0);
	subtype u256		is unsigned (255	downto	0);

	subtype i8			is signed 	(7		downto	0);
	subtype i16			is signed 	(15		downto	0);
	subtype i32			is signed 	(31		downto	0);
	subtype i64			is signed 	(63		downto	0);
	subtype i128		is signed 	(127	downto	0);
	subtype i256		is signed 	(255	downto	0);

	subtype f8			is real 	(7		downto	0);
	subtype f16			is real 	(15		downto	0);
	subtype f32			is real 	(31		downto	0);
	subtype f64			is real 	(63		downto	0);
	subtype f128		is real 	(127	downto	0);
	subtype f256		is real 	(255	downto	0);

	--subtype ll_char_t	is string	(1 to 1);
	--subtype ll_char_t	is string	(1 to 1);

	subtype SLV1		is SLV		(0		downto	0);
	subtype SLV2		is SLV		(1		downto	0);
	subtype SLV3		is SLV		(2		downto	0);
	subtype SLV4		is SLV		(3		downto	0);
	subtype SLV5		is SLV		(4		downto	0);
	subtype SLV6		is SLV		(5		downto	0);
	subtype SLV7		is SLV		(6		downto	0);
	subtype SLV8		is SLV		(7		downto	0);
	subtype SLV9		is SLV		(8		downto	0);
	subtype SLV10		is SLV		(9		downto	0);

	type 	SLV1x1		is array	(1		to		1) of SLV1;
	type 	SLV1x2		is array	(1		to		2) of SLV1;

	type 	SLV2x1		is array	(1		to		1) of SLV2;
	type 	SLV2x2		is array	(1		to		2) of SLV2;
	
	function get_required_width(n : NAT)	return NAT;
	function has_odd_ones(vec : SLV)		return SL;
	--procedure zero_set_if_1(s : inout SL)	return SL;

end package LlanySettings;

package body LlanySettings is
	function get_required_width(n : NAT) return NAT is
	begin
		if n = 0 then	return 1; -- At least 1 bit needed even for value 0
		else			return NAT(ceil(log2(FLOAT(n + 1))));
		end if;
	end function get_required_width;

	function has_odd_ones(vec : SLV) return SL is
		variable parity : SL := '0';
	begin
		for i in vec'range loop
			parity := parity xor vec(i);
		end loop;
		return parity;
	end function has_odd_ones;

	--procedure zero_set_if_1(s : SL)			is
	--begin
	--	if s = '1' then
	--
	--end procedure zero_set_if_1;

	--procedure proc_do_something(input_a : in integer range 0 to c_argument_max, output_b : out integer range 0 to c_argument_max) is
	--begin
	--	counter <= counter + 1;
	--	output_b <= input_a & other_input;
	--	other_output <= input_a;
	--end procedure proc_do_something

end package body LlanySettings;
