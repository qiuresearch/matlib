//	LZW3.c	tiff compression/decompression routines
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "tiff2.h"
#include "object.h"


#define MAXCODE(n)      ((1 << (n)) - 1)
/*
 * The TIFF spec specifies that encoded bit strings range
 * from 9 to 12 bits.  This is somewhat unfortunate in that
 * experience indicates full color RGB pictures often need
 * ~14 bits for reasonable compression.
 */
#define BITS_MIN        9               /* start with 9 bits */
#define BITS_MAX        12              /* max of 12 bit strings */

/* predefined codes */
#define CODE_CLEAR      256             /* code to clear string table */
#define CODE_EOI        257             /* end-of-information code */
#define CODE_FIRST      258             /* first free code entry */
#define CODE_MAX        MAXCODE(BITS_MAX)

#define HSIZE           5003            /* 80% occupancy */
#define HSHIFT          (8-(16-12))


/*
Decoding-specific state.
*/
struct decode
{
   unsigned prefixtab[HSIZE];       /* prefix(code) */
   char  suffixtab[CODE_MAX+1];     /* suffix(code) */
   char  stack[HSIZE-(CODE_MAX+1)];
   char  *stackp;                   /* stack pointer */
   short firstchar;                 /* of string associated w/ last code */
};

#define CHECK_GAP       10000       /* enc_ratio check interval */

/*
Encoding-specific state.
*/
struct encode
{
   long  checkpoint;             /* point at which to clear table */
   long  ratio;                  /* current compression ratio */
   unsigned long incount;        /* (input) data bytes encoded */
   unsigned long outcount;       /* encoded (output) bytes */
   long  htab[HSIZE];            /* hash table */
   short codetab[HSIZE];         /* code table */
};

/*
State block for each open TIFF
file using LZW compression.
*/

#define FLAG_CODEDELTA  0x1             /* increase code string size */
#define FLAG_RESTART    0x2             /* restart interrupted decode */

typedef struct
{
   short    lzw_oldcode;            /* last code encountered */
   unsigned lzw_flags;
   unsigned lzw_nbits;              /* number of bits/code */
   unsigned lzw_maxcode;            /* maximum code for lzw_nbits */
   long     lzw_bitoff;             /* bit offset into data */
   long     lzw_bitsize;            /* size of strip in bits */
   unsigned lzw_free_ent;           /* next free entry in hash table */
   union
   {
      struct  decode dec;
      struct  encode enc;
   } u;
} LZWState;

#define dec_prefix      u.dec.prefixtab
#define dec_suffix      u.dec.suffixtab
#define dec_stack       u.dec.stack
#define dec_stackp      u.dec.stackp
#define dec_firstchar   u.dec.firstchar

#define enc_checkpoint  u.enc.checkpoint
#define enc_ratio       u.enc.ratio
#define enc_incount     u.enc.incount
#define enc_outcount    u.enc.outcount
#define enc_htab        u.enc.htab
#define enc_codetab     u.enc.codetab

/* ---------- prototypes of static functions in this module ---------- */
static void cl_hash(LZWState *);
static void cl_block(struct object_descriptor *, char *);

static unsigned BitCount;
static unsigned ByteOffset;
static unsigned long BitBuffer;
static unsigned FinalByte;
/*
LZW Decoder.
*/

/*
Setup state for decoding a strip.
*/
int LZWPreDecode(struct object_descriptor *ObjPtr,long rawbytes)
/* source (disk) object descriptor, length of compressed strip to decode
Uses space in the object desciptor for storage-- it mallocs that space here.
 */
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp = (LZWState *)info->LZW;
   register short code;
   if (sp == NULL)
   {
      info->LZW = (char *)malloc((unsigned) sizeof (LZWState));
      if (info->LZW == NULL)
      {
	 printf("LZWPreDecode No space for LZW state block\n");
	 return (1);
      }
      sp = (LZWState *)info->LZW;
   }
   sp->lzw_flags = 0;
   sp->lzw_nbits = BITS_MIN;
   sp->lzw_maxcode = MAXCODE(BITS_MIN);

   /* Pre-load the table */
   for (code = 255; code >= 0; code--)
      sp->dec_suffix[code] = (char)code;
   sp->lzw_free_ent = CODE_FIRST;
   sp->lzw_bitoff = 0L;
   /* calculate data size in bits */
   sp->lzw_bitsize = rawbytes;
   sp->lzw_bitsize = (sp->lzw_bitsize << 3L) - (BITS_MAX-1);
   sp->dec_stackp = sp->dec_stack;
   sp->lzw_oldcode = -1;
   sp->dec_firstchar = -1;
   BitCount = 0;    /* modified for GetNextCode CAL 12/28/89 */
   BitBuffer = 0L;
   ByteOffset = 0;
   return (0);
}

/*
Get the next code from the raw data buffer.
*/
static
unsigned GetNextCode(struct object_descriptor *ObjPtr,char *buffer)
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   LZWState *sp = (LZWState *)info->LZW;
   register unsigned code;
   char *bp;


   /*
   This check shouldn't be necessary because each
   strip is suppose to be terminated with CODE_EOI.
   At worst it's a substitute for the CODE_EOI that's
   supposed to be there (see calculation of lzw_bitsize
   in LZWPreDecode()).
   */
   if (sp->lzw_bitoff > sp->lzw_bitsize)
      return (CODE_EOI);
   /*
   If the next entry is too big for the
   current code size, then increase the
   size up to the maximum possible.
   */
   if (sp->lzw_free_ent >= sp->lzw_maxcode) /* bug fixed CAL 12/28/89 */
   {
      sp->lzw_nbits++;
      if (sp->lzw_nbits > BITS_MAX)
	 sp->lzw_nbits = BITS_MAX;
      sp->lzw_maxcode = MAXCODE(sp->lzw_nbits);
   }
   if (sp->lzw_flags & FLAG_CODEDELTA)
   {
      sp->lzw_maxcode = MAXCODE(sp->lzw_nbits = BITS_MIN);
      sp->lzw_flags &= ~FLAG_CODEDELTA;
   }

   /* Code simplified CAL 12/28/89 */
   /* Get to the first byte */
   bp = (char *) (buffer + ByteOffset);
	if (BitCount <= 24){
		BitBuffer |= ((unsigned long) *bp++) << (24 - BitCount);
		BitCount += 8;
		ByteOffset += 1;
		if (BitCount <= 24){
			BitBuffer |= ((unsigned long) *bp++) << (24 - BitCount);
			BitCount += 8;
			ByteOffset += 1;
			if (BitCount <= 24){
				BitBuffer |= ((unsigned long) *bp++) << (24 - BitCount);
				BitCount += 8;
				ByteOffset += 1;
				if (BitCount <= 24){
					BitBuffer |= ((unsigned long) *bp++) << (24 - BitCount);
					BitCount += 8;
					ByteOffset += 1;
				}
			}
		}
	}
   code = (unsigned)(BitBuffer >> (32L - sp->lzw_nbits));
   BitBuffer <<= ((unsigned long) sp->lzw_nbits);
   BitCount -= sp->lzw_nbits;
   sp->lzw_bitoff += sp->lzw_nbits;
   return (code);
}

/*
Decode the next scanline.
*/
int LZWDecode(struct object_descriptor *ObjPtr, char *uncomp, char *comp, long occ)
/* source (disk) object_descriptor, pointer to buffer for uncompressed result,
pointer to compressed data, #bytes of compressed data
*/
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp = (LZWState *)info->LZW;
   register unsigned code;
   register char *stackp;
   unsigned firstchar, oldcode, incode;

   stackp = sp->dec_stackp;
   /* Restart interrupted unstacking operations */
   if (sp->lzw_flags & FLAG_RESTART){
      do{
	 	 if (--occ < 0){
		    /* end of scanline */
		    sp->dec_stackp = stackp;
		    return (0);
		 }
	 	*uncomp++ = *--stackp;
      } while (stackp > sp->dec_stack);
      sp->lzw_flags &= ~FLAG_RESTART;
   }
   oldcode = sp->lzw_oldcode;
   firstchar = sp->dec_firstchar;
   while (occ > 0 && (code = GetNextCode(ObjPtr,comp)) != CODE_EOI)
   {
      if (code == CODE_CLEAR){
		 memset(sp->dec_prefix,0,sizeof (sp->dec_prefix));
		 sp->lzw_flags |= FLAG_CODEDELTA;
		 sp->lzw_free_ent = CODE_FIRST;
		 if ((code = GetNextCode(ObjPtr,comp)) == CODE_EOI)
	   		 break;
		 *uncomp++ = code, occ--;
		 oldcode = firstchar = code;
		 continue;
      }
      incode = code;
      /*
      When a code is not in the table we use (as spec'd):
      StringFromCode(oldcode) +
      FirstChar(StringFromCode(oldcode))
      */
      if (code >= sp->lzw_free_ent){
		 /* code not in table */
		 *stackp++ = firstchar;
		 code = oldcode;
      }
      /* Generate output string (first in reverse) */
      for (; code >= 256; code = sp->dec_prefix[code])
		 *stackp++ = sp->dec_suffix[code];
      *stackp++ = firstchar = sp->dec_suffix[code];
      do{
		 if (--occ < 0){
		    /* end of scanline */
		    sp->lzw_flags |= FLAG_RESTART;
		    break;
		 }
		 *uncomp++ = *--stackp;
      } while (stackp > sp->dec_stack);
      /* Add the new entry to the code table */
      if ((code = sp->lzw_free_ent) < CODE_MAX){
		 sp->dec_prefix[code] = oldcode;
		 sp->dec_suffix[code] = firstchar;
		 sp->lzw_free_ent++;
      }
      oldcode = incode;
   }
   sp->dec_stackp = stackp;
   sp->lzw_oldcode = oldcode;
   sp->dec_firstchar = firstchar;
   if (occ > 0){
		printf("LZWDecode: Not enough data for scanline %u\n",occ);
	      return (1);
   }
   return (0);
}

void LZWCleanup(struct object_descriptor *ObjPtr)
/* frees malloc'd space for decompression (or compression) variables
*/
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   if (info->LZW)
   {
      free(info->LZW);
      info->LZW = NULL;
   }
}

/*
LZW Encoding.
*/
/*
Reset code table.
*/
static void cl_hash(LZWState *sp)
{
   register long *htab_p = sp->enc_htab+HSIZE;
   register long i, m1 = -1;

   i = HSIZE - 16;
   do
   {
      *(htab_p-16) = m1;
      *(htab_p-15) = m1;
      *(htab_p-14) = m1;
      *(htab_p-13) = m1;
      *(htab_p-12) = m1;
      *(htab_p-11) = m1;
      *(htab_p-10) = m1;
      *(htab_p-9) = m1;
      *(htab_p-8) = m1;
      *(htab_p-7) = m1;
      *(htab_p-6) = m1;
      *(htab_p-5) = m1;
      *(htab_p-4) = m1;
      *(htab_p-3) = m1;
      *(htab_p-2) = m1;
      *(htab_p-1) = m1;
      htab_p -= 16;
   } while ((i -= 16) >= 0);
   for (i += 16; i > 0; i--)
      *--htab_p = m1;
}

/*
Reset encoding state at the start of a strip.
*/
int LZWPreEncode(struct object_descriptor *ObjPtr,long numbytes)
/* dest (disk) object_descriptor,length of uncompressed data in bytes
*/
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp = (LZWState *)info->LZW;

   if (sp == NULL)
   {
      info->LZW =(char*)malloc(sizeof (LZWState));
      if (info->LZW == NULL)
      {
	 printf("LZWPreEncode No space for LZW state block");
	 return (1);
      }
      sp = (LZWState *)info->LZW;
   }
   sp->lzw_flags = 0;
   sp->enc_ratio = 0;
   sp->enc_checkpoint = CHECK_GAP;
   sp->lzw_maxcode = MAXCODE(sp->lzw_nbits = BITS_MIN);
   sp->lzw_free_ent = CODE_FIRST;
   sp->lzw_bitoff = 0;
   sp->lzw_bitsize = (numbytes << 3) - (BITS_MAX-1);
   cl_hash(sp);            /* clear hash table */
   sp->lzw_oldcode = -1;   /* generates CODE_CLEAR in LZWEncode */
   BitCount = 0;           /* modified for PutNextCode CAL 12/28/89 */
   BitBuffer = 0L;
   ByteOffset = 0;
   FinalByte = 0;
   return (0);
}

static
void PutNextCode(struct object_descriptor *ObjPtr, unsigned code)
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp = (LZWState *)info->LZW;
   register char *bp;

   bp = (char *)(ObjPtr->Buffer + ByteOffset);

   BitBuffer |= (unsigned long) code << (32L-sp->lzw_nbits-BitCount);
   BitCount += sp->lzw_nbits;
   while (BitCount >= 8)
   {
      *bp++ = BitBuffer >> 24;
      BitBuffer <<= 8;
      BitCount -= 8;
      ByteOffset += 1;
   }
   /* if last byte of strip force last byte to be written */
   if (FinalByte)
      *bp++ = BitBuffer >> 24;


   /*
   enc_outcount is used by the compression analysis machinery
   which resets the compression tables when the compression
   ratio goes up.  lzw_bitoff is used here (in PutNextCode) for
   inserting codes into the output buffer.  tif_rawcc must
   be updated for the mainline write code in TIFFWriteScanline()
   so that data is flushed when the end of a strip is reached.
   Note that the latter is rounded up to ensure that a non-zero
   byte count is present.
   */
   sp->enc_outcount += sp->lzw_nbits;
   sp->lzw_bitoff += sp->lzw_nbits;
/*
   tif->tif_rawcc = (sp->lzw_bitoff + 7) >> 3;
*/   /*
   If the next entry is going to be too big for
   the code size, then increase it, if possible.
   */
   if (sp->lzw_flags & FLAG_CODEDELTA)
   {
      sp->lzw_maxcode = MAXCODE(sp->lzw_nbits = BITS_MIN);
      sp->lzw_flags &= ~FLAG_CODEDELTA;
   }
   else if (sp->lzw_free_ent >= sp->lzw_maxcode)
   {
      sp->lzw_nbits++;
      if (sp->lzw_nbits > BITS_MAX)
	 sp->lzw_nbits = BITS_MAX;
      sp->lzw_maxcode = MAXCODE(sp->lzw_nbits);
   }
}


/*
Check compression ratio and, if things seem to
be slipping, clear the hash table and reset state.
*/
static void cl_block(struct object_descriptor *ObjPtr,char *buffer)
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp = (LZWState *)info->LZW;
   register unsigned long rat;

   sp->enc_checkpoint = sp->enc_incount + CHECK_GAP;
   if (sp->enc_incount > 0x007fffffL)
   {
      /* shift will overflow */
      rat = sp->enc_outcount >> 8;
      rat = (rat == 0 ? 0x7fffffffL : sp->enc_incount / rat);
   }
   else
      rat = (sp->enc_incount << 8) / sp->enc_outcount; /* 8 fract bits */
   if (rat <= sp->enc_ratio)
   {
      sp->enc_ratio = 0;
      cl_hash(sp);
      sp->lzw_free_ent = CODE_FIRST;
      sp->lzw_flags |= FLAG_CODEDELTA;
      PutNextCode(ObjPtr, CODE_CLEAR);
   }
   else
      sp->enc_ratio = rat;
}

/*
Encode a scanline of pixels.

Uses an open addressing double hashing (no chaining) on the
prefix code/next character combination.  We do a variant of
Knuth's algorithm D (vol. 3, sec. 6.4) along with G. Knott's
relatively-prime secondary probe.  Here, the modular division
first probe is gives way to a faster exclusive-or manipulation.
Also do block compression with an adaptive reset, whereby the
code table is cleared when the compression ratio decreases,
but after the table fills.  The variable-length output codes
are re-sized at this point, and a CODE_CLEAR is generated
for the decoder.
*/
int LZWEncode(struct object_descriptor *ObjPtr, char *bp, long cc)
/* dest (disk) object_descriptor,pointer to uncompressed strip of data,
uncompressed strip length in bytes-- malloc ObjPtr->Buffer before compression.
*/
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   register LZWState *sp;
   register long fcode;
   register unsigned c, ent, disp;
   register short h;

   if ((sp = (LZWState *)info->LZW) == NULL)
      return (1);
   ent = sp->lzw_oldcode;
   if (ent == (unsigned) -1 && cc > 0)
   {
      PutNextCode(ObjPtr, CODE_CLEAR);
      ent = *bp++;
      cc--;
      sp->enc_incount++;
   }
   while (cc > 0)
   {
      c = *bp++;
      cc--;
      sp->enc_incount++;
      fcode = (c << BITS_MAX) + ent;
      h = (c << HSHIFT) ^ ent;        /* xor hashing */
      if (sp->enc_htab[h] == fcode){
		 ent = sp->enc_codetab[h];
		 continue;
      }
      if (sp->enc_htab[h] >= 0)
      {
	 /* Primary hash failed, check secondary hash */
	 disp = HSIZE - h;
	 if (h == 0)
	    disp = 1;
	 do
	 {
	    if ((h -= disp) < 0)
	       h += HSIZE;
	    if (sp->enc_htab[h] == fcode)
	    {
	       ent = sp->enc_codetab[h];
	       goto hit;
	    }
	 } while (sp->enc_htab[h] >= 0);
      }
      /* New entry, add to table */
      PutNextCode(ObjPtr, ent);
      ent = c;
      if (sp->lzw_free_ent < CODE_MAX)
      {
	 sp->enc_codetab[h] = sp->lzw_free_ent++;
	 sp->enc_htab[h] = fcode;
      }
      else if (sp->enc_incount >= sp->enc_checkpoint)
	 cl_block(ObjPtr,bp);
hit:  ;
   }
   sp->lzw_oldcode = ent;
   return (0);
}

/*
Finish off an encoded strip by flushing the last
string and tacking on an End Of Information code.
*/
int LZWPostEncode(struct object_descriptor *ObjPtr,long *numbytes)
/*
dest (disk) object_descriptor, returns compressed length which will be in 
ObjPtr->Buffer
*/
{
struct image_info *info=(struct image_info *)ObjPtr->Header;
   LZWState *sp = (LZWState *)info->LZW;

   if (sp->lzw_oldcode != -1)
      PutNextCode(ObjPtr, sp->lzw_oldcode);
   FinalByte = 1;
   PutNextCode(ObjPtr, CODE_EOI);
	*numbytes=ByteOffset+1;
   return (0);
}
