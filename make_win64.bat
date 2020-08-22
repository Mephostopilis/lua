mkdir build64 & pushd build64
cmake -G "Visual Studio 16 2019 Win64" ..
popd
cmake --build build64 --config Debug
