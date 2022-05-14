      ************************************************************
      *  PGM001 Esempio per GIT
      *
      ************************************************************
       ctl-opt option(*srcstmt:*nodebugio) actgrp(*new);
       dcl-s version char(10);
       dcl-s testo   char(30);

       // Versione del programma       
       version='1.2';
       testo='Versione '+Version;
       dsply Testo  ;
       exsr fine;
       //---------------------------
       // fine
       //---------------------------
       begsr fine;
         *inlr = *on;
         return;
       endsr;
 