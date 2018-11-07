#-=============================
# General project configuration
#-=============================

# Indicate which versions of CMake we support
# & default behaviors we want
cmake_minimum_required(VERSION 3.11)

# Policies provide warnings to developers and
# ensure backwards compatibility. Indicate versions
# that we know work to cmake_policy()
cmake_policy(VERSION 3.11...3.12)

# Set values needed to initialize cache variables before
# they are created with enable_language() or project()
set(CMAKE_USER_MAKE_RULES_OVERRIDE_Fortran
  ${CMAKE_CURRENT_LIST_DIR}/cmake/Fortran-overrides.cmake)

# Organize things in visual studio
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set the type/configuration of build to perform, if not set by the user
set ( CMAKE_CONFIGURATION_TYPES "Debug" "Release" "MinSizeRel" "RelWithDebInfo" "CodeCoverage" )
set ( CMAKE_BUILD_TYPE "Release"
  CACHE STRING "Select which configuration to build." )
set_property ( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_CONFIGURATION_TYPES} )

# Tell CMake that it can find modules to include in the cmake/modules directory
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/modules")

# Check that our build tree isn't the same as our source tree
include(CheckOutOfSource)
check_out_of_source()

# Declare the project name, version and languages
project(day_2
  VERSION 1.0
  DESCRIPTION "Day two examples from 'Writing Fortran 2018 Today'"
  HOMEPAGE_URL "https://github.com/SI-F18-today-Nov-2018/Boilerplate"
  LANGUAGES Fortran) # Can add or use C, CXX, CUDA, ASM too

# Informational messages
message( STATUS
  "
=========================================================
   Building ${PROJECT_NAME} examples: ${CMAKE_BUILD_TYPE}
=========================================================
")
message( STATUS "Running with CMake from: ${CMAKE_COMMAND}" )
message( STATUS "Current source dir for Project: ${CMAKE_PROJECT_SOURCE_DIR}")

# You can enable languages before OR after project() declaration.
include(CheckLanguage) # Intrinsic CMake module
check_language(C)
if(CMAKE_C_COMPILER)
  enable_language(C)
else()
  message( WARNING "No C Compiler available, skipping C bindings")
endif()

#-===============================================================
# Setup the build tree match installation with standard locations
#-===============================================================

# Follow the generic GNU installation hierarchy
# This is a standard CMake module
include(GNUInstallDirs)

# Setup a relative directory structure in the build tree that will match the install tree
# This makes packages relocatable, assuming you use relative paths and mind your RPATH
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_INSTALL_BINDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_INSTALL_LIBDIR})
set(CMAKE_Fortran_MODULE_DIRECTORY
  ${CMAKE_INSTALL_INCLUDEDIR}/Fortran/${CMAKE_Fortran_COMPILER_ID}-${CMAKE_Fortran_COMPILER_VERSION}/mod)
file(MAKE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY})
file(MAKE_DIRECTORY ${CMAKE_INSTALL_DATADIR}/inputs)

# Since we are mirroring the install tree in the build tree don't
# re-write RPATHs during installation, build with the final rpath.
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)

#-===========================================
# Define the main build targets and artifacts
#-===========================================

# First add a library, some caveats and best practices for Fortran Modules
add_library( utilities
  src/Day-1/code-jams/02-assertion-interface.f90
  src/Day-1/code-jams/03-assertion-implementation.f90)
# Alias library for flexibility in external project scenarios
add_library(${PROJECT_NAME}::utilities ALIAS utilities)

# Set target properties to allow for transitive dependency propagation
target_include_directories(utilities
  PUBLIC
  $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/${CMAKE_Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>)

# Not needed if $FC=caf or if using find_package(opencoarrays)
target_compile_options( utilities
  PUBLIC "-fcoarray=lib")

# Define an executable
add_executable( test-collective-load-check
  src/05-collective-load-check.f90)
target_compile_options( test-collective-load-check
  PRIVATE "-fcoarray=lib")

# Link the library against the executable
# Properties will be transitively inherited
target_link_libraries( test-collective-load-check
  PUBLIC  ${PROJECT_NAME}::utilities)

# Stage a input file in the Build tree
file(COPY ${CMAKE_CURRENT_LIST_DIR}/src/grid.nml
  DESTINATION ${CMAKE_INSTALL_DATADIR}/inputs)

# Add an executable only for testing
add_executable(assertion-works
  src/test_assertion.f90)
target_link_libraries(assertion-works
  PRIVATE ${PROJECT_NAME}::utilities)

#-=========================================================
# Manage where everything is installed & project consumable
#-=========================================================

# Define which targets to actually install, and, possibly
# for which configurations and components
install(TARGETS utilities test-collective-load-check
  EXPORT ${PROJECT_NAME}_runtime
  ARCHIVE
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
  INCLUDES
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  RUNTIME
  DESTINATION ${CMAKE_INSTALL_BINDIR})

# For Fortran files we need to install the .mod files too
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/Fortran
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING
  PATTERN "*.mod"
  PATTERN "*.smod"
  )


# Define a package-config file, and install it so that
# Other projects can, e.g.,
#     find_package(day_2)
#     ...
#     target_link_libraries(day_2::utilities)
install(EXPORT ${PROJECT_NAME}_runtime
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}Config.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# Add portable unistall command to makefile, adapted from the CMake Wiki FAQ
configure_file ("${CMAKE_CURRENT_LIST_DIR}/cmake/uninstall.cmake.in"
  "${CMAKE_BINARY_DIR}/uninstall.cmake"
  @ONLY)
add_custom_target (uninstall
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_BINARY_DIR}/uninstall.cmake" )

#-==============================
# Define tests and testing stuff
#-==============================

# Allows us to have access to testing capabilities
enable_testing()

# Add a test based on the executable we created
add_test(NAME collective-ld-check
  COMMAND cafrun -np 2 ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/test-collective-load-check
  WORKING_DIRECTORY ${CMAKE_INSTALL_DATADIR}/inputs)

# Set additional test properties, no guarantee of
# return value in Fortran standard
set_tests_properties(collective-ld-check
  PROPERTIES
  PASS_REGULAR_EXPRESSION "Test passed."
  PROCESSORS 2)

# Add another test, to ensure that our assertion utility actually works
# i.e., will fail
add_test(NAME test-assertion-works1
  COMMAND cafrun -np 1 ./assertion-works
  WORKING_DIRECTORY ${CMAKE_INSTALL_BINDIR})
set_tests_properties(test-assertion-works1
  PROPERTIES
  FAIL_REGULAR_EXPRESSION "This should fail!"
  WILL_FAIL TRUE)
add_test(NAME test-assertion-works2
  COMMAND cafrun -np 1 ./assertion-works
  WORKING_DIRECTORY ${CMAKE_INSTALL_BINDIR})
set_tests_properties(test-assertion-works2
  PROPERTIES
  PASS_REGULAR_EXPRESSION "Test passed."
  WILL_FAIL TRUE)
add_test(NAME test-assertion-works3
  COMMAND cafrun -np 1 ./assertion-works
  WORKING_DIRECTORY ${CMAKE_INSTALL_BINDIR})
set_tests_properties(test-assertion-works3
  PROPERTIES
  PASS_REGULAR_EXPRESSION "This should fail!")
