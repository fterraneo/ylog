# YLog Log Manager

The purpose is to manage the log level and the persistence of log messages on the project

## Usage

Calling the method **log** will write the related log message entry into table YLOG_LOG, but only if the passed log level is equal or greater than the global log level.
The global log level can be set into the table YLOG_CONFIG

Basic Usage

```
YCL_LOG=>log(level, tag, method, msg)
```
## Parameters

* **level**: level of the log message
* **tag**: class or container/program in which the log is written
* **method**: method in which the log is written
* **world**: Optional; package or module
* **obj**: Optional; an object variable: if the passed level is DEBUG, the object is serialized and saved into the clustered db and the related guid is saved into the log entry

### LEVELS

* ASSERT
* ERROR
* WARNING
* INFO
* DEBUG

### Examples

Basic Example

```
YCL_LOG=>log( level = YCL_LOG=>info world = 'Y666' tag = 'CLASS_OF_DEATH' method = 'CHECK_FUEL' msg = 'Checking the fuel...').
```

Debug Example with object

```
YCL_LOG=>log( level = YCL_LOG=>debug tag = 'CLASS_OF_DEATH' method = 'UNDOCK NUKE' msg = 'Current lt_table:' object = lt_table ).
```
