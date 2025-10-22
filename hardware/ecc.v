module codificador (
  // input wire clk,
  input wire [7:0] n_in,
  output wire [15:0] mem_out // A saída agora é do tipo wire
);

  // Atribuições contínuas (combinacionais) para os bits de mem_out
  assign mem_out[0]  = n_in[2] ^ n_in[6] ^ n_in[4];
  assign mem_out[1]  = n_in[7] ^ n_in[0];
  assign mem_out[2]  = n_in[2] ^ n_in[4] ^ n_in[5];
  assign mem_out[3]  = n_in[7] ^ n_in[1] ^ n_in[5] ^ n_in[2] ^ n_in[6];
  assign mem_out[4]  = n_in[2] ^ n_in[4] ^ n_in[7] ^ n_in[0];
  assign mem_out[5]  = n_in[7] ^ n_in[6] ^ n_in[2] ^ n_in[4] ^ n_in[5];
  assign mem_out[6]  = n_in[6] ^ n_in[3] ^ n_in[4] ^ n_in[5];
  assign mem_out[7]  = n_in[7] ^ n_in[1] ^ n_in[4] ^ n_in[5] ^ n_in[6] ^ n_in[3];
  assign mem_out[8]  = n_in[0];
  assign mem_out[9]  = n_in[1];
  assign mem_out[10] = n_in[2];
  assign mem_out[11] = n_in[3];
  assign mem_out[12] = n_in[4];
  assign mem_out[13] = n_in[5];
  assign mem_out[14] = n_in[6];
  assign mem_out[15] = n_in[7];

endmodule

module decodificador(
  // input wire clk,
  input wire [15:0] mem_in,
  output reg [7:0] f_out_o
);
  // Sinais internos
  reg [15:0] mem;
  reg [7:0] f;
  reg [7:0] bit_sumi; // corresponde ao somai
  reg [7:0] bit_sum0; // corresponde ao soma0
  reg [7:0] sum_1st  [3:0];  // Declaração do vetor
  reg [7:0] sum0_1st [3:0];  // Declaração do vetor
  reg [7:0] sum_2st  [1:0];  // Declaração do vetor
  reg [7:0] sum0_2st [1:0];  // Declaração do vetor
  reg [3:0] sum_3st, sum0_3st;
  reg [3:0] somai, soma0;
  reg [7:0] e;
  reg [7:0] logica_corr; // usado para correção dos bit flips
  reg logica_baixo;

  // Inicialização
  // initial begin
  //   mem = 16'b0;
  //   f = 8'b0;
  //   bit_sumi = 8'b0;
  //   bit_sum0 = 8'b0;
  //   sum_1st[0] = 8'b0;  // Inicialização dos elementos do vetor
  //   sum_1st[1] = 8'b0;
  //   sum_1st[2] = 8'b0;
  //   sum_1st[3] = 8'b0;

  //   sum0_1st[0] = 8'b0;  // Inicialização dos elementos do vetor
  //   sum0_1st[1] = 8'b0;
  //   sum0_1st[2] = 8'b0;
  //   sum0_1st[3] = 8'b0;

  //   sum_2st[0] = 8'b0;  // Inicialização dos elementos do vetor
  //   sum_2st[1] = 8'b0;

  //   sum0_2st[0] = 8'b0;  // Inicialização dos elementos do vetor
  //   sum0_2st[1] = 8'b0;

  //   sum_3st = 4'b0;
  //   sum0_3st = 4'b0;
  //   somai = 4'b0;
  //   soma0 = 4'b0;
  //   e = 8'b0;
  //   logica_corr = 8'b0;
  //   logica_baixo = 1'b0;
  // end

  // always @(posedge clk) begin
    // mem <= mem_in;  // Armazena o valor de entrada
    // f_out_o <= f;   // Atualiza a saída
  // end
  always @(*) begin
    mem <= mem_in;  // Armazena o valor de entrada
    f_out_o <= f;   // Atualiza a saída
  end

  //============== SOMAi======================================================================

  // always @(*) begin
    // Lógica somai
    assign bit_sumi[0] = (mem[0] != (mem[10] ^ mem[14] ^ mem[12])) ? 1'b1 : 1'b0;
    assign bit_sumi[1] = (mem[1] != (mem[15] ^ mem[8])) ? 1'b1 : 1'b0;
    assign bit_sumi[2] = (mem[2] != (mem[10] ^ mem[12] ^ mem[13])) ? 1'b1 : 1'b0;
    assign bit_sumi[3] = (mem[3] != (mem[15] ^ mem[9]  ^ mem[13] ^ mem[10] ^ mem[14])) ? 1'b1 : 1'b0;
    assign bit_sumi[4] = (mem[4] != (mem[10] ^ mem[12] ^ mem[15] ^ mem[8])) ? 1'b1 : 1'b0;
    assign bit_sumi[5] = (mem[5] != (mem[15] ^ mem[14] ^ mem[10] ^ mem[12] ^ mem[13])) ? 1'b1 : 1'b0;
    assign bit_sumi[6] = (mem[6] != (mem[14] ^ mem[11] ^ mem[12] ^ mem[13])) ? 1'b1 : 1'b0;
    assign bit_sumi[7] = (mem[7] != (mem[15] ^ mem[9]  ^ mem[12] ^ mem[13] ^ mem[14] ^ mem[11])) ? 1'b1 : 1'b0;

    // 1st somai
    assign sum_1st[0] = bit_sumi[0] + bit_sumi[1];
    assign sum_1st[1] = bit_sumi[2] + bit_sumi[3];
    assign sum_1st[2] = bit_sumi[4] + bit_sumi[5];
    assign sum_1st[3] = bit_sumi[6] + bit_sumi[7];

    // 2nd somai
    assign sum_2st[0] = sum_1st[0] + sum_1st[1];
    assign sum_2st[1] = sum_1st[2] + sum_1st[3];

    // 3rd somai
    assign sum_3st = sum_2st[0] + sum_2st[1];
  // end

  //============== SOMA0======================================================================

  // always @(*) begin
    // Lógica soma0
    assign bit_sum0[0] = (mem[8]  != (mem[0] ^ mem[4] ^ mem[5] ^ mem[2])) ? 1'b1 : 1'b0;
    assign bit_sum0[1] = (mem[9]  != (mem[0] ^ mem[1] ^ mem[2] ^ mem[4] ^ mem[5] ^ mem[6] ^ mem[7])) ? 1'b1 : 1'b0;
    assign bit_sum0[2] = (mem[10] != (mem[0] ^ mem[2] ^ mem[3] ^ mem[6] ^ mem[7])) ? 1'b1 : 1'b0;
    assign bit_sum0[3] = (mem[11] != (mem[1] ^ mem[3] ^ mem[4] ^ mem[7])) ? 1'b1 : 1'b0;
    assign bit_sum0[4] = (mem[12] != (mem[0] ^ mem[1] ^ mem[2] ^ mem[3] ^ mem[4] ^ mem[6] ^ mem[7])) ? 1'b1 : 1'b0;
    assign bit_sum0[5] = (mem[13] != (mem[1] ^ mem[2] ^ mem[4])) ? 1'b1 : 1'b0;
    assign bit_sum0[6] = (mem[14] != (mem[0] ^ mem[1] ^ mem[4])) ? 1'b1 : 1'b0;
    assign bit_sum0[7] = (mem[15] != (mem[0] ^ mem[1] ^ mem[4] ^ mem[5] ^ mem[2])) ? 1'b1 : 1'b0;

    // 1st soma0
    assign sum0_1st[0] = bit_sum0[0] + bit_sum0[1];
    assign sum0_1st[1] = bit_sum0[2] + bit_sum0[3];
    assign sum0_1st[2] = bit_sum0[4] + bit_sum0[5];
    assign sum0_1st[3] = bit_sum0[6] + bit_sum0[7];

    // 2nd soma0
    assign sum0_2st[0] = sum0_1st[0] + sum0_1st[1];
    assign sum0_2st[1] = sum0_1st[2] + sum0_1st[3];

    // 3rd soma0
    assign sum0_3st = sum0_2st[0] + sum0_2st[1];
  // end

  //============== Correção=====================================================================

  // always @(*) begin
    // Correção de lógica
    assign logica_corr[0] = (e[0] == 1'b1 && e[7:1] == 7'b0000000) ? 1'b1 :1'b0;
    assign logica_corr[1] = (e[0] == 1'b0 && e[1]   == 1'b1 && e[7:2] ==6'b000000) ? 1'b1 : 1'b0;
    assign logica_corr[2] = (e[0] == 1'b0 && e[2:1] == 2'b01 && e[7:3] ==5'b00000) ? 1'b1 : 1'b0;
    assign logica_corr[3] = (e[0] == 1'b0 && e[3:1] == 3'b001 && e[7:4] ==4'b0000) ? 1'b1 : 1'b0;
    assign logica_corr[4] = (e[0] == 1'b0 && e[4:1] == 4'b0001 && e[7:5] ==3'b000) ? 1'b1 : 1'b0;
    assign logica_corr[5] = (e[0] == 1'b0 && e[5:1] == 5'b00001 && e[7:6] ==2'b00) ? 1'b1 : 1'b0;
    assign logica_corr[6] = (e[0] == 1'b0 && e[6:1] == 6'b000001 && e[7] ==1'b0) ? 1'b1 : 1'b0;
    assign logica_corr[7] = (e[7:0] == 8'b00000001) ? 1'b1 : 1'b0;
    assign logica_baixo = (soma0 == 4'b0010) || (soma0 == 4'b0001 && somai <= 4'b0010) || (soma0 == 4'b0011 && somai > 4'b0011);

    // Correção de bits
    assign f[0] = ((soma0 == 4'b0001) && (logica_corr[0] == 1'b1)) || (logica_baixo && e[0]) ? ~mem[8] : mem[8];
    assign f[1] = ((soma0 == 4'b0001) && (logica_corr[1] == 1'b1)) || (logica_baixo && e[1]) ? ~mem[9] : mem[9];
    assign f[2] = ((soma0 == 4'b0001) && (logica_corr[2] == 1'b1)) || (logica_baixo && e[2]) ? ~mem[10] : mem[10];
    assign f[3] = ((soma0 == 4'b0001) && (logica_corr[3] == 1'b1)) || (logica_baixo && e[3]) ? ~mem[11] : mem[11];
    assign f[4] = ((soma0 == 4'b0001) && (logica_corr[4] == 1'b1)) || (logica_baixo && e[4]) ? ~mem[12] : mem[12];
    assign f[5] = ((soma0 == 4'b0001) && (logica_corr[5] == 1'b1)) || (logica_baixo && e[5]) ? ~mem[13] : mem[13];
    assign f[6] = ((soma0 == 4'b0001) && (logica_corr[6] == 1'b1)) || (logica_baixo && e[6]) ? ~mem[14] : mem[14];
    assign f[7] = ((soma0 == 4'b0001) && (logica_corr[7] == 1'b1)) || (logica_baixo && e[7]) ? ~mem[15] : mem[15];
  // end

endmodule