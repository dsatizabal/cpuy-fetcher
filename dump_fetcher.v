module dump();
	initial begin
		$dumpfile ("fetcher.vcd");
		$dumpvars (0, tb);
		#1;
	end
endmodule
