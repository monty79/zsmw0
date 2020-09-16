*----------------------------------------------------------------------*
***INCLUDE LZSMW0_SHTMO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  WWWPARAMS_STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE WWWPARAMS_STATUS_0200 OUTPUT.
  SET PF-STATUS 'HPAR'.
  SET TITLEBAR '005'.
  CLEAR SY-UCOMM.
  PARAMS_SELECTED = 0.
  PERFORM WWWPARAMS_FILL.
  DESCRIBE TABLE WWWPARAMS_TAB LINES WWWPARAMS_CONTROL-LINES.
ENDMODULE.                 " WWWPARAMS_STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  WWWPARAMS_CONTROL_FILL  OUTPUT
*&---------------------------------------------------------------------*
MODULE WWWPARAMS_CONTROL_FILL OUTPUT.
   READ TABLE WWWPARAMS_TAB INDEX WWWPARAMS_CONTROL-CURRENT_LINE.
   IF SY-SUBRC NE 0. EXIT FROM STEP-LOOP. ENDIF.
ENDMODULE.                 " WWWPARAMS_CONTROL_FILL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0210  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.
  SET PF-STATUS 'H210'.
  SET TITLEBAR '003'.
  IF STATUS_CREATE NE SPACE.
     SET TITLEBAR '004'.
     PERFORM LOOP_AT_SCREEN_210.
  ENDIF.
ENDMODULE.                 " STATUS_0210  OUTPUT
