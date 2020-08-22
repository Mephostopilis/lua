mkdir build32 & pushd build32
cmake -G "Visual Studio 16 2019" ..
popd
cmake --build build32 --config Debug
