package.path = ".\\lualib\\?.lua;" .. package.path
package.cpath = ".\\luaclib\\?.dll;.\\luaclib\\?.so;" .. package.cpath

require "md5.test"
