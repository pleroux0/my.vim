function! mycmake#conan#clear_vars()
  unlet! t:conan_profile
  unlet! t:conan_generator
endfunction

function! mycmake#conan#get_arguments()
  let l:arguments = []

  if exists("t:conan_profile") == 1
    let l:arguments += ["--profile", t:conan_profile]
  endif

  if exists("t:conan_generator")
    let l:arguments += ["--generator", t:conan_generator]
  endif

  return l:arguments
endfunction

function! mycmake#conan#is_conan_project()
  if !exists("t:project_source_dir")
    return v:false
  endif

  call mycmake#util#cd_push(t:project_source_dir)

  let l:out = filereadable("conanfile.txt") || filereadable("conanfile.py")

  call mycmake#util#cd_pop()

  return l:out
endfunction

function! s:conan_command(cmd)
  " Must be a conan project
  if !mycmake#conan#is_conan_project()
    echo "Non-conan project cannot be built with conan build"
    return v:false
  endif

  return mycmake#util#run_command_in(a:cmd, t:project_build_dir)
endfunction

function! mycmake#conan#install()
  " Do nothing if project not set
  if !mycmake#project#is_set()
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["conan", "install"]
  let l:cmd += [fnameescape(mycmake#util#abs_path(t:project_source_dir))]
  let l:cmd += mycmake#conan#get_arguments()

  return s:conan_command(l:cmd)
endfunction

function! mycmake#conan#build()
  " Do nothing if project not set
  if !mycmake#project#is_set()
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["conan", "build"]
  let l:cmd += [fnameescape(mycmake#util#abs_path(t:project_source_dir))]

  return s:conan_command(l:cmd)
endfunction
