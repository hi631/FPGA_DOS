`default_nettype none

module Microcomputer(
	input	wire		clk_50Mi,
  // SDRAM
	inout wire [15:0]     SDRAM_DATA, // SDRAM Data bus 16 Bits
	output wire [12:0]    SDRAM_ADDR, // SDRAM Address bus 13 Bits
	output wire           SDRAM_DQML, // SDRAM Low-byte Data Mask
	output wire           SDRAM_DQMH, // SDRAM High-byte Data Mask
	output wire           SDRAM_nWE,  // SDRAM Write Enable
	output wire           SDRAM_nCAS, // SDRAM Column Address Strobe
	output wire           SDRAM_nRAS, // SDRAM Row Address Strobe
	output wire           SDRAM_nCS,  // SDRAM Chip Select
	output wire [1:0]     SDRAM_BA,   // SDRAM Bank Address
	output wire           SDRAM_CLK,  // SDRAM Clock
	output wire           SDRAM_CKE,  // SDRAM Clock Enable
	// SDCARD
	output wire 		SD_nCS,		// CS
	output wire 		SD_CK,		// SCLK
	output wire 		SD_DI,		// MOSI
	input  wire  		SD_DO,		// MISO
	// I/O
	input	wire			rxd1,
	output wire			txd1,
	//input wire		rxd2,cts1,cts2,
	//output wire		txd2,rts1,rts2,
	input wire   	[1:0]	BTN,
	output wire 	[7:0]	LED
	);

	wire			clk = clk_50M;
	wire			n_reset;
	wire			n_WR;
	wire			n_RD;
	wire	[15:0]	cpuAddress;
	wire	[7:0]	cpuDataOut;
	wire	[7:0]	cpuDataIn;

//	wire	[7:0]	internalRam2DataOut;
	wire	[7:0]	basRomData;
	wire	[7:0]	internalRam1DataOut;
	wire	[7:0]	sdCardDataOut;
	wire	[7:0]	interface1DataOut, interface2DataOut;
	wire	[7:0]	interface3DataOut, interface3Datain;
	reg 	[7:0]	interface4DataOut;
	wire	[7:0]	interface4Datain;
	wire	[7:0]	dramDataOut;
	
	wire			n_memWR;	// :='1';
	wire			n_memRD;	// :='1';

	wire			n_ioWR;	// :='1';
	wire			n_ioRD;	// :='1';
	wire			n_MREQ;	// :='1';
	wire			n_IORQ;	// :='1';	

	wire			n_int1;	// :='1';	
	wire			n_int2;	// :='1';	
	wire			n_internalRam1CS;	// :='1';
	wire			n_internalRam2CS;	// :='1';
	wire			n_basRomCS;	// :='1';
	wire			n_sdCardCS;	// :='1';
//	wire			n_interface1CS;	// :='1';
	wire			n_aaronCS;	// :='1';
	wire			n_interface1CS, n_interface2CS;	// :='1';
	wire			n_interface3CS, n_interface4CS;	// :='1';
	wire			n_dRamCS;
	
	wire			locked,clksdr,clkcs,clk_50M;
	wire			driveLED;
	wire [7:0]  leds,stsout;
	//assign locked   = 1'b1;
	assign n_reset  = locked && ~BTN[0];
	assign LED[7:0] = 0; 
	//assign LED[2] = 1'b1;
	//assign LED[1]   = cpuClock && cpuClockx1 && cpuClockx2;
	//assign LED[0]   = !driveLED;

	//CPM
	reg 			n_RomActive;	// :='1';
	//CPM
	// Disable ROM if out 38. Re-enable when (asynchronous) reset pressed
	always @(posedge n_ioWR) begin
		if (n_reset == 1'b0) begin
			n_RomActive	<= 1'b0;
		end else //if (rising_edge[n_ioWR]) begin
			if (cpuAddress[7:0] == 8'b00111000) begin	// $38
				n_RomActive	<= 1'b1;
			end
		//end
	end

	clkgen clkgen(
		.CLK_IN1(clk_50Mi),.CLK_OUT1(cpuClockx2),.CLK_OUT2(clksdr),
		.CLK_OUT3(clkcs),.CLK_OUT4(clk_50M),.LOCKED(locked));
	 
  t80s #(	1,	1,	0	) cpu1 (
		.reset_n(n_reset), .clk_n(cpuClock), .wait_n(1'b1),
		.int_n(1'b1), .nmi_n(1'b1), .busrq_n(1'b1), 
		.mreq_n(n_MREQ), .iorq_n(n_IORQ), .rd_n(n_RD), .wr_n(n_WR),
		.a(cpuAddress), .di(cpuDataIn), .do(cpuDataOut) );

	// 8KB BASIC
	Z80_CPM_BASIC_ROM	rom1 (
		.address(cpuAddress[12:0]),
		.clock(clk),
		.q(basRomData)
	);

		InternalRam4K	ram1 (
		.address(cpuAddress[10:0]),
		.clock(clk),
		.data(cpuDataOut),
		.wren( ~(n_memWR | n_internalRam1CS)),
		.q(internalRam1DataOut)
	);
	
	bufferedUART	io1 (
		.clk(cpuClock),
		.n_wr(n_interface1CS | n_ioWR), .n_rd(n_interface1CS | n_ioRD),
		.n_int(n_int1), .regSel(cpuAddress[0]),
		.dataIn(cpuDataOut), .dataOut(interface1DataOut),
		.rxClock(serialClock), .txClock(serialClock),
		.rxd(rxd1),	.txd(txd1), .n_cts(1'b0), .n_dcd(1'b0) , .n_rts() );

	bufferedUART	io2 (
		.clk(clk),
		.n_wr(n_interface2CS | n_ioWR), .n_rd(n_interface2CS | n_ioRD),
		.n_int(n_int2), .regSel(cpuAddress[0]),
		.dataIn(cpuDataOut), .dataOut(interface2DataOut),
		.rxClock(serialClock), .txClock(serialClock),
		.rxd(), .txd(), .n_cts(1'b0), .n_dcd(1'b0), .n_rts() );

	sd_controller	sd1 (
		.sdCS(SD_nCS),
		.sdMOSI(SD_DI),
		.sdMISO(SD_DO),
		.sdSCLK(SD_CK),
		.n_wr(n_sdCardCS | n_ioWR),
		.n_rd(n_sdCardCS | n_ioRD),
		.n_reset(n_reset),
		.dataIn(cpuDataOut),
		.dataOut(sdCardDataOut),
		//.stsout(stsout),
		.regAddr(cpuAddress[2:0]),
		.driveLED(driveLED),
		.clk(sdClock)
	);

	reg [15:0] dmyAddress;
	reg [15:0] dmyDataOut;
	wire [15:0] dmyDataIn;
	reg             dmywe,dmyoe;
	reg [3:0] seqct;
	always @(posedge cpuClock) begin 
		seqct <= seqct +1 ;
		case(seqct) 
			4'h0: begin dmyAddress <= 16'h8000; dmyDataOut <= 16'h1234; dmywe <= 1'b1; dmyoe <= 1'b0; end
			4'h1: begin dmywe <= 1'b0; dmyoe <= 1'b0; end
			4'h2: begin dmyAddress <= 16'h8001; dmyDataOut <= 16'habcd; dmywe <= 1'b1; dmyoe <= 1'b0; end
			4'h3: begin dmywe <= 1'b0; dmyoe <= 1'b0; end
			4'h4: begin dmyAddress <= 16'h8000; dmyDataOut <= 16'h1234; dmywe <= 1'b0; dmyoe <= 1'b1; end
			4'h5: begin dmywe <= 1'b0; dmyoe <= 1'b0; end
			4'h6: begin dmyAddress <= 16'h8001; dmyDataOut <= 16'h1234; dmywe <= 1'b0; dmyoe <= 1'b1; end
			4'h7: begin dmywe <= 1'b0; dmyoe <= 1'b0; end
		endcase
	end

	assign SDRAM_CLK = ~clksdr; 
	assign SDRAM_CKE = 1'b1;
	sdram sdram (
	  .clk_hi( clksdr), .sdt( syncsd[2:0]), .init( !locked),
	  .addr({8'h0,cpuAddress}), .din( cpuDataOut), .dout(dramDataOut),
	  .ds( 2'b11), .we(~(n_memWR | n_dRamCS)), .oe(~(n_memRD | n_dRamCS) ),
	  //.addr({8'h0,dmyAddress}), .din( dmyDataOut), .dout(dmyDataIn),
	  //.ds( 2'b11), .we(dmywe), .oe(dmyoe),
	  .sd_addr( SDRAM_ADDR), .sd_data( SDRAM_DATA), .sd_dqm( {SDRAM_DQMH, SDRAM_DQML} ),
	  .sd_ba( SDRAM_BA), .sd_cs( SDRAM_nCS), .sd_we( SDRAM_nWE),
	  .sd_ras( SDRAM_nRAS), .sd_cas( SDRAM_nCAS) );

	reg [3:0]   syncsd;
	reg [7:0]   ramoutb;
	reg clkcpud;
	always @(posedge clksdr)	begin
		clkcpud <= cpuClock;
		if(cpuClock && !clkcpud && syncsd[3:0]!=4'h0) syncsd[3:0] <= 4'h1;
		else                                          syncsd[3:0] <= syncsd[3:0] + 4'd1;
		//
		if(syncsd==3'h6) ramoutb <= dramDataOut;
	end

	assign	n_ioWR	= n_WR | n_IORQ;
	assign	n_memWR	= n_WR | n_MREQ;
	assign	n_ioRD	= n_RD | n_IORQ;
	assign	n_memRD	= n_RD | n_MREQ;

	//assign	n_dRamCS	= (cpuAddress[15:13] == 3'b010) ? (1'b0) : (1'b1);
	assign	n_dRamCS	= ~n_basRomCS;	// 64KB
	assign	n_basRomCS	= (cpuAddress[15:13] == 3'b000 && n_RomActive == 1'b0) ? (1'b0) : (1'b1);	//8KB at 0000 - 1FFF
	//assign	n_internalRam1CS	=  ~n_basRomCS;	// 64KB
	assign	n_internalRam1CS	= (cpuAddress[15:11] == 5'b00100) ? (1'b0) : (1'b1); // 1KB 2000 - 27FF
	assign	n_interface1CS	= (cpuAddress[7:1] == 7'b1000000 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0)	: (1'b1); // 2 Bytes $80-$81
	assign	n_interface2CS	= (cpuAddress[7:1] == 7'b1000001 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0)	: (1'b1); // 2 Bytes $82-$83
	assign	n_interface3CS	= (cpuAddress[7:2] == 6'b100001 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0) : (1'b1);	// 4 Bytes $84-$87(132 -
	assign	n_sdCardCS	= (cpuAddress[7:3] == 5'b10001 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0)	: (1'b1); // 8 Bytes $88-$8F
	assign	n_interface4CS	= (cpuAddress[7:1] == 7'b1001000 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0)	: (1'b1); // 2 Bytes $90-$91(144 -
	assign	n_aaronCS	= (cpuAddress[7:1] == 7'b1001000 && (n_ioWR == 1'b0 || n_ioRD == 1'b0)) ? (1'b0) : (1'b1);	// 2 Bytes $90-$91

	assign	cpuDataIn	= (n_interface1CS == 1'b0) ? (interface1DataOut)
				: (n_interface2CS == 1'b0) ? (interface2DataOut)
				: (n_interface3CS == 1'b0) ? (interface3Datain)
				: (n_interface4CS == 1'b0) ? (interface4Datain)
				: (n_sdCardCS == 1'b0) ? (sdCardDataOut)
				: (n_basRomCS == 1'b0) ? (basRomData)
				//: (n_internalRam1CS == 1'b0) ? (internalRam1DataOut)
				: (n_dRamCS == 1'b0)  ? (dramDataOut)
				: (8'hFF);

(* KEEP *)wire 	cpuClock,cpuClockx2;
(* Preserve *)reg	cpuClockx1;
	reg 	[5:0]		cpuClkCount;
	wire	sdClock,serialClock;
	assign cpuClock  = cpuClockx1; // x1
	always @(posedge cpuClockx2) begin cpuClockx1 <= !cpuClockx1;	end
	
	reg [15:0]	serialClkCount;
	reg [5:0]	sdClkCount;
	assign sdClock   = cpuClockx2;
	assign serialClock	= serialClkCount[15];
	always @(posedge clk_50M) begin
		//if (cpuClkCount < 2) begin	// 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
		//	cpuClkCount	<= cpuClkCount + 1; end else begin cpuClkCount	<= {(5 - 0 + 1){1'b0}}; end
		//if (cpuClkCount < 2) begin	// 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
		//	cpuClock	<= 1'b0; end else begin cpuClock	<= 1'b1; end
		//	if (sdClkCount < 10) begin sdClkCount <= sdClkCount + 1; end
		//	else 					  begin sdClkCount <= {(5 - 0 + 1){1'b0}}; end
		//	if (sdClkCount < 5) sdClock <= 1'b0; else sdClock <= 1'b1;
		// Serial clock // 50MHz master 	// 115200 2416	// 38400 805	// 19200 403	// 9600 201	// 4800 101	// 2400 50
		serialClkCount	<= serialClkCount + 2416;
	end
endmodule
`default_nettype wire
