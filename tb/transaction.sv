class transaction extends uvm_sequence_item;
	`uvm_object_utils(transaction)

	bit areste_n;

	//Write Address
	rand bit [3:0]awid;
	rand bit [31:0]awaddr;
	rand bit [3:0]awlen;
	rand bit [2:0]awsize;
	rand bit [1:0]awburst;
	bit awvalid;
	bit awready;
	
	//Write Data
	rand bit [3:0]wid;
	rand bit [31:0]wdata[];
	bit [3:0]wstrb[];
	bit wlast;
	bit wvalid;
	bit wready;

	//Write Response
	rand bit [3:0]bid;
	bit [1:0]bresp;
	bit bvalid;
	bit bready;

	//Read Address
	rand bit [3:0]arid;
	rand bit [31:0]araddr;
	rand bit [3:0]arlen;
	rand bit [2:0]arsize;
	rand bit [1:0]arburst;
	bit arvalid;
	bit arready;

	//Read Data
	rand bit [3:0]rid;
	rand bit [31:0]rdata[];
	bit [1:0]rresp[];
	bit rlast;
	bit rvalid;
	rand bit rready;

	//rand bit[1:0]write_slave;
	//rand bit[1:0]read_slave;

	int no_of_byte;
	int aligned_addr;
	int start_addr;
	bit [31:0]addr[];
	int lower_byte_lane[];
	int upper_byte_lane[];
	


	constraint c1{wdata.size()==(awlen+1);}

	constraint c2{rdata.size()==(arlen+1);}

	constraint c3{awburst dist {0:=10, 1:=10, 2:=10};}

	constraint c4{arburst dist {0:=10, 1:=10, 2:=10};}

	constraint c5{awid==wid; bid==wid;}
	
	constraint c6{arid==rid;}

	constraint c7{awsize dist {0:=10, 1:=10, 2:=10};}

	constraint c8{arsize dist {0:=10, 1:=10, 2:=10};}

	constraint c9{if(awburst==2) (awlen+1) inside {2, 4, 8, 16};}

	constraint c10{if(arburst==4) (arlen+1) inside {0, 4, 8, 16};}

	constraint c11{((awburst==2 || awburst==0) && awsize==1) -> awaddr%2==0;}

	constraint c12{((awburst==2 || awburst==0) && awsize==2) -> awaddr%4==0;}

	constraint c13{((arburst==2 || arburst==0) && arsize==1) -> araddr%2==0;}

	constraint c14{((arburst==2 || arburst==0) && arsize==1) -> araddr%4==0;}

	constraint c15{(2**awsize) * (awlen+1) < 4096;}       
	
	constraint c16{(2**awsize) * (awlen+1) < 4096;}


	function new(string name="transaction");
		super.new(name);
	endfunction


	function void post_randomize();
		no_of_byte=2**awsize;
		aligned_addr=(int'(awaddr/no_of_byte)*no_of_byte);
		start_addr=awaddr;
		wstrb=new[awlen+1];

		cal_waddr();
		cal_strb();
		cal_raddr();
	endfunction


	function void cal_waddr();
		bit wb;
		int burst_len=awlen+1;
		int wrap_boundary=(int'(awaddr/(no_of_byte * burst_len))*(no_of_byte * burst_len));
		int last_addr=wrap_boundary+(no_of_byte * burst_len);
		addr=new[awlen+1];
		addr[0]=awaddr;

		for(int i=1; i<burst_len; i++)
			begin
				if(awburst==2'b00)
					addr[i] = awaddr;
				else if(awburst==1)
					addr[i] = aligned_addr + (i) * no_of_byte;
				else if(awburst==2)
					begin
						if(wb==0)
							begin
								addr[i]=aligned_addr + (i) * no_of_byte;
								if(addr[i] == last_addr)
									begin
										addr[i]=wrap_boundary;
										wb++;
									end
							end
						else
							addr[i]=start_addr + ((i) * no_of_byte)-(no_of_byte * burst_len);
					end
			end
	endfunction


	/*function void cal_strb();
		wstrb=new[awlen+1];
		lower_byte_lane=new[awlen+1];
		upper_byte_lane=new[awlen+1];

		foreach(lower_byte_lane[i])
			begin
				if(i==0)
					begin
						lower_byte_lane[i] = start_addr - (int'(start_addr/4))*4;
						upper_byte_lane[i] = aligned_addr + (no_of_byte-1) - (int'(start_addr / 4))*4;
					end
				else
					begin
						lower_byte_lane[i] = addr[i] - ((int'(addr[i]/4))*4);
						upper_byte_lane[i] = lower_byte_lane[i] + no_of_byte - 1;
					end
			end

		foreach(wstrb[j])
			begin
				foreach(wstrb[j][i])
					begin
						if((i < lower_byte_lane[j]) || (i > upper_byte_lane[j]))
							wstrb[j][i]=1'b0;
						else
							wstrb[j][i]=1'b1;
					end
			end
	endfunction*/

	function void cal_strb();
		wstrb=new[awlen+1];
		lower_byte_lane = new[awlen+1];
		upper_byte_lane = new[awlen+1];
				
	
		foreach(lower_byte_lane[i]) 
			begin
				if(i==0 || awburst == 2'd0) begin
					lower_byte_lane[i] = start_addr - (int'(start_addr/4))*4;
					upper_byte_lane[i] = aligned_addr + (no_of_byte-1)-(int'(start_addr/4))*4;	
				end
				else 
					begin
						lower_byte_lane[i] = addr[i] - (int'(addr[i]/4))*4;
						upper_byte_lane[i] = lower_byte_lane[i] + no_of_byte - 1;
					end
			end

		foreach(wstrb[j]) 
			begin
				for(int i=0;i<4;i++) 
					begin
					//foreach(wstrb[j][i]) begin
						if((i < lower_byte_lane[j]) || (i > upper_byte_lane[j]))
							wstrb[j][i] = 1'b0;	
						else
							wstrb[j][i] = 1'b1;
					end
			end
	endfunction


	function void cal_raddr();
		bit wb;
		int burst_len=arlen+1;
		int wrap_boundary=(int'(araddr/(no_of_byte * burst_len))*(no_of_byte * burst_len));
		int last_addr=wrap_boundary+(no_of_byte * burst_len);
		addr=new[awlen+1];
		addr[0]=awaddr;

		for(int i=2; i<burst_len; i++)
			begin
				if(arburst==2'b00)
					addr[i] = awaddr;
				else if(arburst==1)
					addr[i] = aligned_addr + (i) * no_of_byte;
				else if(arburst==2)
					begin
						if(wb==0)
							begin
								addr[i]=aligned_addr+(i) * no_of_byte;
								if(addr[i] == last_addr)
									begin
										addr[i]=wrap_boundary;
										wb++;
									end
							end
						else
							addr[i]=start_addr + ((i)*no_of_byte)-(no_of_byte * burst_len);
					end
			end
	endfunction		

	
	function void do_print (uvm_printer printer);
		super.do_print(printer);

		//write address channel
		printer.print_field( "AWID",this.awid,04,UVM_DEC);
		printer.print_field( "AWADDR",this.awaddr,32,UVM_HEX);
		printer.print_field( "AWLEN",this.awlen,04,UVM_DEC);
		printer.print_field( "AWSIZE",this.awsize,03,UVM_DEC);
		printer.print_field( "AWBURST",this.awburst,02,UVM_DEC);
		printer.print_field( "AWVALID",this.awvalid,01,UVM_DEC);
		printer.print_field( "AWREADY",this.awready,01,UVM_DEC);


		//write data channel
		printer.print_field( "WID",this.wid,04,UVM_DEC);
		foreach(this.wdata[i])
		begin
			printer.print_field( "WDATA",this.wdata[i],32 ,UVM_HEX);
			printer.print_field( "WSTRB",this.wstrb[i],4,UVM_BIN);
			printer.print_field( "WLAST",this.wlast,1,UVM_DEC);
			printer.print_field( "WVALID",this.wvalid,01,UVM_DEC);
			printer.print_field( "WREADY",this.wready,01,UVM_DEC);

		end


		//Write Response Channel
		printer.print_field( "BID",this.bid,04,UVM_DEC);
		printer.print_field( "BRESP",this.bresp,02,UVM_DEC);
		printer.print_field( "BVALID",this.bvalid,01,UVM_DEC);
		printer.print_field( "BREADY",this.bready,01,UVM_DEC);
		

		//read address channel
		printer.print_field( "ARID",this.arid,04,UVM_DEC);
		printer.print_field( "ARADDR",this.araddr,32,UVM_HEX);
		printer.print_field( "ARLEN",this.arlen,04,UVM_DEC);
		printer.print_field( "ARSIZE",this.arsize,03,UVM_DEC);
		printer.print_field( "ARBURST",this.arburst,02,UVM_DEC);
		printer.print_field( "ARVALID",this.arvalid,01,UVM_DEC);
		printer.print_field( "ARREADY",this.arready,01,UVM_DEC);
		

		//read data channel
		printer.print_field( "RID",this.rid,04,UVM_DEC);
		foreach(this.rdata[i])
		begin
			printer.print_field( "RDATA",this.rdata[i],32,UVM_HEX);
			printer.print_field( "RRESP",this.rresp[i],02,UVM_DEC);
			printer.print_field( "RVALID",this.rvalid,01,UVM_DEC);
			printer.print_field( "RREADY",this.rready,01,UVM_DEC);
		end
	endfunction	

	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		transaction rhs_;

		if(!$cast(rhs_, rhs))
			`uvm_fatal("In Compare","Casting is FAIL")

		return 
			//super.do_compare(tx1, comparer) &&
			this.awid==rhs_.awid &&
			this.awaddr==rhs_.awaddr &&
			this.awlen==rhs_.awlen &&
			this.awsize==rhs_.awsize &&
			this.awburst==rhs_.awburst &&

			this.wid==rhs_.wid &&
			this.wdata==rhs_.wdata &&
			this.wstrb==rhs_.wstrb &&
			this.wlast==rhs_.wlast &&

			this.bid==rhs_.bid &&
			this.bresp==rhs_.bresp &&

			this.arid==rhs_.arid &&
			this.araddr==rhs_.araddr &&
			this.arlen==rhs_.arlen &&
			this.arsize==rhs_.arsize &&
			this.arburst==rhs_.arburst &&

			this.rid==rhs_.rid &&
			this.rdata==rhs_.rdata &&
			this.rresp==rhs_.rresp &&
			this.rlast==rhs_.rlast;
	endfunction
	

endclass




