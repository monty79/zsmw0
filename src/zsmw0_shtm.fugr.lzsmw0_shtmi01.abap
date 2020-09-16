*----------------------------------------------------------------------*
***INCLUDE LZSMW0_SHTMI01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  WWWPARAMS_CONTROL_COMMAND  INPUT
*&---------------------------------------------------------------------*
module WWWPARAMS_CONTROL_COMMAND input.
  if not ( WWWPARAMS_CHECK is initial ).
    PARAMS_SELECTED = 1.               " mind. ein Objekt selektiert
    read table WWWPARAMS_TAB
                                index WWWPARAMS_CONTROL-CURRENT_LINE.
    if SY-SUBRC eq 0 and SY-UCOMM ne SPACE.
      call function 'ENQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWPARAMS_TAB-RELID
          OBJID        = WWWPARAMS_TAB-OBJID
          SRTF2        = 0
        exceptions
          FOREIGN_LOCK = 1.
      if SY-SUBRC eq 1.
        message I007 with WWWPARAMS_TAB-OBJID.
        clear SY-UCOMM.
        exit.
      endif.
      case SY-UCOMM.
        when 'PCRE'.
          perform CREATE_NEW_PARAMETER.
        when 'PMOD'.
          call function 'ZSMW0_PARAMS_MODIFY_SCREEN'
            exporting
              PARAMS = WWWPARAMS_TAB.
        when 'PDEL'.
          call function 'POPUP_TO_CONFIRM_WITH_VALUE'
            exporting
*             DEFAULTOPTION = 'Y'
              OBJECTVALUE = WWWPARAMS_TAB-NAME(25)
              TEXT_AFTER  = TEXT-014
              TEXT_BEFORE = TEXT-009
              TITEL       = TEXT-016
*             START_COLUMN  = 25
*             START_ROW   = 6
            importing
              ANSWER      = G_ANSWER.
          if G_ANSWER eq 'J'.
            call function 'ZSMW0_PARAMS_DELETE'
              exporting
                RELID = WWWPARAMS_TAB-RELID
                OBJID = WWWPARAMS_TAB-OBJID
                NAME  = WWWPARAMS_TAB-NAME.
          endif.
      endcase.
      call function 'DEQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWPARAMS_TAB-RELID
          OBJID        = WWWPARAMS_TAB-OBJID
          SRTF2        = 0.
    endif.
  endif.

endmodule.                 " WWWPARAMS_CONTROL_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  WWWPARAMS_USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE WWWPARAMS_USER_COMMAND_0200 INPUT.
  PERFORM WWWPARAMS_USER_COMMAND_0200.
ENDMODULE.                 " WWWPARAMS_USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0210 input.
  case SY-UCOMM.
    when 'PSVE'.
      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
          TEXTLINE1 = TEXT-009
          TEXTLINE2 = TEXT-010
          TITEL     = TEXT-011
        importing
          ANSWER    = G_ANSWER.
      if G_ANSWER ne 'J'.
        exit.
      endif.
      clear OBJDATA.
      move-corresponding WWWPARAMS_NEW to OBJDATA.
      perform TR_OBJECT_CHECK_INSERT
                  using OBJDATA SY-SUBRC.
      if SY-SUBRC eq 0.                                 "BINK136505 - RK
        call function 'ZSMW0_PARAMS_MODIFY_SINGLE'
          exporting
            PARAMS = WWWPARAMS_NEW.
      endif.                                            "BINK136505 - RK
      ONE_SCREEN_BACK.
    when 'ENDE'.
      ONE_SCREEN_BACK.
  endcase.
endmodule.                             " USER_COMMAND_0210  INPUT
