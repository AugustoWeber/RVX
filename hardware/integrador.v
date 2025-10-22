module integrador (
    // input wire clk,
    input wire [31:0] palavra_in, // Entrada de 32 bits
    input wire [31:0] memoria1_in, // Entrada da Memória 1
    input wire [31:0] memoria2_in, // Entrada da Memória 2
    output wire [31:0] memoria1_out, // Saída da Memória 1 (para escrita)
    output wire [31:0] memoria2_out, // Saída da Memória 2 (para escrita)
    output wire [31:0] palavra_out // Saída final do microcontrolador
);

    // Sinais para as saídas do divisor_codificador
    wire [31:0] saida1;
    wire [31:0] saida2;

    // Sinais internos para decodificação
    wire [31:0] valor1;
    wire [31:0] valor2;

    // Atribuição dos valores de entrada da memória para os sinais internos
    assign valor1 = memoria1_in;
    assign valor2 = memoria2_in;

    // Instanciação do divisor_codificador
    divisor_codificador u_divisor_codificador (
        // .clk(clk),
        .palavra_in(palavra_in),
        .grupo1_out(),  // Sinais não utilizados
        .grupo2_out(),
        .grupo3_out(),
        .grupo4_out(),
        .saida1(saida1),
        .saida2(saida2)
    );

    // Instanciação do decodificador
    decodificacao_total u_decodificacao_total (
        // .clk(clk),
        .valor1(valor1),
        .valor2(valor2),
        .palavra(palavra_out)
    );

    // Atribuição das saídas codificadas para escrita nas memórias
    assign memoria1_out = saida1;
    assign memoria2_out = saida2;

endmodule

