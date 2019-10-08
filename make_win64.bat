mkdir build64 & pushd build64
cmake -G "Visual Studio 15 2017 Win64" ..
popd
cmake --build build64 --config Debug
