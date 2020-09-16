*----------------------------------------------------------------------*
***INCLUDE LZSMW0_SHTMF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  WWWPARAMS_FILL
*&---------------------------------------------------------------------*
form WWWPARAMS_FILL.

  select * from WWWPARAMS into
                        corresponding fields of table WWWPARAMS_TAB
                   where  RELID       = WWWPARAMS_SEL-RELID
                   and    OBJID         like WWWPARAMS_SEL-OBJID.

endform.                               " WWWPARAMS_FILL

*&---------------------------------------------------------------------*
*&      Form  LOOP_AT_SCREEN_210
*&---------------------------------------------------------------------*
form LOOP_AT_SCREEN_210.
  loop at screen.
    case SCREEN-NAME.
      when 'WWWPARAMS_NEW-LANGU'.
        SCREEN-INPUT = '1'.
      when 'WWWPARAMS_NEW-NAME'.
        SCREEN-INPUT = '1'.
    endcase.
    modify screen.
  endloop.
endform.                               " LOOP_AT_SCREEN_210

*&---------------------------------------------------------------------*
*&      Form  CREATE_NEW_PARAMETER
*&---------------------------------------------------------------------*
form CREATE_NEW_PARAMETER.
  clear WWWPARAMS_NEW.
  WWWPARAMS_NEW-OBJID = WWWPARAMS_TAB-OBJID.
  WWWPARAMS_NEW-RELID = WWWPARAMS_TAB-RELID.
  STATUS_CREATE = 'x'.
  call function 'ZSMW0_PARAMS_MODIFY_SCREEN'
    exporting
      PARAMS = WWWPARAMS_NEW.
  clear STATUS_CREATE.
endform.                               " CREATE_NEW_PARAMETER

*&---------------------------------------------------------------------*
*&      Form  TR_OBJECT_CHECK
*&---------------------------------------------------------------------*
form TR_OBJECT_CHECK_INSERT using   P_KEY like WWWDATATAB
                                    P_RC  like SY-SUBRC.

  data: TAB_KO200 like KO200 occurs 0 with header line,
        TAB_E071K like E071K occurs 0 with header line.
* set object
  move 'R3TR' to TAB_KO200-PGMID.
  concatenate 'W3' P_KEY-RELID into TAB_KO200-OBJECT.
  move P_KEY-OBJID to TAB_KO200-OBJ_NAME.
  move SY-LANGU    to TAB_KO200-MASTERLANG.
  append TAB_KO200.

  call function 'TR_OBJECTS_CHECK'
    tables
      WT_KO200                = TAB_KO200
      WT_E071K                = TAB_E071K
    exceptions
      CANCEL_EDIT_OTHER_ERROR = 1
      SHOW_ONLY_OTHER_ERROR   = 2
      others                  = 3.


  P_RC = SY-SUBRC.
  if P_RC gt 1.
    message id SY-MSGID
            type 'I'
            number SY-MSGNO with SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    exit.
  endif.
  if P_RC gt 0.
    exit.
  endif.

  call function 'TR_OBJECTS_INSERT'
    tables
      WT_KO200                = TAB_KO200
      WT_E071K                = TAB_E071K
    exceptions
      CANCEL_EDIT_OTHER_ERROR = 1
      SHOW_ONLY_OTHER_ERROR   = 2
      others                  = 3.
  P_RC = SY-SUBRC.
  if P_RC gt 1.
    message id SY-MSGID
            type 'I'
            number SY-MSGNO with SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  else.
    exit.
  endif.

endform.                               " TR_OBJECT_CHECK

form WWWPARAMS_USER_COMMAND_0200.
  case SY-UCOMM.
    when 'PCRE'.
      perform CREATE_NEW_PARAMETER.
    when 'ENDE'.                       "Beenden
**********************************************************************
*      LEAVE PROGRAM. " всё ради того, чтобы в редактировании не выкидывало
      ONE_SCREEN_BACK.
*--------------------------------------------------------------------*
    when 'BACK'.
      ONE_SCREEN_BACK.
    when SPACE.
      "nothing
    when others.
      if PARAMS_SELECTED ne 0.
        PARAMS_SELECTED = 0.
      else.
        message I006.
        set screen 200.
      endif.
  endcase.
endform.

*&---------------------------------------------------------------------*
*&      Form  GET_MIMETYPES
*&---------------------------------------------------------------------*
FORM get_mimetypes USING    p_d_mimetype     TYPE c
                            p_d_application  TYPE c
                            p_rc             TYPE sysubrc.
  DATA: l_objid   LIKE wwwdataid,
        mimeapps LIKE w3mimeappl OCCURS 10 WITH HEADER LINE.
  CONCATENATE c_mimeappl sy-uname INTO l_objid-objid.
  IMPORT mimeapps FROM DATABASE wwwdata(st) ID l_objid.
  READ TABLE mimeapps WITH KEY mtype = p_d_mimetype.
  IF sy-subrc EQ 0.
    MOVE mimeapps-appli TO p_d_application.
    p_rc = 0.
  ELSE.
    CLEAR p_d_application.
    p_rc = 1.
  ENDIF.

ENDFORM.                               " GET_MIMETYPES
