*-------------------------------------------------------------------
***INCLUDE MWWW0I01.
*-------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0100 input.
  case SY-UCOMM.
    when 'ENDE'.                       "Beenden
      leave program.
*    when 'HPRF'.                       " Preferences
*      call function 'WWW_SETTINGS'.
*    when 'HSRS'.
*      call function 'WWW_SETTINGS_CLEAR'.
*    when 'HMIM'.
*      perform MAINTAIN_MIMETYPES.
    when 'CROK'              "search report
      or 'EXEC'
      or 'CRO1'.
      perform LAUNCH_THE_SEARCH.
  endcase.
endmodule.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  OBJECT_LIST_COMMAND  INPUT
*&---------------------------------------------------------------------*
module OBJECT_LIST_COMMAND input.
  perform OBJECT_LIST_COMMAND.
endmodule.                             " OBJECT_LIST_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0200 input.
  perform USER_COMMAND_0200.
endmodule.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0300 input.
  perform USER_COMMAND_0300.
endmodule.                             " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0400 input.
  perform USER_COMMAND_0400.
endmodule.                             " USER_COMMAND_0400  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
module USER_COMMAND_0500 input.
  perform USER_COMMAND_0500.
endmodule.                             " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_EXISTENCE  INPUT
*&---------------------------------------------------------------------*
module CHECK_EXISTENCE input.
  if SY-UCOMM = 'HIMP' or SY-UCOMM = 'HCPY'.
    perform CHECK_EXISTENCE.
  endif.
endmodule.                             " CHECK_EXISTENCE  INPUT
