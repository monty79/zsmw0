*&---------------------------------------------------------------------*
*& Report  RSWWWSHW                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Копия RSWWWSHW: сел.экран завёрнут в подэкран,
*& чтобы можно было его включить в другие экраны
*&---------------------------------------------------------------------*

report  ZSMW0_RSWWWSHW message-id W3.
type-pools: KKBLO.

tables: WWWDATA, TDEVC, TADIR.

selection-screen begin of screen 600 as subscreen.

selection-screen begin of block 1 with frame title text-005."TITLTEXT.
select-options:  SO_DEVCL for TADIR-DEVCLASS memory id DVC no intervals
                 no-extension.
select-options: SO_OBJID for WWWDATA-OBJID,
                SO_TEXT  for WWWDATA-TEXT.

selection-screen end of block 1.
parameters: R_RELID     like WWWDATA-RELID no-display,
            R_TITLE(50) no-display.

selection-screen end of screen 600.

data: BACK. "just to see whether F3 has been pressed
data: I_WWWDATA_TAB like WWWDATATAB occurs 100 with header line.

data: I_AFIELD type KKBLO_T_FIELDCAT
               with header line,       " table field description
      G_LAYOUT type KKBLO_LAYOUT.      " layout description

*at selection-screen output.
*  TITLTEXT = R_TITLE.

at selection-screen.
  if SY-UCOMM = 'EXEC'.
    perform RETURN_VALUES.
  endif.

start-of-selection.
  perform RETURN_VALUES.
  leave program.

form RETURN_VALUES.
  BACK = 'N'.
  export BACK to memory id 'webrfc'.
  export SO_OBJID SO_TEXT SO_DEVCL to memory id '%_RSWWWSHW_SEL'.
endform.
