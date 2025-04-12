(define-module (labsolns myapp3)
 #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile)
  #:use-module (guix utils)
  #:use-module ((guix build utils) #:select (alist-replace))
  #:use-module (ice-9 match)
  #:use-module (guix gexp)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((srfi srfi-1) #:select (alist-delete)))

(define-public myapp3
             (let ((commit "7818a789aa88020e255b734ea56a79b24cb8daa1")
        (revision "4"))

  (package
    (name "myapp3")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/myapp3.git")
		    (commit commit)))
	      (file-name (git-file-name name version))
	      (sha256
	             (base32 "0x5ckjczalpyrka2psmmc21ir3i4czldw0qd7yr75wvaxcm5d50p"))))
    (build-system guile-build-system)

(arguments `(
		 #:phases (modify-phases %standard-phases
    			  (add-after 'unpack 'patch-prefix
				     (lambda* (#:key inputs outputs #:allow-other-keys)
				       (let ((out  (assoc-ref outputs "out")))					  
					 (substitute* '( "scripts/myapp3.sh" )
						      (("myapp3storepath")
						       out))					 
					 (substitute* '("scripts/myapp3.sh")
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
								(assoc-ref inputs "guile-dbi") "/share/guile/site/3.0:"
								(getenv "GUILE_LOAD_PATH")))
						     (setenv "GUILE_DBD_PATH"
							      (string-append
							        (assoc-ref inputs "guile-dbd-mysql")  "/lib"
							       )))
						    #t))
			  
		       (add-after 'augment-GUILE_LOAD_PATH 'make-myapp3-dir
			 (lambda* (#:key outputs #:allow-other-keys)
			   (let* ((out  (assoc-ref outputs "out"))
				  (myapp3-dir (string-append out "/share/guile/site/3.0/myapp3"))
				  (mkdir-p myapp3-dir)
				  (dummy (copy-recursively "./myapp3" myapp3-dir))) 
			     #t)))
		       ;; (add-after 'make-myapp3-dir 'make-aux-dir
		       ;; 	 (lambda* (#:key outputs #:allow-other-keys)
		       ;; 	   (let* ((out  (assoc-ref outputs "out"))
		       ;; 		  (aux-dir (string-append out "/aux"))
		       ;; 		  (mkdir-p aux-dir)
		       ;; 		  (dummy (copy-recursively "./aux" aux-dir))) 
		       ;; 	     #t)))
		       	       
		       (add-after 'make-myapp3-dir 'make-bin-dir
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
									    (assoc-ref inputs "guile-dbi") scm3))
					   (guile-load-compiled-path  (string-append  out go3 ":"
										      (assoc-ref inputs "guile-gnutls") go3 ":"
										      (assoc-ref inputs "gnutls") go3 ))
					   (guile-dbd-path (string-append  (assoc-ref inputs "guile-dbd-mysql") "/lib:"
									   (assoc-ref inputs "guile-dbi") "/lib"))
					   (all-files '("myapp3.sh")))				      
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

    
    (inputs
     `(("guile" ,guile-3.0)
       ))
    (native-inputs
     `())
  
  (propagated-inputs `(("guile-gnutls" ,guile-gnutls)
		       ("gnutls" ,gnutls)
		       ("guile-dbi" ,guile-dbi)
		       ("guile-dbd-mysql" ,guile-dbd-mysql)
		       ))


     
    (home-page "https://labsolns.com/limsn/")
    (synopsis "LIMS system for managing multi-well plates and the samples within")
    (description
     "LIMS system for managing multi-well plates and the samples within")
    (license license:lgpl3+))))


