*-------------------------------------------------------------------
***INCLUDE MWWW0O01.
*-------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Module  INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.
  CLEAR SY-UCOMM.
  SET PF-STATUS 'STARTW3'.
  SET TITLEBAR '001'.
  OBJECT_TYPE_NAME = TEXT-005. "Двоичные данные для WebRFC
ENDMODULE.                             " INIT_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_OBJECT_LIST  OUTPUT
*&---------------------------------------------------------------------*
MODULE FILL_OBJECT_LIST OUTPUT.
  READ TABLE WWWDATA_TAB INDEX OBJECT_LIST-CURRENT_LINE.
  IF SY-SUBRC NE 0. EXIT FROM STEP-LOOP. ENDIF.
ENDMODULE.                             " FILL_OBJECT_LIST  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_0200 OUTPUT.
  SET TITLEBAR '005'.
  SET PF-STATUS 'SHOW_HT'.
  CLEAR SY-UCOMM.
  OBJECT_SELECTED = 0.

  PERFORM SELECT_DATA.

  OBJECT_LIST-LINES = LINES( WWWDATA_TAB ).
ENDMODULE.                             " INIT_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'CR_HTM'.
  CLEAR SY-UCOMM.
  SET TITLEBAR '002'.
ENDMODULE.                             " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS 'MOD_DESC'.
  SET TITLEBAR '003'.
ENDMODULE.                             " STATUS_0400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS 'CP_HTM'.
  SET TITLEBAR '004'.
  WWWDATA_NEW-RELID = OBJDATA-RELID. "inherit type of web object
  WWWDATA_NEW-TEXT  = OBJDATA-TEXT.
ENDMODULE.                 " STATUS_0500  OUTPUT
