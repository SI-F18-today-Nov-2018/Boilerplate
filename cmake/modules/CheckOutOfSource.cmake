#Print an error message on an attempt to build inside the source directory tree:
macro(check_out_of_source)
  if ( "${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}" )
    message(FATAL_ERROR "ERROR! "
      "CMAKE_PROJECT_SOURCE_DIR=${CMAKE_PROJECT_SOURCE_DIR}"
      " == CMAKE_PROJECT_BINARY_DIR=${CMAKE_PROJECT_BINARY_DIR}"
      "\nThis project does not support in-source builds:\n"
      "You must now delete the CMakeCache.txt file and the CMakeFiles/ directory under "
      "the 'src' source directory or you will not be able to configure correctly!"
      "\nYou must now run something like:\n"
      "  $ rm -r CMakeCache.txt CMakeFiles/"
      "\n"
      "Please create a directory outside the project source tree and build under that outside directory "
      "in a manner such as\n"
      "  $ mkdir build-project\n"
      "  $ cd build-project\n"
      "  $ CC=gcc FC=gfortran cmake -DBUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/path/to/install/dir /path/to/opencoarrays/src/dir \n"
      "\nsubstituting the appropriate syntax for your shell (the above line assumes the bash shell)."
      )
  endif()
endmacro()
