set -x

# Set the architecture and symlinks for compilers expected by Make-arch
if [[ "${target_platform}" == "osx-64" ]];
then
    ARCH="MACOSXX86_64"
    ln -sf $CC $BUILD_PREFIX/bin/cc
    ln -sf $CXX $BUILD_PREFIX/bin/c++
elif [[ "${target_platform}" == "linux-64" ]];
then
    ARCH="LINUXAMD64"
    ln -sf $CC $BUILD_PREFIX/bin/gcc
    ln -sf $CXX $BUILD_PREFIX/bin/g++
fi

# Compiling plugins from source code
# http://www.ks.uiuc.edu/Research/vmd/plugins/doxygen/compiling.html
export TCLINC=-I$BUILD_PREFIX/include
export TCLLIB=-L$BUILD_PREFIX/lib

cd plugins
make $ARCH TCLINC="$TCLINC" TCLLIB="$TCLLIB"

export PLUGINDIR=$SRC_DIR/vmd-1.9.4a57/plugins
make distrib

# http://www.ks.uiuc.edu/Research/vmd/doxygen/compiling.html
cd $SRC_DIR/vmd-1.9.4a57/
mv LICENSE ..
# Add include paths for Tcl and Tk
export CPATH="$BUILD_PREFIX/include:$PREFIX/include:$CPATH"
export VMDINSTALLBINDIR=$PREFIX/bin
export VMDINSTALLLIBRARYDIR=$PREFIX/lib/vmd
if [[ "$target_platform" == "osx-64" ]]; then
    ./configure $ARCH FLTK FLTKOPENGL TCL LP64 # COLVARS IMD TK SILENT PTHREADS LIBTACHYON ACTC OPENCL CUDA
else
    ./configure $ARCH FLTK FLTKOPENGL TK TCL # NETCDF PTHREADS OPENGL OPENGLPBUFFER XINPUT COLVARS
fi
./configure
cd src
make
make install
