FUNCTION ZSMW0_PARAMS_MAINTAIN.
*"--------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(KEY) LIKE  WWWDATATAB STRUCTURE  WWWDATATAB OPTIONAL
*"--------------------------------------------------------------------
  MOVE-CORRESPONDING KEY TO WWWPARAMS_SEL.
  IF WWWPARAMS_SEL-OBJID IS INITIAL.
     WWWPARAMS_SEL-OBJID = '%'.
  ENDIF.
  TRANSLATE: WWWPARAMS_SEL-OBJID USING '*%'.

  CALL SCREEN 200.
  CLEAR SY-UCOMM.
ENDFUNCTION.
