class master_config extends uvm_object;
	`uvm_object_utils(master_config)
	
	bit is_active=1;
	virtual intf vif;

	function new(string name="master_config");
		super.new(name);
	endfunction
endclass
