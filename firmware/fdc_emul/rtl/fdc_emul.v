//------------------------------------------------------------
// FDC Emul Top Level
//------------------------------------------------------------
// Grabbed from original project Firefly by IanPo (c) 2020-2023
// Refactored by Andy Karpov (c) 2024
// Pinout for real FDC1793 socket, modified by Solegstar (c) 2025
`default_nettype none

module fdc_emul (
	
	// clocks
	input wire         clk,
	input wire         FDC_CLK,

	// cpu signals
	input	wire [1:0] 	FDC_A,
	inout	wire [7:0]	FDC_DATA,
	input	wire			FDC_nWR,
	input	wire			FDC_nRD,
	output wire			nOE_245,
	output wire			DIR_245,

	// decoded ports
	input wire			FDC_nCS,
	input wire			FDC_nRES,
	input	wire			FDC_nDDEN,

	// physical floppy signals
	input	wire			FDC_RDY,
	inout	wire			FDC_WF_DE,
	input	wire			FDC_HRDY,
	output wire			FDC_DRQ,
	output wire			FDC_INTRQ,
	output wire			FDC_TR43,
	input	wire			FDC_RCLK,
	input	wire			FDC_nRAWR,
	output wire			FDC_HLD,
	output wire			FDC_RSTB,
	output wire			FDC_SL,	// EARLY (SL)
	output wire			FDC_SR,	// LATE	(SR)
	input	wire			FDC_WPRT,
	input	wire			FDC_TR00,
	input	wire			FDC_INDEX,
	output wire			FDC_WG,
	output wire			FDC_WR_DATA,
	output wire			FDC_STEP,
	output wire			FDC_DIR

);

reg	[4:0]		r_bdi_ff;
reg				clk_16, r_drq_r_dreg, r_intrq_r_sreg, r_bdi_drq, r_bdi_drq0, r_bdi_intrq, r_bdi_intrq0;
wire				vfoe, wg, rawr, rclk, sync, start, byte_2_read, byte_2_write, translate, reset_crc, vg_reset_n,
					tr43, next_byte, bdi_drq, bdi_intrq, bdi_wr_en, hld, WDATA;

wire	[3:0]		ip_cnt;
wire 	[47:0]	words;
wire	[7:0]		byte_2_main, main_2_byte, bdi_do;
wire	[10:0]	byte_cnt;
wire	[15:0]	crc16_d8;


/////////////////////////////////////////////////////////////////
assign FDC_RSTB = 1'b0;
assign FDC_SL = 1'b0;	// EARLY (SL)
assign FDC_SR = 1'b0;	// LATE	(SR)

assign FDC_WF_DE = wg ? 1'bz : vfoe;

assign FDC_DRQ = bdi_drq;
assign FDC_INTRQ = bdi_intrq;

assign FDC_HLD = hld;
assign FDC_WG = wg;
assign FDC_WR_DATA = ~WDATA;

assign bdi_wr_en = ~( FDC_nCS | FDC_nWR );
assign vg_reset_n = FDC_nRES;

// CLK 16MHz
always @( posedge clk )
begin
	clk_16 <= ~clk_16;
end

// bdi_drq, bdi_intrq crossing clock domain
always @( posedge clk )
begin
	r_bdi_drq0 <= bdi_drq;
	r_bdi_drq <= r_bdi_drq0;
	
	r_bdi_intrq0 <= bdi_intrq;
	r_bdi_intrq <= r_bdi_intrq0;
end

// bdi status register
always @(posedge clk)
	if (~vg_reset_n)
		r_intrq_r_sreg <= 1'b0;
	else
		if (~r_intrq_r_sreg)
			if ( (~FDC_nRD) && (~FDC_nCS) && (FDC_A[1:0] == 2'b00) )	//    BDI (STATUS register) 1F / 83
				r_intrq_r_sreg <= 1'b1;
			else	;
		else
			if ( ~r_bdi_intrq )
				r_intrq_r_sreg <= 1'b0;

// bdi data register
always @( posedge clk )
	if (~vg_reset_n)
		r_drq_r_dreg <= 1'b0;
	else
		if (~r_drq_r_dreg)
			if (  (~( FDC_nWR & FDC_nRD )) && (~FDC_nCS ) && (FDC_A[1:0] == 2'b11) )	// -   BDI (DATA register) 7F / E3
				r_drq_r_dreg <= 1'b1;
			else	;
		else
			if ( ~r_bdi_drq )
				r_drq_r_dreg <= 1'b0;

// data output
assign FDC_DATA = ~FDC_nRD ? bdi_do : 8'bzzzzzzzz;
assign nOE_245 = FDC_nCS;
assign DIR_245 = FDC_nRD;
	
Main_CTRL U14 (
	.iCLK 	( clk_16 ),
	.iRESETn ( vg_reset_n ),
	.iWR_EN 	( bdi_wr_en ),
	.iADR 	( FDC_A[1:0] ),
	.iDATA 	( FDC_DATA ),
	.oDATA 	( bdi_do ),
//
	.oTG43 	( FDC_TR43 ),
	.oSTEP 	( FDC_STEP ),
	.oDIRC 	( FDC_DIR ),
	.oHLD 	( hld ),
	.iHRDY 	( FDC_HRDY ),
	.iTR00 	( ~FDC_TR00 ),		// inv for real FDC
	.iIP 		( ~FDC_INDEX ),	// inv for real FDC
	.iWRPT 	( ~FDC_WPRT ),		// inv for real FDC
	.oWG 		( wg ),
	.oDRQ 	( bdi_drq ),
	.oINTRQ 	( bdi_intrq ),
//
	.iSYNC			( sync ),
	.iBYTE_CNT		( byte_cnt ),
	.iCRC16_D8		( crc16_d8 ),
	.oRESET_CRC		( reset_crc ),
	.oVFOE			( vfoe ),
	.oIP_CNT			( ip_cnt ),
	.iBYTE_2_MAIN	( byte_2_main ),
	.iBYTE_2_READ	( byte_2_read ),
	.oMAIN_2_BYTE	( main_2_byte ),
	.oBYTE_2_WRITE	( byte_2_write ),
	.oTRANSLATE		( translate ),
	.iNEXT_BYTE		( next_byte ),
//
	.iDRQ_R_DREG	( r_drq_r_dreg ),			//  DRQ     
	.i2RQ_R_SREG	( r_intrq_r_sreg )		//  INTRQ  DRQ    
);

DPLL U15 (
	.iCLK		( clk_16 ),
	.iRDDT	( ~FDC_nRAWR ),	// inv for real FDC
	.oRCLK	( rclk ),
	.oRAWR	( rawr ),
	.iVFOE	( vfoe )
);

AMD U16 (
	.iCLK		( clk_16 ),
	.iRCLK	( rclk ),
	.iRAWR	( rawr ),
	.iVFOE	( vfoe ),
	.iIP_CNT	( ip_cnt ),
	.o3WORDS	( words ),
	.oSTART	( start ),
	.oSYNC	( sync )
);

MFMDEC U17 (
	.iCLK		( clk_16 ),
	.iRCLK	( rclk ),
	.iVFOE	( vfoe ),
	.iSTART	( start ),
	.iSYNC	( sync ),
	.i3WORDS	( words ),
	.oBYTE_2_MAIN	( byte_2_main ),
	.oBYTE_2_READ	( byte_2_read )
);

CRC16_D8 U19 (
	.iCLK				( clk_16 ),
	.iRESET_CRC		( reset_crc ),
	.iBYTE_2_MAIN	( byte_2_main ),
	.iMAIN_2_BYTE	( main_2_byte ),
	.iBYTE_2_READ	( byte_2_read ),
	.iBYTE_2_WRITE	( byte_2_write ),
	.oBYTE_CNT		( byte_cnt ),
	.oCRC16_D8		( crc16_d8 )
);

MFMCDR U20 (
	.iCLK				( clk_16 ),
	.iRESETn			( vg_reset_n ),
	.iWG				( wg ),
	.iMAIN_2_BYTE	( main_2_byte ),
	.iBYTE_2_WRITE	( byte_2_write ),
	.iTRANSLATE		( translate ),
	.oNEXT_BYTE		( next_byte ),
	.oWDATA			( WDATA )
);

endmodule
