*&---------------------------------------------------------------------*
*& Include MWWW0TOP                          Modulpool        SAPMWWW0 *
*&                                                                     *
*&---------------------------------------------------------------------*
program ZSAPMWWW0 message-id W3.
tables: TADIR.                    "#EC NEEDED ? правда непонятно, зачем
constants
: GC_WEBRFC type MEMID value 'webrfc'                       "#EC NOTEXT
, GC_RELID type WWWDATA-RELID value 'MI'
, GC_PROG_SELECITON type CPROG value 'ZSMW0_RSWWWSHW'
, GC_SCR_SELECTION type DYNPRONR value '0600'
.
data:  WWWDATA_TAB like ZWWWDATATAB occurs 100 with header line,
       WWWDATA_NEW like ZWWWDATATAB.
data   SEL_FIELD type CHAR1.
data   OBJDATA like ZWWWDATATAB.
data   OBJECT_SELECTED type I.
data   OBJECT_TYPE_NAME(50).
data   SAVE_UCOMM like SY-UCOMM.
*data   LINES type I. "count lines of wwwdata_tab

controls: OBJECT_LIST type tableview using screen 200.

define ONE_SCREEN_BACK.
  SET SCREEN 0.
  LEAVE SCREEN.
end-of-definition.
