/* tv6sys.pro - prototypes of public functions in tv6

An alphabetical cross-reference is at the end.  

The cross-reference is created automatically by the program mkproxrf.exe from
what it finds here.  Thus, the format should be observed.  In particular, the
module names should appear with asterisks and the individual function names
should appear as comments preceded by tabs ("<tab><tab>//").

29 Jan 93 EFE.  Created from many sources
*/

#ifndef TV6SYS_PRO
 #define TV6SYS_PRO

#include <stddef.h>		// _fortran
#include "icf.h"
#include "fortran.h"	// STRD
#include "object.h"
#include "udraw.h"


/********************************* ADDOBJ.C **********************************/

int image_add(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,operation);
		// image_add() ---- binary operations on images

int set_image_sign(struct object_descriptor *);
		// set_image_sign() ---- forces image to signed status

int reset_image_sign(struct object_descriptor *);
		// reset_image_sign() ---- forces image to unsigned status

int binary_op_image(struct object_descriptor *,char *,char *,long,long,operation);
		// binary_op_image() ---- called by image_add

int num_op_image(struct object_descriptor *,char *,float,long,long,operation,long);
		// num_op_image()	 ---- called by image_add

int rfile_add(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,operation);
		// rfile_add()		 ---- floating point rfile binary operations

int binary_op_rfile(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,operation);
		// binary_op_rfile() ---- called by rfile_add -- handles operations on two rfiles

int num_op_rfile(struct object_descriptor *,char *,float,operation,long);
		// num_op_rfile()	 ---- called by rfile_add -- handles case of constant OP rfile


/********************************* ALARM2.C **********************************/

void _init_alarm(void);
		// _init_alarm() ---- install alarm clock interrupts

void _set_alarm(void);
		// _set_alarm() ---- set the alarm clock

void	_reset_alarm(void);
		// _reset_alarm() ---- reset the alarm clock process

void _rmv_alarm(void);
		// _rmv_alarm() ---- remove the interrupts


/********************************* ARCHIVE.C ********************************/

void image_archive(char *,char *);
		// image_archive(); ---- writes all filespec matches to tape

/********************************* AUTODISK.C ********************************/

int auto_disk_name(char *);
		// auto_disk_name(); ---- provides a unique sequential disk name

/********************************* BIN.C *************************************/

void bin_image(struct object_descriptor *,struct object_descriptor *,int);
		// bin_image(); ---- contract an image


/********************************* BLDLUT3.C ********************************/

int bldlut3(struct SAVE_DISPLAY *D, long redo);
		// bldlut3() ---- Builds lookup table


/********************************* BOXCALL.C *********************************/

long boxcall(void);
		// boxcall() ---- Interface between box5.c and tv6.c


/********************************* BOXX.C ************************************/

int boxx(struct object_descriptor *);
		// boxx() ---- A simple box routine -- no display required


/********************************* BOX5.C ************************************/

long box5(StrcObj *, StrcObj *, struct GRAPHER_STRUCTURE *, char *, long, 
				StrcObj *, StrcObj *, long, char *);
		// box5() ---- Interrogation and integration analysis.

long get_value(struct object_descriptor *,short,short,long *);
		// get_value()


/********************************** CATHC.C **********************************/

void Cathc(StrcObj *);
		// MkInt() ---- Calculates intensity correction file.


/********************************* CCC6.C ************************************/

void ccc6_init(void);
		// ccc6_init() ---- initialize camera control module & set up dma

int check_micro_switches(void);
		// check_micro_switches() ---- look for protection vane state

void cs(void);
		// cs() ---- continuously scan the CCD

int exprep(void);
		// exprep() ---- prepare for an exposure up to shutter opening

void delay_msec(int);
		// delay_msec() ---- delay a number of milliseconds

int isord(int);
		// isord() ---- read the (software) state of an optical isolator

void isoset(int, int);
		// isoset() ---- set the (hardware) state of an optical isolator

int micro_switch(int,int *);
		// micro_switch() ---- hook switch sense into extra telemetry addresses

int readim(struct object_descriptor *);
		// readim() ---- read an image into memory and record system status

void setup(void);
		// setup() ---- print the setup table on the screen

void shclos(void);
		// shclos() ---- close the shutter (iso1 off)

void shopen(int);
		// shopen() ---- optionally open the shutter

void tlmccd(void);
		// tlmccd() ---- print telemetry values on the screen

void tlmlocal(void);
		// tlmlocal() ---- enable local addressing and measurement of voltages

void vtrf(void);
		// vtrf() ---- perform a single vertical transfer with binning


/********************************* CCCPM.C ************************************/

int ccdtalk(char *,int);
		// ccdtalk() ---- talk to photometrics -- 


/********************************* _CCC6.ASM *********************************/

void d_delay(int);
		// d_delay() ---- millisecond timer

unsigned long phys_add(short __far *);
		// phys_add() ---- get physical address


/********************************* CLK3.C ************************************/

void clkrd(long *);
		// clkrd() ---- return time left in milliseconds 

int clkset(long *, int *);
		// clkset() ---- start the timer

int clkslp(void);
		// clkslp() ---- wait for time out 

long time_lapse(struct timeb *);
		// time_lapse() ---- elapsed time since a set time

long time_left(void);
		// time_left() ---- return the time left before the alarm rings

int time_out(void);
		// time_out() ---- wait for alarm to time out


/********************************** CONVERT.C ********************************/

int image_convert(struct object_descriptor *,struct object_descriptor *);

/********************************** CORRECT.C ********************************/

void corr_int(StrcObj *, StrcObj *, int *);
		//corr_int() ---- intensity correction

void corr_dist(StrcObj *dest, StrcObj *src, int *err);
		//corr_dist() ---- distortion correction


/********************************* CTRLC_C.ASM *******************************/

void _clr_r386(void);
		// _clr_r386() ---- Clear run386.
	
void	_ctrlc_c(void (*)());
		// _ctrlc_c() ---- Capture ^C.

void _ctrlc_ex		(void);
		// _ctrlc_ex() ---- ^C at exit shutdown.


/********************************* DECODER.C *********************************/

long decoder(char *file, Ulong FileLength, void *structure);
		// decoder() ---- Decode ascii configuration file->struc

long decode_enum(char *strucptr, char *fileptr, char **endptr, 
				struct STRUCTURE_TEMPLATE *tem);
		// decode_enum() ---- Decode an enum template

long encoder(char *file, Ushrt *FileLength, void *structure);
		// encoder() ---- Encode structure->ascii config. file

long GetStructureObject(long which_line, char *name, char *object, void *structure);
		// GetStructureObject() ---- Get an object from a structure	

long GetTemplate(void *structure, void **tem, Ushrt *numlines);		
		// GetTemplate() ---- Get a template for a structure

long PutStructureObject(char *cmd, void *structure);
		// PutStructureObject() ---- Put an object into a structure

long ReadEncodedFile(void *structure, char *file_name);
		// ReadEncodedFile() ---- Read encoded disk file into structure

long TypeStructure(void *structure);
		// TypeStructure() ---- Type a structure per a structure template

long WriteEncodedFile(void *structure, char *file_name);
		// WriteEncodedFile() ---- Write encoded structure into disk file


/********************************* DENS_VGA.C ********************************/

int dens_azim(struct object_descriptor *,long,long,float,float,float,int);
		// dens_azim() ---- dens routine for use with vga


/********************************* DENS2.C ***********************************/

long dens(StrcObj *, StrcObj *, struct GRAPHER_STRUCTURE *, char *, StrcObj *,
	StrcObj *, long, long *, long *, float *, float *, long *,
	float *, float *);
		// dens() ---- Perform densitometerization of images

int im_to_rf_header(StrcObj *, StrcObj *);
		// im_to_rf_header ---- Copy image file header to rfile header

void denscntrl(int *,char *);
		// denscntrl() ---- translation from a string of characters to cntrl
	
flt_convert(struct object_descriptor *,float *,void *,int,int);
		// flt_convert() ---- convert part of a line to floats


/********************************* DIRCTRY.C **********************************/

void directory(char *,char *);
		// directory() ---- display a dos directory.


/********************************* DISP.C ************************************/

long disp(StrcObj *, StrcObj *, long, long);
		// disp() ---- Display a file using the kut and scal method.


/********************************* DO_PALET.C ********************************/

long do_palet(char *, Uchar, Uchar, Uchar, Uchar, char *, Uchar, char *);
		// do_palet() ---- An easy-to-program interface to setup_luts


/********************************* DOUBL2.ASM ********************************/

void doubl(Pchar dstbig, Pchar dstsml, void *src, Pchar blut, Ulong nwrd);
		// doubl() ---- Xfer a double file from PC to Piranha


/********************************* DRAWE.C ***********************************/

void drawe(void);
		// drawe() ---- This is the tv6 mockup of draw.c

void drawe_initialize(void);
		// drawe_initialize() ---- give icf the command list from drawe


/********************************* DRAWP.C ***********************************/

void draw(Pshrt, Pshrt, Pshrt);
		// draw() ---- An entry into fortran draw calls.

// draw1()		The next 11 prototypes (draw1 to draw11) are for fortran draw calls

#define P short *					
void draw1	( P,P,P );			
void draw2	( P,P,P, P,P,P );
void draw3	( P,P,P, P,P,P, P,P,P );
void draw4	( P,P,P, P,P,P, P,P,P, P,P,P );
void draw5	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw6	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw7	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw8	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw9	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw10	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void draw11	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
#undef P

		// draw1() ---- format for the cross-index program
		// draw2()
		// draw3()
		// draw4()
		// draw5()
		// draw6()
		// draw7()
		// draw8()
		// draw9()
		// draw10()
		// draw11()

void drew(short i, short j, short k);
		// drew() ---- C call to drw[i]

/* drew1()		The next 11 prototypes (drew1 to drew11) are for fortran drew calls						*/

#define P short 					
void drew1	( P,P,P );			
void drew2	( P,P,P, P,P,P );
void drew3	( P,P,P, P,P,P, P,P,P );
void drew4	( P,P,P, P,P,P, P,P,P, P,P,P );
void drew5	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew6	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew7	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew8	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew9	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew10	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
void drew11	( P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P, P,P,P );
#undef P

		// drew1() ---- format for the cross-indexing program
		// drew2()
		// drew3()
		// drew4()
		// drew5()
		// drew6()
		// drew7()
		// drew8()
		// drew9()
		// drew10()
		// drew11()


void drw0(Pshrt j, Pshrt k);
		// drw0() ---- Setup and initialize display routines.

void drw1(Pshrt j, Pshrt k);
		// drw1() ---- Dummy routine.

void drw2(Pshrt j, Pshrt k);	
		// drw2() ---- Set grey scale parameters.

void drw3(Pshrt j, Pshrt k);
		// drw3() ---- Plot a point.					

void drw4(Pshrt j, Pshrt k);
		// drw4() ---- Place the internal pointer without drawing

void drw5(Pshrt j, Pshrt k);
		// drw5() ---- Draw a line.					

void drw6(Pshrt j, Pshrt k);
		// drw6() ---- Erase or intensify bit planes

void drw7(Pshrt j, Pshrt k);
		// drw7() ---- Set intensity for draw calls 3,5 & 8.

void drw8(Pchar j, Pshrt k);
		// drw8() ---- Draw characters.					

void drw9(Pshrt j, Pshrt k);
		// drw9() ---- Grey scale display.				

void drw10(Puchar j, Pshrt k);
		// drw10() ---- Xfer bit planes to/from video memory.

void drw11(Pshrt j, Pshrt k);
		// drw11() ---- Overlay lookup table programming.	

void drw12(Pshrt j, Pshrt k);
		// drw12() ---- Grey scale programming.			

void drw13(Pshrt j, Pshrt k);
		// drw13() ---- Return coord's of big cursor.		

void drw14(Pshrt j, Pshrt k);
		// drw14() ---- Return coord's of small cursor.		

void drw15(Pshrt j, Pshrt k);
		// drw15() ---- Mouse-cursor control.				

void drw16(Pshrt j, Pshrt k);
		// drw16() ---- Draw the grey scale test pattern.	

void drw17(Pshrt j, Pshrt k);
		// drw17() ---- Set the character size.			

void drw18(Pshrt j, Pshrt k);
		// drw18() ---- Return coord's of the internal pointer.

void drw19(Pshrt j, Pshrt k);
		// drw19() ---- Set the big cursor coord's.		

void drw20(Pshrt j, Pshrt k);
		// drw20() ---- Set the small cursor coord's.		

void drw21(Pshrt j, Pshrt k);
		// drw21() ---- Set the mouse sensitivity.			

void drw22(Pshrt j, Pshrt k);
		// drw22() ---- Same as drw9.					

void drw23(Pshrt j, Pshrt k);
		// drw23() ---- Dummy routine.					

void drw24(Pshrt j, Pshrt k);
		// drw24() ---- Return # clock tics since last cursor move

void drw25(Pshrt j, Pshrt k);
		// drw25() ---- Dummy routine.					

void drw60(Pshrt j, Pshrt k);
		// drw60() ---- Xfer overlay planes to/from video memory

void drw61(Pshrt j, Pshrt k);
		// drw61() ---- Change the Piranha mode.			

int drw_set_value_mask(void);
		// drw_set_value_mask() ---- Sets pmaks and fore/bkgnd. colors

long freeze_cursors(void);
		// freeze_cursors() ---- Freeze the cursors				

void get_cursor_limits(short *,short *,short *,short *);
		// get_cursor_limits()

int mouse_cursors(struct PIRANHA_STATE *);
		// mouse_cursors()

int mouse_install(void);
		// mouse_install()

void mouse_int(short,short,short,short,short,short);
		// mouse_int()

int mouse_step(struct MOUSE_DESCRIPTOR *,struct TIGA_CURS *,signed char);
		// mouse_step()

int read_mouse_cursor(Pshrt lib_number, struct CURSOR new);
		// read_mouse_cursor() ---- Read new cursor structure into lib

void reset_cursor_overlay(mouse_overlay_plane plane, Ulong *fcolr,long w);
		// reset_cursor_overlay() ----  Reset the overlay state and LUT	

void restore_piranha(struct PIRANHA_STATE *piranha);
		// restore_piranha() ---- Restore Piranha values saved via save_piranha

void restore_TIGA(struct TIGA_STATE *);
		// restore_TIGA() ---- Restore TIGA state saved via save_TIGA

void	save_piranha(struct PIRANHA_STATE *piranha);
		// save_piranha() ---- Save most critical Piranha values		

void save_TIGA(struct TIGA_STATE *, mouse_block);
		// save_TIGA() ---- Save display state with mouse block control

void set_big_cursor(double x, double y);
		// set_big_cursor() ---- Set big cursor w/double arguments

void set_cursor_limits(short,short,short,short);
		// set_cursor_limits()

int set_grey_lut(Ushrt mask, char, char, char, char);
		// set_grey_lut() ---- Set the small grey-scale lookup table.

int set_overlay_lut(Ushrt mask, char value);
		// set_overlay_lut() ---- Set the overlay planes small lookup table

void set_sml_cursor(double x, double y);
		// set_sml_cursor() ---- Set sml cursor w/double arguments

long setup_luts(struct LUTS_STRUCTURE *);
		// setup_luts()

int TIGAcursor(struct TIGA_CURS *);
		// TIGAcursor()

void unfreeze_cursors(long hold_block_mous);
		// unfreeze_cursors() ---- Undo freeze_cursors		

long update_draw_box(short *,short *,short *,short *,long,long *);
		// update_draw_box()

void write_chr(char character);
		// write_chr() ---- Write a character on the screen.


/********************************* DRAWT.C ***********************************/

void drawt(void);
		// drawt() ---- Test draw functions	


/********************************* DRAWX.C ***********************************/

void drawx(int,int,int);
		// drawx()

/********************************* DZNG3.C ***********************************/

int dezng(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,int);
		// dzng3() ---- dezinger routine


/********************************* EDITO.C ***********************************/

long editio	(char *, char *, int);
		// editio() ---- Use EDITOR, but allow commas


/********************************* EDOBJECT.C ********************************/

int EdObject(struct object_descriptor *, int *);
		// EdObject() ---- Edit an object descriptor

int type_object(struct object_descriptor *, int *);
		// type_object() ---- Type an entire object descriptor	

void setup_object_template(void);
		// setup_object_template()


/********************************* ERASE.C ***********************************/

int erase(Pchar cmd, int bits, int onoff);
		// erase() ---- Erases/intenisfies any bit plane.


/********************************* ERROR.C ***********************************/

int __near u_error(char *,unsigned long,unsigned long);
		// u_error()

/********************************* EXABYTE.C *********************************/

int move_tape_image(struct object_descriptor *,struct object_descriptor *);
		// move_tape_image()

int get_tape_im_head(struct object_descriptor *);
		// get_tape_im_head()

int position_tape(int,int,char *,long *);
		// position_tape()

int space_to_end(void);
		// space_to_end()

int tape_dismount(void);
		// tape_dismount() ---- logically dismount tape and rewind


/********************************* EXTERNS.C *********************************/

void externs_initialize(void);
		// externs_initialize() ---- initialize the externs module

void idle_proc(void);
		//idle_proc() ---- invoked while ICF waits for characters

void quit(void);
		// quit() ---- to leave system

void	_reset(void);
		// _reset() ---- reset things and close shutter.

void _dos(void);
		// _dos() ---- invoke a secondary copy of the command processor, command.com


/********************************* FILEPATH.C ********************************/

int filepath(char *path_name, char *file_name, char *extension, char *full_name);
		// filepath() ---- Create full path name from a file name


/********************************* FMEMCP2.ASM *******************************/

void fmemcp2(void __far *dst, void __far *src, size_t length);
		// fmemcp2() ---- Copy memory in 4 byte chunks only

/********************************* GETLINES.C ********************************/

void *getlines(struct object_descriptor *, Ulong xs, Ulong ys, Ulong NumberOfLines, 
				Ulong BlocLength, Pulong pitch, Pulong LinesGotten, Plong StartFlag, Pint uerr);
		// getlines() ---- gets pointer to lines of an object

double *getline_piece(StrcObj *, short, short, short, long *, long *);
		// getlines_piece() ---- Get a piece of a line in double form

void get_coords(long);
		// get_coords()


/********************************* GPIBX.C ***********************************/

int ibwrt(int,char *,int);
		// ibwrt() ---- GPIB write function

int ibrd(int,char *,int);
		// ibrd() ---- GPIB read function

int ibrda(int,char *,int);
		// ibrda() ---- asynch read function

int ibwait(int,int);
		// ibwait() ---- wait for GPIB process

int ibrsp(int,char *);
		// ibrsp() ---- GPIB poll serial byte

int ibfind(char *);
		// ibfind() ---- find GPIB device

int ibclr(int);
		// ibclr() ---- clear GPIB device

int ibloc(int);
		// ibloc() ---- place GPIB device in local mode

int ibtmo(int,int);
		// ibtmo() ---- set GPIB timeout condition

int ccdtalk(char *,int);
		// ccdtalk() ---- talk to photometrics -- 

/********************************* GRAPH.C ***********************************/

void get_coords(long i);
		// get_coords() ---- Extract x,y,er from vectors passed to graph

long graph(long npts, void *x, void *y, long mtrol, void *er, char *gname, 
					struct GRAPHER_STRUCTURE *gstruct);
		// graph() ---- General graphing routine

long look_at_graph(long,void *,void *,long,void *,char *,struct GRAPHER_STRUCTURE *,unsigned long);
		// look_at_graph() ---- Cursor driven analysis of a graph

long setup_grapher(char *cmd);
		// setup_grapher() ---- Setup/test graphing & graph structures	

long update_graph_data(long,void *,void *,long,void *,struct GRAPHER_STRUCTURE *,short,long *);
		// update_graph_data()

short x_coord_to_pix(float x);
		// x_coord_to_pix() ---- Convert graph abscissa to screen x-pix

float x_pix_to_coord(short ix);
		// x_pix_to_coord() ---- Convert screen x-pix to graph ordinate 

short y_coord_to_pix(float y);
		// y_coord_to_pix() ---- Convert graph ordiante to screen y-pix

float y_pix_to_coord(short iy);
		// y_pix_to_coord() ---- Convert screen y-pix -> graph abscissa 


/********************************* GRAY3.C ***********************************/

void gray(struct object_descriptor *,int,char *);
		// gray() ---- create a HP laserjet greyscale output

/********************************* HEADER.C **********************************/

int delete_header(struct object_descriptor *);
		// delete_header() ---- delete object_descriptor Header

int copy_header(struct object_descriptor *,struct object_descriptor *);
		// copy_header() ---- copies information in object.Header to another object's header

int header_op(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,operation);
		// header_op() ---- performs manipulations on relevant header fields for binary ops on objects

int type_header(struct object_descriptor *, int *);
		// type_header() ---- print information from header

int fill_basic_header(struct object_descriptor *,struct object_descriptor *);
		// fill_basic_header() ---- malloc space and fill basic header fields

int header_to_disk(struct object_descriptor *);
		// header_to_disk() ---- writes tiff header to disk

/********************************* HEAPLOOK.C ********************************/

void heaplook(void);
		// heaplook() ---- examine the integrity of the heap


/******************************** HELPS.C ************************************/

int add_buff(char **, int *, char **, int, char *, int *);
		// add_buff() ---- add text to the output buffer for helps.c

int helps(char *, char *, short *);
		// helps() ---- help file manipulator

int strpad(char *, char *, int, int);
		// strpad() ---- xfer a string form src to dst, padded with spaces


/********************************* HISTOGRM.C ********************************/

int histogram(struct object_descriptor *,long,long,long);
		// histogram()


/********************************* HTRFC.C **********************************/

void htrfc(float *,float *,float,float,int,int);
		// Htrfc() ---- performs Hankel transform.

/********************************* HTRFC.C **********************************/

void htrfc(float *,float *,float,float,int,int);
		// Htrfc() ---- performs Hankel transform.

/********************************* ICF.C *************************************/

#define CMND int		// this is redefined as an enum in each module that submits a dictionary

int editor(char *, char *, int);
		// editor() ---- access to the ICF editor processing strings

CMND ICF(int);
		// ICF() ---- main repetitive entry to ICF

void ICFinitialize(char *, int);
		// ICFinitialize() ---- initialize ICF and give it its working buffer

void ICFmonitor(char *);
		// ICFmonitor() ---- simulate a monitor command in the operator's stream

int ICFset_commands(char *[], int, char *);
		// ICFset_commands() ---- give ICF a list of command names and a prompt

void ICFset_proc(char *, void (*)(void));
		// ICFset_proc() ---- introduce an external procedure name to ICF

void ICFset_variable(char *, variable_type, void *);
		// ICFset_variable() ---- introduce an external variable to ICF

void ICFreset(int);
		// ICFreset() ---- simulate the end of a command line


/********************************* ICFS.C ************************************/

variable_type analyze_ICFarg(int);
		// analyze_ICFarg() ---- return information about an ICF argument

void *get_ICFarg(int *, variable_type);
		// get_ICFarg() ---- retrieve a specified type of argument from ICF list

int dpull (double [], int);
		// dpull() ---- get an array of doubles from ICF arg list

int ipull (int [], int);
		// ipull() ---- get an array of ints from ICF arg list

int rpull (float [], int);
		// rpull() ---- get an array of floats from the ICF argument list

int spull (short [], int);
		// spull() ---- get an array of shorts from the ICF argument list

int ResolveDictionary(int *, int);
		// ResolveDictionary() ---- find the valid dictionary for a user command

void _fortran ICFS(int *, double *, struct STRD *, int *);
		// ICFS() ---- fortan entry to get_ICFarg

int Certify(int, ...);
		// Certify() ---- certify that ICF args of the required number & type


/********************************* IMFILTER.C ********************************/

int image_filter(struct object_descriptor *, struct object_descriptor *, short *, short, short);
		// image_filter()


/********************************* IM_MOVES.C ********************************/

int im_mem_tape(struct object_descriptor *);
		// im_mem_tape() ---- dummy routine

int im_disk_tape(struct object_descriptor *);
		// im_disk_tape() ---- dummy routine

int im_tape_mem(struct object_descriptor *);
		// im_tape_mem() ---- dummmy routine

int im_tape_disk(struct object_descriptor *);
		// im_tape_disk() ---- dummy routine

int im_tape_tape(struct object_descriptor *);
		// im_tape_tape() ---- dummy routine

int write_tape_header(struct object_descriptor *,char *,int);
		// write_tape_header() ---- dummy routine

int im_disk_disk(struct object_descriptor *,struct object_descriptor *,unsigned long,unsigned long);
		// im_disk_disk() ---- copies image from one disk file to another


/********************************* IPARS.C ***********************************/

struct object_descriptor *Ipars(int *, object_kind, int *);
		// Ipars() controls the flow of object manipulation, checking for inconsistencies.

struct object_descriptor *FindObject(char *, object_status, int, int *);
		// FindObject() ---- look for objects in the system table, and create new ones

int QueueObject(struct object_descriptor *, object_kind);
		// QueueObject() ---- finish defining an object and get it ready to use.

int CloseDiskObject(struct object_descriptor *);
		// CloseDiskObject() ---- Close the file handle associated with an object.

int DeleteObject(struct object_descriptor **, int);
		// DeleteObject() ---- Close disk files and release memory allocations.*/

int ObjectDoesNotExist(struct object_descriptor *);
		// ObjectDoesNotExist() ---- Test whether an object's name is intact

int OpenDiskObject(struct object_descriptor *, object_type);
		// OpenDiskObject() ---- Open disk file in read or write mode

/********************************* J0C.C **********************************/

float j0c(float);
		// J0c() ---- calculates Bessel function.

/********************************* KILLKEY.C**********************************/

int look_for_kill_key(void);
		// look_for_kill_key() --- ICFreset on esc key

/********************************* KYBDIN.C **********************************/

short _fortran ittinx(void);
		// ittinx() ---- get last extended character

short _fortran kybdin(struct STRD *, struct STRD *);
		// kybdin() ---- get characters without waiting in DOS & permit type-ahead

short kybdinc(char *, char);
		// kybdinc() ---- get characters without waiting in DOS & permit type-ahead

/********************************* LASER4.C ********************************/

int lasplot(struct object_descriptor *,int,int,int,int,int,int,char *);
		// lasplot() ---- laserjet plotting

void lasercntrl(int *,char *);
		// lasercntrl() ---- resolve lasplot control words

void lastic(int,float *,int,float,int);
		// lastic() ---- place tic marks on lasplot page


/********************************* LISTOBJS.C ********************************/

void ListObjects(void);
		// ListObjects() ---- List objects.


/********************************* LUBKSB.C **********************************/

void lubksb(double *,int,int *,double *);
		// Lubksb() ---- solves linear equations w/ludcmp.

/********************************* LUDCMP.C **********************************/

void ludcmp(double *,int,int *,double *,int *);
		// Ludcmp() ---- solves linear equations.

/********************************* LZW3.C ************************************/

int LZWPreDecode(struct object_descriptor *,long);
		// LZWPreDecode() ---- sets up decompression routines

int LZWDecode(struct object_descriptor *,char *,char *,long);
		// LZWDecode() ---- handles the main part of image decompression

void LZWCleanup(struct object_descriptor *);
		// LZWCleanup() ---- frees temporary space use by LZW routines

int LZWPreEncode(struct object_descriptor *,long);
		// LZWPreEncode() ---- sets up LZW compression

int LZWEncode(struct object_descriptor *,char *,long);
		// LZWEncode() ---- main part of compression routines

int LZWPostEncode(struct object_descriptor *,long *);
		// LZWPostEncode() ---- finishes up LZW compression


/********************************** MESH9C.C ********************************/

int mesh9c(struct sqparam ,struct perim , struct sqimage ,int *,
	int *,int ,int *, int *);
		// Mesh9c() ---- finds spots in image for sq1ac


/********************************* MOUSE.ASM *********************************/

int _init_mouse(void);
		// _init_mouse() ---- Initialize the mouse driver.

void _rmv_mouse(void);
		// _rmv_mouse() ----  Remove the mouse driver.

void start_mouse(Ushrt);
		// start_mouse() ---- Set up mouse and turn it on.

void stop_mouse(void);
		// stop_mouse() ---- Stop mouse


/********************************* NINT.C ************************************/

int nint(float x);
		// nint() ---- Real -> integer with correct rounding.


/********************************** OBLIQUE.C **********************************/

void Obliq();
		// Obliq() ---- Calculates obliquity effect correction.

/********************************* OCTCOM.C **********************************/

void gtemp(void);
		// gtemp() ---- get the temperature from the octagon

void stemp(float);
		// stemp() ---- set the temp through the octagon

void gpress(void);
		// gpress() ---- get the pressure from the octagon

void spress(float);
		// spress() ---- get the pressure from the octagon

void octogon_shutter_control(int);
		// octogon_shutter_control() ---- control shutter w/ octogon

/********************************* PATCH.C ***********************************/

long patch(int *narg);
		// patch() ---- Move an area of the display screen around

/********************************* PCL.C **********************************/

void pcl_d_a(int,int);
		// pcl_d_a() ---- D/A conversion

void pcl_digital_word_out(int);
		// pcl_digital_word_out() ---- digital out

void pcl_digital_lbyte_out(int);
		// pcl_digital_lbyte_out() ---- digital out

void pcl_digital_hbyte_out(int);
		// pcl_digital_hbyte_out() ---- digital out

void pcl_digital_bit_set(int);
		// pcl_digital_bit_set() ---- digital out

void pcl_digital_bit_clear(int);
		// pcl_digital_bit_clear() ---- digital out

int  pcl_digital_word_in(void);
		// pcl_digital_word_in() ---- digital out

int  pcl_digital_lbyte_in(void);
		// pcl_digital_lbyte_in() ---- digital out

int  pcl_digital_hbyte_in(void);
		// pcl_digital_hbyte_in() ---- digital out

int  pcl_digital_bit_in(int);
		// pcl_digital_bit_in() ---- digital out

float pcl_a_d(int);
		// pcl_a_d() ---- A/D conversion

/********************************* PEAKER2.C ********************************/
int peaker(struct object_descriptor *,int);
		// peaker() ---- fit peaks in rfiles

int tic_to_graph(struct GRAPHER_STRUCTURE *, int,struct rfile_header *,int,int,float,int);
		// tic_to_graph() ---- place lattice tics on graph of rfile

void peakcntrl(int *,char *);
		// peakcntrl() ---- text interface to peaker control word

void ticcntrl(int *,char *,int *);
		// ticcntrl() ---- text interface to tic control word


/********************************* PERIMC.C **********************************/

void perimc(struct perim *, StrcObj *,int *);
		// perimc() ---- Queries user/displays perimeter for sqc/warpc

void ShowEdge(struct perim *, StrcObj *);
		// ShowEdge() ---- Shows perimeter on screen

/********************************* PERMIN.C **********************************/

// auxx.h
typedef enum{
	UnknownFile,
	PermFile,
	Gen5File,
	} binary_file_type;

int read_binary_image(char *, struct object_descriptor *, binary_file_type, int);
		// read_binary_image()

int write_binary_image(char *, struct object_descriptor *, binary_file_type, int);
		// write_binary_image()


/********************************* PROTDRV.C *********************************/

void _cclose(void);  
		// _cclose() ---- close real mode code.				*/

void	realcall(unsigned long, unsigned long);
		// realcall() ---- call the real mode code

void init_real_code	(char *);
		// init_real_code() ---- initialize real mode code			*/


/********************************* _PROT.ASM *********************************/

unsigned long prottoreal(char _far*, unsigned);
		// prottoreal() ---- convert a protected mode address to real mode

void realcall(unsigned long, unsigned long);
		// realcall() ---- call a real mode procedure and pass in a single far argument pointer

void realexit(void);
		// realexit() ---- force the real mode code to exit

int realload(char *, unsigned long *);
		// realload() ---- load real mode server and initialize it


/********************************* PWRSEE.C **********************************/

long pwrsee(StrcObj *, StrcObj *, long, long, float);
		// pwrsee() ---- Display an image file using the pwr method.


/********************************* QPROC2.C **********************************/

void queue_process(void (*)());
		// queue_process() ---- queue an alarm clock interrupt process (function)

void queue_untimed_process(void (*)());
		// queue_untimed_process() ---- queue a process terminated by software int 4Ah

void _end_process(void);
		//_end_process() ---- finish queueed process at time out


/********************************* QUAD2.ASM *********************************/

void quad2(short,short *,long *,long *,short ,short ,short *);
		// quad2() ---- perform distortion correction

void shrink(long *,short *,long );
		// shrink() ---- divide 4-byte pixels by 16 and output as 2-byte

/********************************* RDCAMSTP.C ********************************/

void read_camera_setup(char *);
		// read_camera_setup() ---- read camera setup table from disk file

/********************************* READCAM.C *********************************/

int read_camera_image(struct object_descriptor *, int, int);
		// read_camera_image() ---- take a picture

void camera_initialize(void);
		// camera_intitialize() ---- set up the camera

void read_image(void);
		// read_image() ---- controls image read after integration


/********************************* READ_OBJ.C ********************************/

char * read_obj(struct object_descriptor *, unsigned long, unsigned long, int *);
		// read_obj() ---- get pointer to data described by an object_descriptor

int writ_obj(struct object_descriptor *,unsigned long,unsigned long,char *);
		// writ_obj() ---- write data to space determined by an object descriptor

int move_image(struct object_descriptor *,struct object_descriptor *);
		// move_image() ---- copies image from one place to another

int move_rfile(struct object_descriptor *,struct object_descriptor *);
		// move_rfile() ---- copy rfiles

int value_fill(char *,float,unsigned long,long);
		// value_fill() ---- fill an array of specified length with a 1,4,8, or 16 bit integer value

int get_disk_head(struct object_descriptor *);
		// get_disk_head() ---- determine Kind of disk file and fill object_descriptor and header

int get_rf_head(struct object_descriptor *);
		// get_rf_head() ---- check for rfile format and fill header and object descriptor

int update_data_size(struct object_descriptor *);
		// update_data_size() ---- checks data buffer for proper length and remallocs if necessary


/********************************* REPAK.ASM *********************************/

void repak(Pcfar dst,Pcfar src,Ulong direc,Ulong npix,Ulong bytpx);
		// repak() ---- Repack pixels for words <-> bytes.


/********************************* RF2ASC.C *********************************/

int rf2asc(struct object_descriptor *,char *);
		// rf2asc() ---- output rfiles in ascii format.

/********************************* RFGRAPH.C *********************************/

int rfgraph(struct object_descriptor *,int);
		// rfgraph() ---- graph rfiles on monitor.

void rfgraphcntrl(int *,char *);
		// rfgraphcntrl() ---- text interface to rfgraph control word

/********************************* RSMOOTH.C *********************************/

int smooth_rfile(struct object_descriptor *,int);
		// smooth_rfile() ---- smooth a rfile with a given width.


/********************************* SCREEN.C **********************************/

#include "screen.pro"		// cross-check declarations

void clrscr(void);
		// clrscr() ---- clear the screen

void get_cursor(int *, int *);
		// get_cursor() ---- get_cursor(&x, &y)

void put_cursor(int, int);
		// put_cursor() ---- put_cursor(x, y)

int reset_cursor(void);
		// reset_cursor() ----  bring cursor to column 1 if not there already

void _fortran rstcur(void);
		// rstcur() ---- fortan entry to reset_cursor

void _screen_msg(void);
		// _screen_msg() ---- put "please wait" message on screen

void _screen_rst(void);
		// _screen_rst() ---- restore screen after message

void write_line(int, char *);
		// write_line() ---- write a line to the screen


/********************************* SEE3.C ************************************/

long implement_display_structure(void);
		// implement_display_structure() ---- Display structure parms - TIGA values, LUTs.

long see(struct object_descriptor *src, struct object_descriptor *dst_vram, 
					struct object_descriptor *dst_dram, int *narg, long nwh);
		// see() ---- Display an image type object.

long setup_display (char *cmd);
		// setup_display() ---- Parses strings for keyword instructions

long setup_palet_mask(char *buf);
		// setup_palet_mask() ---- Interpret a palet mask string to a palet mask


/********************************* SERIAL2.C *********************************/

void clear_msg_buffer(void);
		// clear_msg_buffer() ---- Erase the serial line message buffer

void listen(void);
		// listen() ---- Listen to serial line while performing TV6 functions

void post_message(char *);
		// post_message() ---- Put a message in msg_buffer to print later

void receive(void);
		// receive() ---- Send trigger to SER_TSR

void serial(void);
		// serial() ---- Serial line communication

void serial_display(void);
		// serial_display() ---- Display accumulated serial chars if in listen mode

void serial_initialize(void);
		// serial_initialize() ---- Initialize the serial interface

void serial_reset(void);
		// serial_rest() ---- Reset the serial line trigger

char *serial_update(void);
		// serial_update() ---- Sweep chars from serial TSR

void terminal(void);
		// terminal() ---- Emulate a terminal on serial line

void transmit(void);
		// transmit() ---- Send string on serial line

void trans2(void);
		// trans2() ---- Send startstr to CHESS computer

/********************************* SMOOTHER.C *********************************/

void smoother(int *);
		//Smoother() ---- smooths spot locations.

/********************************* SPLINEC.C **********************************/

void splinec(float *,float *,int ,float ,float ,float *);
		// Splinec() ---- calculates spline fit for warp5.

void splintc(float *,float *,float *,int ,float ,float *);
		// Splintc() ---- calculates spline at given point.

void nrerror(char *);
		// Nrerror() ---- Run time error handler

float *vector(int, int);
		// Vector() ----

int *ivector(int, int);
		// Ivector() ----

double *dvector(int, int);
		// Dvector() ----

float **matrix(int,int,int,int);
		// Matrix() ----

double **dmatrix(int,int,int,int);
		// Dmatrix() ----

int **imatrix(int,int,int,int);
		// Imatrix() ----

float **submatrix(float **,int,int,int,int,int,int);
		// Submatrix() ----

void free_vector(float *,int,int);
		// Free_vecotr() ----

void free_ivector(int *,int,int);
		// Free_ivector() ----

void free_dvector(double *,int,int);
		// Free_dvector() ----

void free_matrix(float **,int,int,int,int);
		// Free_matrix() ----

void free_dmatrix(double **,int,int,int,int);
		// Free_dmatrix() ----

void free_imatrix(int **,int,int,int,int);
		// Free_imatrix() ----

void free_submatrix(float **,int,int,int,int);
		// Free_submatrix() ----

float **convert_matrix(float *,int,int,int,int);
		// Convert_matrix() ----

void free_convert_matrix(float **,int,int,int,int);
		// Free_convert_matrix() ----

/********************************** SPOT7C.C ********************************/

void spot7c(short *, struct sqimage ,struct sqparam , struct perim ,
	int, int , float *, float *,float *, float); 
		// Spot7c() ---- finds individual spots for mesh9c

/*********************************** SQC.C **********************************/

void Square2(StrcObj *);
		// Square2() ---- Calculates distortion correction file.

/********************************** SQXTRA.C *********************************/

void CursorPos(StrcObj *,StrcObj *, int, Ulong *, int *, int *, int *);
		// CursorPos() ---- Finds position/delay of a cursor.

void ScreenToSrc(StrcObj *, StrcObj *, int, int, int *, int *);
		// ScreenToSrc() ---- Converts from screen coords to image coords.

void SrcToScreen(StrcObj *, StrcObj *, int, int, int *, int *);
		// SrcToScreen() ---- Converts from image coords to screen coords.

void Toggle(int, int, int, int *);
		// Toggle() ---- Toggles overlays, gray-scale

/********************************** SQ1AC.C **********************************/

void sq1ac(struct sqparam, struct perim, struct sqimage, int *);
		// Sq1ac() ---- finds spots in image for distortion corr.

/********************************** SQ1BC.C **********************************/

void sq1bc(int *);
		// Sq1bc() ---- finds ideal matrix for spots.

/********************************** SQ1CC.C **********************************/

void sq1cc(int,int *,float *,float *,int *);
		// Sq1cc() ---- calculates point spread of spots.

/********************************* SRC_IMG.C *********************************/

void get_cursors(struct CURSOR_SET *ptr, Ulong *delay);
		// get_cursors() ---- Get cursor coords. within image

long src_img(StrcObj *src, StrcObj *img, struct CURSOR_SET *c);
		// src_img() ---- Set up for conversions of coordinates

long whose_window(double *, double *, double *, double *, long, GET_WINDOW);
		// whose_window() ---- Stack windows for cursor locating

double x_img_to_src(double x_img, struct CURSOR_SET *c);
		// x_img_to_src() ---- Convert from screen to file coords

double x_src_to_img(double x_src, struct CURSOR_SET *c);
		// x_src_to_img() ---- Convert file coords to screen coords

double y_img_to_src(double y_img, struct CURSOR_SET *c);
		// y_img_to_src() ---- Convert from screen to file coords

double y_src_to_img(double y_src, struct CURSOR_SET *c);
		// y_src_to_img() ---- Convert file coords to screen coords


/********************************* SREAD.C ***********************************/

int sread(void *vec, Ulong nunbyt, Ulong handle);
		// sread() ---- Read a file via DOS func. 3Fh. 


/********************************* STASH_SC.C ********************************/

long stash_scn(char *, char *, int *);
		// stash_scn() ---- Xfer part of screen to an image object.


/********************************* STATBOX2.C *********************************/

long statbox(StrcObj *, Ulong, Ulong, Ulong, Ulong, long *, double *, double *,
			 double *, double *, double *, double *, double *, double *,
			 float *, long, float, float);
		// statbox() ---- Compute statistics on a subimage within an image.


/********************************* SWPLOGBF.C ********************************/

void SweepLogBuffer(int);
		// SweepLogBuffer() ---- dump characters to disk if more than 800

void CleanLogBuffer(void);
		// CleanLogBuffer() ---- clean out log buffer in preparation for shutdown

void ZeroLogBuffer(void);
		// ZeroLogBuffer() ---- clear the log buffer


/********************************* SUPPORT.C *********************************/

void shotim(int *);
		// shotim() ---- dummied in support.c - show time left on screen


/********************************* SYSTEM.C **********************************/

void system_s(void);
		// system_s() ---- print system name

int passchk(void);
		// passchk() ---- check whether extended functions are enabled

/********************************* TAPEX.C ***********************************/

int trewind(short);
		// trewind()

int tspace(short,short);
		// tspace()

int twrite(unsigned short,char *);
		// twrite()

int tread(unsigned short *,char *);
		// tread()

int twtm(short);
		// twtm()

int twsm(short);
		// twsm()

int modesen(short *,char *);
		// modesen()

int modesel(short,char *);
		// modesel()

int tstatus(void);
		// tstatus()

int check_tape_ready(void);
		// check_tape_ready()

int tape_bot(void);
		// tape_bot()

int reqsen(short *,char *);
		// reqsen()

void tape_to_disk(char *);
		// tape_to_disk()


/********************************* TIFF_IN.C *********************************/

read_compress_image(struct object_descriptor *, char *);
		// read_compress_image() ---- decompresses entire LZW tiff image into memory

int read_diskimage(struct object_descriptor *,unsigned long,unsigned long,char *);
		// read_diskimage() ---- reads arbitrary portion of uncompressed tiff image into memory

int get_im_head(struct object_descriptor *);
		// get_im_head() ---- resolves disk file tiff header and fills object_descriptor and memory header

time_t tif_date_to_int(char *);
		// tif_date_to_int() ---- converts tiff ascii date yyyy:mm:dd hh:mm:ss to integer


/********************************* TIFF_OUT.C ********************************/

strip_calc(struct object_descriptor *);
		// strip_calc() ---- creates strip_pointers for output tiff file

write_compress_image(struct object_descriptor *,char *);
		// write_compress_image() ---- LZW compresses tiff strips to disk

int writ_diskimage(struct object_descriptor *,unsigned long,unsigned long,char *);
		// writ_disk_image() ---- writes image to disk

char * make_im_head(struct object_descriptor *,long *);
		// make_im_head() ---- creates a TIFF header for output

char * make_tif_header(struct object_descriptor *,long *);
		// make_tif_header() ---- called by make_im_head()

tif_date(char *);
		// tif_date() ---- gets current date and time and forms tiff ascii string


/********************************* TILE_WC.C *********************************/
#ifdef PIRANHA_BD
unsigned long __near u_equipment_status(void);
int __near u_bios_revision(unsigned short __near *);
int __near u_board_revision(unsigned short __near *);
int __near u_buffer(unsigned int);
int __near u_clear_screen(unsigned long);
int __near u_composite(int);
unsigned short __near u_get_page(void);
int __near u_init_palet(void);
int __near u_init_video_regs(MONITORINFO20 __near *);
int __near u_lin_to_xy(unsigned long,int,unsigned int,unsigned char *,short __near *,short __near *);
int __near u_lut_revision(unsigned short __near *);
int __near u_pan_scroll(int,int);
int __near u_pan_scroll_ovl(int,int);
int __near u_reset_piranha(void);
int __near u_select_palet(unsigned int,long);
int __near u_set_accmode(unsigned int);
int __near u_set_board(int);
int __near u_set_page(unsigned int);
int __near u_set_palet(unsigned char *,unsigned char *,unsigned char *);
int __near u_tiga_revision(unsigned short *);
int __near u_tile_revision(unsigned short *);
int __near u_version(char *);
int __near u_vsb_revision(unsigned short *);
int __near u_wait_scan(int);
int __near u_window463(int,int,int,int,int,int,int,int);
int __near u_xy_to_lin(int,int,unsigned long __near *,unsigned char __near *,unsigned short __near *,unsigned char *__near *,unsigned char *__near *,unsigned char *__near *);
int __near u_zoom(unsigned int,unsigned int);
int __near u_zoom_ovl(unsigned int,unsigned int);
int __near u_init_piranha(int);
int __near u_exit_piranha(void);
int __near u_bitblt(int,int,int,int,int,int);
int __near u_clear_frame_buffer(unsigned long);
int __near u_draw_line(int,int,int,int);
int __near u_draw_oval(int,int,int,int);
int __near u_draw_ovalarc(int,int,int,int,int,int);
int __near u_draw_piearc(int,int,int,int,int,int);
int __near u_draw_point(int,int);
int __near u_draw_polyline(unsigned int,POINTS __near *);
int __near u_draw_rect(int,int,int,int);
int __near u_fill_convex(unsigned long,unsigned int,POINTS __near *);
int __near u_fill_oval(unsigned long,int,int,int,int);
int __near u_fill_piearc(unsigned long,int,int,int,int,int,int);
int __near u_fill_polygon(unsigned long,unsigned int,POINTS __near *);
int __near u_fill_rect(unsigned long,int,int,int,int);
int __near u_frame_oval(int,int,int,int,int,int);
int __near u_frame_rect(int,int,int,int,int,int);
int __near u_get_colors(short *,short *);
int __near u_get_config(CONFIG __near *);
short __near u_get_curs_state(void);
int __near u_get_curs_xy(short __near *,short __near *);
unsigned long __near u_get_nearest_color(int,int,int,int);
int __near u_get_palet(unsigned char __near *,unsigned char __near *,unsigned char __near *);
int __near u_get_palet_entry(unsigned long,unsigned char __near *,unsigned char __near *,
				unsigned char __near *,unsigned char __near *);
unsigned long __near u_get_pmask(void);
short __near u_get_ppop(void);
short __near u_get_videmode(void);
int __near u_patnfill_convex(unsigned int,POINTS __near *);
int __near u_patfill_oval(int,int,int,int);
int __near u_patnfill_piearc(int,int,int,int,int,int);
int __near u_patnfill_polygon(unsigned int,POINTS __near *);
int __near u_patnfill_rect(int,int,int,int);
int __near u_patnframe_oval(int,int,int,int,int,int);
int __near u_patnframe_rect(int,int,int,int,int,int);
int __near u_patnpen_line(int,int,int,int);
int __near u_patnpen_ovalarc(int,int,int,int,int,int);
int __near u_patnpen_piearc(int,int,int,int,int,int);
int __near u_patnpen_point(int,int);
int __near u_patnpen_polyline(unsigned int,POINTS __near *);
int __near u_pen_line(int,int,int,int);
int __near u_pen_ovalarc(int,int,int,int,int,int);
int __near u_pen_piearc(int,int,int,int,int,int);
int __near u_pen_point(int,int);
int __near u_pen_polyline(unsigned int,POINTS __near *);
unsigned long __near u_get_pixel(int,int);
int __near u_seed_fill(unsigned long,int,int);
int __near u_seed_patnfill(int,int);
int __near u_set_bcolor(unsigned long);
int __near u_set_colors(unsigned long,unsigned long);
int __near u_set_curs_shape(unsigned long);
int __near u_set_curs_state(int);
int __near u_set_curs_xy(int,int);
int __near u_set_draw_origin(int,int);
int __near u_set_dstbm(unsigned long,int,int,int,int);
int __near u_set_fcolor(unsigned long);
int __near u_set_palet_entry(unsigned long,int,int,int,int);
int __near u_set_patn(PATTERN __near *);
int __near u_set_pensize(int,int);
int __near u_set_pmask(unsigned long);
int __near u_set_ppop(int);
int __near u_set_srcbm(unsigned long,int,int,int,int);
int __near u_set_videomode(int);
int __near u_styled_line(int,int,int,int,unsigned long,int);
int __near u_swap_bm(void);
int __near u_synchronize(void);
int __near u_text_out(short __near *,short __near *,unsigned char __near *);
int __near u_wait_vblank(void);
#endif

/********************************* TV6.C *************************************/

void print_version(void);
		// print_version() ---- Print version info.

void tv6(void);
		// tv6() ---- Main dispatch loop.

void tv6_initialize(void);
		// tv6_initialize() ---- give tv6 command list ot ICF


/********************************* TV6_STRT.C ********************************/

void main(void);
		// main()


/********************************* UDRAW.C ***********************************/

void erase_grey_box(short wide, short high, short x, short y, Uchar msk);
		// erase_grey_box() ---- Erase grey planes in a box

void exit_tiga_bd(void);
		// exit_tiga_bd()

void get_clip_bigrect(Pushrt w, Pushrt h, Pshrt xs, Pshrt ys);
		// get_clip_bigrect() ---- Gets size & position of clipping rectangle

int get_lut(Puchar lut);
		// get_lut() ---- Xfers small lookup table -> vector.

int get_mask(Pulong pmask);
		// get_mask() ---- Outdated get_pmask patch.

int get_tms_byte(Ulong addr, Pchar byt);
		// get_tms_byte() ---- Gets a Piranha byte.

int get_tms_long(Ulong addr, Pulong result);
		// get_tms_long() ---- Gets a Piranha long word.

int get_tms_short(Ulong addr, Pushrt wrd); 
		// get_tms_short() ---- Gets a Piranha short word.

long init_tiga_bd(short);
		// init_tiga_bd()

int lut_ramp(void);
		// lut_ramp() ----  Write a ramp into the red lookup table.

int lut_reverse_ramp(void);
		// lut_reverse_ramp() ---- Write a reverse ramp into the red LUT.

int mapabclose(void);
		// mapabclose() ---- Close both a & b maps

int mapabopn(Ulong dst, Ppcfar mapad);
		// mapabopn() ---- Open both a & b maps

int mapaopn(Ulong dst, Ppcfar pfmap, Pulong numbytes);
		// mapaopn() ---- Open mapa to the Piranha.

void mapaclose(void);
		// mapaclose() ---- Close the Piranha mapa.

int mapbopn(Ulong dst, Ulong pix, Ulong pixbt, Ppcfar pfmap);
		// mapbopn() ---- Open the Piranha mapb.

void mapbclose(void);
		// mapbclose() ---- Close the Pirnaha mapb.

void pan(int x, int y);
		// pan() ---- Pan to (x,y) in the 2048x2048 video memory

int pc_tms(void *, Ulong, Ulong, int, int, Ulong);
		// pc_tms() ---- Xfer strings between PC & Piranha memory

int pc_tms2(void *, Ulong, Ulong, int, int, Ulong );
		// pc_tms2() ---- Xfer data between PC & Piranha via mapb

long restore_palet(unsigned long);
		// restore_palet()

void save_palet(void);
		// save_palet()

int set_clip_bigrect(Ushrt w, Ushrt h, short xleft, short ytop);
		// set_clip_bigrect() ---- Set a big clipping window.

int set_clip_planes(Uchar planes);
		// set_clip_planes() ---- Set bit planes within clipping window.

int set_grey_mask(Uchar mask);
		// set_grey_mask() ---- Set a protection mask for grey planes.

int set_lut(Puchar lut);
		// set_lut() ---- Set the small grey planes lookup table.

int set_mask(Ulong mask);
		// set_mask() ---- Set pmask patch. Outdated.

int set_overlay_mask(Uchar mask);
		// set_overlay_mask() ---- Set a pmask for overlay planes.

int set_planes(Uchar);
		// set_planes() ---- Set bit planes to a value.

int set_tms_byte(Ulong adr, char v);
		// set_tms_byte() ---- Set a Piranha byte.	

int set_tms_long(Ulong adr, Ulong v);
		// set_tms_long() ---- Set a Piranha long.	

int set_tms_short(Ulong adr, Ushrt v);
		// set_tms_short() ---- Set a Piranha short word.

int test_pat(Ushrt nwh);
		// test_pat() ---- Display a grey scale test pattern.

#ifndef PIRANHA_BD
int u_equipment_status(void);
		// u_equipment_status ---- Dummy routine for non-Piranha display bd.

int u_pan_scroll(short, short);
		// u_pan_scroll ---- Dummy routine for non-Piranha display board

int u_set_accmode(Ushrt);
		// u_set_accmode() ---- Dummy routine for non-Piranha display board
#endif


/********************************* UNIIMAGE.C ********************************/

int allocate_vmem_object (struct object_descriptor *ObjPtr);
		// allocate_vmem_object() ---- Allocate Vmemory for an obj._descriptor

long delete_uniimage (struct object_descriptor *uimage);
		// delete_uniimage() ---- Delete a Vmemory type object

char Dram(Ulong bit_address);
		// Dram() ---- Test a bit-address to see if it is in DRAM	

long dram_descriptor(struct object_descriptor *, struct object_descriptor *, 
					long SampleMethod, float, float);
		// dram_descriptor() ---- Fill out a blank Vmemory object_descriptor	*/

int free_vmem_object(struct object_descriptor *ObjPtr);
		// dram_descriptor() ---- Fill out a blank Vmemory object_descriptor

long MoveWindow(char *,StrcObj **,char *,StrcObj **,short,short,short,short,short,short);
		// MoveWindow() ---- Move a window between Vmem images

char object_check(struct object_descriptor *obj);
		// dram_descriptor() ---- Fill out a blank Vmemory object_descriptor

long pcimage_to_uni(struct object_descriptor *,struct object_descriptor *,struct object_descriptor *,char *,long,float,float);
		// pcimage_to_uni() ---- Xfer image from PC to Piranha

long SaveSomeScreen(StrcObj **,char *,short,short,short,short,StrcObj **,char *);
		// SaveSomeScreen()

long uniimage_to_pc(struct object_descriptor *src, struct object_descriptor *dst, long method);
		// uniimage_to_pc() ---- Xfer image from Piranha to PC

long uniimage_to_uni(struct object_descriptor *src, struct object_descriptor *dst, short ppop);
		// uniimage_to_uni() ---- Xfer image within Piranha memory

int vmem_object_exist(struct object_descriptor *ObjPtr);
		// vmem_object_exist() ---- Check if a Vmemory object exists

char Vram(Ulong bit_address);
		// Vram() ---- Check if a bit-address is in VRAM

long vram_descriptor (struct object_descriptor *src, struct object_descriptor *dst, 
					long SampleMethod, float xskip, float yskip);
		//vram_descriptor() ---- Fill in a blank VRAM Vmemory object descrip


/********************************* UNIMOVE.C *********************************/

long unimove(int *narg);
		// unimove() ---- Move parts of a Piranha image		


/********************************* UNITOUNI.C ********************************/

long uni_to_uni(struct object_descriptor *,struct object_descriptor *,int *);
		// uni_to_uni()


/********************************* VGA_DISP.C ********************************/

vga_disp_image(long,long,long,char *);
		// vga_disp_image() ---- display 1,4,8,or 16 bit image on 1024x768x256color VGA screen

int vga_disp_graph(float *,float *,long);
		// vga_disp_graph() ---- display floating point rfile on hi res VGA screen


/*********************************** WARP5.C **********************************/

void Warp5(int *);
		// Warp5() ---- Calculates distortion correction file.

/********************************* XLUT.ASM **********************************/

void xlut(Pcfar map, Ulong src, Pchar big_lut, Ulong i, Ulong);	
		// xlut() ---- LUT translation of a src string to map


/*********************************** XYC.C **********************************/

void xyc(StrcObj *, int *, int *,char *);
		// xyc() ---- returns cursor positions on ' ' input.

/********************************* X6LUT.ASM ********************************/

void x6lut(Pcfar dstsml, void *src, Pchar blut, Ulong nwrd);
		// x6lut() ---- Do 2x2 contraction of a short string

/********************************* ZOOM_IMG *********************************/

long zoom_img(StrcObj *, StrcObj *, StrcObj **, struct CURSOR_SET *, long *);
		// zoom_img() ---- Zoom an image area within the cursor box.


#endif
/* end of prototypes  --  DO NOT alter this line! */


/* ---------- Cross Index ---------- */

/*
add_buff()                    helps.c        mapabclose()                  udraw.c        
allocate_vmem_object()        uniimage.c     mapabopn()                    udraw.c        
analyze_ICFarg()              icfs.c         mapaclose()                   udraw.c        
auto_disk_name()              autodisk.c     mapaopn()                     udraw.c        
bin_image()                   bin.c          mapbclose()                   udraw.c        
binary_op_image()             addobj.c       mapbopn()                     udraw.c        
binary_op_rfile()             addobj.c       Matrix()                      splinec.c      
bldlut3()                     bldlut3.c      Mesh9c()                      mesh9c.c       
box5()                        box5.c         micro_switch()                ccc6.c         
boxcall()                     boxcall.c      MkInt()                       cathc.c        
boxx()                        boxx.c         modesel()                     tapex.c        
camera_intitialize()          readcam.c      modesen()                     tapex.c        
ccc6_init()                   ccc6.c         mouse_cursors()               drawp.c        
ccdtalk()                     cccpm.c        mouse_install()               drawp.c        
ccdtalk()                     gpibx.c        mouse_int()                   drawp.c        
_cclose()                     protdrv.c      mouse_step()                  drawp.c        
Certify()                     icfs.c         move_image()                  read_obj.c     
check_micro_switches()        ccc6.c         move_rfile()                  read_obj.c     
check_tape_ready()            tapex.c        move_tape_image()             exabyte.c      
CleanLogBuffer()              swplogbf.c     MoveWindow()                  uniimage.c     
clear_msg_buffer()            serial2.c      nint()                        nint.c         
clkrd()                       clk3.c         Nrerror()                     splinec.c      
clkset()                      clk3.c         num_op_image()                addobj.c       
clkslp()                      clk3.c         num_op_rfile()                addobj.c       
CloseDiskObject()             ipars.c        ObjectDoesNotExist()          ipars.c        
_clr_r386()                   ctrlc_c.asm    Obliq()                       oblique.c      
clrscr()                      screen.c       octogon_shutter_control()     octcom.c       
Convert_matrix()              splinec.c      OpenDiskObject()              ipars.c        
copy_header()                 header.c       pan()                         udraw.c        
corr_dist()                   correct.c      passchk()                     system.c       
corr_int()                    correct.c      patch()                       patch.c        
cs()                          ccc6.c         pc_tms()                      udraw.c        
_ctrlc_c()                    ctrlc_c.asm    pc_tms2()                     udraw.c        
_ctrlc_ex()                   ctrlc_c.asm    pcimage_to_uni()              uniimage.c     
CursorPos()                   sqxtra.c       pcl_a_d()                     pcl.c          
d_delay()                     _ccc6.asm      pcl_d_a()                     pcl.c          
decode_enum()                 decoder.c      pcl_digital_bit_clear()       pcl.c          
decoder()                     decoder.c      pcl_digital_bit_in()          pcl.c          
delay_msec()                  ccc6.c         pcl_digital_bit_set()         pcl.c          
delete_header()               header.c       pcl_digital_hbyte_in()        pcl.c          
delete_uniimage()             uniimage.c     pcl_digital_hbyte_out()       pcl.c          
DeleteObject()                ipars.c        pcl_digital_lbyte_in()        pcl.c          
dens()                        dens2.c        pcl_digital_lbyte_out()       pcl.c          
dens_azim()                   dens_vga.c     pcl_digital_word_in()         pcl.c          
denscntrl()                   dens2.c        pcl_digital_word_out()        pcl.c          
directory()                   dirctry.c      peakcntrl()                   peaker2.c      
disp()                        disp.c         peaker()                      peaker2.c      
Dmatrix()                     splinec.c      perimc()                      perimc.c       
do_palet()                    do_palet.c     phys_add()                    _ccc6.asm      
_dos()                        externs.c      position_tape()               exabyte.c      
doubl()                       doubl2.asm     post_message()                serial2.c      
dpull()                       icfs.c         print_version()               tv6.c          
Dram()                        uniimage.c     prottoreal()                  _prot.asm      
dram_descriptor()             uniimage.c     put_cursor()                  screen.c       
dram_descriptor()             uniimage.c     PutStructureObject()          decoder.c      
dram_descriptor()             uniimage.c     pwrsee()                      pwrsee.c       
draw()                        drawp.c        quad2()                       quad2.asm      
draw1()                       drawp.c        queue_process()               qproc2.c       
draw10()                      drawp.c        queue_untimed_process()       qproc2.c       
draw11()                      drawp.c        QueueObject()                 ipars.c        
draw2()                       drawp.c        quit()                        externs.c      
draw3()                       drawp.c        read_binary_image()           permin.c       
draw4()                       drawp.c        read_camera_image()           readcam.c      
draw5()                       drawp.c        read_camera_setup()           rdcamstp.c     
draw6()                       drawp.c        read_compress_image()         tiff_in.c      
draw7()                       drawp.c        read_diskimage()              tiff_in.c      
draw8()                       drawp.c        read_image()                  readcam.c      
draw9()                       drawp.c        read_mouse_cursor()           drawp.c        
drawe()                       drawe.c        read_obj()                    read_obj.c     
drawe_initialize()            drawe.c        ReadEncodedFile()             decoder.c      
drawt()                       drawt.c        readim()                      ccc6.c         
drawx()                       drawx.c        realcall()                    _prot.asm      
drew()                        drawp.c        realcall()                    protdrv.c      
drew1()                       drawp.c        realexit()                    _prot.asm      
drew10()                      drawp.c        realload()                    _prot.asm      
drew11()                      drawp.c        receive()                     serial2.c      
drew2()                       drawp.c        repak()                       repak.asm      
drew3()                       drawp.c        reqsen()                      tapex.c        
drew4()                       drawp.c        _reset()                      externs.c      
drew5()                       drawp.c        _reset_alarm()                alarm2.c       
drew6()                       drawp.c        reset_cursor()                screen.c       
drew7()                       drawp.c        reset_cursor_overlay()        drawp.c        
drew8()                       drawp.c        reset_image_sign()            addobj.c       
drew9()                       drawp.c        ResolveDictionary()           icfs.c         
drw0()                        drawp.c        restore_palet()               udraw.c        
drw1()                        drawp.c        restore_piranha()             drawp.c        
drw10()                       drawp.c        restore_TIGA()                drawp.c        
drw11()                       drawp.c        rf2asc()                      rf2asc.c       
drw12()                       drawp.c        rfgraph()                     rfgraph.c      
drw13()                       drawp.c        rfgraphcntrl()                rfgraph.c      
drw14()                       drawp.c        rfile_add()                   addobj.c       
drw15()                       drawp.c        _rmv_alarm()                  alarm2.c       
drw16()                       drawp.c        _rmv_mouse()                  mouse.asm      
drw17()                       drawp.c        rpull()                       icfs.c         
drw18()                       drawp.c        rstcur()                      screen.c       
drw19()                       drawp.c        save_palet()                  udraw.c        
drw2()                        drawp.c        save_piranha()                drawp.c        
drw20()                       drawp.c        save_TIGA()                   drawp.c        
drw21()                       drawp.c        SaveSomeScreen()              uniimage.c     
drw22()                       drawp.c        _screen_msg()                 screen.c       
drw23()                       drawp.c        _screen_rst()                 screen.c       
drw24()                       drawp.c        ScreenToSrc()                 sqxtra.c       
drw25()                       drawp.c        see()                         see3.c         
drw3()                        drawp.c        serial()                      serial2.c      
drw4()                        drawp.c        serial_display()              serial2.c      
drw5()                        drawp.c        serial_initialize()           serial2.c      
drw6()                        drawp.c        serial_rest()                 serial2.c      
drw60()                       drawp.c        serial_update()               serial2.c      
drw61()                       drawp.c        _set_alarm()                  alarm2.c       
drw7()                        drawp.c        set_big_cursor()              drawp.c        
drw8()                        drawp.c        set_clip_bigrect()            udraw.c        
drw9()                        drawp.c        set_clip_planes()             udraw.c        
drw_set_value_mask()          drawp.c        set_cursor_limits()           drawp.c        
Dvector()                     splinec.c      set_grey_lut()                drawp.c        
dzng3()                       dzng3.c        set_grey_mask()               udraw.c        
editio()                      edito.c        set_image_sign()              addobj.c       
editor()                      icf.c          set_lut()                     udraw.c        
EdObject()                    edobject.c     set_mask()                    udraw.c        
encoder()                     decoder.c      set_overlay_lut()             drawp.c        
_end_process()                qproc2.c       set_overlay_mask()            udraw.c        
erase()                       erase.c        set_planes()                  udraw.c        
erase_grey_box()              udraw.c        set_sml_cursor()              drawp.c        
exit_tiga_bd()                udraw.c        set_tms_byte()                udraw.c        
exprep()                      ccc6.c         set_tms_long()                udraw.c        
externs_initialize()          externs.c      set_tms_short()               udraw.c        
filepath()                    filepath.c     setup()                       ccc6.c         
fill_basic_header()           header.c       setup_display()               see3.c         
FindObject()                  ipars.c        setup_grapher()               graph.c        
flt_convert()                 dens2.c        setup_luts()                  drawp.c        
fmemcp2()                     fmemcp2.asm    setup_object_template()       edobject.c     
Free_convert_matrix()         splinec.c      setup_palet_mask()            see3.c         
Free_dmatrix()                splinec.c      shclos()                      ccc6.c         
Free_dvector()                splinec.c      shopen()                      ccc6.c         
Free_imatrix()                splinec.c      shotim()                      support.c      
Free_ivector()                splinec.c      ShowEdge()                    perimc.c       
Free_matrix()                 splinec.c      shrink()                      quad2.asm      
Free_submatrix()              splinec.c      smooth_rfile()                rsmooth.c      
Free_vecotr()                 splinec.c      Smoother()                    smoother.c     
freeze_cursors()              drawp.c        space_to_end()                exabyte.c      
get_clip_bigrect()            udraw.c        Splinec()                     splinec.c      
get_coords()                  getlines.c     Splintc()                     splinec.c      
get_coords()                  graph.c        Spot7c()                      spot7c.c       
get_cursor()                  screen.c       spress()                      octcom.c       
get_cursor_limits()           drawp.c        spull()                       icfs.c         
get_cursors()                 src_img.c      Sq1ac()                       sq1ac.c        
get_disk_head()               read_obj.c     Sq1bc()                       sq1bc.c        
get_ICFarg()                  icfs.c         Sq1cc()                       sq1cc.c        
get_im_head()                 tiff_in.c      Square2()                     sqc.c          
get_lut()                     udraw.c        src_img()                     src_img.c      
get_mask()                    udraw.c        SrcToScreen()                 sqxtra.c       
get_rf_head()                 read_obj.c     sread()                       sread.c        
get_tape_im_head()            exabyte.c      start_mouse()                 mouse.asm      
get_tms_byte()                udraw.c        stash_scn()                   stash_sc.c     
get_tms_long()                udraw.c        statbox()                     statbox2.c     
get_tms_short()               udraw.c        stemp()                       octcom.c       
get_value()                   box5.c         stop_mouse()                  mouse.asm      
getlines()                    getlines.c     strip_calc()                  tiff_out.c     
getlines_piece()              getlines.c     strpad()                      helps.c        
GetStructureObject()          decoder.c      Submatrix()                   splinec.c      
GetTemplate()                 decoder.c      SweepLogBuffer()              swplogbf.c     
gpress()                      octcom.c       system_s()                    system.c       
graph()                       graph.c        tape_bot()                    tapex.c        
gray()                        gray3.c        tape_dismount()               exabyte.c      
gtemp()                       octcom.c       tape_to_disk()                tapex.c        
header_op()                   header.c       terminal()                    serial2.c      
header_to_disk()              header.c       test_pat()                    udraw.c        
heaplook()                    heaplook.c     tic_to_graph()                peaker2.c      
helps()                       helps.c        ticcntrl()                    peaker2.c      
histogram()                   histogrm.c     tif_date()                    tiff_out.c     
Htrfc()                       htrfc.c        tif_date_to_int()             tiff_in.c      
Htrfc()                       htrfc.c        TIGAcursor()                  drawp.c        
ibclr()                       gpibx.c        time_lapse()                  clk3.c         
ibfind()                      gpibx.c        time_left()                   clk3.c         
ibloc()                       gpibx.c        time_out()                    clk3.c         
ibrd()                        gpibx.c        tlmccd()                      ccc6.c         
ibrda()                       gpibx.c        tlmlocal()                    ccc6.c         
ibrsp()                       gpibx.c        Toggle()                      sqxtra.c       
ibtmo()                       gpibx.c        trans2()                      serial2.c      
ibwait()                      gpibx.c        transmit()                    serial2.c      
ibwrt()                       gpibx.c        tread()                       tapex.c        
ICF()                         icf.c          trewind()                     tapex.c        
ICFinitialize()               icf.c          tspace()                      tapex.c        
ICFmonitor()                  icf.c          tstatus()                     tapex.c        
ICFreset()                    icf.c          tv6()                         tv6.c          
ICFS()                        icfs.c         tv6_initialize()              tv6.c          
ICFset_commands()             icf.c          twrite()                      tapex.c        
ICFset_proc()                 icf.c          twsm()                        tapex.c        
ICFset_variable()             icf.c          twtm()                        tapex.c        
idle_proc()                   externs.c      type_header()                 header.c       
im_disk_disk()                im_moves.c     type_object()                 edobject.c     
im_disk_tape()                im_moves.c     TypeStructure()               decoder.c      
im_mem_tape()                 im_moves.c     u_equipment_status()          udraw.c        
im_tape_disk()                im_moves.c     u_error()                     error.c        
im_tape_mem()                 im_moves.c     u_pan_scroll()                udraw.c        
im_tape_tape()                im_moves.c     u_set_accmode()               udraw.c        
im_to_rf_header()             dens2.c        unfreeze_cursors()            drawp.c        
image_add()                   addobj.c       uni_to_uni()                  unitouni.c     
image_archive()               archive.c      uniimage_to_pc()              uniimage.c     
image_filter()                imfilter.c     uniimage_to_uni()             uniimage.c     
Imatrix()                     splinec.c      unimove()                     unimove.c      
implement_display_structure() see3.c         update_data_size()            read_obj.c     
_init_alarm()                 alarm2.c       update_draw_box()             drawp.c        
_init_mouse()                 mouse.asm      update_graph_data()           graph.c        
init_real_code()              protdrv.c      value_fill()                  read_obj.c     
init_tiga_bd()                udraw.c        Vector()                      splinec.c      
Ipars()                       ipars.c        vga_disp_graph()              vga_disp.c     
ipull()                       icfs.c         vga_disp_image()              vga_disp.c     
isord()                       ccc6.c         vmem_object_exist()           uniimage.c     
isoset()                      ccc6.c         Vram()                        uniimage.c     
ittinx()                      kybdin.c       vram_descriptor()             uniimage.c     
Ivector()                     splinec.c      vtrf()                        ccc6.c         
J0c()                         j0c.c          Warp5()                       warp5.c        
kybdin()                      kybdin.c       whose_window()                src_img.c      
kybdinc()                     kybdin.c       writ_disk_image()             tiff_out.c     
lasercntrl()                  laser4.c       writ_obj()                    read_obj.c     
lasplot()                     laser4.c       write_binary_image()          permin.c       
lastic()                      laser4.c       write_chr()                   drawp.c        
listen()                      serial2.c      write_compress_image()        tiff_out.c     
ListObjects()                 listobjs.c     write_line()                  screen.c       
look_at_graph()               graph.c        write_tape_header()           im_moves.c     
look_for_kill_key()           killkey.c      WriteEncodedFile()            decoder.c      
Lubksb()                      lubksb.c       x6lut()                       x6lut.asm      
Ludcmp()                      ludcmp.c       x_coord_to_pix()              graph.c        
lut_ramp()                    udraw.c        x_img_to_src()                src_img.c      
lut_reverse_ramp()            udraw.c        x_pix_to_coord()              graph.c        
LZWCleanup()                  lzw3.c         x_src_to_img()                src_img.c      
LZWDecode()                   lzw3.c         xlut()                        xlut.asm       
LZWEncode()                   lzw3.c         xyc()                         xyc.c          
LZWPostEncode()               lzw3.c         y_coord_to_pix()              graph.c        
LZWPreDecode()                lzw3.c         y_img_to_src()                src_img.c      
LZWPreEncode()                lzw3.c         y_pix_to_coord()              graph.c        
main()                        tv6_strt.c     y_src_to_img()                src_img.c      
make_im_head()                tiff_out.c     ZeroLogBuffer()               swplogbf.c     
make_tif_header()             tiff_out.c     zoom_img()                    zoom_img       

*/
