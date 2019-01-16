FUNCTION Y_LOG_COMMIT.
*"----------------------------------------------------------------------
*"*"Interfaccia locale:
*"  IMPORTING
*"     VALUE(IS_LOG) TYPE  YLOG_LOG
*"----------------------------------------------------------------------

    INSERT ylog_log FROM is_log.


ENDFUNCTION.
