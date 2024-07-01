(define-module (labsolns babweb)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (labsolns guile-oauth)
  #:use-module (labsolns artanis-07)
  #:use-module (json)

  )

(define-public babweb
             (let ((commit "53f09b41efc56402871877fc328ca632742324d7")
        (revision "4"))
(package
  (name "babweb")
  (version (string-append "0.1." (string-take commit 7)))
  (source (origin
           (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/mbcladwell/babweb")
                      (commit commit)))
                        (file-name (git-file-name name version))
                (sha256 
             (base32 "1qdkgwvyq3787k2cfkqk4xyqi67nicy8l8vg4q4ry779v30jjxa9"))))
  (build-system guile-build-system)
  (arguments `(
	     ;;  #:modules (((guix build guile-build-system)
		;;	   #:select (target-guile-effective-version))
		;;	  ,@%gnu-build-system-modules)
		;;	 #:imported-modules ((guix build guile-build-system)
		;;			     ,@%gnu-build-system-modules)
	     ;;  #:tests? #false ; there are none
			#:phases (modify-phases %standard-phases
    		       (add-after 'unpack 'patch-prefix
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let ((out  (assoc-ref outputs "out")))					  
				      (substitute* '("scripts/start-babweb.sh" "scripts/format.sh" "scripts/init-acct.sh" "scripts/masttoot.sh")
					(("babwebstorepath")
					 out))
				      (substitute* '("scripts/start-babweb.sh" "scripts/format.sh" "scripts/init-acct.sh" "scripts/masttoot.sh")
					(("guileloadpath")
					 (string-append  out "/share/guile/site/3.0:"
							 (assoc-ref inputs "guile")  "/share/guile/site/3.0:"
							 (assoc-ref inputs "guile-json")  "/share/guile/site/3.0:"
							 (assoc-ref inputs "guile-oauth")  "/share/guile/site/3.0:"
							 (getenv "GUILE_LOAD_PATH") "\"")))
				      (substitute* '("scripts/start-babweb.sh" "scripts/format.sh" "scripts/init-acct.sh" "scripts/masttoot.sh")
					(("guileexecutable")
					 (string-append (assoc-ref inputs "guile") "/bin/guile")))
				      
				      (substitute* '("scripts/start-babweb.sh" "scripts/format.sh" "scripts/init-acct.sh" "scripts/masttoot.sh")
					(("guileloadcompiledpath")
					 (string-append  out "/lib/guile/3.0/site-ccache:"
							 (assoc-ref inputs "guile")  "/lib/guile/3.0/site-ccache:"
							 (assoc-ref inputs "guile-json")  "/lib/guile/3.0/site-ccache:"
							 (assoc-ref inputs "guile-oauth")  "/lib/guile/3.0/site-ccache:"
							 (getenv "GUILE_LOAD_COMPILED_PATH") "\""))))
				    #t))		    
		       (add-after 'patch-prefix 'make-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (babweb-dir (string-append out "/share/guile/site/3.0/babweb"))
				  (mkdir-p babweb-dir)
				  (dummy (copy-recursively "./babweb" babweb-dir))) 
			     #t)))
		       
			   (add-after 'make-dir 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (scm  "/share/guile/site/3.0")
					   (go   "/lib/guile/3.0/site-ccache")
					   (all-files '("start-babweb.sh" "format.sh" "init-acct.sh" "masttoot.sh")))				      
				      (map (lambda (file)
					     (begin
					       (install-file (string-append "./scripts/" file) bin-dir)
					       (chmod (string-append bin-dir "/" file) #o555 ) ;;read execute, no write
					       (wrap-program (string-append bin-dir "/" file)
							     `( "PATH" ":" prefix  (,bin-dir) )							     
							     `("GUILE_LOAD_PATH" prefix
							       (,(string-append out scm)
								))
							     `("GUILE_LOAD_COMPILED_PATH" prefix
							       (,(string-append out go)))
							     )))
					     all-files))					   					   	    
				      #t))

		       )))
  (native-inputs
    `(("guile" ,guile-3.0)))
  (propagated-inputs `( ("guile-json" ,guile-json-4) ("guile-oauth" ,guile-oauth)("bash" ,bash)("artanis" ,artanis-07)))
  (synopsis "Auto tweeter for educational tweets concerning propaganda")
  (description "Auto tweeter for educational tweets concerning propaganda")
  (home-page "www.build-a-bot.biz")
  (license license:gpl3+))))



