
        Ctl-Opt DFTACTGRP(*no);

        Dcl-Pr Employees ExtPgm;
          DepartmentNumber Char(3);
        End-Pr;

      //---------------------------------------------------------------*

       /copy 'qrpgleref/constants.rpgle'



      //---------------------------------------------------------------*

        Dcl-F depts WORKSTN Sfile(SFLDta:Rrn) IndDS(WkStnInd) InfDS(fileinfo);

          Dcl-S Exit Ind Inz(*Off);

          Dcl-S Rrn          Zoned(4:0) Inz;

          Dcl-DS WkStnInd;
            ProcessSCF     Ind        Pos(21);
            ReprintScf     Ind        Pos(22);
            Error          Ind        Pos(25);
            PageDown       Ind        Pos(30);
            PageUp         Ind        Pos(31);
            SflEnd         Ind        Pos(40);
            SflBegin       Ind        Pos(41);
            NoRecord       Ind        Pos(60);
            SflDspCtl      Ind        Pos(85);
            SflClr         Ind        Pos(75);
            SflDsp         Ind        Pos(95);
          End-DS;

        Dcl-DS FILEINFO;
          //FILENM         Char(NaN)  Pos(E);
          CPFID          Char(7)    Pos(46);
          MBRNAM         Char(10)   Pos(129);
          FMTNAM         Char(10)   Pos(261);
          CURSED         Bindec(4)  Pos(370);
          FUNKEY         Char(1)    Pos(369);
          SFLRRN_TOP     Bindec(4)  Pos(378);
          SF_RRN         Int(5)     Pos(376);
          SF_RCDS        Int(5)     Pos(380);

      //---------------------------------------------------------------*
      *
          Dcl-S Index Int(5);

          Dcl-Ds Department ExtName('DEPARTMENT') Alias Qualified;
          End-Ds;

        //------------------------------------------------------------reb04
          Exit = *Off;
          LoadSubfile();

          Dow (Not Exit);
            Write FOOTER_FMT;
            Exfmt SFLCTL;

            Select;
              When (Funkey = F03);
                Exit = *On;
              When (Funkey = ENTER);
                HandleInputs();
            Endsl;
          Enddo;

          *INLR = *ON;
          Return;

        //------------------------------------------------------------

          Dcl-Proc ClearSubfile;
            SflDspCtl = *Off;
            SflDsp = *Off;

            Write SFLCTL;

            SflDspCtl = *On;

            rrn = 0;
          End-Proc;

          Dcl-Proc LoadSubfile;
            Dcl-S lCount  Int(5);
            Dcl-S Action  Char(1);
            Dcl-S LongAct Char(3);

            ClearSubfile();

            EXEC SQL DECLARE deptCur CURSOR FOR
              SELECT DEPTNO, DEPTNAME
              FROM DEPARTMENT;

            EXEC SQL OPEN deptCur;

            if (sqlstate = '00000');

              dou (sqlstate <> '00000');
                EXEC SQL
                  FETCH NEXT FROM deptCur
                  INTO :Department.DEPTNO, :Department.DEPTNAME;

                if (sqlstate = '00000');
                  XID   = Department.DEPTNO;
                  XNAME = Department.DEPTNAME;

                  rrn += 1;
                  Write SFLDTA;
                endif;
              enddo;

            endif;

            EXEC SQL CLOSE deptCur;

            If (rrn > 0);
              SflDsp = *On;
              SFLRRN = 1;
            Endif;
          End-Proc;

          Dcl-Proc HandleInputs;
            Dcl-S SelVal Char(1);

            Dou (%EOF(depts));
              ReadC SFLDTA;
              If (%EOF(depts));
                Iter;
              Endif;

              SelVal = %Trim(XSEL);

              Select;
                When (SelVal = '6');
                  //DSPLY @XID;
                  Employees(XID);
              Endsl;

              If (XSEL <> *Blank);
                XSEL = *Blank;
                Update SFLDTA;
                SFLRRN = rrn;
              Endif;
            Enddo;
          End-Proc;