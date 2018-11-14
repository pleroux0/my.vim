function! myproject#clear_vars()
  unlet! t:project_build_dir
  unlet! t:project_source_dir
endfunction

function! myproject#is_set()
  let l:build_set = exists("t:project_build_dir")
  let l:source_set = exists("t:project_source_dir")

  if !l:build_set
    echo "Project missing build folder"
  endif

  if !l:source_set
    echo "Project missing source folder"
  endif

  return l:build_set && l:source_set
endfunction

function! myproject#update_compile_commands()
  if !myproject#is_set()
    echo "Updating compile commands requires a project"
    return v:false
  endif

  if !myutil#filereadable("compile_commands.json", t:project_build_dir)
    echo "Build directory does not contain compile_commands.json"
    return v:false
  endif

  " TODO: Gracefully handle empry compile_commands.json (And not crash with
  " python output

  let l:cmd = ["compdb"]
  let l:cmd += ["-p", fnameescape(myutil#abs_path(t:project_build_dir))]
  let l:cmd += ["list"]
  let l:cmd += [">", "compile_commands.json"]

  return myutil#run_command_in(l:cmd, t:project_source_dir)
endfunction
