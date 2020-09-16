FUNCTION ZSMW0_PARAMS_MODIFY_SCREEN.
*"--------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(PARAMS) LIKE  WWWPARAMS STRUCTURE  WWWPARAMS
*"--------------------------------------------------------------------
  WWWPARAMS_NEW = PARAMS.
  CALL SCREEN 210 STARTING AT 6 4 ENDING AT 76 8.
  CLEAR SY-UCOMM.
ENDFUNCTION.
