mkdir build32 & pushd build32
cmake -G "Visual Studio 15 2017" ..
popd
cmake --build build32 --config Debug
