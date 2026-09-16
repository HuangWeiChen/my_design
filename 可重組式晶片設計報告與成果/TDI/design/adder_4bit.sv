module adder_4bit(
    input  logic [4:0][5:0][3:0] a, // 全部改為 Packed
    output logic [4:0][5:0][3:0] s
);
    assign s = a;
endmodule