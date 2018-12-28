*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_YLOG_CONFIG
*   generation date: 27.09.2018 at 19:16:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_YLOG_CONFIG        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
