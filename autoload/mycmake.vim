function! mycmake#clear_vars()
  " Remove CMake settings
  unlet! t:cmake_cxx_compiler
  unlet! t:cmake_c_compiler
  unlet! t:cmake_cxx_flags
  unlet! t:cmake_c_flags
  unlet! t:cmake_generator
  unlet! t:cmake_build_type
  unlet! t:cmake_install_prefix
  unlet! t:cmake_export_compile_commands
  unlet! t:cmake_user_arguments

  " Sanitizers
  unlet! t:cmake_clang_tidy
  unlet! t:cmake_cppcheck

  " Integration with other tools
  unlet! t:cmake_use_conan
  unlet! t:cmake_use_compile_commands
endfunction

function! mycmake#get_arguments()
  let l:arguments = []

  if exists("t:cmake_cxx_compiler")
    let arguments += ["-DCMAKE_CXX_COMPILER=" . t:cmake_cxx_compiler]
  endif

  if exists("t:cmake_c_compiler")
    let arguments += ["-DCMAKE_C_COMPILER=" . t:cmake_c_compiler]
  endif

  if exists("t:cmake_cxx_flags")
    let l:flags = myutil#to_string(t:cmake_cxx_flags)
    let arguments += ["-DCMAKE_CXX_FLAGS=\"" . l:flags . "\""]
    unlet l:flags
  endif

  if exists("t:cmake_c_flags")
    let l:flags = myutil#to_string(t:cmake_c_flags)
    let arguments += ["-DCMAKE_C_FLAGS=\"" . l:flags . "\""]
    unlet l:flags
  endif

  if exists("t:cmake_generator")
    let arguments += ["-G" , "\"" . t:cmake_generator . "\""]
  endif

  if exists("t:cmake_build_type")
    let arguments += ["-DCMAKE_BUILD_TYPE=" . t:cmake_build_type]
  endif

  if exists("t:cmake_install_prefix")
    let arguments += ["-DCMAKE_INSTALL_PREFIX=" . fnameescape(t:cmake_install_prefix)]
  endif

  if exists("t:cmake_export_compile_commands")
    if t:cmake_export_compile_commands
      let arguments += ["-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"]
    endif
  endif

  if exists("t:cmake_clang_tidy")
    let arguments += ["-DCMAKE_C_CLANG_TIDY=" . fnameescape(t:cmake_clang_tidy)]
    let arguments += ["-DCMAKE_CXX_CLANG_TIDY=" . fnameescape(t:cmake_clang_tidy)]
  endif

  if exists("t:cmake_cppcheck")
    let arguments += ["-DCMAKE_C_CPPCHECK=" . fnameescape(t:cmake_cppcheck)]
    let arguments += ["-DCMAKE_CXX_CPPCHECK=" . fnameescape(t:cmake_cppcheck)]
  endif

  if exists("t:cmake_user_arguments")
    if type(t:cmake_user_arguments) == type([])
      let arguments += t:cmake_user_arguments
    else
      let arguments += [t:cmake_user_arguments]
    endif
  endif

  return arguments
endfunction

function! mycmake#is_cmake_project()
  if !exists("t:project_source_dir")
    return v:false
  endif

  return myutil#filereadable("CMakeLists.txt", t:project_source_dir)
endfunction

function! mycmake#configure()
  if !myproject#is_set()
    return v:false
  endif

  " Must be CMake project
  if !mycmake#is_cmake_project()
    echo "Non-cmake project cannot be configured"
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["cmake"]
  let l:cmd += [fnameescape(myutil#abs_path(t:project_source_dir))]
  let l:cmd += mycmake#get_arguments()

  return myutil#run_command_in(l:cmd, t:project_build_dir)
endfunction

function! mycmake#set_make()
  let &makeprg = 'cmake --build ' . fnameescape(t:project_build_dir) . ' --'
endfunction

function! mycmake#clean()
  if !myproject#is_set()
    return v:false
  endif

  " Must be CMake project
  if !mycmake#is_cmake_project()
    echo "Non-cmake project cannot be configured"
    return v:false
  endif

  call myutil#delete("CMakeCache.txt", t:project_build_dir)
  call myutil#delete("CTestTestfile.cmake", t:project_build_dir)

  return v:true
endfunction
