library verilog;
use verilog.vl_types.all;
entity axi_decoder is
    port(
        addr            : in     vl_logic_vector(31 downto 0);
        sel_s0          : out    vl_logic;
        sel_s1          : out    vl_logic;
        decerr          : out    vl_logic
    );
end axi_decoder;
