# Intel Fortran compiler has drastically different flags on windows
# Setup some temporary variables to help abstract how flags are passed
# Detect if the MSVC compiler is the C compiler, then seed the
# ..._INIT variables before CMake queries the compilers and sets the
# corresponding cache variable which would be awkward to edit otherwise
# Testing for WIN32 etc. may not be enough thanks to Cygwin, mingw, msys etc.
# Those will just behave as if they are unix fortran compilers
if(MSVC)
  set(prefix "/")
  set(infix ":")
  set(Qf "Q")
  set(Q "Q")
  set(eq ":")
  set(colon ":")
  set(colon_ ":")
  set(libs_static "/libs:static")
  set(dgblibs "/dbglibs")

  # Add appropriate Windows fortran compiler options (Intel most likely)
else()
  set(prefix "-")
  set( infix " ")
  set( Qf "f")
  set( Q "")
  set( eq "=")
  set( colon "")
  set( colon_ " ")
  set( libs_static "")
  set( dgblibs "")

  set(CMAKE_Fortran_FLAGS_DEBUG_INIT          "-O0 -g")
  set(CMAKE_Fortran_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG -Os")
  set(CMAKE_Fortran_FLAGS_RELEASE_INIT        "-O2 -DNDEBUG")
  set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")
endif()
