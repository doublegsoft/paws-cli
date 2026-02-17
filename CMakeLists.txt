##
## ██████╗░░█████╗░░██╗░░░░░░░██╗░██████╗░░░░░░░█████╗░██╗░░░░░██╗
## ██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝░░░░░░██╔══██╗██║░░░░░██║
## ██████╔╝███████║░╚██╗████╗██╔╝╚█████╗░█████╗██║░░╚═╝██║░░░░░██║
## ██╔═══╝░██╔══██║░░████╔═████║░░╚═══██╗╚════╝██║░░██╗██║░░░░░██║
## ██║░░░░░██║░░██║░░╚██╔╝░╚██╔╝░██████╔╝░░░░░░╚█████╔╝███████╗██║
## ╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═════╝░░░░░░░░╚════╝░╚══════╝╚═╝
##
cmake_minimum_required(VERSION 3.13)

project(libpal C CXX)

set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_CXX_STANDARD 17)

if (WIN32)
elseif (APPLE)
  set(PLATFORM                          "darwin")
elseif (UNIX)
  set(PLATFORM                          "linux")
endif()
set(BUILD                             "build/${PLATFORM}")

################################################################################
##                                                                            ##
##                                 libpal                                     ##
##                                                                            ##
################################################################################
set(LIBPAL_DIR                        "../libpal")
set(LIBPAL_INCLUDE_DIR                "${LIBPAL_DIR}/src")
set(LIBPAL_LIBRARY_DIR                "${LIBPAL_DIR}/${BUILD}")
set(LIBPAL_LIBRARIES                  pal)

################################################################################
##                                                                            ##
##                                 libclix                                    ##
##                                                                            ##
################################################################################
set(LIBCLIX_DIR                       "../libclix")
set(LIBCLIX_INCLUDE_DIR               "${LIBCLIX_DIR}/src")
set(LIBCLIX_LIBRARY_DIR               "${LIBCLIX_DIR}/${BUILD}")
set(LIBCLIX_LIBRARIES                 clix)

################################################################################
##                                                                            ##
##                                    antlr4                                  ##
##                                                                            ##
################################################################################
set(ANTLR4_DIR                        "${LIBPAL_DIR}/3rd/antlr4-4.9.3/runtime/Cpp")
set(ANTLR4_INCLUDE_DIR                "${ANTLR4_DIR}/runtime/src")
set(ANTLR4_LIBRARY_DIR                "${ANTLR4_DIR}/dist")
set(ANTLR4_LIBRARIES                  antlr4-runtime)

################################################################################
##                                                                            ##
##                                   gfc                                      ##
##                                                                            ##
################################################################################
set(GFC_DIR                           "${LIBCLIX_DIR}/3rd/gfc")
set(GFC_INCLUDE_DIR                   "${GFC_DIR}/include")
set(GFC_LIBRARY_DIR                   "${GFC_DIR}/${BUILD}")
set(GFC_LIBRARIES                     gfc)


include_directories(
  "src"
  ${ANTLR4_INCLUDE_DIR}
  ${GFC_INCLUDE_DIR}
  ${LIBCLIX_INCLUDE_DIR}
  ${LIBPAL_INCLUDE_DIR}
)

link_directories(
  ${LIBCLIX_LIBRARY_DIR}
  ${LIBPAL_LIBRARY_DIR}
  ${GFC_LIBRARY_DIR}
)

set(PAWS_SOURCES
  src/mac/main.mm
)


################################################################################
#
# paws (FORCE OBJECTIVE-C++)
#
################################################################################
add_executable(paws
  ${PAWS_SOURCES}
)

target_link_libraries(paws
  ${LIBCLIX_LIBRARIES}
  ${LIBPAL_LIBRARIES}
  ${GFC_LIBRARIES}
  "-framework foundation"
  "-framework carbon"
  "-framework cocoa"
  "-framework accelerate"
  "-framework opencl"
)

set_target_properties(paws PROPERTIES
  BUILD_WITH_INSTALL_RPATH TRUE
)
