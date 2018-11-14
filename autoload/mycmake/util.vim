function! mycmake#util#to_string(value)
  if type(a:value) == type([])
    return join(a:value, " ")
  endif

  return a:value
endfunction

let s:cd_stack = []

function! mycmake#util#cd_push(path)
  let s:cd_stack += [getcwd()]
  exec "cd " . a:path
endfunction

function! mycmake#util#cd_pop()
  if len(s:cd_stack) == 0
    echo "Cannot pop with empty stack!"
    return
  endif

  let l:popped_cd = remove(s:cd_stack, -1)
  exec "cd " . l:popped_cd
endfunction

function! mycmake#util#cd_pop_all()
  if len(s:cd_stack) == 0
    return
  endif

  exec "cd " . s:cd_stack[0]

  let s:cd_stack = []
endfunction

function! mycmake#util#run_command(cmd)
  if type(a:cmd) == type([])
    let l:cmd = join(a:cmd, " ")
  else
    let l:cmd = a:cmd
  endif

  exec ":!" . l:cmd

  if v:shell_error
    echo "Command exited with non-zero exit code"
    return v:false
  endif

  return v:true
endfunction

function! mycmake#util#abs_path(path)
  call mycmake#util#cd_push(a:path)

  let l:out = getcwd()

  call mycmake#util#cd_pop()

  return l:out
endfunction

function! mycmake#util#run_command_in(cmd, workspace)
  call mycmake#util#cd_push(a:workspace)

  let l:out = mycmake#util#run_command(a:cmd)

  call mycmake#util#cd_pop()

  return l:out
endfunction
