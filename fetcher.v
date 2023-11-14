`default_nettype none
`timescale 1ns/1ns

module fetcher (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [7:0] rom_data_in,
    input wire [7:0] icp_value,
    output reg [7:0] ecp_value,
    output reg [7:0] data_out_0,
    output reg [7:0] data_out_1,
    output reg [7:0] data_out_2,
    output wire inhibit_cpu,
    output wire fetcher_inhibitted
);
	parameter CACHE_SIZE = 256;
	parameter MIN_BYTES_LEAD = 16;

	reg [7:0] cache [CACHE_SIZE - 1:0];
	reg [7:0] ecp;

	reg [7:0] ecp_lead;
	reg [7:0] icp_lead;

	assign inhibit_cpu = ecp_lead < MIN_BYTES_LEAD;
	assign fetcher_inhibitted = icp_lead < MIN_BYTES_LEAD;

	assign data_out_0 = cache[icp];
	assign data_out_1 = cache[icp + 1];
	assign data_out_2 = cache[icp + 2];

	assign ecp_value = ecp;

	always @(posedge clk) begin
		if (rst) begin
			ecp <= 0;
		end else begin
			if (ecp > icp_value) begin
				ecp_lead <= ecp - icp_value - 1;
				icp_lead <= (CACHE_SIZE - 1) - ecp + icp_value;
			end else begin
				ecp_lead <= ((CACHE_SIZE - 1) - icp_value) + ecp;
				icp_lead <= icp_value - ecp - 1;
			end

			if (icp_lead >= MIN_BYTES_LEAD) begin
				cache[ecp] <= rom_data_in;
				ecp <= ecp + 1'b1;
			end
		end
	end

endmodule
