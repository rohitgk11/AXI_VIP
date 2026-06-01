class slave_config extends uvm_object;
	`uvm_object_utils(slave_config)
	
	bit is_active=1;
	virtual intf vif;

	function new(string name="slave_config");
		super.new(name);
	endfunction
endclass
