if(WIN32)
    include(${CMAKE_CURRENT_LIST_DIR}/platform_specific/windows.cmake)
elseif(APPLE)
    include(${CMAKE_CURRENT_LIST_DIR}/platform_specific/macos.cmake)
else()
    include(${CMAKE_CURRENT_LIST_DIR}/platform_specific/linux.cmake)
endif()
