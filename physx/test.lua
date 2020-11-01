package.path = "./lualib/?.lua;./sproto/?.lua;" .. package.path
package.cpath = "./luaclib/?.dll;" .. package.cpath
require "physx"

lphysx.Common.initialize()
