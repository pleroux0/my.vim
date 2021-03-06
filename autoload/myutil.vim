function! myutil#cd(path)
  let l:out = getcwd()
  exec "cd " . a:path
  return l:out
endfunction

function! myutil#abs_path(path)
  return fnamemodify(a:path, ":p")
endfunction

function! myutil#to_string(value)
  if type(a:value) == type([])
    return join(a:value, " ")
  endif

  return a:value
endfunction

function! myutil#run_command(cmd)
  exec ":!" . myutil#to_string(a:cmd)

  if v:shell_error
    echo "Command exited with non-zero exit code"
    return v:false
  endif

  return v:true
endfunction

function! myutil#run_command_in(cmd, workspace)
  let l:dir = myutil#cd(a:workspace)

  let l:out = myutil#run_command(a:cmd)

  call myutil#cd(l:dir)

  return l:out
endfunction

function! myutil#filereadable(file, directory)
  let l:cwd = myutil#cd(a:directory)

  let l:out = filereadable(a:file)

  call myutil#cd(l:cwd)

  return l:out
endfunction

function! myutil#reset_make()
  let &makeprg = 'make'
endfunction

function! myutil#delete(file, directory)

  let l:cwd = myutil#cd(t:directory)

  if !filereadable(a:file)
    echo "Skipping deletetion of file that doesn't exist: " . a:file
    return v:true
  endif

  if !filewritable(a:file)
    echo "Cannot delete file without write permissions: " . a:file
    return v:false
  endif

  call delete("CMakeCache.txt")

  myutil#cd(l:cwd)

  return v:true
endfunction
