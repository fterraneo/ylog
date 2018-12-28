*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 27.09.2018 at 19:16:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: YLOG_CONFIG.....................................*
DATA:  BEGIN OF STATUS_YLOG_CONFIG                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YLOG_CONFIG                   .
CONTROLS: TCTRL_YLOG_CONFIG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *YLOG_CONFIG                   .
TABLES: YLOG_CONFIG                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
