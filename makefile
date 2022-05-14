BIN_LIB=FAQ400
LIBLIST=$(BIN_LIB) SAMPLEDB
SHELL=/QOpenSys/usr/bin/qsh

all: pgm001.rpgle depts.sqlrpgle employees.sqlrpgle
#all: pgm001.rpgle

pgm001.rpgle:
depts.sqlrpgle: depts.dspf
employees.sqlrpgle: emps.dspf





%.rpgle:
	system -s "CHGATR OBJ('./qrpglesrc/$*.rpgle') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('./qrpglesrc/$*.rpgle') DBGVIEW(*SOURCE) OPTION(*EVENTF)"

%.sqlrpgle:
	system -s "CHGATR OBJ('./qrpglesrc/$*.sqlrpgle') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('./qrpglesrc/$*.sqlrpgle') COMMIT(*NONE) DBGVIEW(*SOURCE) OPTION(*EVENTF)"

%.dspf:
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./qddssrc/$*.dspf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$*.mbr') MBROPT(*REPLACE)"
	system -s "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*)"