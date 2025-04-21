(define-module (labsolns conmanv6)
   #:use-module (guix packages)
   #:use-module ((guix licenses) #:prefix license:)
   #:use-module (guix download)
   #:use-module (guix git-download)
   #:use-module (guix utils)
   #:use-module (guix build utils)
   #:use-module (guix build-system guile)
   #:use-module (guix build-system gnu)
   #:use-module (gnu packages bash)
   #:use-module (gnu packages)
   #:use-module (gnu packages tls)
   #:use-module (gnu packages nss)
   #:use-module (gnu packages autotools)
   #:use-module (gnu packages guile)
   #:use-module (gnu packages guile-xyz)
   #:use-module (gnu packages pkg-config)
   #:use-module (gnu packages texinfo)
;;   #:use-module (labsolns limsn)
   )

(define-public conmanv6
             (let ((commit "3b91341e5f06efbf623ff89aa2203cb0f5ddb8d1")
        (revision "2"))
  (package
    (name "conmanv6")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/conmanv6.git")
             (commit commit)))
              (file-name (git-file-name name version))
              (sha256
             (base32 "0m1bs9jhjdniq5jjxqka18i6msbalbdk9ivjj42ajqb7al8jfi32"))))
    (build-system guile-build-system)
    (arguments `(
		 #:phases (modify-phases %standard-phases
    			  (add-after 'unpack 'patch-prefix
				     (lambda* (#:key inputs outputs #:allow-other-keys)
				       (let ((out  (assoc-ref outputs "out")))					  
					 (substitute* '("conmanv6/env.scm" "scripts/conman.sh" "scripts/unsubscribes.sh" "scripts/init-conman.sh")
						      (("conmanstorepath")
						       out))					 
					 (substitute* '("scripts/conman.sh" "scripts/unsubscribes.sh")
						      (("guileexecutable")
						       (string-append (assoc-ref inputs "guile") "/bin/guile")))
					 #t)))
       					 
		       		       (add-after 'patch-prefix 'augment-GUILE_LOAD_PATH
						  (lambda* (#:key inputs #:allow-other-keys)
						    (begin
						      (setenv "GUILE_LOAD_PATH"
							      (string-append
							       ".:"
							        (assoc-ref inputs "guile-gnutls")  "/share/guile/site/3.0:"
							        (assoc-ref inputs "gnutls")  "/share/guile/site/3.0:"
							        (assoc-ref inputs "guile-json")  "/share/guile/site/3.0:"
								(assoc-ref inputs "guile-dbi") "/share/guile/site/3.0:"
								(getenv "GUILE_LOAD_PATH")))
						     (setenv "GUILE_DBD_PATH"
							      (string-append
							        (assoc-ref inputs "guile-dbd-mysql")  "/lib"
							       )))
						    #t))
			  
		       (add-after 'augment-GUILE_LOAD_PATH 'make-conman-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (conman-dir (string-append out "/share/guile/site/3.0/conmanv6"))
				  (mkdir-p conman-dir)
				  (dummy (copy-recursively "./conmanv6" conman-dir))) 
			     #t)))
		       (add-after 'make-conman-dir 'make-aux-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (aux-dir (string-append out "/aux"))
				  (mkdir-p aux-dir)
				  (dummy (copy-recursively "./aux" aux-dir))) 
			     #t)))
		       
			   (add-after 'make-aux-dir 'make-bin-dir
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (scm3  "/share/guile/site/3.0")
					   (scm2  "/share/guile/site/2.2")
					   (go3   "/lib/guile/3.0/site-ccache")
					   (go2   "/lib/guile/2.2/site-ccache")
					   (guile-load-path (string-append  out scm3 ":"
									    (assoc-ref inputs "guile-gnutls") scm3 ":"
									    (assoc-ref inputs "gnutls") scm3 ":"
									    (assoc-ref inputs "guile-json") scm3 ":"
									    (assoc-ref inputs "guile-dbi") scm3))
					   (guile-load-compiled-path  (string-append  out go3 ":"
										      (assoc-ref inputs "guile-gnutls") go3 ":"
										      (assoc-ref inputs "gnutls") go3 ))
					   (guile-dbd-path (string-append  (assoc-ref inputs "guile-dbd-mysql") "/lib:"
									   (assoc-ref inputs "guile-dbi") "/lib"))
					   (all-files '("conman.sh" "unsubscribes.sh" "init-conman.sh")))				      
				      (map (lambda (file)
					     (begin
					       (install-file (string-append "./scripts/" file) bin-dir)
					       (chmod (string-append bin-dir "/" file) #o555 ) ;;read execute, no write
					       (wrap-program (string-append bin-dir "/" file)
							     `( "PATH" ":" prefix  (,bin-dir) )							     
							     `("GUILE_LOAD_PATH" ":" prefix (,guile-load-path ))
							     `("GUILE_LOAD_COMPILED_PATH" ":" prefix (,guile-load-compiled-path))
							     `("GUILE_DBD_PATH" ":" prefix (,guile-dbd-path))
							     )))
					     all-files))					   					   	    
				    #t))			   			

		       )))
  (native-inputs
   `(
     ("texinfo" ,texinfo)
     ))
  (inputs `(("bash" ,bash-minimal)
	    ("guile" ,guile-3.0)
	    ))
  (propagated-inputs `( 
		       ("guile-gnutls" ,guile-gnutls)
		       ("gnutls" ,gnutls)
		       ("guile-dbi" ,guile-dbi)
		       ("guile-dbd-mysql" ,guile-dbd-mysql)
		       ("guile-json" ,guile-json-4)
;;		       ("limsn" ,limsn)
		       ))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+))))


