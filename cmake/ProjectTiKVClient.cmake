include(FetchContent)

hunter_add_package(OpenSSL)
find_package(OpenSSL REQUIRED)
hunter_add_package(Protobuf)
find_package(Protobuf CONFIG REQUIRED)
hunter_add_package(gRPC)
find_package(gRPC CONFIG REQUIRED)
hunter_add_package(PocoCpp)
find_package (Poco REQUIRED Foundation Net JSON Util)

set(ENV{PATH} ${GRPC_ROOT}/bin:$ENV{PATH})
FetchContent_Declare(tikv_client_project
  GIT_REPOSITORY https://${URL_BASE}/bxq2011hust/client-c.git
  GIT_TAG        2a3fca44cefe6d67ff19ded6171e66ade0d4f1c4
  # SOURCE_DIR     ${CMAKE_SOURCE_DIR}/deps/src/
  PATCH_COMMAND  export PATH=${GRPC_ROOT}/bin:\$PATH COMMAND protoc --version COMMAND bash third_party/kvproto/scripts/generate_cpp.sh
  # LOG_BUILD true
)

if(NOT tikv_client_project_POPULATED)
  FetchContent_Populate(tikv_client_project)
  list(APPEND CMAKE_MODULE_PATH ${tikv_client_project_SOURCE_DIR}/cmake/)
  set(BUILD_SHARED_LIBS OFF)
  add_subdirectory(${tikv_client_project_SOURCE_DIR} ${tikv_client_project_BINARY_DIR})
  target_include_directories(kvproto PUBLIC ${GRPC_ROOT}/include)
  target_compile_options(fiu PRIVATE -Wno-error -Wno-unused-parameter)
  target_compile_options(kvproto PRIVATE -Wno-error -Wno-unused-parameter)
  target_compile_options(kv_client PRIVATE -Wno-error -Wno-unused-parameter)
endif()

add_library(bcos::tikv_client INTERFACE IMPORTED)
set_property(TARGET bcos::tikv_client PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${tikv_client_project_SOURCE_DIR}/include ${GRPC_ROOT}/include)
set_property(TARGET bcos::tikv_client PROPERTY INTERFACE_LINK_LIBRARIES kv_client gRPC::grpc++ Poco::Foundation)
