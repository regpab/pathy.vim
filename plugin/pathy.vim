function! g:PathyGen(...)
	let g:pathy_exclude = get(g:, 'pathy_exclude', [])
	let g:pathy_depth = get(g:, 'pathy_depth', 2)
	let g:pathy_exclude_override = get(g:, 'pathy_exclude_override', 0)
	let g:pathy_path_override = get(g:, 'pathy_path_override', 0)

	let force_path_override = get(a:, 1, 0)
	let force_exclude_override = get(a:, 2, 0)

	if g:pathy_exclude_override == 0 && force_exclude_override == 0
		let exclude = ["output", "target", "gradle", "build"]
		let exclude = extend(g:pathy_exclude, exclude)
	else
		let exclude = g:pathy_exclude
	endif

	let dirs = []
	let current_dirs = split(system("echo */"), "")
	call map(current_dirs, 'v:val[0:-2]')

	for dir in current_dirs
		if index(exclude, dir) >= 0
			continue
		endif

		call add(dirs, dir .. "/")

		let subdirs = split(system("echo " .. dir .. "/*/", ""))
		if !empty(subdirs)
			call map(subdirs, 'split(v:val,"/")[1]')
			call filter(subdirs, 'index(exclude,v:val)<0')
			call map(subdirs, 'dir .. "/" .. v:val .. "/**/"')

			let dirs = extend(dirs, subdirs)
		endif
	endfor

	let result = join(dirs, ",")

	if g:pathy_path_override == 0 && force_path_override == 0
		execute "set path+=" .. result
	else
		execute "set path=" .. result
	endif
endfunction

call g:PathyGen()

function! g:PathyExclude(value)
	let g:pathy_exclude = get(g:, 'pathy_exclude', [])
	call add(g:pathy_exclude, a:value)
	call g:PathyReload()
endfunction

function! g:PathyExcludeCurrent()
	let saved_unnamed_register = @@

	normal! yy
	let current_dir = shellescape(@@)[1:-4]
	echom current_dir
	call g:PathyExclude(current_dir)

	let @@ = saved_unnamed_register
endfunction

function! g:PathyReload()
	call PathyGen(1, 1)
endfunction
