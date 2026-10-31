library verilog;
use verilog.vl_types.all;
entity axi_arbiter is
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        req             : in     vl_logic_vector(1 downto 0);
        transaction_done: in     vl_logic;
        grant           : out    vl_logic_vector(1 downto 0)
    );
end axi_arbiter;
