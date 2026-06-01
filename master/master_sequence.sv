class master_sequence extends uvm_sequence#(transaction);
	`uvm_object_utils(master_sequence)

	function new(string name="master_sequence");
		super.new(name);
	endfunction

endclass

class fixed_sequence extends master_sequence;
	`uvm_object_utils(fixed_sequence)

	function new(string name="fixed_sequence");
		super.new(name);
	endfunction

	task body();
		repeat(1)
			begin
				req=transaction::type_id::create("req");
				start_item(req);
				assert(req.randomize() with {awburst==2'b00; arburst==2'b00;});
				finish_item(req);
			end
	endtask

endclass

class increment_sequence extends master_sequence;
	`uvm_object_utils(increment_sequence)

	function new(string name="increment_sequence");
		super.new(name);
	endfunction

	task body();
		repeat(1)
			begin
				req=transaction::type_id::create("req");
				start_item(req);
				assert(req.randomize() with {awburst==2'b01; arburst==2'b01;});
				finish_item(req);
			end
	endtask

endclass

class wrap_sequence extends master_sequence;
	`uvm_object_utils(wrap_sequence)

	function new(string name="wrap_sequence");
		super.new(name);
	endfunction

	task body();
		repeat(1)
			begin
				req=transaction::type_id::create("req");
				start_item(req);
				assert(req.randomize() with {awburst==2'b10; arburst==2'b10;});
				finish_item(req);
			end
	endtask

endclass
