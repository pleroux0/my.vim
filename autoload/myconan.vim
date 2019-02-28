function! myconan#clear_vars()
  unlet! t:conan_profile
  unlet! t:conan_generator
endfunction

function! myconan#get_arguments()
  let l:arguments = []

  if exists("t:conan_profile") == 1
    let l:arguments += ["--profile", t:conan_profile]
  endif

  if exists("t:conan_generator")
    let l:arguments += ["--generator", t:conan_generator]
  endif

  return l:arguments
endfunction

function! myconan#is_conan_project()
  if !exists("t:project_source_dir")
    return v:false
  endif

  let l:dir = myutil#cd(t:project_source_dir)

  let l:out = filereadable("conanfile.txt") || filereadable("conanfile.py")

  call myutil#cd(l:dir)

  return l:out
endfunction

function! myconan#is_conan_workspace()
  if !exists("t:project_source_dir")
    return v:false
  endif

  let l:dir = myutil#cd(t:project_source_dir)

  let l:out = filereadable("conanws.yml")

  call myutil#cd(l:dir)

  return l:out
endfunction

function! s:conan_command(cmd)
  " Must be a conan project
  if !myconan#is_conan_project() && !myconan#is_conan_workspace()
    echo "Non-conan project cannot be built with conan build"
    return v:false
  endif

  return myutil#run_command_in(a:cmd, t:project_build_dir)
endfunction

function! myconan#install()
  " Do nothing if project not set
  if !myproject#is_set()
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["conan", "install"]
  let l:cmd += [fnameescape(myutil#abs_path(t:project_source_dir))]
  let l:cmd += ["-if " . fnameescape(myutil#abs_path(t:project_build_dir))]
  let l:cmd += myconan#get_arguments()

  return s:conan_command(l:cmd)
endfunction

function! myconan#build()
  " Do nothing if project not set
  if !myproject#is_set()
    return v:false
  endif

  call mkdir(t:project_build_dir, "p")

  let l:cmd = ["conan", "build"]
  let l:cmd += [fnameescape(myutil#abs_path(t:project_source_dir))]

  return s:conan_command(l:cmd)
endfunction
