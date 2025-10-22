module divisor_codificador (
    // input wire clk,
    input wire [31:0] palavra_in,   // Entrada de 32 bits
    output wire [15:0] grupo1_out,  // Saída do grupo 1
    output wire [15:0] grupo2_out,  // Saída do grupo 2
    output wire [15:0] grupo3_out,  // Saída do grupo 3
    output wire [15:0] grupo4_out,  // Saída do grupo 4
    output wire [31:0] saida1,      // Nova saída 1
    output wire [31:0] saida2       // Nova saída 2
);

    // Instanciando 4 módulos codificadores para cada grupo de 8 bits
    wire [7:0] grupo1_in, grupo2_in, grupo3_in, grupo4_in;

    // Dividindo a palavra de 32 bits em 4 grupos de 8 bits
    assign grupo1_in = palavra_in[31:24];
    assign grupo2_in = palavra_in[23:16];
    assign grupo3_in = palavra_in[15:8];
    assign grupo4_in = palavra_in[7:0];

    // Instanciando o módulo codificador para cada grupo
    codificador cod1 (
        // .clk(clk),
        .n_in(grupo1_in),
        .mem_out(grupo1_out)
    );

    codificador cod2 (
        // .clk(clk),
        .n_in(grupo2_in),
        .mem_out(grupo2_out)
    );

    codificador cod3 (
        // .clk(clk),
        .n_in(grupo3_in),
        .mem_out(grupo3_out)
    );

    codificador cod4 (
        // .clk(clk),
        .n_in(grupo4_in),
        .mem_out(grupo4_out)
    );

    // Atribuindo explicitamente os valores a saida1 e saida2

    assign saida1[31:16] = grupo1_out[15:0];
    // assign saida1[30] = grupo1_out[14];
    // assign saida1[29] = grupo1_out[13];
    // assign saida1[28] = grupo1_out[12];
    // assign saida1[27] = grupo1_out[11];
    // assign saida1[26] = grupo1_out[10];
    // assign saida1[25] = grupo1_out[9];
    // assign saida1[24] = grupo1_out[8];
    // assign saida1[23] = grupo1_out[7];
    // assign saida1[22] = grupo1_out[6];
    // assign saida1[21] = grupo1_out[5];
    // assign saida1[20] = grupo1_out[4];
    // assign saida1[19] = grupo1_out[3];
    // assign saida1[18] = grupo1_out[2];
    // assign saida1[17] = grupo1_out[1];
    // assign saida1[16] = grupo1_out[0];

    assign saida1[15:0] = grupo2_out[15:0];
    // assign saida1[14] = grupo2_out[14];
    // assign saida1[13] = grupo2_out[13];
    // assign saida1[12] = grupo2_out[12];
    // assign saida1[11] = grupo2_out[11];
    // assign saida1[10] = grupo2_out[10];
    // assign saida1[9] = grupo2_out[9];
    // assign saida1[8] = grupo2_out[8];
    // assign saida1[7] = grupo2_out[7];
    // assign saida1[6] = grupo2_out[6];
    // assign saida1[5] = grupo2_out[5];
    // assign saida1[4] = grupo2_out[4];
    // assign saida1[3] = grupo2_out[3];
    // assign saida1[2] = grupo2_out[2];
    // assign saida1[1] = grupo2_out[1];
    // assign saida1[0] = grupo2_out[0];

    assign saida2[31:16] = grupo3_out[15:0];
    // assign saida2[30] = grupo3_out[14];
    // assign saida2[29] = grupo3_out[13];
    // assign saida2[28] = grupo3_out[12];
    // assign saida2[27] = grupo3_out[11];
    // assign saida2[26] = grupo3_out[10];
    // assign saida2[25] = grupo3_out[9];
    // assign saida2[24] = grupo3_out[8];
    // assign saida2[23] = grupo3_out[7];
    // assign saida2[22] = grupo3_out[6];
    // assign saida2[21] = grupo3_out[5];
    // assign saida2[20] = grupo3_out[4];
    // assign saida2[19] = grupo3_out[3];
    // assign saida2[18] = grupo3_out[2];
    // assign saida2[17] = grupo3_out[1];
    // assign saida2[16] = grupo3_out[0];

    assign saida2[15:0] = grupo4_out[15:0];
    // assign saida2[14] = grupo4_out[14];
    // assign saida2[13] = grupo4_out[13];
    // assign saida2[12] = grupo4_out[12];
    // assign saida2[11] = grupo4_out[11];
    // assign saida2[10] = grupo4_out[10];
    // assign saida2[9] = grupo4_out[9];
    // assign saida2[8] = grupo4_out[8];
    // assign saida2[7] = grupo4_out[7];
    // assign saida2[6] = grupo4_out[6];
    // assign saida2[5] = grupo4_out[5];
    // assign saida2[4] = grupo4_out[4];
    // assign saida2[3] = grupo4_out[3];
    // assign saida2[2] = grupo4_out[2];
    // assign saida2[1] = grupo4_out[1];
    // assign saida2[0] = grupo4_out[0];

endmodule

