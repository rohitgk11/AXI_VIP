interface intf(input bit aclk);
	//logic aclk;
	logic areste_n;

	//Write Address
	logic [3:0]awid;
	logic [31:0]awaddr;
	logic [3:0]awlen;
	logic [2:0]awsize;
	logic [1:0]awburst;
	logic awvalid;
	logic awready;
	
	//Write Data
	logic [3:0]wid;
	logic [31:0]wdata;
	logic [3:0]wstrb;
	logic wlast;
	logic wvalid;
	logic wready;

	//Write Response
	logic bid;
	logic [1:0]bresp;
	logic bvalid;
	logic bready;

	//Read Address
	logic [3:0]arid;
	logic [31:0]araddr;
	logic [3:0]arlen;
	logic [2:0]arsize;
	logic [1:0]arburst;
	logic arvalid;
	logic arready;

	//Read Data
	logic [3:0]rid;
	logic [31:0]rdata;
	logic [1:0]rresp;
	logic rlast;
	logic rvalid;
	logic rready;

	clocking mdrv@(posedge aclk);
		default input #1 output #1;
		output awid, awaddr, awlen, awsize, awburst, awvalid;
		input awready;

		output wid, wdata, wstrb, wlast, wvalid;
		input wready;
		
		output bready;
		input bid, bresp, bvalid;

		output arid, araddr, arlen, arsize, arburst, arvalid;
		input arready;

		output rready;
		input rid, rdata, rresp,  rlast, rvalid;
	endclocking 

	clocking mmon@(posedge aclk);
		default input #1 output #1;
		input awid, awaddr, awlen, awsize, awburst, awvalid;
		input awready;

		input wid, wdata, wstrb, wlast, wvalid;
		input wready;
		
		input bvalid;
		input bid, bresp, bready;

		input arid, araddr, arlen, arsize, arburst, arvalid;
		input arready;

		input rready;
		input rid, rdata, rresp,  rlast, rvalid;
	endclocking 

	clocking sdrv@(posedge aclk);
		default input #1 output #1;
		input awid, awaddr, awlen, awsize, awburst, awvalid;
		output awready;

		input wid, wdata, wstrb, wlast, wvalid;
		output wready;
		
		input bready;
		output bid, bresp, bvalid;

		input arid, araddr, arlen, arsize, arburst, arvalid;
		output arready;

		input rready;
		output rid, rdata, rresp,  rlast, rvalid;
	endclocking 

	clocking smon@(posedge aclk);
		default input #1 output #1;
		input awid, awaddr, awlen, awsize, awburst, awvalid;
		input awready;

		input wid, wdata, wstrb, wlast, wvalid;
		input wready;
		
		input bvalid;
		input bid, bresp, bready;

		input arid, araddr, arlen, arsize, arburst, arvalid;
		input arready;

		input rready;
		input rid, rdata, rresp,  rlast, rvalid;
	endclocking 

	modport MDRV(clocking mdrv);
	modport MMON(clocking mmon);
	modport SDRV(clocking sdrv);
	modport SMON(clocking smon);

	//Write Address
	property p1;
		@(posedge aclk) $rose(awvalid) |-> !$isunknown(awaddr) || !$isunknown(awlen) || !$isunknown(awsize) || !$isunknown(awburst);
	endproperty

	property p2;
		@(posedge aclk) $rose(awvalid) && $rose(awready) |=> !awvalid;
	endproperty

	
	//Write Data
	 property p5;
		@(posedge aclk) $rose(wvalid) && $rose(wready) |=> !wvalid;
	endproperty

	
	//Read Address
	property p3;
		@(posedge aclk) $rose(arvalid) |-> !$isunknown(araddr) || !$isunknown(arlen) || !$isunknown(arsize) || !$isunknown(arburst);
	endproperty

	property p4;
		@(posedge aclk) $rose(arvalid) && $rose(arready) |=> !arvalid;
	endproperty

	
	//Read Data
	 property p6;
		@(posedge aclk) $rose(rvalid) && $rose(rready) |=> !rvalid;
	endproperty


	pprt1:assert property(p1)
			$display("P1 PASS");
		else
			$display("P1 FAIL");

	pprt2:assert property(p2)
		$display("P2 PASS");
		else
		$display("P2 FAIL");

	pprt3:assert property(p3)
			$display("P3 PASS");
		else
			$display("P3 FAIL");

	pprt4:assert property(p4)
			$display("P4 PASS");
		else
			$display("P4 FAIL");

	pprt5:assert property(p5)
			$display("P5 PASS");
		else
			$display("P5 FAIL");

	pprt6:assert property(p6)
			$display("P6 PASS");
		else
			$display("P6 FAIL");
	
	/*pprt7:assert property(p7)
			$display("P7 PASS");
		else
			$display("P7 FAIL");*/

endinterface







