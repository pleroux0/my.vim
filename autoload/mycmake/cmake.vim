function! mycmake#cmake#clear_vars()
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

function! mycmake#cmake#get_arguments()
  let l:arguments = []

  if exists("t:cmake_cxx_compiler")
    let arguments += ["-DCMAKE_CXX_COMPILER=" . t:cmake_cxx_compiler]
  endif

  if exists("t:cmake_c_compiler")
    let arguments += ["-DCMAKE_C_COMPILER=" . t:cmake_c_compiler]
  endif

  if exists("t:cmake_cxx_flags")
    let l:flags = mycmake#util#to_string(t:cmake_cxx_flags)
    let arguments += ["-DCMAKE_CXX_FLAGS=\"" . l:flags . "\""]
    unlet l:flags
  endif

  if exists("t:cmake_c_flags")
    let l:flags = mycmake#util#to_string(t:cmake_c_flags)
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

function! mycmake#cmake#is_cmake_project()
  if !exists("t:project_source_dir")
    return v:false
  endif

  call mycmake#util#cd_push(t:project_source_dir)

  let l:out = filereadable("CMakeLists.txt")

  call mycmake#util#cd_pop()

  return l:out
endfunction

function! mycmake#cmake#configure()
  if !mycmake#project#is_set()
    return v:false;
  endif

  " Must be CMake project
  if !mycmake#cmake#is_cmake_project()
    echo "Non-cmake project cannot be configured"
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["cmake"]
  let l:cmd += [fnameescape(mycmake#util#abs_path(t:project_source_dir))]
  let l:cmd += mycmake#cmake#get_arguments()

  return mycmake#util#run_command_in(l:cmd, t:project_build_dir)
endfunction

function! mycmake#cmake#update_compiler_commands()
  if !mycmake#project#is_set()
    return v:false;
  endif

  " Must be CMake project
  if !mycmake#cmake#is_cmake_project()
    echo "Updating compiler commands only works with cmake projects"
    return v:false
  endif

  " Must be exporting compile commands
  if exists("t:cmake_export_compile_commands")
    if !t:cmake_export_compile_commands
      echo "Compile commands must be exported to update them"
      return v:false
    endif
  else
    echo "Compile commands must be exported to update them"
    return v:false
  endif

  " TODO: Gracefully handle empry compile_commands.json (And not crash with
  " python output

  let l:cmd = ["compdb"]
  let l:cmd += ["-p", fnameescape(mycmake#util#abs_path(t:project_build_dir))]
  let l:cmd += ["list"]
  let l:cmd += [">", "compile_commands.json"]

  echo l:cmd

  return mycmake#util#run_command_in(l:cmd, t:project_source_dir)
endfunction
