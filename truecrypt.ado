*! version 1.1.0 Matthew White 14mar2012
pr truecrypt
	vers 9
	if c(os) != "Windows" {
		di as err "Stata for Windows required"
		ex 198
	}
	syntax [anything(name=volume)], [Mount DISmount DRive(str) PROGdir(str)]
	
	***Check syntax***
	* Check strings.
	loc volume `volume'
	loc temp : subinstr loc volume `"""' "", count(loc dq)
	if `dq' {
		di as err `"filename cannot contain ""'
		ex 198
	}
	foreach option in drive progdir {
		loc temp : subinstr loc `option' `"""' "", count(loc dq)
		if `dq' {
			di as err `"option `option'() cannot contain ""'
			ex 198
		}
	}
	
	* -mount-, -dismount-
	if "`mount'`dismount'" == "" loc mount mount
	else if "`mount'" != "" & "`dismount'" != "" {
		di as err "options mount and dismount are mutually exclusive"
		ex 198
	}
	
	* -mount- options
	if "`mount'" != "" {
		* `volume'
		conf f "`volume'"
	}
	* -dismount- options
	else {
		* `volume'
		if "`volume'" != "" {
			di as err "option dismount: filename not allowed"
			ex 198
		}
		
		* -drive-
		if "`drive'" == "" {
			di as err "option dismount must be specified with option drive"
			ex 198
		}
	}
	
	* -drive-
	if "`drive'" != "" {
		if !regexm("`drive'", "^[A-Za-z]:?$") {
			di as err "option drive(): invalid drive"
			ex 198
		}
		else loc drive = regexr("`drive'", ":$", "")
	}
	
	* -progdir-
	if "`progdir'" == "" loc progdir C:\Program Files\TrueCrypt
	conf f "`progdir'\TrueCrypt.exe"
	
	* Check that the drive is available if -mount- or is mounted if -dismount-.
	mata: st_local("mounted", strofreal(direxists("`drive':")))
	if "`mount'" != "" & `mounted' {
		di as err "mount: drive letter `drive' not available"
		ex 198
	}
	else if "`dismount'" != "" & !`mounted' {
		di as err "dismount: no volume specified by drive letter `drive'"
		ex 198
	}
	***End***
	
	* -mount-
	if "`mount'" != "" ///
		sh "`progdir'\TrueCrypt.exe" /v "`volume'" `=cond("`drive'" != "", "/l `drive'", "")' /q
	* -dismount-
	else ///
		sh "`progdir'\TrueCrypt.exe" /d `drive' /q
end

* Changes history
* version 1.0.0  21feb2012
* version 1.1.0  14mar2012
*	-progdir()- is optional
*	Syntax checks added
