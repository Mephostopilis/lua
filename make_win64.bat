mkdir build64 & pushd build64
cmake -G "Visual Studio 15 2017 Win64" ..
popd
cmake --build build64 --config Debug
rem md plugin_lua53\Plugins\x86_64
rem copy /Y build64\Release\xlua.dll plugin_lua53\Plugins\x86_64\xlua.dll
rem pause