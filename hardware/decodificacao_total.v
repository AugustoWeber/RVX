module decodificacao_total (
    // input wire clk,
    input wire [31:0] valor1,  // Entrada 1 de 32 bits
    input wire [31:0] valor2,  // Entrada 2 de 32 bits
    output wire [31:0] palavra  // Saída única, que concatena as saídas de decodificadores
);

    // Sinais internos para as palavras de 16 bits
    wire [15:0] var1a, var1b, var2a, var2b;

    // Separando os valores de 32 bits em palavras de 16 bits
    assign var1a = valor1[31:16];  // Bits mais significativos de valor1
    assign var1b = valor1[15:0];   // Bits menos significativos de valor1
    assign var2a = valor2[31:16];  // Bits mais significativos de valor2
    assign var2b = valor2[15:0];   // Bits menos significativos de valor2

    // Instância do módulo decodificador para cada palavra de 16 bits
    wire [7:0] f_out1, f_out2, f_out3, f_out4;

    decodificador dec1 (
        // .clk(clk),
        .mem_in(var1a),
        .f_out_o(f_out1)
    );

    decodificador dec2 (
        // .clk(clk),
        .mem_in(var1b),
        .f_out_o(f_out2)
    );

    decodificador dec3 (
        // .clk(clk),
        .mem_in(var2a),
        .f_out_o(f_out3)
    );

    decodificador dec4 (
        // .clk(clk),
        .mem_in(var2b),
        .f_out_o(f_out4)
    );

    // Concatenando as saídas para formar a variável palavra (32 bits)
    assign palavra = {f_out1, f_out2, f_out3, f_out4};  // Concatenando as saídas

endmodule

