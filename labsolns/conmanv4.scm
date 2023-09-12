(define-module (labsolns conmanv4)
   #:use-module (guix packages)
   #:use-module ((guix licenses) #:prefix license:)
   #:use-module (guix download)
   #:use-module (guix git-download)
     #:use-module (guix build-system guile)
   #:use-module (gnu packages)
   #:use-module (gnu packages autotools)
   #:use-module (gnu packages guile)
   #:use-module (gnu packages guile-xyz)
   #:use-module (gnu packages pkg-config)
   #:use-module (gnu packages texinfo)
   #:use-module (gnutls))

(define-public conmanv4
             (let ((commit "3b3d164a0e6b1dd23bbbe01e8dd2b7440c12dfb7")
        (revision "1"))
  (package
    (name "conmanv4")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/conmanv4.git")
             (commit commit)))
              (file-name (git-file-name name version))
              (sha256
             (base32 "1jrbkpb79k33g0b8r2q05ajs4v5sl874psi8mfzhv1l8n1jxfdgc"))))
    (build-system guile-build-system)
    (arguments `(
		 #:phases (modify-phases %standard-phases
    			  (add-after 'unpack 'patch-prefix
				     (lambda* (#:key inputs outputs #:allow-other-keys)
				       (let ((out  (assoc-ref outputs "out"))					  
					 (substitute* '("conmanv4/env.scm")
						      (("conmanstorepath")
						       out))
					 (substitute* '("scripts/conman.sh")
						      (("guileloadpath")
						       (string-append  out "/share/guile/site/3.0:"
								       (assoc-ref inputs "guile")  "/share/guile/site/3.0:"
								       ;;  (assoc-ref inputs "gnutls")  "/share/guile/site/3.0:"
								       (getenv "GUILE_LOAD_PATH") "\"")))
					 (substitute* '("scripts/conman.sh")
						      (("guileexecutable")
						       (string-append (assoc-ref inputs "guile") "/bin/guile")))
					 (substitute* '("scripts/conman.sh")
						      (("guileloadcompiledpath")
						       (string-append  out "/lib/guile/3.0/site-ccache:"
								       (assoc-ref inputs "guile")  "/lib/guile/3.0/site-ccache:"
								       ;; (assoc-ref inputs "gnutls")  "/lib/guile/3.0/site-ccache:"
								       (getenv "GUILE_LOAD_COMPILED_PATH") "\""))))
				    #t)))		    
		       (add-after 'patch-prefix 'make-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (conman-dir (string-append out "/share/guile/site/3.0/conmanv4"))
				  (mkdir-p conman-dir)
				  (dummy (copy-recursively "./conmanv4" conman-dir))) 
			     #t)))
		       
			   (add-after 'make-dir 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (scm  "/share/guile/site/3.0")
					   (go   "/lib/guile/3.0/site-ccache")
					   (all-files '("conman.sh")))				      
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
   `(
      ("texinfo" ,texinfo)))
  (inputs `(("guile" ,guile-3.0)))
	   ; ("gnutls" ,gnutls)))
  (propagated-inputs `())
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+))))

